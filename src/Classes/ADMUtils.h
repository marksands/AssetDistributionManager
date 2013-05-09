//
//  ADMUtils.h
//  ADMContentLoader
//
//  Created by Mark Sands on 4/28/13.
//  Copyright (c) 2013 Mark Sands. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 TODO: write
 */
BOOL ADMAddSkipBackupAttributeToFileWithPath(NSString *path);

/**
 TODO: write
 */
BOOL ADMAddSkipBackupAttributeToFileWithURL(NSURL *url);

/**
 TODO: write
 */
BOOL ADMCreateDirectoryForRepoId(NSString *repositoryId);

/**
 TODO: write
 */
NSString *ADMGetApplicationDocumentsDirectory();

/**
 TODO: write
 */
BOOL ADMDirectoryExistsAtPath(NSString *path);

/**
 TODO: write
 */
BOOL ADMDirectoryExistsAtURL(NSURL *url);

/**
 TODO: write
 */
BOOL ADMFileExistsAtPath(NSString *path);

/**
 TODO: write
 */
BOOL ADMFileExistsAtURL(NSURL *url);

/**
 TODO: write
 */
NSString *ADMPathForRepoId(NSString *repositoryId);

/**
 TODO: write
 */
BOOL ADMDirectoryExistsForRepoId(NSString *repositoryId);

/**
 TODO: write
 */
NSString *ADMManifestPathForRepoId(NSString *repositoryId);

/**
 TODO: write
 */
NSDictionary *ADMManifestDictionaryRepresenationForRepoId(NSString *repositoryId);

/**
 TODO: write
 */
NSNumber *ADMVersionForBundleId(NSString *repositoryId, NSString *bundleId);

/**
 TODO: write
 */
NSString *ADMPathForBundleId(NSString *repositoryId, NSString *bundleId);

/**
 TODO: write
 */
NSArray *ADMDirectoryPathsForRepoId(NSString *repositoryId);

/**
 TODO: write
 */
NSString *ADMBundleIdFromDescriptor(NSString *descriptor);

/**
 TODO: write
 */
NSString *ADMRepoIdFromDescriptor(NSString *descriptor);
