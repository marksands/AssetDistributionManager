//
//  ADMBundle.h
//  ADMLoader
//
//  Created by Mark Sands on 4/26/13.
//  Copyright (c) 2013 Mark Sands. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ADMRepo;

/**
 The ADMBundle class is a proxy class that treats content directories as NSBundles.
 
 An NSBundle object represents a location in the file system that groups code and resources that can be used in a program. Many of the methods you use to load resources from a bundle automatically locate the appropriate starting directory and look for resources in known places.
 */
@interface ADMBundle : NSProxy

/// ----------------
/// @name Properties
/// ----------------

/**
 The repository of content bundles
 */
@property (nonatomic, strong, readonly) ADMRepo *repo;

/**
 The name of the content bundle
 */
@property (nonatomic, strong, readonly) NSString *bundleId;

/// ----------------
/// @name Initializing a ADMBundle
/// ----------------

/** ------------------------------------------------------------------------------------------------
 Returns a ADMBundle object initialized to correspond to the specified bundle path.
 
 @discussion This method returns an autoreleased object, or nil if the bundle does not identify an accessible bundle directory.
 
 @param descriptor The combined ids of the repository id and bundle id in the form of `repo.bundle`.
 @param error The error object returned in case of failure.
 
 @return The NSBundle object that corresponds to bundle path, or nil if the bundle does not identify an accessible bundle directory.
 */
+ (id)bundleWithDescriptor:(NSString *)descriptor error:(NSError * __autoreleasing *)error;

/** ------------------------------------------------------------------------------------------------
 Returns a ADMBundle object initialized to correspond to the specified bundle path.
 
 @discussion This method returns an autoreleased object, or nil if the bundle does not identify an accessible bundle directory.
 
 @param repositoryId The name of the repository that points to the bundle directory's parent directory.
 @param bundleId The name of the bundle that corresponds to the latest version of the bundle directory.
 @param error The error object returned in case of failure.

 @return The NSBundle object that corresponds to bundle path, or nil if the bundle does not identify an accessible bundle directory.
 */
+ (id)bundleWithRepoId:(NSString *)repositoryId bundleId:(NSString *)bundleId error:(NSError * __autoreleasing *)error;

/** ------------------------------------------------------------------------------------------------
 Returns a ADMBundle object initialized to correspond to the specified bundle path.
 
 @discussion This method allocates and initializes the returned object, or nil if the bundle does not identify an accessible bundle directory.
 
 @param descriptor The combined ids of the repository id and bundle id in the form of `repo.bundle`.
 @param error The error object returned in case of failure.
 
 @return The NSBundle object that corresponds to bundle path, or nil if the bundle does not identify an accessible bundle directory.
 */
- (id)initWithDescriptor:(NSString *)descriptor error:(NSError * __autoreleasing *)error;

/** ------------------------------------------------------------------------------------------------
 Returns a ADMBundle object initialized to correspond to the specified bundle path.

 @discussion This method allocates and initializes the returned object, or nil if the bundle does not identify an accessible bundle directory.
 
 @param repositoryId The name of the repository that points to the bundle directory's parent directory.
 @param bundleId The name of the bundle that corresponds to the latest version of the bundle directory.
 @param error The error object returned in case of failure.

 @return The NSBundle object that corresponds to bundle path, or nil if the bundle does not identify an accessible bundle directory.
 */
- (id)initWithRepoId:(NSString *)repositoryId bundleId:(NSString *)bundleId error:(NSError * __autoreleasing *)error;

/// ----------------
/// @name Getting a NSBundle
/// ----------------

/** ------------------------------------------------------------------------------------------------
 Returns the NSBundle object that corresponds to the directory where the asset content is located.

 @return The NSBundle object that corresponds to the directory where the asset content is located, or nil if a bundle object could not be created.
*/
- (NSBundle *)NSBundle;

@end
