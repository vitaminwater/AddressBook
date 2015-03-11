//
//  CCListStoreTableViewCell.m
//  Linotte
//
//  Created by stant on 09/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListStoreTableViewCell.h"

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <HexColors/HexColor.h>

@implementation CCListStoreTableViewCell
{
    UIImageView *_image;
    UILabel *_title;
    UILabel *_info;
    
    NSMutableArray *_constraints;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
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
    _title = [UILabel new];
    _title.translatesAutoresizingMaskIntoConstraints = NO;
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
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==8)-[_image(==100)]-(==3)-[_title]-|" options:0 metrics:nil views:views];
    [_constraints addObjectsFromArray:horizontalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==5)-[view]-(==5)-|" options:0 metrics:nil views:@{@"view" : view}];
        [_constraints addObjectsFromArray:verticalConstraints];
    }

    [self addConstraints:_constraints];
}

- (void)loadImageFromUrl:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@_store_small", kCCLinotteStaticServer, urlString]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    [_image setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"list_pin_neutral"] success:nil failure:nil];
}

#pragma mark - setter methods

- (void)setImage:(UIImage *)image
{
    _image.image = image;
}

- (void)setTitle:(NSString *)title author:(NSString *)author
{
    NSMutableAttributedString *attributedString = [NSMutableAttributedString new];
    
    NSAttributedString *nameAttributedString = [[NSAttributedString alloc] initWithString:[title stringByAppendingString:@"\n"] attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Montserrat-Bold" size:18], NSForegroundColorAttributeName : [UIColor darkGrayColor]}];
    NSAttributedString *authorAttributedString = [[NSAttributedString alloc] initWithString:[@"by " stringByAppendingString:author] attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Futura-Book" size:16], NSForegroundColorAttributeName : [UIColor grayColor]}];
    
    [attributedString appendAttributedString:nameAttributedString];
    [attributedString appendAttributedString:authorAttributedString];
    
    [_title setAttributedText:attributedString];
}

@end
