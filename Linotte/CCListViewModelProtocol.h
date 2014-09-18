//
//  CCListViewModelProtocol.h
//  Linotte
//
//  Created by stant on 13/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCList;
@class CCListViewContentProvider;

@class CCAddress;

@protocol CCListViewModelProtocol <NSObject>

@required

@property(nonatomic, assign)CCListViewContentProvider *provider;

- (void)loadListItems;

- (void)expandList:(CCList *)list;
- (void)reduceList:(CCList *)list;

- (void)addAddress:(CCAddress *)address;
- (void)removeAddress:(CCAddress *)address;

- (void)addList:(CCList *)list;
- (void)removeList:(CCList *)list;

- (BOOL)address:(CCAddress *)address movedToList:(CCList *)list;
- (BOOL)address:(CCAddress *)address movedFromList:(CCList *)list;

@end
