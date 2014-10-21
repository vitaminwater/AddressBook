//
//  CCListOutputExpandedSettingsView.m
//  Linotte
//
//  Created by stant on 28/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListListExpandedSettingsView.h"

#import "CCListListExpandedTableViewCell.h"

#define kCCListListExpandedTableViewCell @"kCCListListExpandedTableViewCell"

@implementation CCListListExpandedSettingsView
{
    UILabel *_helpLabel;
    
    UITableView *_list; // TODO tableview names hamonisation
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self setupHelpLabel];
        [self setupList];
        [self setupLayout];
    }
    return self;
}

- (void)setupHelpLabel
{
    _helpLabel = [UILabel new];
    _helpLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _helpLabel.font = [UIFont fontWithName:@"Futura-Book" size:21];
    _helpLabel.backgroundColor = [UIColor clearColor];
    _helpLabel.textColor = [UIColor whiteColor];
    _helpLabel.textAlignment = NSTextAlignmentJustified;
    _helpLabel.text = NSLocalizedString(@"LIST_HELP", @"");
    _helpLabel.numberOfLines = 0;
    [self addSubview:_helpLabel];
}

- (void)setupList
{
    _list = [UITableView new];
    _list.translatesAutoresizingMaskIntoConstraints = NO;
    _list.backgroundColor = [UIColor clearColor];
    _list.separatorColor = [UIColor whiteColor];
    _list.separatorStyle = UITableViewCellSeparatorStyleNone;
    _list.rowHeight = 35;
    _list.delegate = self;
    _list.dataSource = self;
    [_list registerClass:[CCListListExpandedTableViewCell class] forCellReuseIdentifier:kCCListListExpandedTableViewCell];
    [self addSubview:_list];
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_helpLabel, _list);
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_helpLabel]-[_list(==100)]-|" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==15)-[view]-(==15)-|" options:0 metrics:nil views:@{@"view" : view}];
        [self addConstraints:horizontalConstraints];
    }
}

#pragma mark - UITableViewDelegate/UITableViewDataSource methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCListListExpandedTableViewCell *cell = (CCListListExpandedTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if (cell) {
        cell.isAdded = !cell.isAdded;
        if (cell.isAdded) {
            [_delegate listSelectedAtIndex:indexPath.row];
        } else {
            [_delegate listUnselectedAtIndex:indexPath.row];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCListListExpandedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCCListListExpandedTableViewCell];
    
    [cell setName:[_delegate listNameAtIndex:indexPath.row]];
    cell.isAdded = [_delegate isListSelectedAtIndex:indexPath.row];
    
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
