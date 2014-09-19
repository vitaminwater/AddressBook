//
//  CCListSettingsTableViewCell.m
//  Linotte
//
//  Created by stant on 07/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAddressListSettingsTableViewCell.h"

@interface CCAddressListSettingsTableViewCell()

@property(nonatomic, strong)UIImageView *checkImageView;

@end

@implementation CCAddressListSettingsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = [UIView new];
        self.backgroundView.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [UIFont fontWithName:@"Futura-Book" size:19];
        
        [self setupCheckImageView];
    }
    return self;
}

- (void)setupCheckImageView
{
    _checkImageView = [UIImageView new];
    _checkImageView.contentMode = UIViewContentModeScaleAspectFit;
    _checkImageView.image = [UIImage imageNamed:@"check_list_icon-off"];
    [self addSubview:_checkImageView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect checkImageViewFrame = self.bounds;
    checkImageViewFrame.size.width = checkImageViewFrame.size.height;
    checkImageViewFrame.size.height -= 15;
    checkImageViewFrame.origin.y = 7.5;
    _checkImageView.frame = checkImageViewFrame;
    
    CGRect textLabelFrame = self.bounds;
    textLabelFrame.origin.x = checkImageViewFrame.size.width;
    self.textLabel.frame = textLabelFrame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

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

@end
