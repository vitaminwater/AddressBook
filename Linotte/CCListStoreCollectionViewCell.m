//
//  CCListStoreTableViewCell.m
//  Linotte
//
//  Created by stant on 09/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListStoreCollectionViewCell.h"

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <HexColors/HexColor.h>

@implementation CCListStoreCollectionViewCell
{
    UIImageView *_image;
    UILabel *_title;
    UILabel *_info;
    
    NSMutableArray *_constraints;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupImage];
        [self setupTitle];
        [self setupLayout];
    }
    return self;
}

- (void)setupImage
{
    _image = [UIImageView new];
    _image.translatesAutoresizingMaskIntoConstraints = NO;
    _image.contentMode = UIViewContentModeScaleAspectFit;
   [self addSubview:_image];
}

- (void)setupTitle
{
    NSString *color = @"#6b6b6b";
    _title = [UILabel new];
    _title.translatesAutoresizingMaskIntoConstraints = NO;
    _title.font = [UIFont fontWithName:@"Montserrat-Bold" size:18];
    _title.textColor = [UIColor colorWithHexString:color];
    _title.textAlignment = NSTextAlignmentCenter;
    _title.numberOfLines = 0;
    [self addSubview:_title];
}

- (void)setupLayout
{
    if (_constraints)
        [self removeConstraints:_constraints];
    
    _constraints = [@[] mutableCopy];

    NSDictionary *views = NSDictionaryOfVariableBindings(_image, _title);
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==20)-[_image(==80)]-(==20)-[_title]-|" options:0 metrics:nil views:views];
    [_constraints addObjectsFromArray:verticalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view" : view}];
        [_constraints addObjectsFromArray:horizontalConstraints];
    }

    [self addConstraints:_constraints];
}

- (void)loadImageFromUrl:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@_store_small", kCCLinotteStaticServer, urlString]];
    [_image setImageWithURL:url placeholderImage:[UIImage imageNamed:@"list_pin_neutral"]];
}

#pragma mark - setter methods

- (void)setImage:(UIImage *)image
{
    _image.image = image;
}

- (void)setTitle:(NSString *)title
{
    _title.text = title;
}

@end
