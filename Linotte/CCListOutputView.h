//
//  CCListOutputView.h
//  Linotte
//
//  Created by stant on 10/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCListOutputViewDelegate.h"

@interface CCListOutputView : UIView

@property(nonatomic, assign)id<CCListOutputViewDelegate> delegate;
@property(nonatomic, assign)BOOL addViewExpanded;

- (void)setupAddView:(UIView *)addView;
- (void)setupListView:(UIView *)listView;
- (void)setupLayout;

- (void)setListIconImage:(UIImage *)image;
- (void)setListInfosText:(NSString *)listInfos;
- (void)setNotificationEnabled:(BOOL)notificationEnabled;

@end
