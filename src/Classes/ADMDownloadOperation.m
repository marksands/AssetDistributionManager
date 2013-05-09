//
//  ADMDownloadOperation.m
//  ADMContentLoader
//
//  Created by Mark Sands on 4/26/13.
//  Copyright (c) 2013 Mark Sands. All rights reserved.
//

#import "ADMDownloadOperation.h"

static NSString * const kADMNetworkingLockName = @"com.adm.networking.operation.lock";

typedef NS_ENUM(NSInteger, ADMDownloadOperationState) {
    ADMDownloadOperationPausedState,
    ADMDownloadOperationReadyState,
    ADMDownloadOperationExecutingState,
    ADMDownloadOperationFinishedState
};

static inline NSString * ADMKeyPathFromOperationState(ADMDownloadOperationState state) {
    switch (state) {
        case ADMDownloadOperationReadyState:
            return @"isReady";
        case ADMDownloadOperationExecutingState:
            return @"isExecuting";
        case ADMDownloadOperationFinishedState:
            return @"isFinished";
        case ADMDownloadOperationPausedState:
            return @"isPaused";
        default:
            return @"state";
    }
}

static inline BOOL ADMStateTransitionIsValid(ADMDownloadOperationState fromState, ADMDownloadOperationState toState, BOOL isCancelled) {
    switch (fromState) {
        case ADMDownloadOperationReadyState:
            switch (toState) {
                case ADMDownloadOperationPausedState:
                case ADMDownloadOperationExecutingState:
                    return YES;
                case ADMDownloadOperationFinishedState:
                    return isCancelled;
                default:
                    return NO;
            }
        case ADMDownloadOperationExecutingState:
            switch (toState) {
                case ADMDownloadOperationPausedState:
                case ADMDownloadOperationFinishedState:
                    return YES;
                default:
                    return NO;
            }
        case ADMDownloadOperationFinishedState:
            return NO;
        case ADMDownloadOperationPausedState:
            return toState == ADMDownloadOperationReadyState;
        default:
            return YES;
    }
}

@interface ADMDownloadOperation ()
@property (readwrite, nonatomic, assign) ADMDownloadOperationState state;
@property (readwrite, nonatomic, strong) NSURLConnection *connection;
@property (readwrite, nonatomic, strong) NSURLRequest *request;
@property (readwrite, nonatomic, strong) NSURLResponse *response;
@property (readwrite, nonatomic, strong) NSRecursiveLock *lock;
@property (readwrite, nonatomic, strong) NSString *path;
@property (readwrite, nonatomic, assign) long long totalBytesRead;
@property (readwrite, nonatomic, assign) long long totalBytesToRead;
@property (readwrite, nonatomic, assign) float progress;
@property (readwrite, nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (readwrite, nonatomic, copy) void((^downloadProgress)(float percentage));
@end

@implementation ADMDownloadOperation

+ (void) __attribute__((noreturn)) networkRequestThreadEntryPoint:(id)__unused object
{
    do {
        @autoreleasepool {
            [[NSRunLoop currentRunLoop] run];
        }
    } while (YES);
}

+ (NSThread *)networkRequestThread
{
    static NSThread *_networkRequestThread = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _networkRequestThread = [[NSThread alloc] initWithTarget:self selector:@selector(networkRequestThreadEntryPoint:) object:nil];
        [_networkRequestThread start];
    });
    
    return _networkRequestThread;
}

- (id)initWithRequest:(NSURLRequest *)urlRequest downloadPath:(NSString *)path
{
    self = [super init];
    
    self.progress = 0;
    
    self.lock = [[NSRecursiveLock alloc] init];
    self.lock.name = kADMNetworkingLockName;
    
    self.runLoopModes = [NSSet setWithObject:NSRunLoopCommonModes];
    
    self.request = urlRequest;
    
    self.path = path;
    
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.path append:NO];

    self.state = ADMDownloadOperationReadyState;
    
    return self;
}

- (void)setDownloadProgressBlock:(void (^)(float))block
{
    self.downloadProgress = block;
}

- (void)setState:(ADMDownloadOperationState)state
{
    [self.lock lock];
    
    if (ADMStateTransitionIsValid(self.state, state, [self isCancelled])) {
        NSString *oldStateKey = ADMKeyPathFromOperationState(self.state);
        NSString *newStateKey = ADMKeyPathFromOperationState(state);
        
        [self willChangeValueForKey:newStateKey];
        [self willChangeValueForKey:oldStateKey];
        _state = state;
        [self didChangeValueForKey:oldStateKey];
        [self didChangeValueForKey:newStateKey];
    }
    
    [self.lock unlock];
}

