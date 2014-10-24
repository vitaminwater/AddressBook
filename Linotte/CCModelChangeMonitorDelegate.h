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

- (void)listWillExpand:(CCList *)list;
- (void)listDidExpand:(CCList *)list;
- (void)listWillReduce:(CCList *)list;
- (void)listDidReduce:(CCList *)list;

- (void)listDidAdd:(CCList *)list;

- (void)listWillRemove:(CCList *)list;
- (void)listDidRemove:(NSString *)identifier;

- (void)listDidUpdate:(CCList *)list;

- (void)addressDidAdd:(CCAddress *)address;

- (void)addressWillRemove:(CCAddress *)address;
- (void)addressDidRemove:(NSString *)identifier;

- (void)addressDidUpdate:(CCAddress *)address;
- (void)addressDidUpdateUserData:(CCAddress *)address;

- (void)address:(CCAddress *)address willMoveToList:(CCList *)list;
- (void)address:(CCAddress *)address didMoveToList:(CCList *)list;
- (void)address:(CCAddress *)address willMoveFromList:(CCList *)list;
- (void)address:(CCAddress *)address didMoveFromList:(CCList *)list;

@end
