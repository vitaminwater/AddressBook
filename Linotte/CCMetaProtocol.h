//
//  CCMetaProtocol.h
//  Linotte
//
//  Created by stant on 27/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCMetaProtocol <NSObject>

@property (nonatomic, strong)NSString *action;
@property (nonatomic, strong)NSString *uid;
@property (nonatomic, strong)id content;

@end
