//
//  CCIdentifierModel.h
//  Linotte
//
//  Created by stant on 04/10/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCIdentifierModel : NSObject

@property(nonatomic, strong)NSString *identifier;

- (instancetype)initWithIdentifier:(NSString *)identifier;

@end
