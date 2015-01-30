//
//  CCNoteView.h
//  Linotte
//
//  Created by stant on 29/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCNoteView : UIView

@property(nonatomic, strong)NSString *text;
@property(nonatomic, weak)id<UITextViewDelegate> delegate;

@end
