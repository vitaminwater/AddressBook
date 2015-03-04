//
//  CCListInstallerView.m
//  Linotte
//
//  Created by stant on 26/10/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListInstallerView.h"

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <HexColors/HexColor.h>

#import "CCListInstallerCloseButton.h"

@implementation CCListInstallerView
{
    UIScrollView *_scrollView;
    UIView *_contentView;
    
    UIImageView *_imageView;
    UILabel *_nameLabel;
    UILabel *_infoLabel;
    
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
        
        [self setupScrollView];
        [self setupImage];
        [self setupTitle];
        [self setupListInfos];
        [self setupLayout];
    }
    return self;
}

- (void)setupScrollView
{
    _scrollView = [UIScrollView new];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_scrollView];
    
    _contentView = [UIView new];
    _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addSubview:_contentView];
}

- (void)setupImage
{
    _imageView = [UIImageView new];
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_contentView addSubview:_imageView];
}

- (void)setupTitle
{
    NSString *color = @"#6b6b6b";
    _nameLabel = [UILabel new];
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _nameLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:21];
    _nameLabel.textColor = [UIColor colorWithHexString:color];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    _nameLabel.numberOfLines = 0;
    [_contentView addSubview:_nameLabel];
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
    [_contentView addSubview:_infoLabel];
}

- (void)setupLayout
{
    {
        NSDictionary *views = NSDictionaryOfVariableBindings(_scrollView, _contentView);
        {
            NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|" options:0 metrics:nil views:views];
            [self addConstraints:verticalConstraints];
            
            NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:0 metrics:nil views:views];
            [self addConstraints:horizontalConstraints];
        }

        {
            NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_contentView]|" options:0 metrics:nil views:views];
            [_scrollView addConstraints:verticalConstraints];
            
            NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_contentView(==_scrollView)]|" options:0 metrics:nil views:views];
            [_scrollView addConstraints:horizontalConstraints];
        }
    }

    {
        NSDictionary *views = NSDictionaryOfVariableBindings(_imageView, _nameLabel, _infoLabel);
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==20)-[_imageView(==150)]-[_nameLabel]-[_infoLabel]-(>=20)-|" options:0 metrics:nil views:views];
        [_contentView addConstraints:verticalConstraints];
        
        for (UIView *view in views.allValues) {
            NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view" : view}];
            [_contentView addConstraints:horizontalConstraints];
        }
    }
}

#pragma mark - setter methods

- (void)loadListIconWithUrl:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@_in_app_big", kCCLinotteStaticServer, urlString]];
    [_imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"list_pin_neutral"]];
}

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

@end
