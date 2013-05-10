//
//  LoadingViewController.m
//  ADMContentLoader
//
//  Created by Mark Sands on 4/27/13.
//  Copyright (c) 2013 Mark Sands. All rights reserved.
//

#import "LoadingViewController.h"
#import "ADMBundle.h"

@interface LoadingViewController ()
@property (nonatomic, strong) ADMRepo *repo;
@end

@implementation LoadingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"master" ofType:@"bundle"]];
    
    self.repo = [[ADMRepo alloc] initWithSourceURL:url repoId:@"com.adm.live"];
    self.repo.delegate = self;
    [self.repo update];
}

- (void)repo:(ADMRepo *)repo downloadProgress:(float)progress
{
    NSLog(@"%f%% downloaded", progress * 100);
}

- (void)repoDidFinishCloningAllBundles:(ADMRepo *)repo
{
    NSLog(@"Finished cloning bundles!");
    
    NSError *error = nil;
    NSBundle *catsBundle = [ADMBundle bundleWithDescriptor:@"com.adm.master.cats" error:&error];
    
    if (error) {
        [[[UIAlertView alloc] initWithTitle:error.localizedFailureReason
                                    message:error.localizedDescription
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return;
    }
    
    self.imageView.image = [UIImage imageWithContentsOfFile:[catsBundle pathForResource:@"cat1" ofType:@"jpg"]];
    
    self.imageView.animationImages = @[
        [UIImage imageWithContentsOfFile:[catsBundle pathForResource:@"cat1" ofType:@"jpg"]],
        [UIImage imageWithContentsOfFile:[catsBundle pathForResource:@"cat2" ofType:@"jpg"]],
        [UIImage imageWithContentsOfFile:[catsBundle pathForResource:@"cat3" ofType:@"jpg"]],
        [UIImage imageWithContentsOfFile:[catsBundle pathForResource:@"cat4" ofType:@"jpg"]]
    ];
    self.imageView.animationRepeatCount = HUGE_VAL;
    self.imageView.animationDuration = 4;
    
    [self.imageView startAnimating];
}

@end
