//
//  CCLinotteUrlCommand.h
//  Linotte
//
//  Created by stant on 12/03/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCLinotteUrlCommand <NSObject>

@property(nonatomic, readonly)NSString *match;

- (void)execute:(NSArray *)args;

@end
