//
//  CCNoteView.m
//  Linotte
//
//  Created by stant on 29/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCNoteView.h"

@implementation CCNoteView
{
    UILabel *_titleLabel;
    UITextView *_textView;
}

@dynamic text;
@dynamic delegate;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self setupTitleLabel];
        [self setupTextView];
        [self setupLayout];
    }
    return self;
}

- (void)setupTitleLabel
{
    _titleLabel = [UILabel new];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.text = NSLocalizedString(@"NOTE_VIEW_TITLE", @"");
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:25];
    [self addSubview:_titleLabel];
}

- (void)setupTextView
{
    _textView = [UITextView new];
    _textView.translatesAutoresizingMaskIntoConstraints = NO;
    _textView.backgroundColor = [UIColor clearColor];
    _textView.textColor = [UIColor whiteColor];
    _textView.font = [UIFont fontWithName:@"Futura-Book" size:21];
    [_textView setTintColor:[UIColor whiteColor]];
    [self addSubview:_textView];
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_titleLabel, _textView);
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_titleLabel][_textView]|" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
        [self addConstraints:horizontalConstraints];
    }
}

- (void)didMoveToSuperview
{
    if (self.superview == nil)
        return;
    if ([_textView.text isEqualToString:@""])
        [_textView becomeFirstResponder];
}

#pragma mark - setter/getter methods

- (NSString *)text
{
    return _textView.text;
}

- (void)setText:(NSString *)text
{
    _textView.text = text;
}

- (id<UITextViewDelegate>)delegate
{
    return _textView.delegate;
}

- (void)setDelegate:(id<UITextViewDelegate>)delegate
{
    _textView.delegate = delegate;
}

@end
