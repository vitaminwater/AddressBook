//
//  CCListViewCellTableViewCell.m
//  Linotte
//
//  Created by stant on 07/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListViewTableViewCell.h"

#import <HexColors/HexColor.h>

#import "UIImage+CCInvert.h"

#import "CCListViewTableViewCellDetailLabel.h"


@implementation CCListViewTableViewCell
{
    UILabel *_realTextLabel;
    CCListViewTableViewCellDetailLabel *_realDetailTextLabel;
    
    UIButton *_bellButton;
    
    UIImageView *_compasView;
    
    NSMutableArray *_constraints;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
        
        [self setupLabels];
        [self setupBellButton];
        [self setupCompas];
        [self setupLayout];
        
        UILongPressGestureRecognizer *longPressedGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(removePressed:)];
        [self addGestureRecognizer:longPressedGestureRecognizer];
    }
    return self;
}

- (void)setupLabels
{
    _realTextLabel = [UILabel new];
    _realTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _realTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _realTextLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:20];
    _realTextLabel.textColor = [UIColor colorWithHexString:@"#6B6B6B"];
    [self.contentView addSubview:_realTextLabel];
    
    _realDetailTextLabel = [CCListViewTableViewCellDetailLabel new];
    _realDetailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_realDetailTextLabel];
}

- (void)setupBellButton
{
    _bellButton = [UIButton new];
    _bellButton.translatesAutoresizingMaskIntoConstraints = NO;
    _bellButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_bellButton setImage:[UIImage imageNamed:@"bell_button_off"] forState:UIControlStateNormal];
    [_bellButton setImage:[UIImage imageNamed:@"bell_button_on"] forState:UIControlStateSelected];
    [_bellButton addTarget:self action:@selector(bellPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_bellButton];
}

- (void)setupCompas
{
    UIImage *compasImage = [UIImage imageNamed:@"direction"];
    _compasView = [[UIImageView alloc] initWithImage:compasImage];
    _compasView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_compasView];
}

- (void)setupLayout
{
    //NSDictionary *views = NSDictionaryOfVariableBindings(_realTextLabel, _realDetailTextLabel, _bellButton, _compasView);
    
    if (_constraints)
        [self.contentView removeConstraints:_constraints];
    _constraints = [@[] mutableCopy];
    
    // realTextLabel and reatDetailTextLabel
    {
        NSLayoutConstraint *topTextLabelConstraint = [NSLayoutConstraint constraintWithItem:_realTextLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:10];
        [_constraints addObject:topTextLabelConstraint];
        
        NSLayoutConstraint *bottomDetailLabelConstraint = [NSLayoutConstraint constraintWithItem:_realDetailTextLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-15];
        [_constraints addObject:bottomDetailLabelConstraint];
        
        for (UIView *view in @[_realTextLabel, _realDetailTextLabel]) {
            NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:view == _realTextLabel ? 16 : 8];
            [_constraints addObject:leftConstraint];
        }
    }
    
    // compasView
    {
        if (_compasView.hidden == NO) {
            NSLayoutConstraint *horizontalConstraint = [NSLayoutConstraint constraintWithItem:_compasView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:-16];;
            [_constraints addObject:horizontalConstraint];
        } else {
            NSLayoutConstraint *horizontalConstraint = [NSLayoutConstraint constraintWithItem:_compasView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:-16];;
            [_constraints addObject:horizontalConstraint];
        }
        
        NSLayoutConstraint *verticalConstraint = [NSLayoutConstraint constraintWithItem:_compasView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.35 constant:0];
        [_constraints addObject:verticalConstraint];
    }
    
    // bellButton
    {
        NSLayoutConstraint *horizontalConstraint = [NSLayoutConstraint constraintWithItem:_bellButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_compasView attribute:NSLayoutAttributeLeft multiplier:1 constant:-5];
        [_constraints addObject:horizontalConstraint];
        
        NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:_bellButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_compasView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        [_constraints addObject:centerYConstraint];
    }
    
    [self.contentView addConstraints:_constraints];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self highlightLabels:selected];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    [self highlightLabels:highlighted];
}

- (void)highlightLabels:(BOOL)highlight
{
    if (highlight) {
        
    } else {
        
    }
}

- (UILabel *)textLabel
{
    return _realTextLabel;
}

- (UILabel *)detailTextLabel
{
    return _realDetailTextLabel.label;
}

- (UIImageView *)markerImageView
{
    return _realDetailTextLabel.imageView;
}

- (void)prepareForReuse
{
}

#pragma mark - UIButton target methods

- (void)removePressed:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateRecognized)
        [_delegate deleteAddress:self];
}

- (void)bellPressed:(id)sender
{
    [_delegate setNotificationEnabled:!_bellButton.selected forCell:self];
}

#pragma mark - setter methods

- (void)setNotificationEnabled:(BOOL)notificationEnabled
{
    _bellButton.selected = notificationEnabled;
}

- (void)setAngle:(double)angle
{
    CATransform3D transform = CATransform3DMakeRotation(angle / 180 * M_PI, 0, 0, 1);
    _compasView.layer.transform = transform;
}

- (void)setDirectionHidden:(BOOL)directionHidden
{
    if (_directionHidden == directionHidden)
        return;
    
    [self willChangeValueForKey:@"directionHidden"];
    _directionHidden = directionHidden;
    _compasView.hidden = directionHidden;
    [self setupLayout];
    [self didChangeValueForKey:@"directionHidden"];
}

@end
