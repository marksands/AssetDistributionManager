//
//  ADMRepo.m
//  ADMContentLoader
//
//  Created by Mark Sands on 4/26/13.
//  Copyright (c) 2013 Mark Sands. All rights reserved.
//

#import "ADMRepo.h"
#import "ADMDownloadOperation.h"
#import "ADMManifestDownloadOperation.h"
#import "ADMUtils.h"
#import "ADMUntarOperation.h"

@interface ADMRepo ()
{
    NSUInteger bundleDownloadCount;
}

@property (readwrite, nonatomic) NSOperationQueue *operationQueue;

- (NSOperation *)garbageCollectOperation;
- (NSOperation *)finishOperation;

- (NSArray *)downloadOperations;
- (NSArray *)versionedBundleIds;
- (NSArray *)expiredBundleIds;

- (void)downloadProgress;
@end

@implementation ADMRepo

- (id)initWithSourceURL:(NSURL *)url repoId:(NSString *)repositoryId
{
    self = [super init];
    
    self.repositoryId = repositoryId;
    
    self.cdnURL = url;
    self.sourceURL = url;
    
    self.operationQueue = [[NSOperationQueue alloc] init];
    [self.operationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    
    return self;
}

- (NSDictionary *)manifestDictionary
{
    return ADMManifestDictionaryRepresenationForRepoId(self.repositoryId);
}

- (NSArray *)bundleIds
{
    return [self.manifestDictionary[@"bundles"] allKeys];
}

- (void)update
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[[self.sourceURL URLByAppendingPathComponent:self.repositoryId] URLByAppendingPathComponent:@"index.json"]];
    ADMManifestDownloadOperation *manifestOperation = [[ADMManifestDownloadOperation alloc] initWithRequest:request
                                                                                                     repoId:self.repositoryId];
    [self.operationQueue addOperation:manifestOperation];

    [manifestOperation waitUntilFinished];
    
    NSOperation *garbageCollectOp = [self garbageCollectOperation];
    
    bundleDownloadCount = self.expiredBundleIds.count;
    
    for (NSString *bundleId in self.expiredBundleIds)
    {
        NSString *tarPath = [[ADMPathForRepoId(self.repositoryId) stringByAppendingPathComponent:bundleId] stringByAppendingPathExtension:@"tar"];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[[[self.cdnURL URLByAppendingPathComponent:self.repositoryId isDirectory:YES] URLByAppendingPathComponent:bundleId] URLByAppendingPathExtension:@"tar.gz"]];
        
        ADMDownloadOperation *operation = [[ADMDownloadOperation alloc] initWithRequest:request downloadPath:tarPath];
        ADMUntarOperation *untarOp = [[ADMUntarOperation alloc] initWithPath:tarPath];
    
        [operation setDownloadProgressBlock:^(float percentage) {
            [self downloadProgress];
        }];
    
        [untarOp addDependency:operation];
        [garbageCollectOp addDependency:untarOp];
        
        [self.operationQueue addOperation:operation];
        [self.operationQueue addOperation:untarOp];
    }
    
    NSOperation *finishOp = [self finishOperation];
    [finishOp addDependency:garbageCollectOp];
    
    [self.operationQueue addOperation:garbageCollectOp];
    [self.operationQueue addOperation:finishOp];
}

#pragma mark - Private

- (void)downloadProgress
{
    float totalDownloadProgress = [[self.downloadOperations valueForKeyPath:@"@sum.progress"] floatValue];
    float finishedCount = bundleDownloadCount - self.downloadOperations.count;
    totalDownloadProgress += finishedCount;
    
    float totalProgress = totalDownloadProgress / bundleDownloadCount;
    
    [self.delegate repo:self downloadProgress:totalProgress];
}

#pragma mark - Operation

- (NSOperation *)garbageCollectOperation
{
    NSOperation *garbageCollectOp = [NSBlockOperation blockOperationWithBlock:^{
        
        NSArray *repoContents = ADMDirectoryPathsForRepoId(self.repositoryId);
        
        NSArray *expiredBundles = [repoContents filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
            return ![self.versionedBundleIds containsObject:[evaluatedObject lastPathComponent]];
        }]];
                
        for (NSString *bundlePath in expiredBundles)
        {
            NSError *error = nil;
            
            BOOL success = [[NSFileManager defaultManager] removeItemAtPath:bundlePath error:&error];
            
            if (!success && error) {
                [NSException raise:NSInternalInconsistencyException
                            format:@"Unable to remove bundle %@: %@", bundlePath, error.localizedDescription];
            }
        }
    }];
    
    return garbageCollectOp;
}

- (NSOperation *)finishOperation
{
    NSOperation *finishOp = [NSBlockOperation blockOperationWithBlock:^{
        ADMAddSkipBackupAttributeToFileWithPath([ADMGetApplicationDocumentsDirectory() stringByAppendingPathComponent:self.repositoryId]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate repoDidFinishCloningAllBundles:self];
        });
    }];
    
    return finishOp;
}

#pragma mark - Helper

- (NSArray *)downloadOperations
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self isKindOfClass: %@", ADMDownloadOperation.class];
    return [self.operationQueue.operations filteredArrayUsingPredicate:predicate];
}

- (NSArray *)versionedBundleIds
{
    NSMutableArray *bundleIds = [NSMutableArray array];
    
    for (NSString *bundleId in self.bundleIds) {
        NSString *bundlePath = ADMPathForBundleId(self.repositoryId, bundleId);
        [bundleIds addObject:[bundlePath lastPathComponent]];
    }
    
    return bundleIds;
}

- (NSArray *)expiredBundleIds
{
    NSMutableArray *expiredBundles = [NSMutableArray array];
    
    for (NSString *bundleId in self.bundleIds)
    {
        NSString *bundlePath = ADMPathForBundleId(self.repositoryId, bundleId);
        
        BOOL exists = ADMDirectoryExistsAtPath(bundlePath);
        if (!exists) {
            [expiredBundles addObject:[bundlePath lastPathComponent]];
        }
    }
    
    return expiredBundles;
}

@end
