//
//  ADMTestBundles.h
//  ADMContentLoader
//
//  Created by Mark Sands on 5/7/13.
//  Copyright (c) 2013 Mark Sands. All rights reserved.
//

#import <Foundation/Foundation.h>

#define testBundle [[NSBundle alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"bundle"]]
#define catsBundle [[NSBundle alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"cats" ofType:@"bundle"]]
#define dogsBundle [[NSBundle alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"dogs" ofType:@"bundle"]]
#define masterBundle [[NSBundle alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"master" ofType:@"bundle"]]
#define updatedTestBundle [[NSBundle alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"updatedtest" ofType:@"bundle"]]
