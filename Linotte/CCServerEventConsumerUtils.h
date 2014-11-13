//
//  CCServerEventConsumerUtils.h
//  Linotte
//
//  Created by stant on 12/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CCServerEvent.h"

@interface CCServerEventConsumerUtils : NSObject

+ (NSArray *)eventsWithEventType:(CCServerEventEvent)event list:(CCList *)list;
+ (void)deleteEvents:(NSArray *)events;

@end
