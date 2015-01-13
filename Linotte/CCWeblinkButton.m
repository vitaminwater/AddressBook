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
        
        self.titleLabel.font = [UIFont fontWithName:@"Futura-Book" size:15];
        [self setTitle:_link forState:UIControlStateNormal];
        [self setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
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
