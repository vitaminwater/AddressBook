//
//  CCListStoreView.h
//  Linotte
//
//  Created by stant on 09/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCBaseListStoreView.h"

#import "CCListStoreHomeViewDelegate.h"
#import "CCListStoreGroupFooterCellDelegate.h"

@interface CCListStoreHomeView : CCBaseListStoreView<CCListStoreGroupFooterCellDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property(nonatomic, assign)id<CCListStoreHomeViewDelegate> delegate;

@end
