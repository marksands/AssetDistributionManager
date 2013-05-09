//
//  ADMUtils.m
//  ADMContentLoader
//
//  Created by Mark Sands on 4/28/13.
//  Copyright (c) 2013 Mark Sands. All rights reserved.
//

#import "ADMUtils.h"

BOOL ADMAddSkipBackupAttributeToFileWithPath(NSString *path)
{
    return ADMAddSkipBackupAttributeToFileWithURL([NSURL fileURLWithPath:path]);
}

BOOL ADMAddSkipBackupAttributeToFileWithURL(NSURL *url)
{
    NSError *error = nil;
    BOOL success = [url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
        
    return success;
}

NSString *ADMGetApplicationDocumentsDirectory()
{
    static NSString *dir = nil;
    
    if (dir == nil) {
        dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        if (dir.length == 0) {
            [NSException raise:@"Documents directory not found"
                        format:@"NSSearchPathForDirectoriesInDomains returned an empty directory"];
        }
    }
    
    return dir;
}

BOOL ADMCreateDirectoryForRepoId(NSString *repositoryId)
{
    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:ADMPathForRepoId(repositoryId)
                                             withIntermediateDirectories:YES
                                                              attributes:nil
                                                                   error:&error];
    if (!success) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Error creating directory for repoId %@: %@", repositoryId, error.localizedDescription];
    }
    
    return success;
}

BOOL ADMDirectoryExistsAtPath(NSString *path)
{
    BOOL isDir;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
    
    return (isDir && exists);
}

BOOL ADMFileExistsAtPath(NSString *path)
{
    BOOL isDir;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
    
    return (!isDir && exists);
}

BOOL ADMDirectoryExistsAtURL(NSURL *url)
{
    return ADMDirectoryExistsAtPath(url.path);
}

BOOL ADMFileExistsAtURL(NSURL *url)
{
    return ADMFileExistsAtPath(url.path);
}

NSString *ADMPathForRepoId(NSString *repositoryId)
{
    return [ADMGetApplicationDocumentsDirectory() stringByAppendingPathComponent:repositoryId];
}

BOOL ADMDirectoryExistsForRepoId(NSString *repositoryId)
{
    return ADMDirectoryExistsAtPath(ADMPathForRepoId(repositoryId));
}

NSString *ADMManifestPathForRepoId(NSString *repositoryId)
{
    return [ADMPathForRepoId(repositoryId) stringByAppendingPathComponent:@"index.json"];
}

NSNumber *ADMVersionForBundleId(NSString *repositoryId, NSString *bundleId)
{
    NSDictionary *json = ADMManifestDictionaryRepresenationForRepoId(repositoryId);
    NSNumber *version = [[json[@"bundles"] objectForKey:bundleId] objectForKey:@"version"];
    return version;
}

NSString *ADMPathForBundleId(NSString *repositoryId, NSString *bundleId)
{
    NSNumber *version = ADMVersionForBundleId(repositoryId, bundleId);
    return [ADMPathForRepoId(repositoryId) stringByAppendingPathComponent:[bundleId stringByAppendingFormat:@"-%d", version.intValue]];
}

NSDictionary *ADMManifestDictionaryRepresenationForRepoId(NSString *repositoryId)
{
    NSString *manifestFile = ADMManifestPathForRepoId(repositoryId);
    NSData *jsonData = [NSData dataWithContentsOfFile:manifestFile];

    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    
    if (!json && error) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Error parsing JSON data from repoId %@: %@", repositoryId, error.localizedDescription];
    }
    
    return json;
}

NSArray *ADMDirectoryPathsForRepoId(NSString *repositoryId)
{
    NSArray *repoContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:ADMPathForRepoId(repositoryId) error:nil];

    NSMutableArray *directories = [NSMutableArray array];

    for (NSString *file in repoContents) {
        NSString *filePath = [ADMPathForRepoId(repositoryId) stringByAppendingPathComponent:file];
        if (ADMDirectoryExistsAtPath(filePath)) {
            [directories addObject:filePath];
        }
    }
    
    return [NSArray arrayWithArray:directories];
}

NSString *ADMBundleIdFromDescriptor(NSString *descriptor)
{
    NSArray *components = [descriptor componentsSeparatedByString:@"."];
    NSString *bundleId = [components lastObject];
    return bundleId;
}

NSString *ADMRepoIdFromDescriptor(NSString *descriptor)
{
    NSMutableArray *components = [[descriptor componentsSeparatedByString:@"."] mutableCopy];
    [components removeLastObject];
    NSString *repositoryId = [components componentsJoinedByString:@"."];
    return repositoryId;
}
