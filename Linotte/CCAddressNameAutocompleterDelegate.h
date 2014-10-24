//
//  CCAddressNameAutocompleterDelegate.h
//  Linotte
//
//  Created by stant on 22/10/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCAddressNameAutocompleterDelegate <NSObject>

- (void)autocompeteWaitingLocation:(id)sender;
- (void)autocompleteStarted:(id)sender;
- (void)autocompleteResultsRecieved:(id)sender;
- (void)autocompleteEnded:(id)sender;

@end
