//
//  CCGroupListStoreViewController.m
//  Linotte
//
//  Created by stant on 04/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCGroupListStoreViewController.h"

#import "CCLinotteEngineCoordinator.h"
#import "CCLinotteAuthenticationManager.h"
#import "CCLinotteAPI.h"

#import "CCBaseListStoreView.h"

@implementation CCGroupListStoreViewController
{
    NSDictionary *_groupDict;
}

- (instancetype)initWithGroup:(NSDictionary *)groupDict
{
    self = [super init];
    if (self) {
        _groupDict = groupDict;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.title = _groupDict[@"name"];
}

#pragma mark - Data methods

- (void)loadData:(NSUInteger)pageNumber
{
    if (CCLEC.authenticationManager.readyToSend == NO)
        return;
    [CCLEC.linotteAPI fetchListsForGroup:_groupDict[@"identifier"] success:^(NSArray *lists) {
        self.lists = lists;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
}

@end
