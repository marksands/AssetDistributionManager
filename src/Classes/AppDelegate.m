//
//  AppDelegate.m
//  ADMContentLoader
//
//  Created by Mark Sands on 4/26/13.
//  Copyright (c) 2013 Mark Sands. All rights reserved.
//

#import "AppDelegate.h"

#import "ADMRepo.h"

#import "LoadingViewController.h"

@interface AppDelegate () <ADMRepoDelegate>
@property (strong, nonatomic) ADMRepo *repo;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.repo = [[ADMRepo alloc] initWithSourceURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"master" ofType:@"bundle"]]
                                                   repoId:@"com.adm.master"];
    self.repo.delegate = self;
    [self.repo update];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[LoadingViewController alloc] initWithNibName:@"LoadingViewController" bundle:nil];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)repo:(ADMRepo *)repo downloadProgress:(float)progress
{
    NSLog(@"AD rogress %f%%", progress * 100);
}

- (void)repoDidFinishCloningAllBundles:(ADMRepo *)repo
{
    NSLog(@"AD Loading complete.");
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
