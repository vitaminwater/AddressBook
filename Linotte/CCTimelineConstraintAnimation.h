//
//  CCTween.h
//  Linotte
//
//  Created by stant on 28/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCTimelineConstraintAnimation : NSObject

@property(nonatomic, assign)CGFloat progress;

- (void)addTimeLineConstraintAnimationItem:(CGFloat)progressFrom progressTo:(CGFloat)progressTo valueFrom:(CGFloat)valueFrom valueTo:(CGFloat)valueTo constraint:(NSLayoutConstraint *)constraint;

@end
