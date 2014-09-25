//
//  CCListView.m
//  Linotte
//
//  Created by stant on 06/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListView.h"

#import <HexColors/HexColor.h>

#import "CCActionResultHUD.h"

#import "CCListViewContentProvider.h"
#import "CCListViewTableViewCell.h"
#import "CCFlatColorButton.h"

#define kCCListViewTableViewCellIdentifier @"kCCListViewTableViewCellIdentifier"

#define kCCDistanceColors @[@"#6b6b6b", @"#898989", @"#afafaf", @"#c8c8c8"]

@interface CCListView()

@property(nonatomic, strong)UIView *emptyView;
@property(nonatomic, strong)UITableView *tableView;

@property(nonatomic, strong)UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation CCListView

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
        _panGestureRecognizer.delegate = self;
        [self addGestureRecognizer:_panGestureRecognizer];
        
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
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _tableView.rowHeight = 100;
        
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
    _emptyView = [_delegate getEmptyView];
    _emptyView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_emptyView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_emptyView);
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_emptyView]|" options:0 metrics:nil views:views];
    [self addConstraints:horizontalConstraints];
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_emptyView]|" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
    
    _emptyView.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        _emptyView.alpha = 1;
    }];
}

- (void)removeEmptyView
{
    [UIView animateWithDuration:0.2 animations:^{
        _emptyView.alpha = 0;
    } completion:^(BOOL finished) {
        [_emptyView removeFromSuperview];
        _emptyView = nil;
    }];
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
    
    [_tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)insertCellsAtIndexes:(NSIndexSet *)indexSet
{
    NSMutableArray *indexPaths = [@[] mutableCopy];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        [indexPaths addObject:indexPath];
    }];
    [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if (_emptyView) {
        [self removeEmptyView];
    }
}

- (void)deleteCellsAtIndexes:(NSIndexSet *)indexSet
{
    NSMutableArray *indexPaths = [@[] mutableCopy];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        [indexPaths addObject:indexPath];
    }];
    [_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
    
    if ([_delegate numberOfListItems] == 0 && _emptyView == nil)
        [self setupEmptyView];
}

- (void)unselect
{
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
}

- (void)showConfirmationHUD:(NSString *)detailText
{
    [CCActionResultHUD showActionResultWithImage:[UIImage imageNamed:@"completed"] text:detailText delay:1];
}

#pragma mark - UIGestureRecognizer target methods

- (void)panGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:self];
        if (fabs(translation.x) < fabs(translation.y) && translation.y < 0)
            [_delegate hideOptionView];
    }
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
    /*NSDate *lastNotif = [_delegate lastNotifForAddressAtIndex:index];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"dd/MM HH:mm";*/
    double distance = [_delegate distanceForListItemAtIndex:index];
    NSString *distanceUnit = @"m";
    
    if (distance > 1000) {
        distance /= 1000;
        distanceUnit = @"km";
    }
    
    NSString *distanceText = [NSString stringWithFormat:@"%.02f %@", distance, distanceUnit /*, [dateFormatter stringFromDate:lastNotif]*/];
    cell.textLabel.text = [_delegate nameForListItemAtIndex:index];
    if (distance > 0)
        cell.detailTextLabel.text = distanceText;
    else
        cell.detailTextLabel.text = NSLocalizedString(@"DISTANCE_UNAVAILABLE", @"");

    [cell setNotificationEnabled:[_delegate notificationEnabledForListItemAtIndex:index]];
    if ([_delegate orientationAvailableAtIndex:index]) {
        [cell setAngle:[_delegate angleForListItemAtIndex:index]];
        cell.directionHidden = NO;
    } else {
        cell.directionHidden = YES;
    }
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
    NSLog(@"%f", scrollView.contentOffset.y);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y < -30)
        [_delegate showOptionView];
    else if (scrollView.contentOffset.y > 0)
        [_delegate hideOptionView];
}

#pragma mark - setter methods

- (void)setDelegate:(id<CCListViewDelegate>)delegate
{
    _delegate = delegate;
    
    if ([_delegate numberOfListItems] == 0)
        [self setupEmptyView];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
