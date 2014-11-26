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

@class CCListMeta;

@protocol CCModelChangeMonitorDelegate <NSObject>

@optional

- (void)listsDidAdd:(NSArray *)lists send:(BOOL)send;

- (void)listsWillRemove:(NSArray *)lists send:(BOOL)send;
- (void)listsDidRemove:(NSArray *)identifiers send:(BOOL)send;

- (void)listsDidUpdate:(NSArray *)lists send:(BOOL)send;
- (void)listsWillUpdateUserData:(NSArray *)lists send:(BOOL)send;
- (void)listsDidUpdateUserData:(NSArray *)lists send:(BOOL)send;

- (void)addressesDidUpdate:(NSArray *)addresses send:(BOOL)send;
- (void)addressesWillUpdateUserData:(NSArray *)addresses send:(BOOL)send;
- (void)addressesDidUpdateUserData:(NSArray *)addresses send:(BOOL)send;

- (void)addresses:(NSArray *)addresses willMoveToList:(CCList *)list send:(BOOL)send;
- (void)addresses:(NSArray *)addresses didMoveToList:(CCList *)list send:(BOOL)send;
- (void)addresses:(NSArray *)addresses willMoveFromList:(CCList *)list send:(BOOL)send;
- (void)addresses:(NSArray *)addresses didMoveFromList:(CCList *)list send:(BOOL)send;

- (void)listMetasAdd:(NSArray *)listMetas;
- (void)listMetasUpdate:(NSArray *)listMetas;
- (void)listMetasRemove:(NSArray *)listMetas;

- (void)addressMetasAdd:(NSArray *)addressMetas;
- (void)addressMetasUpdate:(NSArray *)addressMetas;
- (void)addressMetasRemove:(NSArray *)addressMetas;

- (void)addressesDidNotify:(NSArray *)addresses;

@end
