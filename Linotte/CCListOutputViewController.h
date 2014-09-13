//
//  CCListOutputViewController.h
//  Linotte
//
//  Created by stant on 10/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCListOutputViewDelegate.h"

@class CCList;

@interface CCListOutputViewController : UIViewController<CCListOutputViewDelegate>

- (id)initWithList:(CCList *)list;

@end
