//
//  CCListInstallerView.m
//  Linotte
//
//  Created by stant on 26/10/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListInstallerView.h"

#import <HexColors/HexColor.h>

#import "CCListInstallerCloseButton.h"

@implementation CCListInstallerView
{
    UIImageView *_imageView;
    UILabel *_nameLabel;
    UILabel *_infoLabel;
    UIView *_addToLinotteView;
    UIButton *_addToLinotteButton;
    CCListInstallerCloseButton *_closeButton;
    
    NSMutableArray *_constraints;
    
    NSDateFormatter *_dateFormatter;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.opaque = YES;
        
        _dateFormatter = [NSDateFormatter new];
        [_dateFormatter setDateFormat:@"dd/MM/yy"];
        
        [self setupImage];
        [self setupTitle];
        [self setupListInfos];
        [self setupAddToLinotte];
        [self setupCloseButton];
        [self setupLayout];
    }
    return self;
}

- (void)setupImage
{
    _imageView = [UIImageView new];
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_imageView];
}

- (void)setupTitle
{
    NSString *color = @"#6b6b6b";
    _nameLabel = [UILabel new];
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _nameLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:21];
    _nameLabel.textColor = [UIColor colorWithHexString:color];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_nameLabel];
}

- (void)setupListInfos
{
    NSString *color = @"#6b6b6b";
    _infoLabel = [UILabel new];
    _infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _infoLabel.font = [UIFont fontWithName:@"Futura-Book" size:18];
    _infoLabel.textColor = [UIColor colorWithHexString:color];
    _infoLabel.textAlignment = NSTextAlignmentCenter;
    _infoLabel.numberOfLines = 0;
    [self addSubview:_infoLabel];
}

- (void)setupAddToLinotte
{
    _addToLinotteView = [UIView new];
    _addToLinotteView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_addToLinotteView];
    
    NSString *color = @"#6b6b6b";
    UILabel *addToLinotteLabel = [UILabel new];
    addToLinotteLabel.translatesAutoresizingMaskIntoConstraints = NO;
    addToLinotteLabel.font = [UIFont fontWithName:@"Futura-Book" size:18];
    addToLinotteLabel.textColor = [UIColor colorWithHexString:color];
    addToLinotteLabel.text = NSLocalizedString(@"LIST_INSTALL_LABEL", @"");
    [_addToLinotteView addSubview:addToLinotteLabel];
    
    _addToLinotteButton = [UIButton new];
    _addToLinotteButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_addToLinotteButton addTarget:self action:@selector(addToLinotteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _addToLinotteButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_addToLinotteButton setImage:[UIImage imageNamed:@"notification_button_off"] forState:UIControlStateNormal];
    [_addToLinotteButton setImage:[UIImage imageNamed:@"notification_button_on"] forState:UIControlStateSelected];
    [_addToLinotteView addSubview:_addToLinotteButton];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(addToLinotteLabel, _addToLinotteButton);
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[addToLinotteLabel]-[_addToLinotteButton]-|" options:0 metrics:nil views:views];
    [_addToLinotteView addConstraints:horizontalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
        [_addToLinotteView addConstraints:verticalConstraints];
    }
}

- (void)setupCloseButton
{
    NSString *color = @"#6b6b6b";
    _closeButton = [CCListInstallerCloseButton new];
    _closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _closeButton.titleLabel.font = [UIFont fontWithName:@"Futura-Book" size:18];
    _closeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _closeButton.backgroundColor = [UIColor whiteColor];
    [_closeButton setTitleColor:[UIColor colorWithHexString:color] forState:UIControlStateNormal];
    [_closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_closeButton setTitle:NSLocalizedString(@"CLOSE", @"") forState:UIControlStateNormal];
    [self addSubview:_closeButton];
}

- (void)setupLayout
{
    if (_constraints)
        [self removeConstraints:_constraints];
    
    _constraints = [@[] mutableCopy];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_imageView, _nameLabel, _infoLabel, _addToLinotteView, _closeButton);
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==20)-[_imageView]-[_nameLabel]-[_infoLabel]-[_addToLinotteView]-[_closeButton]|" options:0 metrics:nil views:views];
    [_constraints addObjectsFromArray:verticalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view" : view}];
        [_constraints addObjectsFromArray:horizontalConstraints];
    }
    
    [self addConstraints:_constraints];
}

#pragma mark - setter methods

- (void)setListIconImage:(UIImage *)iconImage
{
    [_imageView setImage:iconImage];
}

- (void)setListName:(NSString *)listName
{
    [_nameLabel setText:listName];
}

- (void)setListInfos:(NSString *)listAuthor numberOfAddresses:(NSUInteger)numberOfAddresses numberOfInstalls:(NSUInteger)numberOfInstalls lastUpdate:(NSDate *)lastUpdate
{
    NSString *lastUpdateString = [_dateFormatter stringFromDate:lastUpdate];
    NSString *infos = [NSString stringWithFormat:NSLocalizedString(@"LIST_INFOS_FORMAT", @""), listAuthor, numberOfAddresses, numberOfInstalls, lastUpdateString];
    [_infoLabel setText:infos];
}

- (void)setAlreadyInstalled
{
    _addToLinotteButton.selected = YES;
}

- (void)cancelInstallAction
{
    _addToLinotteButton.selected = !_addToLinotteButton.selected;
}

#pragma mark - UIButton target methods

- (void)addToLinotteButtonPressed:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected)
        [_delegate addToLinotteButtonPressed];
    else
        [_delegate removeFromLinotteButtonPressed];
}

- (void)closeButtonPressed:(id)sender
{
    [_delegate closeButtonPressed];
}

@end
