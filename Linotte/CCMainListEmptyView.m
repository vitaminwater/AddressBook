//
//  CCMainListEmptyView.m
//  Linotte
//
//  Created by stant on 25/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCMainListEmptyView.h"

@interface CCMainListEmptyView()

@property(nonatomic, strong)UIImageView *helpImageView;

@end

@implementation CCMainListEmptyView

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self setupHelpImage];
        [self setupLayout];
    }
    return self;
}

- (void)setupHelpImage
{
    _helpImageView = [UIImageView new];
    _helpImageView.image = [UIImage imageNamed:NSLocalizedString(@"NO_NOTE_SPLASH", @"")];
    _helpImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_helpImageView];
}

- (void)setupLayout
{
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:_helpImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    [self addConstraint:centerXConstraint];
    
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:_helpImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    [self addConstraint:centerYConstraint];
}

@end
