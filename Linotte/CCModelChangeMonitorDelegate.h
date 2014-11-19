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

- (void)listDidAdd:(CCList *)list send:(BOOL)send;

- (void)listWillRemove:(CCList *)list send:(BOOL)send;
- (void)listDidRemove:(NSString *)identifier send:(BOOL)send;

- (void)listDidUpdate:(CCList *)list send:(BOOL)send;
- (void)listDidUpdateUserData:(CCList *)list send:(BOOL)send;

- (void)addressesDidUpdate:(NSArray *)addresses send:(BOOL)send;
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

@end
