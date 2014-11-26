//
//  CCHomeListViewModel.h
//  Linotte
//
//  Created by stant on 13/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListViewModel.h"

#import "CCListViewModelProtocol.h"
#import "CCModelChangeMonitorDelegate.h"

@interface CCBookAndNotifiedListViewModel : CCListViewModel<CCListViewModelProtocol, CCModelChangeMonitorDelegate>

@end
