//
//  CCListOutputView.m
//  Linotte
//
//  Created by stant on 10/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListOutputView.h"

@interface CCListOutputView()

@property(nonatomic, strong)UIImageView *listIcon;
@property(nonatomic, strong)UITextView *listInfos;

@property(nonatomic, strong)UIView *addView;
@property(nonatomic, strong)UIView *listView;

@end

@implementation CCListOutputView

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setupList
{
    
}

- (void)setupLayout
{
    
}

@end
