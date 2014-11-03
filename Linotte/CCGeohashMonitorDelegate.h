//
//  CCGeohashMonitorDelegate.h
//  Linotte
//
//  Created by stant on 14/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCGeohashMonitorDelegate <NSObject>

- (void)didEnterGeohashes:(NSArray *)geohash;

@end
