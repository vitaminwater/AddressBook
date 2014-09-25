//
//  CCListOutputListViewModel.h
//  Linotte
//
//  Created by stant on 13/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListViewModelProtocol.h"
#import "CCListViewModel.h"

#import "CCModelChangeMonitorDelegate.h"

@interface CCListOutputListViewModel : CCListViewModel<CCListViewModelProtocol, CCModelChangeMonitorDelegate>

- (id)initWithList:(CCList *)list;

@end
