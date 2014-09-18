//
//  CCListStoreViewController.h
//  Linotte
//
//  Created by stant on 09/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCListStoreViewDelegate.h"

#import "CCListStoreViewControllerDelegate.h"

@interface CCListStoreViewController : UIViewController<CCListStoreViewDelegate>

@property(nonatomic, assign)id<CCListStoreViewControllerDelegate> delegate;

@end
