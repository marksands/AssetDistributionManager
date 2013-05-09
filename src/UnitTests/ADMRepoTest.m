//
//  ADMRepoTest.m
//  ADMContentLoader
//
//  Created by Mark Sands on 4/26/13.
//  Copyright (c) 2013 Mark Sands. All rights reserved.
//

#import "ADMRepoTest.h"
#import "ADMRepo.h"

#import "ADMTestBundles.h"

@implementation ADMRepoTest
{
    ADMRepo *masterRepo;
    NSURL *sourceURL;
}

- (void)setUp
{
    [super setUp];
    
    sourceURL = [testBundle bundleURL];
}

- (void)tearDown
{
    sourceURL = nil;
    
    [super tearDown];
}

#pragma mark - 

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
    masterRepo = [[ADMRepo alloc] initWithSourceURL:bundleurl repoId:@"com.adm.master"];
    [masterRepo update];
    [masterRepo.operationQueue waitUntilAllOperationsAreFinished];
}

- (void)resetBundles
{
    [self clearDocumentBundles];
    [self setBundleInDocumentsDirectory];
}

#pragma mark -

- (void)testADMRepoSetsRepositoryId
{
    ADMRepo *repo = [[ADMRepo alloc] initWithSourceURL:sourceURL repoId:@"com.adm.test"];
    STAssertEqualObjects(repo.repositoryId, @"com.adm.test", @"ADMRepo's repositoryId is com.adm.test.");
}

- (void)testADMRepoSetsSourceURL
{
    ADMRepo *repo = [[ADMRepo alloc] initWithSourceURL:sourceURL repoId:@"com.adm.test"];
    STAssertEqualObjects(repo.sourceURL, [testBundle bundleURL], @"ADMRepo's sourceURL is the testBundle's bundleURL.");
}

- (void)testADMRepoSetsDefaultCDNURL
{
    ADMRepo *repo = [[ADMRepo alloc] initWithSourceURL:sourceURL repoId:@"com.adm.test"];
    STAssertEqualObjects(repo.cdnURL, repo.sourceURL, @"ADMRepo's default cdnURL is the sourceURL.");
}

- (void)testADMRepoSetsCDNURL
{
    ADMRepo *repo = [[ADMRepo alloc] initWithSourceURL:sourceURL repoId:@"com.adm.test"];
    repo.cdnURL = [NSURL URLWithString:@"file:///localhost/"];
    STAssertFalse([repo.cdnURL isEqual:repo.sourceURL], @"ADMRepo can set a cdnURL separate from the source URL.");
}

- (void)testADMRepoParsesManifest
{
    [self resetBundles];
    
    NSDictionary *manifestDictionary = @{ @"bundles": @{ @"cats": @{ @"version": @1 },
                                                         @"dogs": @{ @"version": @2 }}};
    STAssertTrue([masterRepo.manifestDictionary isEqualToDictionary:manifestDictionary], @"ADMRepo parses manifest json file.");
}

- (void)testADMRepoReturnsRepoBundleIds
{
    [self resetBundles];

    NSArray *bundleIds = @[@"dogs", @"cats"];
    STAssertTrue([masterRepo.bundleIds isEqualToArray:bundleIds], @"ADMRepo parses bundles from manifest json file.");
}

@end

