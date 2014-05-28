//
//  CCAddView.m
//  Linotte
//
//  Created by stant on 06/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAddView.h"

#import "CCAddViewConstants.h"

#import "CCAddViewTableViewCell.h"

#define kCCAddViewTableViewCell @"kCCAddViewTableViewCell"

@interface CCAddView()

@property(nonatomic, strong)NSString *textFieldValueSave;

@property(nonatomic, strong)UITextField *textField;
@property(nonatomic, strong)UITableView *tableView;

@end

@implementation CCAddView

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupTextField];
        [self setupTableView];
    }
    return self;
}

- (void)setupTextField
{
    _textField = [UITextField new];
    _textField.translatesAutoresizingMaskIntoConstraints = NO;
    _textField.delegate = self;
    _textField.textAlignment = NSTextAlignmentCenter;
    _textField.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:25];
    _textField.textColor = [UIColor darkGrayColor];
    _textField.backgroundColor = [UIColor clearColor];
    _textField.placeholder = @"* place's name *";
    
    UIView *leftView = [UIView new];
    leftView.frame = CGRectMake(0, 0, 15, _textField.frame.size.height);
    leftView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _textField.leftView = leftView;
    _textField.leftViewMode = UITextFieldViewModeAlways;

    UIView *rightView = [UIView new];
    rightView.frame = CGRectMake(0, 0, 15, _textField.frame.size.height);
    rightView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _textField.rightView = rightView;
    _textField.rightViewMode = UITextFieldViewModeAlways;
    
    [_textField addTarget:self action:@selector(textFieldEventEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [self addSubview:_textField];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_textField);
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_textField]|" options:0 metrics:nil views:views];
    [self addConstraints:horizontalConstraints];
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_textField(kCCAddViewTextFieldHeight)]" options:0 metrics:kCCAddViewTextFieldHeightMetric views:views];
    [self addConstraints:verticalConstraints];
}

- (void)setupTableView
{
    NSAssert(_textField != nil, kCCWrongSetupMethodsOrderError);
    
    _tableView = [UITableView new];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;

    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_tableView registerClass:[CCAddViewTableViewCell class] forCellReuseIdentifier:kCCAddViewTableViewCell];
    
    [self addSubview:_tableView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_tableView, _textField);
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:0 metrics:nil views:views];
    [self addConstraints:horizontalConstraints];
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_textField][_tableView]|" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
}

- (void)enableField
{
    if (_textField.enabled == YES)
        return;
    _textField.placeholder = @"* place's name *";
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
    _textField.text = @"";
    _textField.placeholder = @"Missing connection";
    _textField.enabled = NO;
}

- (void)reloadAutocompletionResults
{
    [_tableView reloadData];
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
    CCAddViewTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:kCCAddViewTableViewCell];
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
