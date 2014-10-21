//
//  CCListOutputAddressListTableViewCell.m
//  Linotte
//
//  Created by stant on 26/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListOutputAddressListTableViewCell.h"

@implementation CCListOutputAddressListTableViewCell
{
    UIImageView *_checkImageView;
    
    UILabel *_addressNameLabel;
    UILabel *_addressAddressLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupCheckImageView];
        [self setupLabels];
        [self setupLayout];
    }
    return self;
}

- (void)setupCheckImageView
{
    _checkImageView = [UIImageView new];
    _checkImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _checkImageView.contentMode = UIViewContentModeCenter;
    _checkImageView.image = [UIImage imageNamed:@"check_list_icon_gris-off"];
    [self.contentView addSubview:_checkImageView];
}

- (void)setupLabels
{
    _addressNameLabel = [UILabel new];
    _addressNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _addressNameLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:25];
    _addressNameLabel.textColor = [UIColor darkGrayColor];
    [self.contentView addSubview:_addressNameLabel];
    
    _addressAddressLabel = [UILabel new];
    _addressAddressLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _addressAddressLabel.font = [UIFont fontWithName:@"Futura-Book" size:15];
    _addressAddressLabel.textColor = [UIColor darkGrayColor];
    [self.contentView addSubview:_addressAddressLabel];
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_checkImageView, _addressNameLabel, _addressAddressLabel);
    {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==15)-[_checkImageView(==25)]-[_addressNameLabel]-|" options:0 metrics:nil views:views];
        [self.contentView addConstraints:horizontalConstraints];
        
        NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:_checkImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_addressNameLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        [self.contentView addConstraint:centerYConstraint];
        
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:_checkImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_addressNameLabel attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
        [self.contentView addConstraint:heightConstraint];
    }
    
    {
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_addressNameLabel][_addressAddressLabel(==_addressNameLabel)]" options:0 metrics:nil views:views];
        [self.contentView addConstraints:verticalConstraints];
        
        NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:_addressNameLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        [self addConstraint:centerYConstraint];
    }
    
    {
        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:_addressAddressLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_addressNameLabel attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        [self.contentView addConstraint:leftConstraint];
        
        NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:_addressAddressLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        [self.contentView addConstraint:rightConstraint];
    }
}

#pragma mark - setter methods

- (void)setIsAdded:(BOOL)isAdded
{
    _isAdded = isAdded;
    _checkImageView.image = [UIImage imageNamed:_isAdded ? @"check_list_icon-on" : @"check_list_icon_gris-off"];
}

- (void)setName:(NSString *)name
{
    _addressNameLabel.text = name;
}

- (void)setAddress:(NSString *)address
{
    _addressAddressLabel.text = address;
}

@end
