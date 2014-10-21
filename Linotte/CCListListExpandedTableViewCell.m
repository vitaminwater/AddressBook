//
//  CCListListExpandedTableViewCell.m
//  Linotte
//
//  Created by stant on 29/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListListExpandedTableViewCell.h"

@implementation CCListListExpandedTableViewCell

{
    UIImageView *_checkImageView;
    
    UILabel *_addressNameLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = [UIView new];
        self.backgroundView.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        [self setupCheckImageView];
        [self setupAddressNameLabel];
        [self setupLayout];
    }
    return self;
}

- (void)setupAddressNameLabel
{
    _addressNameLabel = [UILabel new];
    _addressNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _addressNameLabel.textColor = [UIColor whiteColor];
    _addressNameLabel.backgroundColor = [UIColor clearColor];
    _addressNameLabel.font = [UIFont fontWithName:@"Futura-Book" size:19];
    [self.contentView addSubview:_addressNameLabel];
}

- (void)setupCheckImageView
{
    _checkImageView = [UIImageView new];
    _checkImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _checkImageView.contentMode = UIViewContentModeCenter;
    _checkImageView.image = [UIImage imageNamed:@"check_list_icon-off"];
    [self.contentView addSubview:_checkImageView];
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_checkImageView, _addressNameLabel);
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_checkImageView(==25)]-[_addressNameLabel]|" options:0 metrics:nil views:views];
    [self.contentView addConstraints:horizontalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
        [self.contentView addConstraints:verticalConstraints];
    }
}

#pragma mark - setter methods

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [UIView animateWithDuration:0.2 animations:^{
        _checkImageView.alpha = editing ? 0 : 1;
    }];
}

- (void)setIsAdded:(BOOL)isAdded
{
    _isAdded = isAdded;
    _checkImageView.image = [UIImage imageNamed:_isAdded ? @"check_list_icon-on" : @"check_list_icon-off"];
}

- (void)setName:(NSString *)name
{
    _addressNameLabel.text = name;
}

@end
