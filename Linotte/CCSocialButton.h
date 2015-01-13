//
//  CCSocialButton.h
//  Linotte
//
//  Created by stant on 06/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCSocialButton : UIButton

@property(nonatomic, readonly)NSString *userName;

- (id)initWithUserName:(NSString *)userName;

@end
