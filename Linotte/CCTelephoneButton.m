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
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    return self;
}

#pragma mark - CCContactButtonProtocol methods

- (void)buttonPressed
{
    NSString *cleanNumber = [[_number componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
    NSString *dialstring = [[NSString alloc] initWithFormat:@"tel:%@", cleanNumber];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:dialstring]];
}

@end
