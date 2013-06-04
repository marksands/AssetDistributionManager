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
 `ADMRepo` allows the user to synchronously or asynchronously download versioned assets over the air. It uses the repository ID to form a manifest that holds the repository's makeup and it downloads the file specified by the source URL.
 
 Versioned assets are gzipped tarballs that have a version suffix to their name that corresponds to the current version found in the manifest JSON file. The remote server is responsible for properly configuring the manifest file and delivering the latest manifest file that corresponds to the existing tarballs in the remote asset repository. The tarballs can be archived using tar's CLI `tar -cvf files-1.tar.gz files/`.

 ## Automatic Content Loading
 
 The user can create as many instances of `ADMRepo` as they prefer while specifying unique repository IDs. The user can choose whether or not to wait on the assets to download or let them operate on a background thread. 
 */
@interface ADMRepo : NSObject

///-------------------
/// @name Initializers
///-------------------

/**
 Initializes an `ADMRepo` object with the specified source URL and repository ID.
 
 This is the designated initializer.

 @param url The remote source URL to download the manifest and asset tarballs. This argument must not be `nil`.
 @param repositoryId The name of the remote repository. This argument must not be `nil`.
 
 @return The newly-initialized ADMClient or nil
*/
- (id)initWithSourceURL:(NSURL *)url repoId:(NSString *)repositoryId;

///-----------------------------
/// @name Updating Repo Contents
///-----------------------------

/**
 Attempts to update the local repository in the iOS device to match the remote server configuration.
 
 It first checks the remote server manifest and checks for discrepencies among the local repository configuration if it exists. It then downloads only the necessary remote tarballs and extracts the archive in the Documents directory for bundle access.
 */
- (void)update;

/// -----------------------------
/// @name Accessing Repo Contents
/// -----------------------------

/**
 Returns the index.json manifest file in dictionary format.
 
 @return The dictionary represetnation of the index.json manifest file
 */
- (NSDictionary *)manifestDictionary;

/**
 Returns the list of the bundle IDs from the manifest.
 
 @return An array of bundle IDs
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
 The remote source URL used to download the manifest files and tarballs if the cdnURL is not set.
 */
@property (strong, nonatomic) NSURL *sourceURL;

/**
 An optional CDN URL can be set to download the tarballs using this remote server address instead of the sourceURL. This is useful to separate the index.json manifest cache from the tarball caches when using a CDN.
 */
@property (strong, nonatomic) NSURL *cdnURL;

/**
 The operation queue which manages operations enqueued by the HTTP client.
 */
@property (readonly, nonatomic) NSOperationQueue *operationQueue;

@end
