//
//  CCSearchListStoreView.h
//  Linotte
//
//  Created by stant on 05/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCSearchListStoreViewDelegate.h"

@class CCBaseListStoreView;

@interface CCSearchListStoreView : UIView<UITextFieldDelegate>

@property(nonatomic, weak)id<CCSearchListStoreViewDelegate> delegate;
@property(nonatomic, readonly)CCBaseListStoreView *listStoreView;

- (instancetype)initWithListStoreView:(CCBaseListStoreView *)listStoreView;

@end
