//
//  CCListSettingsTableViewCell.m
//  Linotte
//
//  Created by stant on 07/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListConfigTableViewCell.h"

#import <HexColors/HexColor.h>

@interface CCListConfigTableViewCell()

@property(nonatomic, strong)UIButton *expandedButton;

@end

@implementation CCListConfigTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = [UIView new];
        self.backgroundView.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        self.textLabel.textColor = [UIColor colorWithHexString:@"#6b6b6b"];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [UIFont fontWithName:@"Futura-Book" size:25];
        
        [self setupCheckImageView];
    }
    return self;
}

- (void)setupCheckImageView
{
    _expandedButton = [UIButton new];
    _expandedButton.contentMode = UIViewContentModeScaleAspectFit;
    [_expandedButton setImage:[UIImage imageNamed:@"check_list_icon-off"] forState:UIControlStateNormal];
    [_expandedButton setImage:[UIImage imageNamed:@"check_list_icon-on"] forState:UIControlStateSelected];
    [_expandedButton addTarget:self action:@selector(expandedButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _expandedButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_expandedButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect checkImageViewFrame = self.bounds;
    checkImageViewFrame.size.width = checkImageViewFrame.size.height;
    checkImageViewFrame.size.height -= 15;
    checkImageViewFrame.origin.y = 7.5;
    _expandedButton.frame = checkImageViewFrame;
    
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
        _expandedButton.alpha = editing ? 0 : 1;
    }];
}

- (void)initialExpandedState:(BOOL)expandedState
{
    _expandedButton.selected = expandedState;
}

#pragma mark - UIButton target methods

- (void)expandedButtonPressed:(id)sender
{
    _expandedButton.selected = !_expandedButton.selected;
    if (_expandedButton.selected)
        [_delegate checkedCell:self];
    else
        [_delegate uncheckedCell:self];
}

@end
