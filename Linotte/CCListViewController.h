//
//  CCListViewController.h
//  Linotte
//
//  Created by stant on 06/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

#import "CCListViewControllerDelegate.h"

#import "CCListViewDelegate.h"

#import "CCListViewContentProviderDelegate.h"
#import "CCListOutputViewControllerDelegate.h"
#import "CCOutputViewControllerDelegate.h"

@class CCAddress;
@class CCListViewContentProvider;
@class CCAnimationDelegator;

@interface CCListViewController : UIViewController<CCListViewDelegate, CCListViewContentProviderDelegate, CCListOutputViewControllerDelegate, CCOutputViewControllerDelegate, CLLocationManagerDelegate>

@property(nonatomic, weak)id<CCListViewControllerDelegate> delegate;
@property(nonatomic, strong)CCListViewContentProvider *provider;
@property(nonatomic, assign)BOOL deletableItems;
@property(nonatomic, strong)CCAnimationDelegator *animatorDelegator;

- (instancetype)initWithProvider:(CCListViewContentProvider *)provider;

@end
