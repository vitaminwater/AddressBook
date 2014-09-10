//
//  CCFlatColorButton.m
//  AdRem
//
//  Created by stant on 07/02/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCFlatColorButton.h"

@interface CCFlatColorButton()
{
    NSMutableDictionary *_colors;
}

@end

@implementation CCFlatColorButton

static void *context = &context;

- (id)init
{
    self = [super init];
    if (self) {
        _colors = [@{} mutableCopy];
        [self addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:context];
        [self addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:context];
        [self addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:context];
    }
    return self;
}

- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state
{
    if (color == nil)
        [_colors removeObjectForKey:@(state)];
    else
        _colors[@(state)] = color;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"highlighted"] ||
        [keyPath isEqualToString:@"selected"] ||
        [keyPath isEqualToString:@"enabled"]) {
        UIColor *color = _colors[@(self.state)];
        if (color != nil)
            self.backgroundColor = color;
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    if (self.state == UIControlStateNormal && _colors[@(UIControlStateNormal)] == nil)
        _colors[@(UIControlStateNormal)] = backgroundColor;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"highlighted" context:context];
    [self removeObserver:self forKeyPath:@"selected" context:context];
    [self removeObserver:self forKeyPath:@"enabled" context:context];
}

@end