- (void)dealloc
{
    self.downloadProgress = nil;
    self.request = nil;
    self.connection = nil;
    self.response = nil;
    
    if (_outputStream) {
        [_outputStream close];
        self.outputStream = nil;
    }
    
    if (self.backgroundTaskIdentifier) {
        [[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskIdentifier];
        self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    }
}

- (void)setShouldExecuteAsBackgroundTaskWithExpirationHandler:(void (^)(void))handler
{
    [self.lock lock];
    
    if (!self.backgroundTaskIdentifier)
    {
        UIApplication *application = [UIApplication sharedApplication];
        
        __weak __typeof(&*self)weakSelf = self;
        
        self.backgroundTaskIdentifier = [application beginBackgroundTaskWithExpirationHandler:^{
            __strong __typeof(&*weakSelf)strongSelf = weakSelf;
            
            if (handler) {
                handler();
            }
            
            if (strongSelf) {
                [strongSelf cancel];
                
                [application endBackgroundTask:strongSelf.backgroundTaskIdentifier];
                strongSelf.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
            }
        }];
    }
    
    [self.lock unlock];
}

- (void)setCompletionBlock:(void (^)(void))block
{
    [self.lock lock];

    if (!block) {
        [super setCompletionBlock:nil];
    }
    else {
        __weak __typeof(&*self)weakSelf = self;
        [super setCompletionBlock:^ {
            block();
            [weakSelf setCompletionBlock:nil];
        }];
    }
    
    [self.lock unlock];
}

- (void)pause
{
    if ([self isPaused] || [self isFinished] || [self isCancelled]) {
        return;
    }
    
    [self.lock lock];
    
    if ([self isExecuting]) {
        [self.connection cancel];
        [self.connection performSelector:@selector(cancel)
                                onThread:[[self class] networkRequestThread]
                              withObject:nil
                           waitUntilDone:NO
                                   modes:[self.runLoopModes allObjects]];
    }
    
    self.state = ADMDownloadOperationPausedState;
    
    [self.lock unlock];
}

- (BOOL)isPaused
{
    return self.state == ADMDownloadOperationPausedState;
}

- (void)resume
{
    if (![self isPaused]) {
        return;
    }
    
    [self.lock lock];
    
    self.state = ADMDownloadOperationReadyState;
    
    [self start];
    
    [self.lock unlock];
}

#pragma mark - NSOperation

- (BOOL)isReady
{
    return self.state == ADMDownloadOperationReadyState && [super isReady];
}

- (BOOL)isExecuting
{
    return self.state == ADMDownloadOperationExecutingState;
}

- (BOOL)isFinished
{
    return self.state == ADMDownloadOperationFinishedState;
}

- (BOOL)isConcurrent
{
    return YES;
}

- (void)start
{
    [self.lock lock];
    
    if ([self isReady])
    {
        self.state = ADMDownloadOperationExecutingState;
        
        [self performSelector:@selector(operationDidStart)
                     onThread:[[self class] networkRequestThread]
                   withObject:nil
                waitUntilDone:NO
                        modes:[self.runLoopModes allObjects]];
    }
    
    [self.lock unlock];
}

- (void)operationDidStart
{
    [self.lock lock];
    
    if ([self isCancelled]) {
        [self finish];
    }
    else {
        self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO];
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        for (NSString *runLoopMode in self.runLoopModes) {
            [self.connection scheduleInRunLoop:runLoop forMode:runLoopMode];
            [self.outputStream scheduleInRunLoop:runLoop forMode:runLoopMode];
        }
        
        [self.connection start];
    }
    
    [self.lock unlock];
}

- (void)finish
{
    self.state = ADMDownloadOperationFinishedState;
}

- (void)cancel
{
    [self.lock lock];
    
    if (![self isFinished] && ![self isCancelled]) {
        
        [self willChangeValueForKey:@"isCancelled"];
        [super cancel];
        [self didChangeValueForKey:@"isCancelled"];
        
        // Cancel the connection on the thread it runs on to prevent race conditions
        [self performSelector:@selector(cancelConnection)
                     onThread:[[self class] networkRequestThread]
                   withObject:nil
                waitUntilDone:NO
                        modes:[self.runLoopModes allObjects]];
    }
    
    [self.lock unlock];
}

- (void)cancelConnection
{
    if (self.connection) {
        
        [self.connection cancel];
        
        // Manually send this delegate message since `[self.connection cancel]` causes the connection to never send another message to its delegate
        NSDictionary *userInfo = nil;
        
        if ([self.request URL]) {
            userInfo = [NSDictionary dictionaryWithObject:[self.request URL] forKey:NSURLErrorFailingURLErrorKey];
        }
        
        [self performSelector:@selector(connection:didFailWithError:)
                   withObject:self.connection
                   withObject:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:userInfo]];
    }
}

#pragma mark - NSURLConnection

- (void)connection:(NSURLConnection __unused *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.response = response;
    
    self.totalBytesToRead = self.response.expectedContentLength;
    
    [self.outputStream open];
}

- (void)connection:(NSURLConnection __unused *)connection didReceiveData:(NSData *)data
{
    self.totalBytesRead += [data length];
    
    if ([self.outputStream hasSpaceAvailable]) {
        const uint8_t *dataBuffer = (uint8_t *)data.bytes;
        [self.outputStream write:&dataBuffer[0] maxLength:data.length];
    }
    
    self.progress = (float)self.totalBytesRead / self.totalBytesToRead;
    
    if (self.downloadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.downloadProgress((float)self.totalBytesRead / self.totalBytesToRead);
        });
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection __unused *)connection
{
    [self.outputStream close];
    
    [self finish];
    
    self.connection = nil;
}

- (void)connection:(NSURLConnection __unused *)connection didFailWithError:(NSError *)error
{
    [self.outputStream close];
    
    [self finish];
    
    self.connection = nil;
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    if ([self isCancelled]) {
        return nil;
    }
    
    return cachedResponse;
}

@end
