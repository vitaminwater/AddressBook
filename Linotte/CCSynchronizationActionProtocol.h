//
//  CCSynchronizationActionProtocol.h
//  Linotte
//
//  Created by stant on 10/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

@class CCList;

typedef void(^CCSynchronizationCompletionBlock)(BOOL goOnSyncing, BOOL error);

@protocol CCSynchronizationActionProtocol <NSObject>

- (void)triggerWithList:(CCList *)list coordinates:(CLLocationCoordinate2D)coordinates completionBlock:(CCSynchronizationCompletionBlock)completionBlock;

@end
