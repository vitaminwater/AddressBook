//
//  CCMetaContainerView.h
//  Linotte
//
//  Created by stant on 27/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCMetaProtocol.h"

@interface CCMetaContainerView : UIView

- (void)beginMetaAddBatch;
- (void)addMeta:(id<CCMetaProtocol>)meta;
- (void)addMetas:(NSArray *)metas;
- (void)endMetaAddBatch;

- (void)updateMeta:(id<CCMetaProtocol>)meta;
- (void)updateMetas:(NSArray *)metas;

@end
