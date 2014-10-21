//
//  CCTween.h
//  Linotte
//
//  Created by stant on 28/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef BOOL(^CCAnimatorAnimationBlock)(CGFloat value);
typedef void(^CCAnimatorFingerLiftBlock)();

@interface CCAnimationDelegator : NSObject

- (void)setTimeLineAnimationItemForKey:(NSString *)key animationBlock:(CCAnimatorAnimationBlock)animationBlock fingerLiftBlock:(CCAnimatorFingerLiftBlock)fingerLiftBlock;

- (void)fingerLifted;
- (BOOL)fingerMoved:(CGFloat)pixel;

@end
