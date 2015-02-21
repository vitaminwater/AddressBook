//
//  CCOpenHoursMeta.m
//  Linotte
//
//  Created by stant on 27/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCOpenHoursMeta.h"

#import "CCLinotteAPI.h"

@implementation CCOpenHoursMeta
{
    UIScrollView *_daysScroll;
    
    BOOL _movedToToday;
}

- (instancetype)initWithMeta:(id<CCMetaProtocol>)meta
{
    self = [super initWithMeta:meta];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self setupDays];
        [self setupLayout];
    }
    return self;
}

- (void)setupDays
{
    _daysScroll = [UIScrollView new];
    _daysScroll.translatesAutoresizingMaskIntoConstraints = NO;
    _daysScroll.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    _daysScroll.pagingEnabled = YES;
    _daysScroll.showsHorizontalScrollIndicator = NO;
    [self addSubview:_daysScroll];
    
    UIView *scrollContent = [UIView new];
    scrollContent.translatesAutoresizingMaskIntoConstraints = NO;
    scrollContent.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    [_daysScroll addSubview:scrollContent];
    
    {
        NSDictionary *views = NSDictionaryOfVariableBindings(scrollContent, _daysScroll);
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollContent]|" options:0 metrics:nil views:views];
        [_daysScroll addConstraints:horizontalConstraints];
        
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollContent(==_daysScroll)]|" options:0 metrics:nil views:views];
        [_daysScroll addConstraints:verticalConstraints];
    }
    
    NSArray *dayNames = @[NSLocalizedString(@"DAY_MON", @""), NSLocalizedString(@"DAY_TUE", @""), NSLocalizedString(@"DAY_WED", @""), NSLocalizedString(@"DAY_THU", @""), NSLocalizedString(@"DAY_FRI", @""), NSLocalizedString(@"DAY_SAT", @""), NSLocalizedString(@"DAY_SUN", @"")];
    
    NSMutableDictionary *views = [@{} mutableCopy];
    NSMutableString *format = [@"H:|" mutableCopy];
    NSMutableArray *dayViews = [@[] mutableCopy];
    for (NSString *dayName in dayNames) {
        NSUInteger index = [dayNames indexOfObject:dayName];
        NSString *viewName = [NSString stringWithFormat:@"dayView%d", (int)index];

        UILabel *dayView = [UILabel new];
        dayView.translatesAutoresizingMaskIntoConstraints = NO;
        dayView.numberOfLines = 0;
        dayView.textAlignment = NSTextAlignmentCenter;
        dayView.attributedText = [self attributesStringForDayName:dayName];
        [scrollContent addSubview:dayView];
        
        [dayViews addObject:dayView];
        views[viewName] = dayView;
        [format appendFormat:@"[%@]", viewName];
    }
    [format appendString:@"|"];
    
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views];
    [scrollContent addConstraints:horizontalConstraints];
    
    for (UIView *view in views.allValues) {
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_daysScroll attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
        [_daysScroll addConstraint:widthConstraint];
        
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
        [scrollContent addConstraints:verticalConstraints];
    }
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_daysScroll);
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_daysScroll]|" options:0 metrics:nil views:views];
    [self addConstraints:horizontalConstraints];
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_daysScroll]|" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
}

- (NSAttributedString *)attributesStringForDayName:(NSString *)dayName {
    NSDictionary *days = @{NSLocalizedString(@"DAY_MON", @"") : @"mon", NSLocalizedString(@"DAY_TUE", @"") : @"tue", NSLocalizedString(@"DAY_WED", @"") : @"wed", NSLocalizedString(@"DAY_THU", @"") : @"thu", NSLocalizedString(@"DAY_FRI", @"") : @"fri", NSLocalizedString(@"DAY_SAT", @"") : @"sat", NSLocalizedString(@"DAY_SUN", @"") : @"sun"};
    NSMutableAttributedString *attributedString = [NSMutableAttributedString new];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", dayName] attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"Montserrat-Bold" size:20]}]];
    
    id hours = self.meta.content[days[dayName]];
    if (hours == nil) {
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"CLOSED", @"") attributes:@{NSForegroundColorAttributeName : [UIColor redColor], NSFontAttributeName : [UIFont fontWithName:@"Futura-BookItalic" size:20]}]];
    } else {
        NSString *hoursString;
        if ([hours isKindOfClass:[NSArray class]]) {
            hoursString = [(NSArray *)hours componentsJoinedByString:@"\n"];
        } else {
            hoursString = hours;
        }
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:hoursString attributes:@{NSForegroundColorAttributeName : [UIColor greenColor], NSFontAttributeName : [UIFont fontWithName:@"Futura-BookItalic" size:20]}]];
    }
    
    return attributedString;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_movedToToday)
        return;
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [calendar components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    NSInteger weekday=[dateComponents weekday] == 1 ? 6 : [dateComponents weekday]-2;
    
    CGRect daysScrollFrame = _daysScroll.frame;
    daysScrollFrame.origin.x = daysScrollFrame.size.width * weekday;
    [_daysScroll scrollRectToVisible:daysScrollFrame animated:NO];
    
    _movedToToday = YES;
}

#pragma mark - CCBaseMetaWidgetProtocol methods

- (void)updateContent
{
}

+ (NSString *)action
{
    return @"hours";
}

@end
