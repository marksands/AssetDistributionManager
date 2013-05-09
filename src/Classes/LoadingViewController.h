//
//  LoadingViewController.h
//  ADMContentLoader
//
//  Created by Mark Sands on 4/27/13.
//  Copyright (c) 2013 Mark Sands. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ADMRepo.h"

@interface LoadingViewController : UIViewController <ADMRepoDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end
