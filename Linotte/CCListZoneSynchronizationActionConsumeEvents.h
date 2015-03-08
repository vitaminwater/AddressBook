//
//  CCListZoneSynchronizationActionConsumeEvents.h
//  Linotte
//
//  Created by stant on 17/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCBaseSynchronizationActionConsumeEvents.h"

@class CCList;
@class CCListZone;

void fetchListEventsProcess(CCList *list, CCListZone *listZone, NSArray *eventsDicts);

@interface CCListZoneSynchronizationActionConsumeEvents : CCBaseSynchronizationActionConsumeEvents<CCSynchronizationActionConsumeEventsProviderProtocol>

@end
