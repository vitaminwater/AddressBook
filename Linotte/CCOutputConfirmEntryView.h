//
//  CCOutputConfirmEntryView.h
//  Linotte
//
//  Created by stant on 11/08/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCOutputConfirmEntryViewDelegate.h"

@interface CCOutputConfirmEntryView : UIView

@property(nonatomic, weak)id<CCOutputConfirmEntryViewDelegate> delegate;
@property(nonatomic, assign)BOOL notificationEnabled;

@end
