//
//  CCListView.m
//  Linotte
//
//  Created by stant on 06/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListView.h"

#import "CCListViewTableViewCell.h"

#define kCCListViewTableViewCellIdentifier @"kCCListViewTableViewCellIdentifier"

@interface CCListView()
{
    UIImageView *_helpImage;
}

@property(nonatomic, strong)UITableView *tableView;

@end

@implementation CCListView

- (id)initWithHelpOn:(BOOL)helpOn
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self setupTableView];
        
        if (helpOn)
            [self setupHelpImage];
    }
    return self;
}

- (void)setupTableView
{
    _tableView = [UITableView new];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.frame = self.frame;
    _tableView.backgroundColor = [UIColor clearColor];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _tableView.rowHeight = 100;
    
    [_tableView registerClass:[CCListViewTableViewCell class] forCellReuseIdentifier:kCCListViewTableViewCellIdentifier];
    
    [self addSubview:_tableView];
}

- (void)setupHelpImage
{
    _helpImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:NSLocalizedString(@"NO_NOTE_SPLASH", @"")]];
    _helpImage.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_helpImage];
    
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:_helpImage attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    [self addConstraint:centerXConstraint];
    
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:_helpImage attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    [self addConstraint:centerYConstraint];
}

- (void)reloadAddressList
{
    [_tableView reloadData];
}

- (void)reloadVisibleAddresses
{
    NSArray *cells = _tableView.visibleCells;
    for (CCListViewTableViewCell *cell in cells) {
        NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
        [self updateCell:cell atIndex:indexPath.row];
    }
}

- (void)insertAddressAtIndex:(NSUInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if (_helpImage) {
        [_helpImage removeFromSuperview];
        _helpImage = nil;
    }
}

- (void)deleteAddressAtIndex:(NSUInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

#pragma mark - CCListViewTableViewCellDelegate methods

- (void)deleteAddress:(CCListViewTableViewCell *)sender
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:sender];
    [_delegate deleteAddressAtIndex:indexPath.row];
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCListViewTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:kCCListViewTableViewCellIdentifier];
    [self updateCell:cell atIndex:indexPath.row];
    cell.delegate = self;
    return cell;
}

- (void)updateCell:(CCListViewTableViewCell *)cell atIndex:(NSUInteger)index
{
    /*NSDate *lastNotif = [_delegate lastNotifForAddressAtIndex:index];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"dd/MM HH:mm";*/
    NSString *distanceText = [NSString stringWithFormat:@"%.02f m", [_delegate distanceForAddressAtIndex:index]/*, [dateFormatter stringFromDate:lastNotif]*/];
    cell.textLabel.text = [_delegate nameForAddressAtIndex:index];
    cell.detailTextLabel.text = distanceText;
    cell.angle = [_delegate angleForAddressAtIndex:index];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_delegate numberOfAddresses];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_delegate didSelectAddressAtIndex:indexPath.row];
}

@end
