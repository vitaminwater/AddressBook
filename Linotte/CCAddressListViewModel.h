//
//  CCAddressListViewModel.h
//  Linotte
//
//  Created by stant on 24/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListViewModel.h"

#import "CCListViewModelProtocol.h"
#import "CCModelChangeMonitorDelegate.h"

@interface CCAddressListViewModel : CCListViewModel<CCListViewModelProtocol, CCModelChangeMonitorDelegate>

@end
