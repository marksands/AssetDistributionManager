//
//  ADMUntar.h
//  ADMContentLoader
//
//  Created by Mark Sands on 4/28/13.
//  Copyright (c) 2013 Mark Sands. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADMUntar : NSObject

+ (BOOL)untarFileAtPath:(NSString *)path error:(NSError * __autoreleasing *)error;

@end
