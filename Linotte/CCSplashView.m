//
//  CCSplashView.m
//  Linotte
//
//  Created by stant on 10/08/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCSplashView.h"

#pragma mark - Slogan elements class

@interface CCSplashViewItem : UIView

@property(nonatomic, strong)UIImageView *imageView;
@property(nonatomic, strong)UILabel *label;

@end

@implementation CCSplashViewItem

- (id)initWithImage:(UIImage *)image text:(NSString *)text
{
    self = [super init];
    if (self) {
        _imageView = [[UIImageView alloc] initWithImage:image];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
        
        _label = [UILabel new];
        _label.translatesAutoresizingMaskIntoConstraints = NO;
        [_label setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        _label.textColor = [UIColor whiteColor];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.font = [UIFont fontWithName:@"Montserrat-Bold" size:15];
        _label.text = text;
        [self addSubview:_label];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_imageView, _label);
        
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_imageView]-(==10)-[_label]|" options:0 metrics:nil views:views];
        [self addConstraints:verticalConstraints];
        
        for (UIView *view in views.allValues) {
            NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
            [self addConstraints:horizontalConstraints];
        }
    }
    return self;
}

@end

#pragma mark - Actual implementation

@interface CCSplashView()

@property(nonatomic, strong)UIImageView *logo;
@property(nonatomic, strong)UILabel *titleLabel;
@property(nonatomic, strong)NSArray *elements;

@end

@implementation CCSplashView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"splash_bg.png"]];
        
        [self setupSkipButton];
        [self setupTitle];
        [self setupElements];
    }
    return self;
}

- (void)setupSkipButton
{
    UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    skipButton.translatesAutoresizingMaskIntoConstraints = NO;
    [skipButton addTarget:self action:@selector(skipButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [skipButton setTitle:NSLocalizedString(@"SKIP_BUTTON_TEXT", @"") forState:UIControlStateNormal];
    skipButton.titleLabel.font = [UIFont fontWithName:@"Futura-Book" size:20];
    [skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addSubview:skipButton];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:skipButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:-5];
    [self addConstraint:rightConstraint];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:skipButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:-5];
    [self addConstraint:bottomConstraint];
}

- (void)setupTitle
{
    _logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"splash_logo.png"]];
    _logo.translatesAutoresizingMaskIntoConstraints = NO;
    [_logo setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    _logo.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_logo];
    
    _titleLabel = [UILabel new];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    _titleLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:32];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.text = @"LINOTTE";
    [self addSubview:_titleLabel];
    
    NSLayoutConstraint *centerXLogoConstraint = [NSLayoutConstraint constraintWithItem:_logo attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    [self addConstraint:centerXLogoConstraint];
    
    NSLayoutConstraint *centerXTitleLabelConstraint = [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    [self addConstraint:centerXTitleLabelConstraint];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_logo, _titleLabel);
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==25)-[_logo(==50)]-(==10)-[_titleLabel]" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
}

- (void)setupElements
{
    
    UIView *spacerView1 = [UIView new];
    spacerView1.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:spacerView1];
    
    UIView *spacerView2 = [UIView new];
    spacerView2.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:spacerView2];
    
    CCSplashViewItem *iNote = [[CCSplashViewItem alloc] initWithImage:[UIImage imageNamed:@"inote.png"] text:NSLocalizedString(@"INOTE", @"")];
    iNote.translatesAutoresizingMaskIntoConstraints= NO;
    [self addSubview:iNote];
    
    CCSplashViewItem *iForget = [[CCSplashViewItem alloc] initWithImage:[UIImage imageNamed:@"iforget.png"] text:NSLocalizedString(@"IFORGET", @"")];
    iForget.translatesAutoresizingMaskIntoConstraints= NO;
    [self addSubview:iForget];
    
    CCSplashViewItem *iStroll = [[CCSplashViewItem alloc] initWithImage:[UIImage imageNamed:@"istroll.png"] text:NSLocalizedString(@"ISTROLL", @"")];
    iStroll.translatesAutoresizingMaskIntoConstraints= NO;
    [self addSubview:iStroll];
    
    CCSplashViewItem *iFind = [[CCSplashViewItem alloc] initWithImage:[UIImage imageNamed:@"ifind.png"] text:NSLocalizedString(@"IMREMINDED", @"")];
    iFind.translatesAutoresizingMaskIntoConstraints= NO;
    [self addSubview:iFind];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_titleLabel, spacerView1, spacerView2, iNote, iForget, iStroll, iFind);
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_titleLabel][spacerView1(>=16)][iNote]-[iForget(==iNote)]-[iStroll(==iNote)]-[iFind(==iNote)][spacerView2(==spacerView1)]|" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
    
    _elements = @[_titleLabel, iNote, iForget, iStroll, iFind];
    
    for (UIView *view in views.allValues) {
        NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        [self addConstraint:centerXConstraint];
        
        view.alpha = 0;
    }
}

#pragma mark - UIView overriden methods

- (void)layoutSubviews
{
    static BOOL firstTime = YES;
    
    if (firstTime == YES) {
        CGRect bounds = self.bounds;
        
        CGRect imageViewInitialFrame = CGRectMake(0, 0, 200, 200);
        imageViewInitialFrame.origin.x = bounds.size.width / 2 - imageViewInitialFrame.size.width / 2;
        imageViewInitialFrame.origin.y = bounds.size.height / 2 - imageViewInitialFrame.size.height / 2;
        
        [super layoutSubviews];
        
        _logo.frame = imageViewInitialFrame;
        [UIView animateWithDuration:0.5 animations:^{
            [self setNeedsLayout];
            [super layoutSubviews];
        } completion:^(BOOL finished) {
            [UIView animateKeyframesWithDuration:2 delay:0.3 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
                for (UIView *view in _elements) {
                    [UIView addKeyframeWithRelativeStartTime:1.0f / [_elements count] * [_elements indexOfObject:view] relativeDuration:2.0f / [_elements count] animations:^{
                        view.alpha = 1;
                    }];
                }
            } completion:^(BOOL finished) {
                
            }];
        }];
        firstTime = NO;
    } else {
        [super layoutSubviews];
    }
}

#pragma mark - UIButton target methods

- (void)skipButtonPressed:(id)sender
{
    [_delegate splashFinish];
}

@end
