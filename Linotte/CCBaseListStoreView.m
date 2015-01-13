//
//  CCListStoreView.m
//  Linotte
//
//  Created by stant on 04/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCBaseListStoreView.h"
#import "CCListStoreCollectionViewCell.h"

#import "CCActionResultHUD.h"

@implementation CCBaseListStoreView
{
    UICollectionView *_listView;
    
    UIView *_networkStatusView;
    
    CCActionResultHUD *_actionResult;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.opaque = YES;
        
        [self setupList];
        [self setupLayout];
    }
    return self;
}

- (void)dealloc
{
    if (_actionResult != nil)
        [CCActionResultHUD removeActionResult:_actionResult];
}

- (void)setupList
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    CGFloat itemEdge = screenSize.width / 2 - 21;
    layout.itemSize = CGSizeMake(itemEdge, itemEdge);
    
    layout.minimumInteritemSpacing = 7;
    layout.minimumLineSpacing = 7;
    
    _listView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _listView.translatesAutoresizingMaskIntoConstraints = NO;
    _listView.backgroundColor = [UIColor whiteColor];
    [self setupList:_listView];
    [self addSubview:_listView];
}

- (void)setupList:(UICollectionView *)listView {}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_listView);
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_listView]|" options:0 metrics:nil views:views];
    [self addConstraints:horizontalConstraints];
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_listView]|" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
}

- (void)unreachable
{
    _actionResult = [CCActionResultHUD showActionResultWithImage:[UIImage imageNamed:@"network_status"] inView:self text:NSLocalizedString(@"MISSING_LOCATION", @"") delay:0];
    self.userInteractionEnabled = NO;
}

- (void)reachable
{
    if (_actionResult != nil)
        [CCActionResultHUD removeActionResult:_actionResult];
    self.userInteractionEnabled = YES;
}

- (void)addListInstallerView:(UIView *)view
{
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:view];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(view);
    NSArray *widthConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:views];
    [self addConstraints:widthConstraints];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [self addConstraint:bottomConstraint];
    
    [self layoutIfNeeded];
    
    [self removeConstraint:bottomConstraint];
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [self addConstraint:topConstraint];
    
    [UIView animateWithDuration:0.2 animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)removeListInstallerView:(UIView *)view completionBlock:(void(^)())completionBlock
{
    NSLayoutConstraint *topConstraint = [[self.constraints filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"firstItem = %@ && firstAttribute = %d", view, NSLayoutAttributeTop]] firstObject];
    [self removeConstraint:topConstraint];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [self addConstraint:bottomConstraint];
    
    [UIView animateWithDuration:0.2 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
        completionBlock();
    }];
}

#pragma mark - List management

- (void)reloadData
{
    [_listView reloadData];
}

@end
