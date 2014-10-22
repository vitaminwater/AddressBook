//
//  CCAddView.m
//  Linotte
//
//  Created by stant on 06/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAddAddressView.h"

#import "CCAddAddressViewTableViewCell.h"

#define kCCAddViewTableViewCell @"kCCAddViewTableViewCell"
#define kCCLoadingViewHeight 25


@implementation CCAddAddressView
{
    NSString *_textFieldValueSave;

    UITextField *_textField;
    UIView *_loadingView;
    UILabel *_loadingLabel;
    UITableView *_tableView;

    NSLayoutConstraint *_loadingViewTopConstraint;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self setupTextField];
        [self setupLoadingView];
        [self setupTableView];
        [self setupLayout];
    }
    return self;
}

- (void)setupTextField
{
    _textField = [UITextField new];
    _textField.translatesAutoresizingMaskIntoConstraints = NO;
    _textField.delegate = self;
    _textField.font = [UIFont fontWithName:@"Montserrat-Bold" size:28];
    _textField.textColor = [UIColor darkGrayColor];
    _textField.backgroundColor = [UIColor clearColor];
    _textField.placeholder = NSLocalizedString(@"PLACE_NAME", @"");
    
    UIImageView *leftView = [UIImageView new];
    leftView.frame = CGRectMake(0, 0, 58, [kCCAddViewTextFieldHeight floatValue]);
    leftView.contentMode = UIViewContentModeCenter;
    leftView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    leftView.image = [UIImage imageNamed:@"add_field_icon"];
    _textField.leftView = leftView;
    _textField.leftViewMode = UITextFieldViewModeAlways;

    UIView *rightView = [UIView new];
    rightView.frame = CGRectMake(0, 0, 15, [kCCAddViewTextFieldHeight floatValue]);
    rightView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _textField.rightView = rightView;
    _textField.rightViewMode = UITextFieldViewModeAlways;
    
    [_textField addTarget:self action:@selector(textFieldEventEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [self addSubview:_textField];
}

- (void)setupLoadingView
{
    _loadingView = [UIView new];
    _loadingView.translatesAutoresizingMaskIntoConstraints = NO;
    _loadingView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    _loadingView.alpha = 0;
    [self insertSubview:_loadingView belowSubview:_textField];
    
    {
        _loadingLabel = [UILabel new];
        _loadingLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _loadingLabel.text = @"Loading";
        _loadingLabel.textColor = [UIColor whiteColor];
        _loadingLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        [_loadingView addSubview:_loadingLabel];
        
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
        [activityIndicatorView startAnimating];
        [_loadingView addSubview:activityIndicatorView];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_loadingLabel, activityIndicatorView);
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[activityIndicatorView]-[_loadingLabel]" options:0 metrics:nil views:views];
        [_loadingView addConstraints:horizontalConstraints];
        
        for (UIView *v in views.allValues) {
            NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view" : v}];
            [_loadingView addConstraints:verticalConstraints];
        }
    }
}

- (void)setupTableView
{
    NSAssert(_textField != nil, kCCWrongSetupMethodsOrderError);
    
    _tableView = [UITableView new];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.backgroundColor = [UIColor clearColor];

    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_tableView registerClass:[CCAddAddressViewTableViewCell class] forCellReuseIdentifier:kCCAddViewTableViewCell];
    
    [self insertSubview:_tableView belowSubview:_loadingView];
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_textField, _loadingView, _tableView);
    
    //loading view constraints
    {
        _loadingViewTopConstraint = [NSLayoutConstraint constraintWithItem:_loadingView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_textField attribute:NSLayoutAttributeBottom multiplier:1 constant:-kCCLoadingViewHeight];
        [self addConstraint:_loadingViewTopConstraint];
        
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:_loadingView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:kCCLoadingViewHeight];
        [self addConstraint:heightConstraint];
    }

    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_textField(kCCAddViewTextFieldHeight)][_tableView]|" options:0 metrics:kCCAddViewTextFieldHeightMetric views:views];
    [self addConstraints:verticalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
        [self addConstraints:horizontalConstraints];
    }
}

- (void)enableField
{
    if (_textField.enabled == YES)
        return;
    _textField.placeholder = NSLocalizedString(@"PLACE_NAME", @"");
    _textField.enabled = YES;
    _textField.text = _textFieldValueSave;
}

- (void)disableField
{
    if (_textField.enabled == NO)
        return;
    
    if ([_textField isFirstResponder]) {
        [_textField resignFirstResponder];
        [_delegate reduceAddView];
    }

    _textFieldValueSave = _textField.text;
    _textField.backgroundColor = [UIColor clearColor];
    _textField.text = @"";
    _textField.placeholder = @"Missing connection";
    _textField.enabled = NO;
}

- (void)showLoading:(NSString *)message
{
    [self layoutIfNeeded];
    _loadingLabel.text = message;
    _loadingViewTopConstraint.constant = 0;
    [UIView animateWithDuration:0.2 animations:^{
        _loadingView.alpha = 1;
        [self layoutIfNeeded];
    }];
}

- (void)hideLoading
{
    [self layoutIfNeeded];
    _loadingViewTopConstraint.constant = -kCCLoadingViewHeight;
    [UIView animateWithDuration:0.2 animations:^{
        _loadingView.alpha = 0;
        [self layoutIfNeeded];
    }];
}

- (void)reloadAutocompletionResults
{
    [_tableView reloadData];
}

- (void)drawRect:(CGRect)rect
{
    CGRect frame = _textField.bounds;
    
    CGFloat lineHeight = 0.5 * [[UIScreen mainScreen] scale];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, lineHeight);
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, frame.origin.x, frame.origin.y + lineHeight / 2);
    CGContextAddLineToPoint(context, frame.origin.x + frame.size.width, frame.origin.y + lineHeight / 2);
    CGContextStrokePath(context);
    
    /*CGContextBeginPath(context);
    CGContextMoveToPoint(context, frame.origin.x, frame.origin.y + frame.size.height - lineHeight / 2);
    CGContextAddLineToPoint(context, frame.origin.x + frame.size.width, frame.origin.y + frame.size.height - lineHeight / 2);
    CGContextStrokePath(context);*/
    
    [super drawRect:rect];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setNeedsDisplay];
}

#pragma mark - UITextFieldDelegate methods

- (void)textFieldEventEditingChanged:(id)sender
{
    [_delegate autocompleteName:_textField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_textField resignFirstResponder];
    [_delegate reduceAddView];
    return NO;
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCAddAddressViewTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:kCCAddViewTableViewCell];
    cell.textLabel.text = [_delegate nameForAutocompletionResultAtIndex:indexPath.row];
    cell.detailTextLabel.text = [_delegate addressForAutocompletionResultAtIndex:indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger count = [_delegate numberOfAutocompletionResults];
    return count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_textField resignFirstResponder];
    _textField.text = @"";
    [_delegate autocompletionResultSelectedAtIndex:indexPath.row];
}

@end
