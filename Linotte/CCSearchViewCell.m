//
//  CCSearchViewCell.m
//  Linotte
//
//  Created by stant on 13/02/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCSearchViewCell.h"

#import <HexColors/HexColor.h>

@implementation CCSearchViewCell
{
    UIImageView *_iconView;
    UILabel *_nameLabel;
    UILabel *_detailLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self setupIcon];
        [self setupNameLabel];
        [self setupDetailLabel];
        [self setupLayout];
    }
    return self;
}

- (void)setupIcon
{
    _iconView = [UIImageView new];
    _iconView.translatesAutoresizingMaskIntoConstraints = NO;
    _iconView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_iconView];
}

- (void)setupNameLabel
{
    _nameLabel = [UILabel new];
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _nameLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:17];
    _nameLabel.textColor = [UIColor colorWithHexString:@"#6B6B6B"];
    [self.contentView addSubview:_nameLabel];
}

- (void)setupDetailLabel
{
    _detailLabel = [UILabel new];
    _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _detailLabel.font = [UIFont fontWithName:@"Futura-BookItalic" size:14];
    _detailLabel.textColor = [UIColor colorWithHexString:@"#6B6B6B"];
    _detailLabel.numberOfLines = 0;
    [self.contentView addSubview:_detailLabel];
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_iconView, _nameLabel, _detailLabel);
    
    {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==8)-[_iconView(==40)]-[_nameLabel]-(==8)-|" options:0 metrics:nil views:views];
        [self.contentView addConstraints:horizontalConstraints];
    }
    
    {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_iconView]-[_detailLabel]|" options:0 metrics:nil views:views];
        [self.contentView addConstraints:horizontalConstraints];
    }

    {
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_iconView]-|" options:0 metrics:nil views:views];
        [self.contentView addConstraints:verticalConstraints];
    }
    
    {
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_nameLabel][_detailLabel]-|" options:0 metrics:nil views:views];
        [self.contentView addConstraints:verticalConstraints];
    }
}

#pragma mark - value setter methods

- (void)setIcon:(UIImage *)icon
{
    _iconView.image = icon;
}

- (void)setName:(NSString *)name
{
    _nameLabel.text = name;
}

- (void)setDetail:(NSString *)detail
{
    _detailLabel.text = detail;
}

@end
