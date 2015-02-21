//
//  CCLinotteBrowserView.h
//  Linotte
//
//  Created by stant on 06/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCLinotteBrowserViewDelegate.h"

@interface CCLinotteBrowserView : UIView<UIWebViewDelegate>

@property(nonatomic, weak)id<CCLinotteBrowserViewDelegate> delegate;

- (void)loadRootUrl:(NSString *)rootUrl;

@end
