//
//  CCAutocomplete.h
//  AdRem
//
//  Created by stant on 23/01/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCGoogleAutocomplete : NSObject

@property(nonatomic, strong)NSString *status;
@property(nonatomic, strong)NSArray *predictions;

@end
