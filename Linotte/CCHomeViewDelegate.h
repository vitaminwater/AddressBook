//
//  CCMainViewDelegate.h
//  Linotte
//
//  Created by stant on 13/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    CCHomeViewPanelMyAddresses = 0,
    CCHomeViewPanelMyBooks = 1,
    CCHomeViewPanelLastNotification = 2,
} CCHomeViewPanel;

@protocol CCHomeViewDelegate <NSObject>

- (void)homePanelSelected:(CCHomeViewPanel)viewPanel;
- (void)filterList:(NSString *)filterText;

@end
