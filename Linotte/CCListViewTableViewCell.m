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

@interface CCListViewTableViewCell()

@property(nonatomic, strong)UILabel *realTextLabel;
@property(nonatomic, strong)UILabel *realDetailTextLabel;

@property(nonatomic, strong)UIImageView *compasView;
@property(nonatomic, strong)UIImage *compasImage;
@property(nonatomic, strong)UIImage *invertedCompasImage;

@property(nonatomic, strong)NSLayoutConstraint *leftEjectButtonConstraint;

@end

@implementation CCListViewTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UIView *selectedBackgroundView = [UIView new];
        selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        self.selectedBackgroundView = selectedBackgroundView;
        
        [self setupLabels];
        [self setupButton];
        [self setupCompas];
    }
    return self;
}

- (void)setupLabels
{
    self.realTextLabel = [UILabel new];
    self.realTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.realTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:self.realTextLabel];
    
    self.realDetailTextLabel = [UILabel new];
    self.realDetailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.realDetailTextLabel];
    
    self.realTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.realTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:25];
    self.realTextLabel.textColor = [UIColor blackColor];
    
    self.realDetailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.realDetailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    self.realDetailTextLabel.textColor = [UIColor colorWithWhite:0 alpha:0.5];
    
    NSLayoutConstraint *topTextLabelConstraint = [NSLayoutConstraint constraintWithItem:self.realTextLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:15];
    [self.contentView addConstraint:topTextLabelConstraint];
    
    NSLayoutConstraint *bottomDetailLabelConstraint = [NSLayoutConstraint constraintWithItem:self.realDetailTextLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-15];
    [self.contentView addConstraint:bottomDetailLabelConstraint];
    
    for (UIView *view in @[self.realTextLabel, self.realDetailTextLabel]) {
        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:8];
        [self.contentView addConstraint:leftConstraint];
    }
}

- (void)setupButton
{
    UIButton *button = [UIButton new];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [button setImage:[UIImage imageNamed:@"eject.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(removePressed:) forControlEvents:UIControlEventTouchUpInside];
    button.alpha = 0.7;
    [self.contentView addSubview:button];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(button);
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[button(==50)]" options:0 metrics:nil views:views];
    [self.contentView addConstraints:horizontalConstraints];
    
    _leftEjectButtonConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    [self addConstraint:_leftEjectButtonConstraint];
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button]|" options:0 metrics:nil views:views];
    [self.contentView addConstraints:verticalConstraints];
    
    UISwipeGestureRecognizer *swipGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipGestureRecognizer:)];
    swipGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipGestureRecognizer];
    swipGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipGestureRecognizer:)];
    swipGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipGestureRecognizer];
}

- (void)setupCompas
{
    _compasImage = [UIImage imageNamed:@"direction.png"];
    _invertedCompasImage = [UIImage inverseColor:_compasImage];
    _compasView = [[UIImageView alloc] initWithImage:_compasImage];
    _compasView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_compasView];
    
    NSLayoutConstraint *horizontalConstraint = [NSLayoutConstraint constraintWithItem:_compasView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:-16];;
    [self.contentView addConstraint:horizontalConstraint];
    
    NSLayoutConstraint *verticalConstraint = [NSLayoutConstraint constraintWithItem:_compasView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.35 constant:0];
    [self.contentView addConstraint:verticalConstraint];
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
        self.realTextLabel.textColor = [UIColor whiteColor];
        self.realDetailTextLabel.textColor = [UIColor whiteColor];
        self.compasView.image = _invertedCompasImage;
    } else {
        self.realTextLabel.textColor = [UIColor blackColor];
        self.realDetailTextLabel.textColor = [UIColor colorWithWhite:0 alpha:0.5];
        self.compasView.image = _compasImage;
    }
}

- (UILabel *)textLabel
{
    return self.realTextLabel;
}

- (UILabel *)detailTextLabel
{
    return self.realDetailTextLabel;
}

- (void)prepareForReuse
{
    _leftEjectButtonConstraint.constant = 0;
}

#pragma mark - UIButton target methods

- (void)removePressed:(id)sender
{
    [_delegate deleteAddress:self];
}

#pragma mark - UIGestureRecognizer target methods

- (void)swipGestureRecognizer:(UISwipeGestureRecognizer *)swipGestureRecognizer
{
    if (swipGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (swipGestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
            _leftEjectButtonConstraint.constant = -50;
        } else if (swipGestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {
            _leftEjectButtonConstraint.constant = 0;
        }
        [UIView animateWithDuration:0.2 animations:^{
            [self.contentView layoutIfNeeded];
        }];
    }
}

#pragma mark - setter methods

- (void)setAngle:(double)angle
{
    _angle = angle;
    CATransform3D transform = CATransform3DMakeRotation(_angle / 180 * M_PI, 0, 0, 1);
    _compasView.layer.transform = transform;
}

@end
