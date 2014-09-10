//
//  CCListConfigViewController.h
//  Linotte
//
//  Created by stant on 09/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCListConfigViewDelegate.h"
#import "CCListConfigViewControllerDelegate.h"

@interface CCListConfigViewController : UIViewController<CCListConfigViewDelegate>

@property(nonatomic, assign)id<CCListConfigViewControllerDelegate> delegate;

@end
