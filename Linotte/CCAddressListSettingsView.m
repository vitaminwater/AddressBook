//
//  CCListSettingsView.m
//  Linotte
//
//  Created by stant on 06/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAddressListSettingsView.h"

#import <HexColors/HexColor.h>

#import "NSString+CCLocalizedString.h"

#import "CCAddressListSettingsTableViewCell.h"

#define kCCListSettingsTableViewCell @"kCCListSettingsTableViewCell"

@interface CCAddressListSettingsView()

@property(nonatomic, strong)NSIndexPath *selectedPath;

@property(nonatomic, strong)UITextView *helpView;

@property(nonatomic, strong)UITextField *listName;
@property(nonatomic, strong)UITableView *listSelector;
@property(nonatomic, strong)UIButton *editListButton;

@property(nonatomic, strong)NSLayoutConstraint *listSelectorHeightConstraint;

@end

@implementation CCAddressListSettingsView

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self setupHelp];
        [self setupListName];
        [self setupEditListButton];
        [self setupListSelector];
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
    _helpView.textAlignment = NSTextAlignmentJustified;
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
    _listName.textColor = [UIColor colorWithHexString:@"#6B6B6B"];
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

- (void)setupEditListButton
{
    _editListButton = [UIButton new];
    _editListButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_editListButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_editListButton setTitleColor:[UIColor colorWithHexString:@"#f4607c"] forState:UIControlStateNormal];
    [_editListButton setTitle:NSLocalizedString(@"EDIT_LIST", @"") forState:UIControlStateNormal];
    [_editListButton addTarget:self action:@selector(editListPressed:) forControlEvents:UIControlEventTouchUpInside];
    _editListButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    _editListButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self addSubview:_editListButton];
}

- (void)setupListSelector
{
    _listSelector = [UITableView new];
    _listSelector.translatesAutoresizingMaskIntoConstraints = NO;
    _listSelector.backgroundColor = [UIColor clearColor];
    _listSelector.separatorColor = [UIColor whiteColor];
    _listSelector.separatorStyle = UITableViewCellSeparatorStyleNone;
    _listSelector.rowHeight = 35;
    _listSelector.delegate = self;
    _listSelector.dataSource = self;
    [_listSelector registerClass:[CCAddressListSettingsTableViewCell class] forCellReuseIdentifier:kCCListSettingsTableViewCell];
    [self addSubview:_listSelector];
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_helpView, _listName, _editListButton, _listSelector);
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_helpView]-[_listName(==40)]-(==4)-[_editListButton][_listSelector(==150)]|" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view": view}];
        [self addConstraints:horizontalConstraints];
    }
}

- (void)hideEditListButton
{
    if (_editListButton.hidden == YES)
        return;
    [UIView animateWithDuration:0.2 animations:^{
        _editListButton.alpha = 0;
    } completion:^(BOOL finished) {
        _editListButton.hidden = YES;
    }];
}

- (void)showEditListButton
{
    if (_editListButton.hidden == NO)
        return;
    _editListButton.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        _editListButton.alpha = 1;
    }];
}

#pragma mark - setter methods

- (void)setDelegate:(id<CCAddressListSettingsViewDelegate>)delegate
{
    _delegate = delegate;
    
    if ([_delegate numberOfLists] == 0) {
        _editListButton.alpha = 0;
        _editListButton.hidden = YES;
    }
}

#pragma mark - UIButton target methods

- (void)editListPressed:(UIButton *)sender
{
    BOOL newEditing = !_listSelector.editing;
    [_listSelector setEditing:newEditing animated:YES];
    if (newEditing) {
        [_editListButton setTitle:NSLocalizedString(@"OK", @"") forState:UIControlStateNormal];
        [_editListButton setTitleColor:[UIColor colorWithHexString:@"#5acfc4"] forState:UIControlStateNormal];
    } else {
        [_editListButton setTitle:NSLocalizedString(@"EDIT_LIST", @"") forState:UIControlStateNormal];
        [_editListButton setTitleColor:[UIColor colorWithHexString:@"#f4607c"] forState:UIControlStateNormal];
    }
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if (textField.text.length == 0)
        return NO;
    
    NSUInteger insertedIndex = [_delegate createListWithName:_listName.text];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:insertedIndex inSection:0];
    [_listSelector insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [_listSelector scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    _listName.text = @"";
    
    [self showEditListButton];
    return NO;
}

#pragma mark - UITableViewDelegate/UITableViewDataSource methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCAddressListSettingsTableViewCell *cell = (CCAddressListSettingsTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
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
    CCAddressListSettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCCListSettingsTableViewCell];
    
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_delegate removeListAtIndex:indexPath.row];
        [_listSelector deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        if ([_delegate numberOfLists] == 0)
            [self hideEditListButton];
    }
}

@end
