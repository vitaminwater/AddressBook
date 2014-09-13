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

@protocol CCListViewModelProtocol <NSObject>

@required

- (void)loadListItems:(CCListViewContentProvider *)provider;

- (void)expandList:(CCList *)list;
- (void)reduceList:(CCList *)list;

@end
