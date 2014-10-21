//
//  CCTween.m
//  Linotte
//
//  Created by stant on 28/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAnimationDelegator.h"

/**
 * 
 * CCTimeLineConstraintAnimation item
 *
 */

@interface CCAnimationDelegatorItem : NSObject

@property(nonatomic, copy)CCAnimatorAnimationBlock animationBlock;
@property(nonatomic, copy)CCAnimatorFingerLiftBlock fingerLiftBlock;

@end



@implementation CCAnimationDelegatorItem
{
    CGFloat _lastValue;
}

- (BOOL)callAnimationBlock:(CGFloat)value
{
    return _animationBlock(value);
}

- (void)callFingerLiftBlock
{
    _fingerLiftBlock();
}

@end






/**
 *
 * CCTimelineConstraintAnimation implementation
 *
 */

@implementation CCAnimationDelegator
{
    NSMutableDictionary *_items;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _items = [@{} mutableCopy];
    }
    return self;
}

- (void)setTimeLineAnimationItemForKey:(NSString *)key animationBlock:(CCAnimatorAnimationBlock)animationBlock fingerLiftBlock:(CCAnimatorFingerLiftBlock)fingerLiftBlock
{
    CCAnimationDelegatorItem *item = [CCAnimationDelegatorItem new];
    item.animationBlock = animationBlock;
    item.fingerLiftBlock = fingerLiftBlock;
    _items[key] = item;
}

- (void)fingerLifted
{
    for (CCAnimationDelegatorItem *item in _items.allValues) {
        [item callFingerLiftBlock];
    }
}

- (BOOL)fingerMoved:(CGFloat)pixel
{
    BOOL updated = NO;
    for (CCAnimationDelegatorItem *item in _items.allValues) {
        updated |= [item callAnimationBlock:pixel];
    }
    return updated;
}

@end
