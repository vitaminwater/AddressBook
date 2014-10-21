//
//  CCListStoreView.m
//  Linotte
//
//  Created by stant on 09/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListStoreView.h"

#import "CCListStoreTableViewCell.h"

#define kCCListStoreTableViewCell @"kCCListStoreTableViewCell"


@implementation CCListStoreView
{
    UICollectionView *_listView;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self setupList];
        [self setupLayout];
    }
    return self;
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
    [_listView registerClass:[CCListStoreTableViewCell class] forCellWithReuseIdentifier:kCCListStoreTableViewCell];
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

#pragma mark - UICollectionViewDelegate/UICollectionViewDataSource methods

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CCListStoreTableViewCell *cell = [_listView dequeueReusableCellWithReuseIdentifier:kCCListStoreTableViewCell forIndexPath:indexPath];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_delegate numberOfLists];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

@end
