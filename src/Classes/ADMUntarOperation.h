//
//  ADMUntarOperation.h
//  ADMContentLoader
//
//  Created by Mark Sands on 5/2/13.
//  Copyright (c) 2013 Mark Sands. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADMUntarOperation : NSOperation

- (id)initWithPath:(NSString *)path;

@property (copy, nonatomic) NSString *path;

@end
