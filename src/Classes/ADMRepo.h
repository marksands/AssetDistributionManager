//
//  ADMRepo.h
//  ADMContentLoader
//
//  Created by Mark Sands on 4/26/13.
//  Copyright (c) 2013 Mark Sands. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ADMRepo;

@protocol ADMRepoDelegate <NSObject>
@optional
- (void)repoDidFinishCloningAllBundles:(ADMRepo *)repo;
- (void)repo:(ADMRepo *)repo downloadProgress:(float)progress;
@end

/**
 Arhive tarballs using the command line `tar -cvf file.tar.gz file/`
 */
@interface ADMRepo : NSObject

///-------------------
/// @name Initializers
///-------------------

/**
 TODO: write something

 @param url <discussion>
 @param repositoryId <discussion>
 
 @return object or nil
*/
- (id)initWithSourceURL:(NSURL *)url repoId:(NSString *)repositoryId;

///-----------------------------
/// @name Updating Repo Contents
///-----------------------------

/**
 TODO: write something
 */
- (void)update;

/// -----------------------------
/// @name Accessing Repo Contents
/// -----------------------------

/**
 TODO: write something
 */
- (NSDictionary *)manifestDictionary;

/**
 TODO: write something
 */
- (NSArray *)bundleIds;

///-----------------------------
/// @name Accessing the Delegate
///-----------------------------

/**
 The receiver's delegate.
 
 @discussion A `ADMRepo` delegate responds to messages sent by download operations.
 */
@property (weak, nonatomic) id<ADMRepoDelegate> delegate;

/// -------------------------------
/// @name Accessing Repo Attributes
/// -------------------------------

/**
 The name of the repository parent directory for all encompassing bundles.
 */
@property (strong, nonatomic) NSString *repositoryId;

/**
 source URL
 */
@property (strong, nonatomic) NSURL *sourceURL;

/**
 CDN URL
 */
@property (strong, nonatomic) NSURL *cdnURL;

/**
 The operation queue which manages operations enqueued by the HTTP client.
 */
@property (readonly, nonatomic) NSOperationQueue *operationQueue;

@end
