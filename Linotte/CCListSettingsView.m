//
//  CCListSettingsView.m
//  Linotte
//
//  Created by stant on 06/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListSettingsView.h"

#import <HexColors/HexColor.h>

#import "NSString+CCLocalizedString.h"

#import "CCListSettingsTableViewCell.h"

#define kCCListSettingsTableViewCell @"kCCListSettingsTableViewCell"

@interface CCListSettingsView()

@property(nonatomic, strong)NSIndexPath *selectedPath;

@property(nonatomic, strong)UITextView *helpView;
@property(nonatomic, strong)UIButton *closeButton;

@property(nonatomic, strong)UITextField *listName;
@property(nonatomic, strong)UITableView *listSelector;

@end

@implementation CCListSettingsView

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#6b6b6b" alpha:0.85];
        self.alpha = 0.5;
        self.opaque = NO;
        self.layer.cornerRadius = 15;
        self.layer.masksToBounds = YES;
        
        [self setupHelp];
        [self setupListName];
        [self setupListSelector];
        [self setupCloseButton];
        [self setupLayout];
    }
    return self;
}

- (void)setupHelp
{
    _helpView = [UITextView new];
    _helpView.translatesAutoresizingMaskIntoConstraints = NO;
    _helpView.font = [UIFont fontWithName:@"Futura-Book" size:21];
    _helpView.backgroundColor = [UIColor clearColor];
    _helpView.textColor = [UIColor whiteColor];
    _helpView.textAlignment = NSTextAlignmentCenter;
    _helpView.editable = NO;
    _helpView.scrollEnabled = NO;
    _helpView.text = NSLocalizedString(@"LIST_HELP", @"");
    [self addSubview:_helpView];
}

- (void)setupListName
{
    _listName = [UITextField new];
    _listName.translatesAutoresizingMaskIntoConstraints = NO;
    _listName.backgroundColor = [UIColor whiteColor];
    _listName.font = [UIFont fontWithName:@"Montserrat-Bold" size:24];
    _listName.textColor = [UIColor blackColor];
    [_listName setReturnKeyType:UIReturnKeyGo];
    _listName.placeholder = NSLocalizedString(@"CREATE_LIST", @"");
    _listName.delegate = self;
    [self addSubview:_listName];
    
    UIView *leftView = [UIView new];
    leftView.frame = CGRectMake(0, 0, 5, 0);
    _listName.leftView = leftView;
    _listName.leftViewMode = UITextFieldViewModeAlways;

    UIView *rightView = [UIView new];
    rightView.frame = CGRectMake(0, 0, 5, 0);
    _listName.rightView = rightView;
    _listName.rightViewMode = UITextFieldViewModeAlways;
}

- (void)setupListSelector
{
    _listSelector = [UITableView new];
    _listSelector.translatesAutoresizingMaskIntoConstraints = NO;
    _listSelector.backgroundColor = [UIColor clearColor];
    _listSelector.separatorColor = [UIColor whiteColor];
    _listSelector.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _listSelector.rowHeight = 35;
    _listSelector.delegate = self;
    _listSelector.dataSource = self;
    [_listSelector registerClass:[CCListSettingsTableViewCell class] forCellReuseIdentifier:kCCListSettingsTableViewCell];
    [self addSubview:_listSelector];
}

- (void)setupCloseButton
{
    _closeButton = [UIButton new];
    _closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_closeButton setTitle:NSLocalizedString(@"CLOSE", @"") forState:UIControlStateNormal];
    [_closeButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    _closeButton.titleLabel.font = [UIFont fontWithName:@"Futura-Book" size:19];
    [_closeButton setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.5]];
    [_closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _closeButton.opaque = NO;
    [self addSubview:_closeButton];
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_helpView, _listName, _listSelector, _closeButton);
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_helpView]-[_listName(==40)]-(==4)-[_listSelector(==150)]-[_closeButton(==35)]|" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": view}];
        [self addConstraints:horizontalConstraints];
    }
}

#pragma mark - UIButton target methods

- (void)closeButtonPressed:(UIButton *)sender
{
    [_delegate closeListSettingsView:self success:NO];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if (textField.text.length == 0)
        return NO;
    
    NSUInteger insertedIndex = [_delegate createListWithName:_listName.text];
    
    [_listSelector insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:insertedIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    return NO;
}

#pragma mark - UITableViewDelegate/UITableViewDataSource methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCListSettingsTableViewCell *cell = (CCListSettingsTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if (cell) {
        cell.isAdded = !cell.isAdded;
        if (cell.isAdded) {
            [_delegate listSelectedAtIndex:indexPath.row];
        } else {
            [_delegate listUnselectedAtIndex:indexPath.row];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCListSettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCCListSettingsTableViewCell];
    
    cell.textLabel.text = [_delegate listNameAtIndex:indexPath.row];
    cell.isAdded = [_delegate isListSelectedAtIndex:indexPath.row];

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_delegate numberOfLists];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

@end
