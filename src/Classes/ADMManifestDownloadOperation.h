//
//  ADMManifestDownloadOperation.h
//  ADMContentLoader
//
//  Created by Mark Sands on 4/27/13.
//  Copyright (c) 2013 Mark Sands. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADMDownloadOperation.h"

@interface ADMManifestDownloadOperation : ADMDownloadOperation

- (id)initWithRequest:(NSURLRequest *)urlRequest repoId:(NSString *)repositoryId;

@end
