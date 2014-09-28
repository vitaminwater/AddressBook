//
//  CCListViewTableViewCellDetailLabel.m
//  Linotte
//
//  Created by stant on 09/08/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListViewTableViewCellDetailLabel.h"

#import <HexColors/HexColor.h>

@implementation CCListViewTableViewCellDetailLabel

- (id)init
{
    self = [super init];
    if (self) {
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"white_pin.png"]];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
        
        _label = [UILabel new];
        _label.translatesAutoresizingMaskIntoConstraints = NO;
        _label.font = [UIFont fontWithName:@"Futura-Book" size:18];
        _label.textColor = [UIColor colorWithHexString:@"#6B6B6B"];
        _label.numberOfLines = 0;
        [self addSubview:_label];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_imageView, _label);
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_imageView]-(==5)-[_label]" options:0 metrics:nil views:views];
        [self addConstraints:horizontalConstraints];
        
        NSArray *imageVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_imageView(==35)]|" options:0 metrics:nil views:views];
        [self addConstraints:imageVerticalConstraints];
        
        NSLayoutConstraint *labelVerticalConstraint = [NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_imageView attribute:NSLayoutAttributeCenterY multiplier:1 constant:3];
        [self addConstraint:labelVerticalConstraint];
    }
    return self;
}

@end