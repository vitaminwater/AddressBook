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
#import "CCListConfigViewControllerDelegate.h"

@class CCAddress;
@class CCListViewContentProvider;

@interface CCListViewController : UIViewController<CCListViewDelegate, CCListConfigViewControllerDelegate, CLLocationManagerDelegate, UIAlertViewDelegate>

@property(nonatomic, weak)id<CCListViewControllerDelegate> delegate;
@property(nonatomic, strong)CCListViewContentProvider *provider;

- (id)initWithProvider:(CCListViewContentProvider *)provider;

- (void)addressAdded:(CCAddress *)address;

@end
