//
//  CCAddAddressAtLocationViewController.m
//  Linotte
//
//  Created by stant on 26/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAddAddressAtLocationViewController.h"

#import "CCAddAddressAtLocationView.h"

@implementation CCAddAddressAtLocationViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"AT_LOCATION", @"");
    }
    return self;
}

- (void)loadView
{
    CCAddAddressAtLocationView *view = [CCAddAddressAtLocationView new];
    view.delegate = self;
    self.view = view;
}

- (void)setFirstInputAsFirstResponder
{
    [((CCAddAddressAtLocationView *)self.view) setFirstInputAsFirstResponder];
}

@end
