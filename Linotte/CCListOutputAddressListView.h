//
//  CCListOutputAddressListView.h
//  Linotte
//
//  Created by stant on 25/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCListOutputAddressListViewDelegate.h"

@interface CCListOutputAddressListView : UIView

@property(nonatomic, weak)id<CCListOutputAddressListViewDelegate> delegate;

@end
