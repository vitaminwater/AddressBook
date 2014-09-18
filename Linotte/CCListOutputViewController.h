//
//  CCListOutputViewController.h
//  Linotte
//
//  Created by stant on 10/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCListOutputViewDelegate.h"

#import "CCListOutputViewControllerDelegate.h"

@class CCList;

@interface CCListOutputViewController : UIViewController<CCListOutputViewDelegate>

@property(nonatomic, assign)id<CCListOutputViewControllerDelegate> delegate;

- (id)initWithList:(CCList *)list;

@end
