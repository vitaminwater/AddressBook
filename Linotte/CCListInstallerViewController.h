//
//  CCListInstallerViewController.h
//  Linotte
//
//  Created by stant on 26/10/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCListInstallerViewDelegate.h"

#import "CCListInstallerViewControllerDelegate.h"

@interface CCListInstallerViewController : UIViewController<CCListInstallerViewDelegate>

@property(nonatomic, assign)id<CCListInstallerViewControllerDelegate> delegate;

- (instancetype)initWithIdentifier:(NSString *)identifier;
- (instancetype)initWithpublicListDict:(NSDictionary *)publicListDict;

@end
