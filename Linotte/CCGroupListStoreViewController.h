//
//  CCGroupListStoreViewController.h
//  Linotte
//
//  Created by stant on 04/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCFlatListStoreViewController.h"

@interface CCGroupListStoreViewController : CCFlatListStoreViewController

- (instancetype)initWithGroup:(NSDictionary *)groupDict;

@end
