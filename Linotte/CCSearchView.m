//
//  CCSearchView.m
//  Linotte
//
//  Created by stant on 11/02/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCSearchView.h"

#import "CCFlatColorButton.h"

#import "CCSearchViewCell.h"

#import <HexColors/HexColor.h>

#define kCCSearchViewCellIdentifier @"kCCSearchViewCellIdentifier"

#define kCCSearchViewListSection 0
#define kCCSearchViewAddressSection 1

@implementation CCSearchView
{
    CCFlatColorButton *_closeButton;
    UITableView *_tableView;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self setupCloseButton];
        [self setupTableView];
        [self setupLayout];
    }
    return self;
}

- (void)setupCloseButton
{
    _closeButton = [CCFlatColorButton new];
    _closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _closeButton.backgroundColor = [UIColor colorWithHexString:@"#ffae64"];
    [_closeButton setBackgroundColor:[UIColor colorWithHexString:@"#ef9e54"] forState:UIControlStateHighlighted];
    [_closeButton setTitle:NSLocalizedString(@"CLOSE_SEARCH", @"") forState:UIControlStateNormal];
    [self addSubview:_closeButton];
}

- (void)setupTableView
{
    _tableView = [UITableView new];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [_tableView registerClass:[CCSearchViewCell class] forCellReuseIdentifier:kCCSearchViewCellIdentifier];
    _tableView.rowHeight = 75;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self addSubview:_tableView];
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_closeButton, _tableView);
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView][_closeButton]|" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
        [self addConstraints:horizontalConstraints];
    }
}

- (void)updateVisibleCells
{
    NSArray *visibleCells = [_tableView visibleCells];
    for (CCSearchViewCell *cell in visibleCells) {
        NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
        [self updateCell:cell forRowAtIndexPath:indexPath];
    }
}

- (void)reloadTableView
{
    [_tableView reloadData];
}

#pragma mark - UIButton target methods

- (void)closeButtonPressed:(id)sender
{
    [_delegate closeButtonPressed];
}

#pragma mark - UITableViewDataSource/Delegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCSearchViewCell *cell = (CCSearchViewCell *)[_tableView dequeueReusableCellWithIdentifier:kCCSearchViewCellIdentifier];

    [self updateCell:cell forRowAtIndexPath:indexPath];
    return cell;
}

- (void)updateCell:(CCSearchViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kCCSearchViewListSection) {
        [cell setIcon:[_delegate listIconAtIndex:indexPath.row]];
        [cell setName:[_delegate listNameAtIndex:indexPath.row]];
        [cell setDetail:[_delegate listDetailAtIndex:indexPath.row]];
    } else {
        [cell setIcon:[_delegate addressIconAtIndex:indexPath.row]];
        [cell setName:[_delegate addressNameAtIndex:indexPath.row]];
        [cell setDetail:[_delegate addressDetailAtIndex:indexPath.row]];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kCCSearchViewListSection) {
        return [_delegate numberOfLists];
    } else {
        return [_delegate numberOfAddresses];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([_delegate showSections] == NO)
        return nil;
    if (section == kCCSearchViewListSection) {
        return NSLocalizedString(@"LISTS", @"");
    } else {
        return NSLocalizedString(@"ADDRESSES", @"");
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kCCSearchViewListSection) {
        [_delegate listSelectedAtIndex:indexPath.row];
    } else {
        [_delegate addressSelectedAtIndex:indexPath.row];
    }
    [_tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
