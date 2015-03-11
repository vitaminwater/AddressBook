//
//  CCListOutputViewDelegate.h
//  Linotte
//
//  Created by stant on 10/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCListOutputViewDelegate <NSObject>

- (void)notificationEnabled:(BOOL)enabled;
- (void)filterList:(NSString *)filterText;

@end
