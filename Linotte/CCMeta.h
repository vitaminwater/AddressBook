//
//  CCMeta.h
//  Linotte
//
//  Created by stant on 27/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCMetaProtocol.h"

@interface CCMeta : NSObject<CCMetaProtocol>

+ (instancetype)metaWithAction:(NSString *)action uid:(NSString *)uid content:(NSDictionary *)content;

@end
