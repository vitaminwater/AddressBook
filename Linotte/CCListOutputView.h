//
//  CCListOutputView.h
//  Linotte
//
//  Created by stant on 10/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCListOutputViewDelegate.h"

@class CCListView;

@interface CCListOutputView : UIView<UITextFieldDelegate>

@property(nonatomic, assign)id<CCListOutputViewDelegate> delegate;

- (void)setupListView:(CCListView *)listView;
- (void)setupLayout;

- (void)searchFieldResignFirstResponder;
- (void)presentSearchViewControllerView:(UIView *)searchViewControllerView;
- (void)dismissSearchViewControllerView;

- (void)loadListIconWithUrl:(NSString *)urlString;
- (void)setListIconImage:(UIImage *)image;
- (void)setListInfosText:(NSString *)listInfos;
- (void)setNotificationEnabled:(BOOL)notificationEnabled;

@end
