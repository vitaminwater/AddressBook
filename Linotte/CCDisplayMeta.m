//
//  CCDisplayMeta.m
//  Linotte
//
//  Created by stant on 27/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCDisplayMeta.h"

@implementation CCDisplayMeta
{
    UITextView *_textView;
}

- (instancetype)initWithMeta:(id<CCMetaProtocol>)meta
{
    self = [super initWithMeta:meta];
    if (self) {
        [self setupLabels];
        [self setupLayout];
    }
    return self;
}

- (void)setupLabels
{
    _textView = [UITextView new];
    _textView.translatesAutoresizingMaskIntoConstraints = NO;
    _textView.scrollEnabled = NO;
    _textView.backgroundColor = [UIColor clearColor];
    _textView.textContainer.lineFragmentPadding = 0;
    _textView.textContainerInset = UIEdgeInsetsZero;
    [self addSubview:_textView];
    
    [self updateContent];
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_textView);
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_textView]|" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
    
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_textView]|" options:0 metrics:nil views:views];
    [self addConstraints:horizontalConstraints];
}

#pragma mark - CCBaseMetaWidgetProtocol methods

- (void)updateContent
{
    _textView.text = @"";
    
    NSMutableAttributedString *content = [NSMutableAttributedString new];
    for (NSString *title in ((NSDictionary *)self.meta.content).allKeys) {
        id bodyId = ((NSDictionary *)self.meta.content)[title];
        NSString *body;
        
        if ([bodyId isKindOfClass:[NSNumber class]])
            body = [(NSNumber *)bodyId stringValue];
        else if ([bodyId isKindOfClass:[NSString class]])
            body = bodyId;
        else if ([bodyId isKindOfClass:[NSArray class]]) {
            NSMutableString *tmp = [@"" mutableCopy];
            for (NSString *line in (NSArray *)bodyId) {
                [tmp appendString:line];
            }
            body = tmp;
        }
            
        if ([body length] == 0)
            continue;
        
        NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@"\r\n"];
        
        if ([title isEqualToString:@"notitle"] == false) {
            NSAttributedString *displayString = [[NSAttributedString alloc] initWithString:[[title stringByTrimmingCharactersInSet:cs] stringByAppendingString:@"\n"] attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Montserrat-Bold" size:18], NSForegroundColorAttributeName : [UIColor darkGrayColor]}];
            [content appendAttributedString:displayString];
        }
        
        NSAttributedString *contentString = [[NSAttributedString alloc] initWithString:[[body stringByTrimmingCharactersInSet:cs] stringByAppendingString:@"\n"] attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:17], NSForegroundColorAttributeName : [UIColor darkGrayColor]}];
        [content appendAttributedString:contentString];
    }
    [_textView setAttributedText:content];
}

+ (NSString *)action
{
    return @"display";
}

@end
