//
//  CCEmailButton.m
//  Linotte
//
//  Created by stant on 06/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCEmailButton.h"

@implementation CCEmailButton
{
    NSString *_email;
}

- (instancetype)initWithEmail:(NSString *)email
{
    self = [super init];
    if (self) {
        _email = email;
        
        self.titleLabel.font = [UIFont fontWithName:@"Futura-Book" size:18];
        [self setTitle:_email forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    return self;
}

#pragma mark - CCContactButtonProtocol methods

- (void)buttonPressed
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCCShowEmailNotification object:@{@"email" : _email}];
}

@end
