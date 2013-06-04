//
//  ADMBundle.m
//  ADMContentLoader
//
//  Created by Mark Sands on 4/26/13.
//  Copyright (c) 2013 Mark Sands. All rights reserved.
//

#import "ADMBundle.h"
#import "ADMRepo.h"
#import "ADMUtils.h"

@interface ADMBundle ()

/**
 NSBundle object that invocations are forwared to
 */
@property (nonatomic, strong) NSBundle *bundle;

@end

@implementation ADMBundle

+ (id)bundleWithDescriptor:(NSString *)descriptor error:(NSError * __autoreleasing *)error
{
    return [[ADMBundle alloc] initWithRepoId:ADMRepoIdFromDescriptor(descriptor) bundleId:ADMBundleIdFromDescriptor(descriptor) error:error];
}

+ (id)bundleWithRepoId:(NSString *)repositoryId bundleId:(NSString *)bundleId error:(NSError * __autoreleasing *)error
{
    return [[ADMBundle alloc] initWithRepoId:repositoryId bundleId:bundleId error:error];
}

- (id)initWithDescriptor:(NSString *)descriptor error:(NSError * __autoreleasing *)error
{
    return [self initWithRepoId:ADMRepoIdFromDescriptor(descriptor) bundleId:ADMBundleIdFromDescriptor(descriptor) error:error];
}

- (id)initWithRepoId:(NSString *)repositoryId bundleId:(NSString *)bundleId error:(NSError * __autoreleasing *)error
{
    NSString *bundlePath = ADMPathForBundleId(repositoryId, bundleId);
    _bundleId = bundleId;
    self.bundle = [NSBundle bundleWithURL:[NSURL fileURLWithPath:bundlePath]];
    
    if (self.bundle == nil)
    {
        if (error != NULL)
        {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:bundlePath
                                                                 forKey:NSFilePathErrorKey];
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadNoSuchFileError userInfo:userInfo];
        }
        
        return nil;
    }
    
    return self;
}

- (void)dealloc
{
    self.bundle = nil;
    _bundleId = nil;
}

- (BOOL)isKindOfClass:(Class)aClass
{
    return aClass == [ADMBundle class] || aClass == [NSBundle class];
}

- (NSBundle *)NSBundle
{
    return (NSBundle *)self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature* sig = [self.bundle methodSignatureForSelector:aSelector];
    return sig;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    [anInvocation setTarget:self.bundle];
    [anInvocation invoke];
}

@end
