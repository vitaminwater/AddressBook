//
//  CCFlatListStoreView.m
//  Linotte
//
//  Created by stant on 05/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCFlatListStoreView.h"

#import "CCListStoreTableViewCell.h"

@implementation CCFlatListStoreView

- (void)setupList:(UITableView *)listView {
    [listView registerClass:[CCListStoreTableViewCell class] forCellReuseIdentifier:kCCListStoreCell];
    listView.delegate = self;
    listView.dataSource = self;
}

#pragma mark - UICollectionViewDelegate/UICollectionViewDataSource methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_delegate listSelectedAtIndex:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableViewCell *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCListStoreTableViewCell *cell = [self.listView dequeueReusableCellWithIdentifier:kCCListStoreCell forIndexPath:indexPath];
    
    [cell setTitle:[_delegate nameForListAtIndex:indexPath.row]
     author:[_delegate authorForListAtIndex:indexPath.row]];
    
    NSString *iconUrl = [_delegate iconUrlForListAtIndex:indexPath.row];
    //[cell setImage:[UIImage imageNamed:@"list_pin_neutral"]];
    [cell loadImageFromUrl:iconUrl];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_delegate numberOfLists];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

@end
