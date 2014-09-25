//
//  CCModelChangeMonitorProtocol.h
//  Linotte
//
//  Created by stant on 23/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCAddress;
@class CCList;

@protocol CCModelChangeMonitorDelegate <NSObject>

@optional

- (void)expandList:(CCList *)list;
- (void)reduceList:(CCList *)list;

- (void)addList:(CCList *)list;
- (void)removeList:(CCList *)list;
- (void)updateList:(CCList *)list;

- (void)addAddress:(CCAddress *)address;
- (void)removeAddress:(CCAddress *)address;
- (void)updateAddress:(CCAddress *)address;

- (BOOL)address:(CCAddress *)address movedToList:(CCList *)list;
- (BOOL)address:(CCAddress *)address movedFromList:(CCList *)list;

@end
