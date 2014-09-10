//
//  CCOutputViewDelegate.h
//  Linotte
//
//  Created by stant on 12/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    CCRouteTypeTrain,
    CCRouteTypeCar,
    CCRouteTypeBicycling,
    CCRouteTypeWalk
} CCRouteType;

@protocol CCOutputViewDelegate <NSObject>

// list stuffs
- (NSUInteger)createListWithName:(NSString *)name;
- (void)removeListAtIndex:(NSUInteger)index;
- (void)listSelectedAtIndex:(NSUInteger)index;
- (void)listUnselectedAtIndex:(NSUInteger)index;
- (BOOL)isListSelectedAtIndex:(NSUInteger)index;

- (NSUInteger)numberOfLists;
- (NSString *)listNameAtIndex:(NSUInteger)index;
- (NSString *)listIconAtIndex:(NSUInteger)index;

- (NSString *)currentListNames;

// route
- (void)launchRoute:(CCRouteType)type;

// address display
- (double)addressDistance;
- (NSString *)addressName;
- (NSString *)addressString;
- (NSString *)addressProvider;
- (double)addressLatitude;
- (double)addressLongitude;
- (BOOL)notificationEnabled;

- (void)setNotificationEnabled:(BOOL)enable;

@end
