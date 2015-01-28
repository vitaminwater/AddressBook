//
//  CCSocialMeta.m
//  Linotte
//
//  Created by stant on 06/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCSocialMeta.h"

#import "CCMetaProtocol.h"

#import "CCFacebookSocialButton.h"
#import "CCTwitterSocialButton.h"
#import "CCPinterestSocialButton.h"
#import "CCFoursquareSocialButton.h"

@implementation CCSocialMeta
{
    NSMutableArray *_socialSiteButtons;
    
    NSMutableArray *_constraints;
}

- (instancetype)initWithMeta:(id<CCMetaProtocol>)meta
{
    self = [super initWithMeta:meta];
    if (self) {
        [self setupContent];
    }
    return self;
}

- (void)setupContent
{
    [self setupButtons];
    [self setupLayout];
}

- (void)setupButtons
{
    _socialSiteButtons = [@[] mutableCopy];
    
    if (self.meta.content[@"facebook"] != nil) {
        [self addSocialSiteButton:[[CCFacebookSocialButton alloc] initWithUserName:self.meta.content[@"facebook"]]];
    }
    if (self.meta.content[@"twitter"] != nil) {
        [self addSocialSiteButton:[[CCTwitterSocialButton alloc] initWithUserName:self.meta.content[@"twitter"]]];
    }
    if (self.meta.content[@"pinterest"] != nil) {
        [self addSocialSiteButton:[[CCPinterestSocialButton alloc] initWithUserName:self.meta.content[@"pinterest"]]];
    }
    if (self.meta.content[@"foursquare"] != nil) {
        [self addSocialSiteButton:[[CCFoursquareSocialButton alloc] initWithUserName:self.meta.content[@"foursquare"]]];
    }
}

- (void)addSocialSiteButton:(UIButton *)button
{
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    [_socialSiteButtons addObject:button];
}

- (void)setupLayout
{
    if (_constraints != nil)
        [self removeConstraints:_constraints];
    _constraints = [@[] mutableCopy];
    
    if ([_socialSiteButtons count] == 0)
        return;
    
    NSMutableDictionary *views = [@{} mutableCopy];
    
    NSUInteger index = 0;
    NSMutableString *format = [@"H:|-" mutableCopy];
    for (UIView *view in _socialSiteButtons) {
        NSString *key = [NSString stringWithFormat:@"view%d", (unsigned int)index];
        [views setValue:view forKey:key];
        [format appendFormat:@"[%@]-", key];
        ++index;
        
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[view]-|" options:0 metrics:nil views:@{@"view" : view}];
        [_constraints addObjectsFromArray:verticalConstraints];
    }
    [format deleteCharactersInRange:(NSRange){[format length] - 1, 1}];
    
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:0 views:views];
    [_constraints addObjectsFromArray:horizontalConstraints];
    
    [self addConstraints:_constraints];
}

#pragma mark - UIButton target methods

- (void)buttonPressed:(id<CCSocialButtonProtocol>)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCCShowBrowserNotification object:[sender socialAccountUrl]];
}

#pragma mark - CCBaseMetaWidgetProtocol methods

- (void)updateContent
{
    for (UIView *view in _socialSiteButtons) {
        [view removeFromSuperview];
    }
    [_socialSiteButtons removeAllObjects];
    
    [self setupContent];
}

+ (NSString *)action
{
    return @"social";
}

@end
