//
//  CCFlatListStoreView.m
//  Linotte
//
//  Created by stant on 05/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCFlatListStoreView.h"

#import "CCListStoreCollectionViewCell.h"

@implementation CCFlatListStoreView

- (void)setupList:(UICollectionView *)listView {
    [listView registerClass:[CCListStoreCollectionViewCell class] forCellWithReuseIdentifier:kCCListStoreCell];
    listView.delegate = self;
    listView.dataSource = self;
}

#pragma mark - UICollectionViewDelegate/UICollectionViewDataSource methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [_delegate listSelectedAtIndex:indexPath.row];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CCListStoreCollectionViewCell *cell = [self.listView dequeueReusableCellWithReuseIdentifier:kCCListStoreCell forIndexPath:indexPath];
    
    [cell setTitle:[_delegate nameForListAtIndex:indexPath.row]];
    
    NSString *iconUrl = [_delegate iconUrlForListAtIndex:indexPath.row];
    //[cell setImage:[UIImage imageNamed:@"list_pin_neutral"]];
    [cell loadImageFromUrl:iconUrl];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_delegate numberOfLists];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

@end
