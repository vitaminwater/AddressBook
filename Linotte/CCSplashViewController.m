//
//  CCSplashViewController.m
//  Linotte
//
//  Created by stant on 10/08/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCSplashViewController.h"

#import <Mixpanel/Mixpanel.h>

#import "CCSplashView.h"

@interface CCSplashViewController ()

@end

@implementation CCSplashViewController

- (void)loadView
{
    CCSplashView *view = [CCSplashView new];
    view.delegate = self;
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_delegate splashFinish];
    });
}

#pragma mark - CCSplashViewDelegate methods

- (void)splashFinish
{
    [_delegate splashFinish];
    [[Mixpanel sharedInstance] track:@"Splash skipped"];
}

@end
