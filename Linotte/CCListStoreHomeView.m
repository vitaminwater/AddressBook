//
//  CCListStoreView.m
//  Linotte
//
//  Created by stant on 09/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListStoreHomeView.h"
#import "CCListStoreTableViewCell.h"
#import "CCListStoreGroupHeaderCell.h"
#import "CCListStoreGroupFooterCell.h"

@implementation CCListStoreHomeView

- (void)setupList:(UITableView *)listView {
    [listView registerClass:[CCListStoreTableViewCell class] forCellReuseIdentifier:kCCListStoreCell];
    [listView registerClass:[CCListStoreGroupHeaderCell class] forHeaderFooterViewReuseIdentifier:kCCListStoreGroupHeaderCell];
    [listView registerClass:[CCListStoreGroupFooterCell class] forHeaderFooterViewReuseIdentifier:kCCListStoreGroupFooterCell];
    listView.delegate = self;
    listView.dataSource = self;
}

#pragma mark - CCListStoreGroupFooterCellDelegate methods

- (void)groupCellPressed:(CCListStoreGroupFooterCell *)sender
{
    [_delegate groupSelectedAtIndex:sender.section];
}

#pragma mark - UICollectionViewDelegate/UICollectionViewDataSource methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_delegate listSelectedAtIndex:indexPath.row forGroupAtIndex:indexPath.section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCListStoreTableViewCell *cell = [self.listView dequeueReusableCellWithIdentifier:kCCListStoreCell forIndexPath:indexPath];
    
    [cell setTitle:[_delegate nameForListAtIndex:indexPath.row forGroupAtIndex:indexPath.section]
        author:[_delegate authorForListAtIndex:indexPath.row forGroupAtIndex:indexPath.section]];

    NSString *iconUrl = [_delegate iconUrlForListAtIndex:indexPath.row forGroupAtIndex:indexPath.section];
    [cell loadImageFromUrl:iconUrl];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_delegate numberOfListsForGroupAtIndex:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_delegate numberOfGroups];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CCListStoreGroupHeaderCell *cell = (CCListStoreGroupHeaderCell *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:kCCListStoreGroupHeaderCell];
    cell.groupTitle = [_delegate nameForGroupAtIndex:section];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    CCListStoreGroupFooterCell *cell = (CCListStoreGroupFooterCell *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:kCCListStoreGroupFooterCell];
    cell.section = section;
    cell.delegate = self;
    return cell;
}

@end
