//
//  CCListInstallerView.h
//  Linotte
//
//  Created by stant on 26/10/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCListInstallerViewDelegate.h"

@interface CCListInstallerView : UIView

@property(nonatomic, assign)id<CCListInstallerViewDelegate> delegate;

- (void)loadListIconWithUrl:(NSString *)urlString;
- (void)setListIconImage:(UIImage *)iconImage;
- (void)setListName:(NSString *)listName;
- (void)setListInfos:(NSString *)listAuthor numberOfAddresses:(NSUInteger)numberOfAddresses numberOfInstalls:(NSUInteger)numberOfInstalls lastUpdate:(NSDate *)lastUpdate;

@end
