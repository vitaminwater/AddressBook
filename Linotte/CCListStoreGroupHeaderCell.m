//
//  CCListStoreGroupHeaderCell.m
//  Linotte
//
//  Created by stant on 05/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCListStoreGroupHeaderCell.h"

#import <HexColors/HexColor.h>

@implementation CCListStoreGroupHeaderCell
{
    UILabel *_titleLabel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupGroupTitle];
    }
    return self;
}

- (void)setupGroupTitle
{
    _titleLabel = [UILabel new];
    _titleLabel.frame = self.contentView.bounds;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    NSString *color = @"#6b6b6b";
    _titleLabel.textColor = [UIColor colorWithHexString:color];
    _titleLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:25];
    _titleLabel.numberOfLines = 0;
    [self.contentView addSubview:_titleLabel];
}

- (void)setGroupTitle:(NSString *)groupTitle
{
    _titleLabel.text = groupTitle;
}

- (NSString *)groupTitle
{
    return _titleLabel.text;
}

@end
