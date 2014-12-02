//
//  CCBaseMetaWidget.h
//  Linotte
//
//  Created by stant on 27/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCMetaProtocol.h"

@interface CCMetaWidget : UIView

@property(nonatomic, readonly)id<CCMetaProtocol> meta;

+ (CCMetaWidget *)widgetForMeta:(id<CCMetaProtocol>)meta;

- (void)updateContent;
+ (NSString *)action;

@end
