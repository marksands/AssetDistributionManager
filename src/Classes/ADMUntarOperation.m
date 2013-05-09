//
//  ADMUntarOperation.m
//  ADMContentLoader
//
//  Created by Mark Sands on 5/2/13.
//  Copyright (c) 2013 Mark Sands. All rights reserved.
//

#import "ADMUntarOperation.h"
#import "ADMUntar.h"

@implementation ADMUntarOperation

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    self.path = path;
    return self;
}

- (void)main
{
    if (!self.isCancelled)
    {
        @try {
            NSError *error = nil;
            
            if (![ADMUntar untarFileAtPath:self.path error:&error])
            {
                if (error) {
                    [NSException raise:NSInternalInconsistencyException
                                format:@"%@", error.localizedDescription];
                }
            }
            
            if (![[NSFileManager defaultManager] removeItemAtPath:self.path error:&error])
            {
                if (error) {
                    [NSException raise:NSInternalInconsistencyException
                                format:@"%@", error.localizedDescription];
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"<%@> - Error: %@", NSStringFromClass(self.class), exception);
        }
    }
}

@end
