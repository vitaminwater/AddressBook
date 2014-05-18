//
//  CCMainView.h
//  Linotte
//
//  Created by stant on 07/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCMainView : UIView

@property(nonatomic, assign)BOOL addViewExpanded;

- (void)setupAddView:(UIView *)addView;
- (void)setupListView:(UIView *)listView;

@end
