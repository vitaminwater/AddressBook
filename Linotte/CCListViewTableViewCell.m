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


@interface CCListViewTableViewCell()

@property(nonatomic, strong)UIButton *deleteButton;

@property(nonatomic, strong)UILabel *realTextLabel;
@property(nonatomic, strong)CCListViewTableViewCellDetailLabel *realDetailTextLabel;

@property(nonatomic, strong)UIImageView *compasView;
@property(nonatomic, strong)UIImage *compasImage;
@property(nonatomic, strong)UIImage *invertedCompasImage;

@property(nonatomic, strong)NSLayoutConstraint *rightEjectButtonConstraint;

@end

@implementation CCListViewTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self setupButton];
        [self setupLabels];
        [self setupCompas];
    }
    return self;
}

- (void)setupLabels
{
    _realTextLabel = [UILabel new];
    _realTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _realTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _realTextLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:25];
    _realTextLabel.textColor = [UIColor colorWithHexString:@"#6B6B6B"];
    [self.contentView addSubview:_realTextLabel];
    
    _realDetailTextLabel = [CCListViewTableViewCellDetailLabel new];
    _realDetailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_realDetailTextLabel];

    NSLayoutConstraint *topTextLabelConstraint = [NSLayoutConstraint constraintWithItem:_realTextLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:15];
    [self.contentView addConstraint:topTextLabelConstraint];
    
    NSLayoutConstraint *bottomDetailLabelConstraint = [NSLayoutConstraint constraintWithItem:_realDetailTextLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-15];
    [self.contentView addConstraint:bottomDetailLabelConstraint];
    
    for (UIView *view in @[_realTextLabel, _realDetailTextLabel]) {
        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_deleteButton attribute:NSLayoutAttributeRight multiplier:1 constant:8];
        [self.contentView addConstraint:leftConstraint];
    }
}

- (void)setupButton
{
    _deleteButton = [UIButton new];
    _deleteButton.translatesAutoresizingMaskIntoConstraints = NO;
    _deleteButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_deleteButton setImage:[UIImage imageNamed:@"delete_note"] forState:UIControlStateNormal];
    [_deleteButton addTarget:self action:@selector(removePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_deleteButton];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_deleteButton);
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_deleteButton(==90)]" options:0 metrics:nil views:views];
    [self.contentView addConstraints:horizontalConstraints];
    
    _rightEjectButtonConstraint = [NSLayoutConstraint constraintWithItem:_deleteButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    [self addConstraint:_rightEjectButtonConstraint];
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_deleteButton]|" options:0 metrics:nil views:views];
    [self.contentView addConstraints:verticalConstraints];
    
    UISwipeGestureRecognizer *swipGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipGestureRecognizer:)];
    swipGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipGestureRecognizer];
    swipGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipGestureRecognizer:)];
    swipGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipGestureRecognizer];
}

- (void)setupCompas
{
    _compasImage = [UIImage imageNamed:@"direction"];
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
        
    } else {
        
    }
}

- (UILabel *)textLabel
{
    return self.realTextLabel;
}

- (UILabel *)detailTextLabel
{
    return self.realDetailTextLabel.label;
}

- (UIImageView *)markerImageView
{
    return self.realDetailTextLabel.imageView;
}

- (void)prepareForReuse
{
    _rightEjectButtonConstraint.constant = 0;
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
        if (swipGestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {
            _rightEjectButtonConstraint.constant = 95;
        } else if (swipGestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
            _rightEjectButtonConstraint.constant = 0;
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
