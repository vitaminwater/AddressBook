//
//  CCListViewContentProviderDelegate.h
//  Linotte
//
//  Created by stant on 20/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCListViewContentProviderDelegate <NSObject>

- (void)refreshCellsAtIndexes:(NSIndexSet *)indexSet;
- (void)insertCellsAtIndexes:(NSIndexSet *)indexSet;
- (void)removeCellsAtIndexes:(NSIndexSet *)indexSet;

- (void)sortOrderChanged;

@end
