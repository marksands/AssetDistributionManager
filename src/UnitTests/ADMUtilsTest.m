//
//  ADMUtilsTest.m
//  ADMContentLoader
//
//  Created by Mark Sands on 5/8/13.
//  Copyright (c) 2013 Mark Sands. All rights reserved.
//

#import "ADMUtilsTest.h"
#import "ADMUtils.h"

@implementation ADMUtilsTest

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (NSString *)createManifestForRepoId:(NSString *)repositoryId
{
    ADMCreateDirectoryForRepoId(repositoryId);
    NSString *repoPath = ADMPathForRepoId(repositoryId);
    NSString *filePath = [repoPath stringByAppendingPathComponent:@"index.json"];

    NSDictionary *manifest = @{ @"bundles": @{ @"dogs": @{ @"version": @1 }}};
    
    NSData *manifestData = [NSJSONSerialization dataWithJSONObject:manifest
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];

    BOOL success = [[NSFileManager defaultManager] createFileAtPath:filePath
                                                           contents:manifestData
                                                         attributes:nil];
    
    STAssertTrue(success, @"File successfully created.");

    return filePath;
}

#pragma mark -

- (void)testADMAddSkipBackupAttributesToFileSkipsBackup
{
    NSString *filePath = [self createManifestForRepoId:@"com.adm.testrepo"];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    NSString *repoPath = ADMPathForRepoId(@"com.adm.testrepo");
    
    ADMAddSkipBackupAttributeToFileWithURL(fileURL);
    
    NSNumber *isExcluded = nil;
    [fileURL getResourceValue:&isExcluded forKey:NSURLIsExcludedFromBackupKey error:nil];

    STAssertTrue([isExcluded isEqualToNumber:@YES], @"Skip backup attribute added to file.");
    [[NSFileManager defaultManager] removeItemAtPath:repoPath error:nil];
}

- (void)testADMCreateDirectoryForRepoIDCreatesDirectory
{
    ADMCreateDirectoryForRepoId(@"com.adm.testrepo");
    NSString *repoPath = ADMPathForRepoId(@"com.adm.testrepo");
    
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:repoPath], @"Repo directory for com.adm.testrepo created.");

    [[NSFileManager defaultManager] removeItemAtPath:repoPath error:nil];
}

- (void)testADMGetApplicationDocumentsDirectoryReturnsDirectory
{
    NSString *documentsPath = ADMGetApplicationDocumentsDirectory();
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:documentsPath], @"Documents directory returned.");
}

- (void)testADMDirectoryExists
{
    NSString *repoPath = ADMPathForRepoId(@"com.adm.testrepo");
    
    [[NSFileManager defaultManager] createDirectoryAtPath:repoPath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];

    STAssertTrue(ADMDirectoryExistsAtPath(repoPath), @"Directory exists at path %@.", repoPath);
    [[NSFileManager defaultManager] removeItemAtPath:repoPath error:nil];
}

- (void)testADMFileExists
{
    NSString *filePath = [self createManifestForRepoId:@"com.adm.testrepo"];
    NSString *repoPath = ADMPathForRepoId(@"com.adm.testrepo");
    
    STAssertTrue(ADMFileExistsAtPath(filePath), @"File exists at path %@.", filePath);
    [[NSFileManager defaultManager] removeItemAtPath:repoPath error:nil];
}

- (void)testADMDirectoryExistsForRepoId
{
    ADMCreateDirectoryForRepoId(@"com.adm.testrepo");

    STAssertTrue(ADMDirectoryExistsForRepoId(@"com.adm.testrepo"), @"Repo directory exists for repo com.adm.testrepo.");
    [[NSFileManager defaultManager] removeItemAtPath:ADMPathForRepoId(@"com.adm.testrepo") error:nil];
}

- (void)testADMPathForRepoId
{
    NSString *repoPath = ADMPathForRepoId(@"com.adm.testrepo");
    NSString *verboseRepoPath = [ADMGetApplicationDocumentsDirectory() stringByAppendingPathComponent:@"com.adm.testrepo"];
    
    STAssertEqualObjects(repoPath, verboseRepoPath, @"ADMPathForRepoId returns a valid path.");
}

- (void)testADMPathForBundleId
{
    [self createManifestForRepoId:@"com.adm.testrepo"];
    ADMPathForBundleId(@"com.adm.testrepo", @"dogs");
}

- (void)testADMManifsetPathForRepoId
{
    NSString *manifestPath = ADMManifestPathForRepoId(@"com.adm.testrepo");
    NSString *verboseManifsetPath = [[ADMGetApplicationDocumentsDirectory() stringByAppendingPathComponent:@"com.adm.testrepo"] stringByAppendingPathComponent:@"index.json"];
    
    STAssertEqualObjects(manifestPath, verboseManifsetPath, @"ADMManifestPathForRepoId returns a valid manifset path.");
}

- (void)testADMManifsetDictionaryRepresenation
{
    // TODO
}

- (void)testADMVersionForBundle
{
    // TODO
}

- (void)testADMDirectoryPathsForRepoId
{
    // TODO
}

- (void)testADMBundleIdFromDescriptor
{
    NSString *bundleId = ADMBundleIdFromDescriptor(@"com.adm.testrepo.cats");
    STAssertEqualObjects(bundleId, @"cats", @"ADMBundleIdFromDescriptor successfully parses bundleId.");
}

- (void)testADMRepoIdFromDescriptor
{
    NSString *repoId = ADMRepoIdFromDescriptor(@"com.adm.testrepo.cats");
    STAssertEqualObjects(repoId, @"com.adm.testrepo", @"ADMBundleIdFromDescriptor successfully parses repoId.");
}

@end
