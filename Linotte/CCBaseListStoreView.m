//
//  CCListStoreView.m
//  Linotte
//
//  Created by stant on 04/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCBaseListStoreView.h"
#import "CCListStoreTableViewCell.h"

#import "CCActionResultHUD.h"

@implementation CCBaseListStoreView
{
    UITableView *_listView;
    
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
    layout.itemSize = CGSizeMake(itemEdge, 200);
    
    layout.minimumInteritemSpacing = 7;
    layout.minimumLineSpacing = 7;
    
    _listView = [UITableView new];
    _listView.translatesAutoresizingMaskIntoConstraints = NO;
    _listView.backgroundColor = [UIColor whiteColor];
    _listView.rowHeight = 70;
    [self setupList:_listView];
    [self addSubview:_listView];
}

- (void)setupList:(UITableView *)listView {}

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

#pragma mark - List management

- (void)reloadData
{
    [_listView reloadData];
}

@end
