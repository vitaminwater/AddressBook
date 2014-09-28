//
//  CCTween.m
//  Linotte
//
//  Created by stant on 28/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCTimelineConstraintAnimation.h"

/**
 * 
 * CCTimeLineConstraintAnimation item
 *
 */

@interface CCTimeLineConstraintAnimationItem : NSObject

@property(nonatomic, assign)CGFloat progressFrom;
@property(nonatomic, assign)CGFloat progressTo;

@property(nonatomic, assign)CGFloat valueFrom;
@property(nonatomic, assign)CGFloat valueTo;

@property(nonatomic, strong)NSLayoutConstraint *constraint;

@end

@implementation CCTimeLineConstraintAnimationItem

- (void)processProgress:(CGFloat)progress
{
    if (progress < _progressFrom) {
        _constraint.constant = _valueFrom;
        return;
    }
    
    if (progress > _progressTo) {
        _constraint.constant = _valueTo;
        return;
    }
    
    CGFloat progressDelta = _progressTo - _progressFrom;
    CGFloat progressRatio = (progress - _progressFrom) / progressDelta;
    CGFloat valueDelta = _valueTo - _valueFrom;
    _constraint.constant = _valueFrom + valueDelta * progressRatio;
}

@end


/**
 *
 * CCTimelineConstraintAnimation implementation
 *
 */

@implementation CCTimelineConstraintAnimation
{
    NSMutableArray *_items;
}

- (id)init
{
    self = [super init];
    if (self) {
        _items = [@[] mutableCopy];
    }
    return self;
}

- (void)addTimeLineConstraintAnimationItem:(CGFloat)progressFrom progressTo:(CGFloat)progressTo valueFrom:(CGFloat)valueFrom valueTo:(CGFloat)valueTo constraint:(NSLayoutConstraint *)constraint
{
    CCTimeLineConstraintAnimationItem *item = [CCTimeLineConstraintAnimationItem new];
    item.progressFrom = progressFrom;
    item.progressTo = progressTo;
    item.valueFrom = valueFrom;
    item.valueTo = valueTo;
    item.constraint = constraint;
    
    NSUInteger index = [_items indexOfObject:item inSortedRange:(NSRange){0, [_items count]} options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(CCTimeLineConstraintAnimationItem *item1, CCTimeLineConstraintAnimationItem *item2) {
        if (item1.progressFrom == item2.progressFrom)
            return NSOrderedSame;
        
        if (item1.progressFrom < item2.progressFrom)
            return NSOrderedAscending;
        return NSOrderedDescending;
    }];
    
    [_items insertObject:item atIndex:index];
}

#pragma mark - setter methods

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    
    for (CCTimeLineConstraintAnimationItem *item in _items) {
        [item processProgress:progress];
    }
}

@end
