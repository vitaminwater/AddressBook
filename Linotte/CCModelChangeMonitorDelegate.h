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

- (void)listWillExpand:(CCList *)list fromNetwork:(BOOL)fromNetwork;
- (void)listDidExpand:(CCList *)list fromNetwork:(BOOL)fromNetwork;
- (void)listWillReduce:(CCList *)list fromNetwork:(BOOL)fromNetwork;
- (void)listDidReduce:(CCList *)list fromNetwork:(BOOL)fromNetwork;

- (void)listDidAdd:(CCList *)list fromNetwork:(BOOL)fromNetwork;

- (void)listWillRemove:(CCList *)list fromNetwork:(BOOL)fromNetwork;
- (void)listDidRemove:(NSString *)identifier fromNetwork:(BOOL)fromNetwork;

- (void)listDidUpdate:(CCList *)list fromNetwork:(BOOL)fromNetwork;

- (void)addressDidAdd:(CCAddress *)address fromNetwork:(BOOL)fromNetwork;

- (void)addressWillRemove:(CCAddress *)address fromNetwork:(BOOL)fromNetwork;
- (void)addressDidRemove:(NSString *)identifier fromNetwork:(BOOL)fromNetwork;

- (void)addressDidUpdate:(CCAddress *)address fromNetwork:(BOOL)fromNetwork;
- (void)addressDidUpdateUserData:(CCAddress *)address fromNetwork:(BOOL)fromNetwork;

- (void)address:(CCAddress *)address willMoveToList:(CCList *)list fromNetwork:(BOOL)fromNetwork;
- (void)address:(CCAddress *)address didMoveToList:(CCList *)list fromNetwork:(BOOL)fromNetwork;
- (void)address:(CCAddress *)address willMoveFromList:(CCList *)list fromNetwork:(BOOL)fromNetwork;
- (void)address:(CCAddress *)address didMoveFromList:(CCList *)list fromNetwork:(BOOL)fromNetwork;

@end
