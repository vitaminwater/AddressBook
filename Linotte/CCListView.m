//
//  CCListView.m
//  Linotte
//
//  Created by stant on 06/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListView.h"

#import <HexColors/HexColor.h>

#import "CCListViewContentProvider.h"
#import "CCListViewTableViewCell.h"
#import "CCFlatColorButton.h"

#define kCCListViewTableViewCellIdentifier @"kCCListViewTableViewCellIdentifier"

#define kCCDistanceColors @[@"#6b6b6b", @"#898989", @"#afafaf", @"#c8c8c8"]

@interface CCListView()

@property(nonatomic, strong)UIImageView *helpImage;

@property(nonatomic, strong)UIView *buttonContainer;
@property(nonatomic, strong)UITableView *tableView;

@property(nonatomic, assign)CGFloat panVelocity;
@property(nonatomic, strong)NSLayoutConstraint *buttonContainerHeightConstraint;

@end

@implementation CCListView

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self setupButtons];
        [self setupTableView];
        [self setupLayout];
        
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
        panGestureRecognizer.delegate = self;
        [self addGestureRecognizer:panGestureRecognizer];
    }
    return self;
}

- (void)setupButtons
{
    _buttonContainer = [UIView new];
    _buttonContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_buttonContainer];
    
    CCFlatColorButton *discoveryButton = [self createButton];
    [discoveryButton addTarget:self action:@selector(discoverPressed:) forControlEvents:UIControlEventTouchUpInside];
    [discoveryButton setTitle:NSLocalizedString(@"ADD_LIST", @"") forState:UIControlStateNormal];
    [discoveryButton setBackgroundColor:[UIColor colorWithHexString:@"#8e44ad"]];
    [discoveryButton setBackgroundColor:[UIColor colorWithHexString:@"#9b59b6"] forState:UIControlStateHighlighted];
    
    CCFlatColorButton *listManagerButton = [self createButton];
    [listManagerButton addTarget:self action:@selector(listManagerPressed:) forControlEvents:UIControlEventTouchUpInside];
    [listManagerButton setTitle:NSLocalizedString(@"EXPANDED_DISPLAYED_LIST", @"") forState:UIControlStateNormal];
    [listManagerButton setBackgroundColor:[UIColor colorWithHexString:@"#2980b9"]];
    [listManagerButton setBackgroundColor:[UIColor colorWithHexString:@"#3498db"] forState:UIControlStateHighlighted];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(listManagerButton, discoveryButton);
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[discoveryButton][listManagerButton(==discoveryButton)]|" options:0 metrics:nil views:views];
    [_buttonContainer addConstraints:horizontalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
        [_buttonContainer addConstraints:verticalConstraints];
    }
}

- (CCFlatColorButton *)createButton
{
    CCFlatColorButton *button = [CCFlatColorButton new];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"Futura-Book" size:20];

    button.titleLabel.numberOfLines = 0;

    [_buttonContainer addSubview:button];
    
    return button;
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
    NSDictionary *views = NSDictionaryOfVariableBindings(_buttonContainer, _tableView);
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_buttonContainer][_tableView]|" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
        [self addConstraints:horizontalConstraints];
    }
    
    _buttonContainerHeightConstraint = [NSLayoutConstraint constraintWithItem:_buttonContainer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:0];
    [self addConstraint:_buttonContainerHeightConstraint];
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
    
    _helpImage.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        _helpImage.alpha = 1;
    }];
}

- (void)reloadListItemList
{
    [_tableView reloadData];
}

- (void)reloadVisibleListItems
{
    NSArray *cells = _tableView.visibleCells;
    for (CCListViewTableViewCell *cell in cells) {
        NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
        [self updateCell:cell atIndex:indexPath.row];
    }
}

- (void)insertListItemAtIndex:(NSUInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if (_helpImage) {
        [UIView animateWithDuration:0.2 animations:^{
            _helpImage.alpha = 0;
        } completion:^(BOOL finished) {
            [_helpImage removeFromSuperview];
            _helpImage = nil;
        }];
    }
}

- (void)deleteListItemAtIndex:(NSUInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    
    if ([_delegate numberOfListItems] == 0 && _helpImage == nil)
        [self setupHelpImage];
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
    
    NSArray *distanceColors = kCCLinotteColors;
    int distanceColorIndex = distance / 500;
    distanceColorIndex = MIN(distanceColorIndex, (int)[distanceColors count] - 1);
    
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
    if (distance > 0) {
        NSString *color = distanceColors[distanceColorIndex];
        cell.colorCode = color;
    }
    cell.angle = [_delegate angleForListItemAtIndex:index];
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
    CCListViewTableViewCell *cell = (CCListViewTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [_delegate didSelectListItemAtIndex:indexPath.row color:cell.colorCode];
}

#pragma mark - UIbutton target methods

- (void)listManagerPressed:(UIButton *)sender
{
    [_delegate showListManagement];
}

- (void)discoverPressed:(UIButton *)sender
{
    [_delegate showListStore];
}

#pragma mark - UIPanGestureRecognizer target methods

- (void)panGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat y = [panGestureRecognizer translationInView:self].y;
        [panGestureRecognizer setTranslation:CGPointZero inView:self];
        CGFloat newHeight = _buttonContainerHeightConstraint.constant + y;
        NSLog(@"%f %f", y, _tableView.contentOffset.y);
        
        if (y > 0 && _tableView.contentOffset.y > 0) {
            return;
        }
        
        newHeight = MIN(50, MAX(0, newHeight));
        _panVelocity = [panGestureRecognizer velocityInView:self].y;
        _buttonContainerHeightConstraint.constant = newHeight;
        if (newHeight > 0 && newHeight < 50)
            _tableView.contentOffset = CGPointMake(_tableView.contentOffset.x, _tableView.contentOffset.y + y);
        [self layoutIfNeeded];
    } else {
        NSLog(@"%f", _panVelocity);
        if (_buttonContainerHeightConstraint.constant < 25 || _panVelocity < -800)
            _buttonContainerHeightConstraint.constant = 0;
        else if (_buttonContainerHeightConstraint.constant > 25 || _panVelocity > 800)
            _buttonContainerHeightConstraint.constant = 50;
        [UIView animateWithDuration:0.2 animations:^{
            [self layoutIfNeeded];
        }];
    }
}

#pragma mark - setter methods

- (void)setDelegate:(id<CCListViewDelegate>)delegate
{
    _delegate = delegate;
    
    if ([_delegate numberOfListItems] == 0)
        [self setupHelpImage];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
