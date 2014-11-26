//
//  CCStreetAddressAutoComplete.h
//  Linotte
//
//  Created by stant on 24/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCBaseAutoComplete.h"

@interface CCStreetAddressAutoComplete : CCBaseAutoComplete

- (void)fetchCompleteInfosForResultAtIndex:(NSUInteger)index completionBlock:(void(^)(CCAddressAutocompletionResult *result))completionBlock;

@end
