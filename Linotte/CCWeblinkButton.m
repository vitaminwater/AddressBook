//
//  CCWeblinkButton.m
//  Linotte
//
//  Created by stant on 06/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCWeblinkButton.h"

@implementation CCWeblinkButton
{
    NSString *_link;
}

- (instancetype)initWithLink:(NSString *)link
{
    self = [super init];
    if (self) {
        _link = link;
        self.backgroundColor = [UIColor clearColor];
        [self setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.2] forState:UIControlStateHighlighted];
        
        NSString *domain = [[NSURL URLWithString:_link] host];
        if (domain == nil)
            domain = _link;
        self.titleLabel.font = [UIFont fontWithName:@"Futura-Book" size:18];
        [self setTitle:domain forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    return self;
}

#pragma mark - CCContactButtonProtocol methods

- (void)buttonPressed
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCCShowBrowserNotification object:_link];
}

@end
