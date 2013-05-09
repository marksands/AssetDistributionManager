//
//  ADMManifestDownloadOperation.m
//  ADMContentLoader
//
//  Created by Mark Sands on 4/27/13.
//  Copyright (c) 2013 Mark Sands. All rights reserved.
//

#import "ADMManifestDownloadOperation.h"
#import "ADMUtils.h"

@implementation ADMManifestDownloadOperation

- (id)initWithRequest:(NSURLRequest *)urlRequest repoId:(NSString *)repositoryId
{
    if (!ADMDirectoryExistsForRepoId(repositoryId)) {
        ADMCreateDirectoryForRepoId(repositoryId);
    }

    NSString *path = ADMManifestPathForRepoId(repositoryId);
    
    return [super initWithRequest:urlRequest downloadPath:path];
}

@end
