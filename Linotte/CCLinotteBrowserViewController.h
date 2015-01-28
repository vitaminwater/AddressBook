//
//  CCLinotteBrowserViewController.h
//  Linotte
//
//  Created by stant on 06/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCLinotteBrowserViewDelegate.h"
#import "CCLinotteBrowserViewControllerDelegate.h"

@interface CCLinotteBrowserViewController : UIViewController<CCLinotteBrowserViewDelegate>

@property(nonatomic, weak)id<CCLinotteBrowserViewControllerDelegate> delegate;

- (instancetype)initWithRootUrl:(NSString *)rootUrl;

@end
