//
//  CCSearchViewController.h
//  Linotte
//
//  Created by stant on 11/02/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

#import "CCSearchViewDelegate.h"
#import "CCSearchViewControllerDelegate.h"

@class CCList;

@interface CCSearchViewController : UIViewController<CCSearchViewDelegate, CLLocationManagerDelegate>

@property(nonatomic, weak)id<CCSearchViewControllerDelegate> delegate;

- (instancetype)initWithList:(CCList *)list;

- (void)updateSearchString:(NSString *)searchString;

@end
