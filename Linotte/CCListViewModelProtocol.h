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

@end
