//
//  CCPicsMeta.m
//  Linotte
//
//  Created by stant on 27/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCPhotoMeta.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

#define kCCSpacing 5

@implementation CCPhotoMeta
{
    NSMutableArray *_photos;
}

- (instancetype)initWithMeta:(id<CCMetaProtocol>)meta
{
    self = [super initWithMeta:meta];
    if (self) {
        [self setupPhotos];
    }
    return self;
}

- (void)setupPhotos
{
    _photos = [@[] mutableCopy];
    
    NSArray *photoDicts = self.meta.content;
    for (NSDictionary *photosDict in photoDicts) {
        UIImageView *imageView = [UIImageView new];
        NSURL *url = [NSURL URLWithString:photosDict[@"url"]];
        [imageView setImageWithURL:url];
    }
}

- (void)layoutSubviews
{
    CGRect bounds = self.bounds;
    CGFloat spacing = kCCSpacing;
    CGFloat edge = bounds.size.width / 3 - spacing * 4;
    
    for (int i = 0; i < [_photos count]; ++i) {
        UIView *photo = _photos[i];
        CGRect imageFrame = CGRectMake(spacing + (edge + spacing) * (i % 2), spacing + (edge + spacing) * (i / 3), edge, edge);
        photo.frame = imageFrame;
    }
}

- (CGSize)intrinsicContentSize
{
    CGRect bounds = self.bounds;
    CGFloat spacing = kCCSpacing;
    CGFloat edge = bounds.size.width / 3 - spacing * 4;
    NSUInteger rows = [_photos count] / 3 + 1;
    return CGSizeMake(bounds.size.width, spacing + (edge + spacing) * rows);
}

#pragma mark - CCBaseMetaWidgetProtocol methods

- (void)updateContent
{
    
}

+ (NSString *)action
{
    return @"photo";
}

@end
