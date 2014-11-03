//
//  CCListSynchronizationAction.h
//  Linotte
//
//  Created by stant on 02/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class CCList;

@protocol  CCListSynchronizationActionProtocol<NSObject>

- (void)performSynchronizationWithCompletionBlock:(void(^)())completionBlock;

@end

@interface CCListSynchronizationProcessor : NSObject

@property(nonatomic, strong)CCList *list;
@property(nonatomic, readonly)NSInteger priority;
@property(nonatomic, readonly)NSObject<CCListSynchronizationActionProtocol> *synchronizationAction;

- (instancetype)initWithList:(CCList *)list currentLocation:(CLLocationCoordinate2D)currentLocation;

@end
