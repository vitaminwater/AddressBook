//
//  CCSynchronizationActionInitialFetch.h
//  Linotte
//
//  Created by stant on 10/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CCSynchronizationActionProtocol.h"

#import "CCModelChangeMonitorDelegate.h"

@interface CCSynchronizationActionInitialFetch : NSObject<CCModelChangeMonitorDelegate, CCSynchronizationActionProtocol>

@end
