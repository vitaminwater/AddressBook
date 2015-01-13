//
//  CCFlatListStoreViewController.h
//  Linotte
//
//  Created by stant on 05/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCBaseListStoreViewController.h"

#import "CCFlatListStoreViewDelegate.h"

@interface CCFlatListStoreViewController : CCBaseListStoreViewController<CCFlatListStoreViewDelegate>

@property(nonatomic, strong)NSArray *lists;

@end
