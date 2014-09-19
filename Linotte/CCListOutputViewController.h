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
#import "CCAddAddressViewController.h"

#import "CCListViewController.h"

@class CCList;

@interface CCListOutputViewController : UIViewController<CCListOutputViewDelegate, CCListViewControllerDelegate, CCAddAddressViewControllerDelegate>

@property(nonatomic, assign)id<CCListOutputViewControllerDelegate> delegate;

- (id)initWithList:(CCList *)list;

@end
