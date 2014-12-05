//
//  CCTelephoneButton.m
//  Linotte
//
//  Created by stant on 04/12/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCTelephoneButton.h"

@implementation CCTelephoneButton
{
    NSString *_number;
}

- (instancetype)initWithNumber:(id)number
{
    self = [super init];
    if (self) {
        _number = [NSString stringWithFormat:@"%@", number];
        
        self.titleLabel.font = [UIFont fontWithName:@"Futura-Book" size:15];
        [self setTitle:_number forState:UIControlStateNormal];
        [self setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    return self;
}

- (void)buttonPressed
{
    NSString *dialstring = [[NSString alloc] initWithFormat:@"tel:%@", _number];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:dialstring]];
}

@end
