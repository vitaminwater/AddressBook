//
//  CCBaseMetaWidget.h
//  Linotte
//
//  Created by stant on 27/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCMetaProtocol.h"

@interface CCBaseMetaWidget : UIView

@property(nonatomic, readonly)id<CCMetaProtocol> meta;
@property(nonatomic, readonly)BOOL isValid;

- (instancetype)initWithMeta:(id<CCMetaProtocol>)meta;
+ (CCBaseMetaWidget *)widgetForMeta:(id<CCMetaProtocol>)meta;

@end
