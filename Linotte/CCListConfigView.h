//
//  CCListConfigView.h
//  Linotte
//
//  Created by stant on 09/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCListConfigTableViewCellDelegate.h"
#import "CCListConfigViewDelegate.h"

@interface CCListConfigView : UIView<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CCListConfigTableViewCellDelegate>

@property(nonatomic, assign)id<CCListConfigViewDelegate> delegate;

@end
