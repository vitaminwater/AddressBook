//
//  CCListItemsDelegate.h
//  Linotte
//
//  Created by stant on 10/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCList;

@protocol CCListItemsDelegate <NSObject>

- (void)listItemSelected:(CCList *)list;
- (void)addressItemSelected:(CCList *)list;

@end
