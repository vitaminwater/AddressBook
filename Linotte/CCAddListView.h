//
//  CCAddListView.h
//  Linotte
//
//  Created by stant on 17/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCAddListViewDelegate.h"

@interface CCAddListView : UIView<UITextFieldDelegate>

@property(nonatomic, assign)id<CCAddListViewDelegate> delegate;

@end
