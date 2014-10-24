//
//  CCListView.m
//  Linotte
//
//  Created by stant on 06/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListView.h"

#import <HexColors/HexColor.h>

#import "CCAnimationDelegator.h"

#import "CCActionResultHUD.h"

#import "CCListViewContentProvider.h"
#import "CCListViewTableViewCell.h"
#import "CCFlatColorButton.h"

#define kCCListViewTableViewCellIdentifier @"kCCListViewTableViewCellIdentifier"

#define kCCDistanceColors @[@"#6b6b6b", @"#898989", @"#afafaf", @"#c8c8c8"]

@implementation CCListView
{
    UIView *_emptyView;
    UITableView *_tableView;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _animatorDelegator = [CCAnimationDelegator new];
        
        [self setupTableView];
        [self setupLayout];
    }
    return self;
}

- (void)setupTableView
{
    _tableView = [UITableView new];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.separatorColor = [UIColor darkGrayColor];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _tableView.rowHeight = 110;
        
    [_tableView registerClass:[CCListViewTableViewCell class] forCellReuseIdentifier:kCCListViewTableViewCellIdentifier];
    
    [self addSubview:_tableView];
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_tableView);
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
        [self addConstraints:horizontalConstraints];
    }
}

- (void)setupEmptyView
{
    if (_emptyView != nil)
        return;

    _emptyView = [_delegate getEmptyView];
    _emptyView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_emptyView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_emptyView);
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_emptyView]|" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
    
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:_emptyView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    [self addConstraint:centerYConstraint];
    
    _emptyView.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        _emptyView.alpha = 1;
    }];
}

- (void)removeEmptyView
{
    if (_emptyView == nil)
        return;
    
    [UIView animateWithDuration:0.2 animations:^{
        _emptyView.alpha = 0;
    } completion:^(BOOL finished) {
        [_emptyView removeFromSuperview];
        _emptyView = nil;
    }];
}

- (void)drawRect:(CGRect)rect
{
    CGRect frame = self.bounds;
    
    CGFloat lineHeight = 0.5 * [[UIScreen mainScreen] scale];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, lineHeight);
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, frame.origin.x, frame.origin.y + lineHeight / 2);
    CGContextAddLineToPoint(context, frame.origin.x + frame.size.width, frame.origin.y + lineHeight / 2);
    CGContextStrokePath(context);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, frame.origin.x, frame.origin.y + frame.size.height - lineHeight / 2);
    CGContextAddLineToPoint(context, frame.origin.x + frame.size.width, frame.origin.y + frame.size.height - lineHeight / 2);
    CGContextStrokePath(context);
    
    [super drawRect:rect];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setNeedsDisplay];
}

- (void)reloadData
{
    [_tableView reloadData];
}

- (void)reloadVisibleCells
{
    NSArray *cells = _tableView.visibleCells;
    for (CCListViewTableViewCell *cell in cells) {
        NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
        [self updateCell:cell atIndex:indexPath.row];
    }
}

- (void)reloadCellsAtIndexes:(NSIndexSet *)indexSet
{
    NSMutableArray *indexPaths = [@[] mutableCopy];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        [indexPaths addObject:indexPath];
    }];
    
    [_tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

- (void)insertCellsAtIndexes:(NSIndexSet *)indexSet
{
    NSMutableArray *indexPaths = [@[] mutableCopy];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        [indexPaths addObject:indexPath];
    }];
    [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)deleteCellsAtIndexes:(NSIndexSet *)indexSet
{
    NSMutableArray *indexPaths = [@[] mutableCopy];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        [indexPaths addObject:indexPath];
    }];
    [_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)unselect
{
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - CCListViewTableViewCellDelegate methods

- (void)deleteAddress:(CCListViewTableViewCell *)sender
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:sender];
    [_delegate deleteListItemAtIndex:indexPath.row];
}

- (void)setNotificationEnabled:(BOOL)enabled forCell:(id)sender
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:sender];
    [_delegate setNotificationEnabled:enabled atIndex:indexPath.row];
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
    cell.textLabel.text = [[_delegate nameForListItemAtIndex:index] uppercaseString];
    cell.detailTextLabel.text = [_delegate infoForListItemAtIndex:index];
    [cell setNotificationEnabled:[_delegate notificationEnabledForListItemAtIndex:index]];
    if ([_delegate orientationAvailableAtIndex:index]) {
        [cell setAngle:[_delegate angleForListItemAtIndex:index]];
        cell.directionHidden = NO;
    } else {
        cell.directionHidden = YES;
    }
    [cell setDeletable:[_delegate deletableForListItemAtIndex:index]];
    cell.markerImageView.image = [_delegate iconForListItemAtIndex:index];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_delegate numberOfListItems];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_delegate didSelectListItemAtIndex:indexPath.row];
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.decelerating == YES && scrollView.contentOffset.y < 0)
        return;
    if ([_animatorDelegator fingerMoved:-scrollView.contentOffset.y])
        scrollView.contentOffset = CGPointZero;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate == NO)
        [_animatorDelegator fingerLifted];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [_animatorDelegator fingerLifted];
}

#pragma mark - setter methods

- (void)setDelegate:(id<CCListViewDelegate>)delegate
{
    _delegate = delegate;
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
