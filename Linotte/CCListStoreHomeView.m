//
//  CCListStoreView.m
//  Linotte
//
//  Created by stant on 09/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListStoreHomeView.h"
#import "CCListStoreCollectionViewCell.h"
#import "CCListStoreGroupHeaderCell.h"
#import "CCListStoreGroupFooterCell.h"

@implementation CCListStoreHomeView

- (void)setupList:(UICollectionView *)listView {
    [listView registerClass:[CCListStoreCollectionViewCell class] forCellWithReuseIdentifier:kCCListStoreCell];
    [listView registerClass:[CCListStoreGroupHeaderCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kCCListStoreGroupHeaderCell];
    [listView registerClass:[CCListStoreGroupFooterCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kCCListStoreGroupFooterCell];
    listView.delegate = self;
    listView.dataSource = self;
}

#pragma mark - CCListStoreGroupFooterCellDelegate methods

- (void)groupCellPressed:(CCListStoreGroupFooterCell *)sender
{
    NSIndexPath *indexPath = sender.indexPath;
    [_delegate groupSelectedAtIndex:indexPath.section];
}

#pragma mark - UICollectionViewDelegate/UICollectionViewDataSource methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [_delegate listSelectedAtIndex:indexPath.row forGroupAtIndex:indexPath.section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CCListStoreCollectionViewCell *cell = [self.listView dequeueReusableCellWithReuseIdentifier:kCCListStoreCell forIndexPath:indexPath];
    
    [cell setTitle:[_delegate nameForListAtIndex:indexPath.row forGroupAtIndex:indexPath.section]];

    NSString *iconUrl = [_delegate iconUrlForListAtIndex:indexPath.row forGroupAtIndex:indexPath.section];
    [cell loadImageFromUrl:iconUrl];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_delegate numberOfListsForGroupAtIndex:section];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [_delegate numberOfGroups];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        CCListStoreGroupHeaderCell *cell = (CCListStoreGroupHeaderCell *)[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kCCListStoreGroupHeaderCell forIndexPath:indexPath];
        cell.groupTitle = [_delegate nameForGroupAtIndex:indexPath.section];
        return cell;
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        CCListStoreGroupFooterCell *cell = (CCListStoreGroupFooterCell *)[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kCCListStoreGroupFooterCell forIndexPath:indexPath];
        cell.indexPath = indexPath;
        cell.delegate = self;
        return cell;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGRect bounds = [UIScreen mainScreen].bounds;
    bounds.size.height = 70;
    return bounds.size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    CGRect bounds = [UIScreen mainScreen].bounds;
    bounds.size.height = 70;
    return bounds.size;
}

@end
