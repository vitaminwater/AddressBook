//
//  CCListOutputAddressListView.m
//  Linotte
//
//  Created by stant on 25/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListOutputAddressListView.h"

#import <HexColors/HexColor.h>

#import "CCListOutputAddressListTableViewCell.h"

#import "CCFlatColorButton.h"

#define kCCListOutputAddressListTableViewCell @"kCCListOutputAddressListTableViewCell"


@implementation CCListOutputAddressListView
{
    UIView *_topView;
    UITextField *_textField;
    UITableView *_list;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self setupTopView];
        [self setupSearchField];
        [self setupAddressList];
        [self setupLayout];
    }
    return self;
}

- (void)setupTopView
{
    _topView = [UIView new];
    _topView.translatesAutoresizingMaskIntoConstraints = NO;
    _topView.backgroundColor = [UIColor clearColor];
    [self addSubview:_topView];
    
    UIView *statusBar = [UIView new];
    statusBar.translatesAutoresizingMaskIntoConstraints = NO;
    statusBar.backgroundColor = [UIColor lightGrayColor];
    [_topView addSubview:statusBar];
    
    UILabel *helpLabel = [UILabel new];
    helpLabel.translatesAutoresizingMaskIntoConstraints = NO;
    helpLabel.textColor = [UIColor darkGrayColor];
    helpLabel.numberOfLines = 0;
    helpLabel.textAlignment = NSTextAlignmentCenter;
    helpLabel.font = [UIFont fontWithName:@"Futura-Book" size:20];
    helpLabel.text = NSLocalizedString(@"LIST_OUTPUT_ADDRESS_LIST_HELP", @"");
    [_topView addSubview:helpLabel];
    
    CCFlatColorButton *closeButton = [CCFlatColorButton new];
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    closeButton.backgroundColor = [UIColor colorWithHexString:@"#ffae64"];
    [closeButton setBackgroundColor:[UIColor colorWithHexString:@"#ef9e54"] forState:UIControlStateHighlighted];
    [closeButton setTitle:NSLocalizedString(@"LIST_OUTPUT_ADDRESS_LIST_CLOSE", @"") forState:UIControlStateNormal];
    closeButton.titleLabel.font = [UIFont fontWithName:@"Futura-Book" size:20];
    closeButton.layer.cornerRadius = 15;
    closeButton.clipsToBounds = YES;
    [closeButton addTarget:self action:@selector(closePressed:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:closeButton];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(statusBar, helpLabel, closeButton);
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[statusBar(==22)]-(==20)-[helpLabel]-[closeButton(==30)]|" options:0 metrics:nil views:views];
    [_topView addConstraints:verticalConstraints];
    
    // status bar
    {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[statusBar]|" options:0 metrics:nil views:views];
        [_topView addConstraints:horizontalConstraints];
    }
    
    // close button
    {
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:closeButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:_topView attribute:NSLayoutAttributeWidth multiplier:0.3 constant:0];
        [_topView addConstraint:widthConstraint];
    }
    
    // help label
    {
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:helpLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:_topView attribute:NSLayoutAttributeWidth multiplier:1 constant:-40];
        [_topView addConstraint:widthConstraint];
    }
    
    for (UIView *view in views.allValues) {
        NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_topView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        [_topView addConstraint:centerXConstraint];
    }
}

- (void)setupSearchField
{
    _textField = [UITextField new];
    _textField.translatesAutoresizingMaskIntoConstraints = NO;
    _textField.font = [UIFont fontWithName:@"Montserrat-Bold" size:28];
    _textField.textColor = [UIColor darkGrayColor];
    _textField.backgroundColor = [UIColor whiteColor];
    _textField.placeholder = NSLocalizedString(@"LIST_NAME", @"");
    _textField.delegate = self;
    
    UIButton *cancelButton = [UIButton new];
    [cancelButton setImage:[UIImage imageNamed:@"cancel_button"] forState:UIControlStateNormal];
    cancelButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    cancelButton.frame = CGRectMake(0, 0, 40, [kCCAddViewTextFieldHeight floatValue]);
    cancelButton.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [cancelButton addTarget:self action:@selector(cancelPressed:) forControlEvents:UIControlEventTouchUpInside];
    _textField.rightView = cancelButton;
    _textField.rightViewMode = UITextFieldViewModeWhileEditing;
    
    [self addSubview:_textField];
}

- (void)setupAddressList
{
    _list = [UITableView new];
    _list.translatesAutoresizingMaskIntoConstraints = NO;
    [_list registerClass:[CCListOutputAddressListTableViewCell class] forCellReuseIdentifier:kCCListOutputAddressListTableViewCell];
    _list.delegate = self;
    _list.dataSource = self;
    _list.rowHeight = 70;
    [self addSubview:_list];
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_topView, _textField, _list);
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_topView][_textField(==kCCAddViewTextFieldHeight)][_list]|" options:0 metrics:kCCAddViewTextFieldHeightMetric views:views];
    [self addConstraints:verticalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
        [self addConstraints:horizontalConstraints];
    }
}

#pragma mark - UIButton target methods

- (void)closePressed:(id)sender
{
    [_delegate closePressed];
}

- (void)cancelPressed:(id)sender
{
    _textField.text = @"";
}

#pragma mark - UITextFieldDelegate/DataSource methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCListOutputAddressListTableViewCell *cell = (CCListOutputAddressListTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.isAdded = !cell.isAdded;
    
    if (cell.isAdded)
        [_delegate addressAddedAtIndex:indexPath.row];
    else
        [_delegate addressUnaddedAtIndex:indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCListOutputAddressListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCCListOutputAddressListTableViewCell];
    cell.delegate = self;
    [cell setName:[_delegate nameForAddressAtIndex:indexPath.row]];
    [cell setAddress:[_delegate addressForAddressAtIndex:indexPath.row]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_delegate numberOfAddresses];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark - CCListOutputAddressListTableViewCellDelegate methods

@end
