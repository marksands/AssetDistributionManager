//
//  ADMBundleTest.m
//  ADMBundleTest
//
//  Created by Mark Sands on 4/26/13.
//  Copyright (c) 2013 Mark Sands. All rights reserved.
//

#import "ADMBundleTest.h"
#import "ADMTestBundles.h"
#import "ADMRepo.h"

#import "ADMBundle.h"

@implementation ADMBundleTest
{
    ADMRepo *repo;
    NSURL *fileURL;
}

- (void)setUp
{
    [super setUp];
    
    fileURL = [NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@""]];
}

- (void)tearDown
{
    fileURL = nil;
    
    [super tearDown];
}

- (void)clearDocumentBundles
{
    NSURL *documentsDirectoryURL = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
    
    NSDirectoryEnumerator *directoryEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:documentsDirectoryURL
                                                                      includingPropertiesForKeys:@[NSURLIsDirectoryKey]
                                                                                         options:0
                                                                                    errorHandler:^BOOL(NSURL *url, NSError *error){
                                                                                        return YES;
                                                                                    }];
    for (NSURL *url in directoryEnumerator)
    {
        NSNumber *isDirectory = nil;
        if ([url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil]) {
            if (isDirectory) {
                [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
            }
        }
    }
}

- (void)setBundleInDocumentsDirectory
{
    NSURL *bundleurl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"master" ofType:@"bundle"]];
    repo = [[ADMRepo alloc] initWithSourceURL:bundleurl repoId:@"com.adm.master"];
    [repo update];
    [repo.operationQueue waitUntilAllOperationsAreFinished];
}

- (void)resetBundles
{
    [self clearDocumentBundles];
    [self setBundleInDocumentsDirectory];
}

#pragma mark -

- (void)testADMBundleActsLikeANSBundle
{
    [self resetBundles];
    
    ADMBundle *bundle = [ADMBundle bundleWithDescriptor:@"com.adm.master.dogs" error:nil];
    STAssertTrue([bundle isKindOfClass:NSBundle.class], @"ADMBundle is not an NSBundle");
}

- (void)testADMBundleReturnsTheBundlePath
{
    [self resetBundles];

    ADMBundle *bundle = [ADMBundle bundleWithDescriptor:@"com.adm.master.dogs" error:nil];
    STAssertEqualObjects([[(NSBundle *)bundle bundlePath] lastPathComponent], @"dogs-2", @"ADMBundle's bundlePath is not correct");
}

@end
