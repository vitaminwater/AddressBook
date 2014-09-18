//
//  CCOutputViewControllerDelegate.h
//  Linotte
//
//  Created by stant on 13/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCList;
@class CCAddress;

@protocol CCOutputViewControllerDelegate <NSObject>

- (void)address:(CCAddress *)address movedToList:(CCList *)list;
- (void)address:(CCAddress *)address movedFromList:(CCList *)list;
- (void)addressNotificationChanged:(CCAddress *)address;

- (void)listCreated:(CCList *)list;

@end
