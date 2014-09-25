//
//  CCListOutputAddressListView.m
//  Linotte
//
//  Created by stant on 25/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListOutputAddressListView.h"

@interface CCListOutputAddressListView()

@property(nonatomic, strong)UIView *topView;
@property(nonatomic, strong)UITextField *searchField;
@property(nonatomic, strong)UITableView *addressList;

@end

@implementation CCListOutputAddressListView

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self setupTopView];
        [self setupSearchField];
        [self setupAddressList];
        [self setupLayout];
    }
    return self;
}

- (void)setupTopView
{
    
}

- (void)setupSearchField
{
    
}

- (void)setupAddressList
{
    
}

- (void)setupLayout
{
    
}

@end
