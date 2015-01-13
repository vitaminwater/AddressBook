//
//  CCFlatListStoreView.h
//  Linotte
//
//  Created by stant on 05/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCBaseListStoreView.h"

#import "CCFlatListStoreViewDelegate.h"

@interface CCFlatListStoreView : CCBaseListStoreView<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property(nonatomic, weak)id<CCFlatListStoreViewDelegate> delegate;

@end
