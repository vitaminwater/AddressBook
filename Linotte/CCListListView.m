//
//  CCListListView.m
//  Linotte
//
//  Created by stant on 14/03/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCListListView.h"

#import "CCListListViewCell.h"

#define kCCListListViewCellReuseIdentifier @"kCCListListViewCellReuseIdentifier"

@implementation CCListListView
{
    UITableView *_listView;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupListView];
        [self setupLayout];
    }
    return self;
}

- (void)setupListView
{
    _listView = [UITableView new];
    _listView.translatesAutoresizingMaskIntoConstraints = NO;
    [_listView registerClass:[CCListListViewCell class] forCellReuseIdentifier:kCCListListViewCellReuseIdentifier];
    _listView.rowHeight = 80;
    _listView.delegate = self;
    _listView.dataSource = self;
    [self addSubview:_listView];
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_listView);
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_listView]|" options:0 metrics:nil views:views];
    [self addConstraints:horizontalConstraints];
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_listView]|" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
}

- (void)reloadListView
{
    [_listView reloadData];
}

#pragma mark - UITableViewDelegate/DataSource methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_delegate numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_delegate numberOfListsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCListListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCCListListViewCellReuseIdentifier];
    [cell setIcon:[_delegate listIconAtIndex:indexPath.row inSection:indexPath.section]];
    [cell setName:[_delegate listNameAtIndex:indexPath.row inSection:indexPath.section]];
    [cell setDetail:[_delegate authorNameAtIndex:indexPath.row inSection:indexPath.section]];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [_delegate titleForSection:section];
}

@end
