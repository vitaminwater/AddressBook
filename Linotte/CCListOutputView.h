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

@end
