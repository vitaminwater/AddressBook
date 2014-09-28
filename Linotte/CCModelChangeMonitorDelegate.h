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
- (void)listExpanded:(CCList *)list;
- (void)listWillReduce:(CCList *)list;
- (void)listReduced:(CCList *)list;

- (void)listAdded:(CCList *)list;

- (void)listWillRemove:(CCList *)list;
- (void)listRemoved:(CCList *)list;

- (void)listUpdated:(CCList *)list;

- (void)addressAdded:(CCAddress *)address;
- (void)addressRemoved:(CCAddress *)address;
- (void)addressUpdated:(CCAddress *)address;

- (BOOL)address:(CCAddress *)address willMoveToList:(CCList *)list;
- (BOOL)address:(CCAddress *)address didMoveToList:(CCList *)list;
- (BOOL)address:(CCAddress *)address willMoveFromList:(CCList *)list;
- (BOOL)address:(CCAddress *)address didMoveFromList:(CCList *)list;

@end
