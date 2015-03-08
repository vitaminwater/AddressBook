//
//  CCSynchronizationActionMergeZone.h
//  Linotte
//
//  Created by stant on 04/03/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCSynchronizationActionProtocol.h"

#import "CCModelChangeMonitorDelegate.h"

@interface CCSynchronizationActionMergeZones : NSObject<CCModelChangeMonitorDelegate, CCSynchronizationActionProtocol>

@end
