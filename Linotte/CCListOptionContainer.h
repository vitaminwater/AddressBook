//
//  CCListOptionContainer.h
//  Linotte
//
//  Created by stant on 15/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCListOptionContainer : UIView<UIScrollViewDelegate>

@property(nonatomic, readonly)NSArray *buttons;

- (void)addButtonWithIcon:(UIImage *)icon title:(NSString *)title titleColor:(UIColor *)titleColor target:(id)target action:(SEL)action;

@end
