//
//  CCAddAddressView.m
//  Linotte
//
//  Created by stant on 24/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAutocompleteAddAddressView.h"

#import <HexColors/HexColor.h>

#import "CCLinotteField.h"

#import "CCAddAddressViewTableViewCell.h"

#define kCCAddViewTableViewCell @"kCCAddViewTableViewCell"
#define kCCLoadingViewHeight 25

@implementation CCAutocompleteAddAddressView
{
    UIView *_loadingView;
    UILabel *_loadingLabel;
    
    NSString *_autocompleteFieldValueSave;
    
    NSLayoutConstraint *_loadingViewTopConstraint;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.opaque = YES;
        
        [self setupViews];
        [self setupLayout];
    }
    return self;
}

- (void)setupViews
{
    [self setupTableView];
    [self setupLoadingView];
    [self setupTextField];
}

- (void)setupTableView
{
    _tableView = [UITableView new];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.rowHeight = 60;
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_tableView registerClass:[CCAddAddressViewTableViewCell class] forCellReuseIdentifier:kCCAddViewTableViewCell];
    
    [self addSubview:_tableView];
}

- (void)setupLoadingView
{
    _loadingView = [UIView new];
    _loadingView.translatesAutoresizingMaskIntoConstraints = NO;
    _loadingView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    _loadingView.alpha = 0;
    [self addSubview:_loadingView];
    
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

- (void)setupTextField
{
    _autocompletedField = [[CCLinotteField alloc] initWithImage:[UIImage imageNamed:@"add_field_icon"]];
    _autocompletedField.translatesAutoresizingMaskIntoConstraints = NO;
    _autocompletedField.delegate = self;
    _autocompletedField.placeholder = NSLocalizedString(@"PLACE_NAME", @"");
    [_autocompletedField addTarget:self action:@selector(textFieldEventEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    [self addSubview:_autocompletedField];
}

- (void)setupLayout
{
    //loading view constraints
    {
        _loadingViewTopConstraint = [NSLayoutConstraint constraintWithItem:_loadingView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_tableView attribute:NSLayoutAttributeTop multiplier:1 constant:-kCCLoadingViewHeight];
        [self addConstraint:_loadingViewTopConstraint];
        
        NSArray *horizontaConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_loadingView]|" options:0 metrics:nil views:@{@"_loadingView" : _loadingView}];
        [self addConstraints:horizontaConstraints];
        
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:_loadingView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:kCCLoadingViewHeight];
        [self addConstraint:heightConstraint];
    }
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setNeedsDisplay];
}

- (void)enableField
{
    if (_autocompletedField.enabled == YES)
        return;
    _autocompletedField.placeholder = NSLocalizedString(@"PLACE_NAME", @"");
    _autocompletedField.enabled = YES;
    _autocompletedField.text = _autocompleteFieldValueSave;
}

- (void)disableField
{
    if (_autocompletedField.enabled == NO)
        return;
    
    if ([_autocompletedField isFirstResponder]) {
        [_autocompletedField resignFirstResponder];
    }
    
    _autocompleteFieldValueSave = _autocompletedField.text;
    _autocompletedField.backgroundColor = [UIColor clearColor];
    _autocompletedField.text = @"";
    _autocompletedField.placeholder = NSLocalizedString(@"MISSING_LOCATION", @"");
    _autocompletedField.enabled = NO;
}

- (void)cleanBeforeClose
{
    [_autocompletedField resignFirstResponder];
    _autocompletedField.text = @"";
}

/*- (void)drawRect:(CGRect)rect
{
    CGRect frame = _autocompletedField.bounds;
    
    CGFloat lineHeight = 0.5 * [[UIScreen mainScreen] scale];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, lineHeight);
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, frame.origin.x, frame.origin.y + lineHeight / 2);
    CGContextAddLineToPoint(context, frame.origin.x + frame.size.width, frame.origin.y + lineHeight / 2);
    CGContextStrokePath(context);
    
    [super drawRect:rect];
}*/

- (void)setFirstInputAsFirstResponder
{
    [_autocompletedField becomeFirstResponder];
}

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == _autocompletedField)
        [self.delegate autocompleteName:_autocompletedField.text];
}

- (void)textFieldEventEditingChanged:(UITextField *)textField
{
    if (textField == _autocompletedField)
        [self.delegate autocompleteName:_autocompletedField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _autocompletedField) {
        [_autocompletedField resignFirstResponder];
    }
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_autocompletedField resignFirstResponder];
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_delegate autocompletionResultSelectedAtIndex:indexPath.row];
    [self cleanBeforeClose];
}

@end
