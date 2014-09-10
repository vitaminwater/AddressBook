//
//  CCListConfigView.m
//  Linotte
//
//  Created by stant on 09/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListConfigView.h"

#import <HexColors/HexColor.h>

#import "CCListConfigTableViewCell.h"

#define kCCListConfigTableViewCell @"kCCListConfigTableViewCell"

@interface CCListConfigView()

@property(nonatomic, strong)UITextView *helpView1;
@property(nonatomic, strong)UITextView *helpView2;
@property(nonatomic, strong)UITextField *listName;
@property(nonatomic, strong)UIButton *editListButton;
@property(nonatomic, strong)UITableView *listView;

@end

@implementation CCListConfigView

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self setupHelp];
        [self setupListName];
        [self setupEditListButton];
        [self setupList];
        [self setupLayout];
    }
    return self;
}

- (void)setupHelp
{
    //_helpView1 = [self createHelp:NSLocalizedString(@"LIST_CONFIG_HELP1", @"") fontSize:21];
    _helpView2 = [self createHelp:NSLocalizedString(@"LIST_CONFIG_HELP2", @"") fontSize:17];
}

- (UITextView *)createHelp:(NSString *)text fontSize:(NSUInteger)fontSize
{
    UITextView *textView = [UITextView new];
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    textView.font = [UIFont fontWithName:@"Futura-Book" size:fontSize];
    textView.backgroundColor = [UIColor clearColor];
    textView.textColor = [UIColor colorWithHexString:@"#6B6B6B"];
    textView.textAlignment = NSTextAlignmentJustified;
    textView.editable = NO;
    textView.scrollEnabled = NO;
    textView.text = text;
    [self addSubview:textView];
    return textView;
}

- (void)setupListName
{
    _listName = [UITextField new];
    _listName.translatesAutoresizingMaskIntoConstraints = NO;
    _listName.backgroundColor = [UIColor whiteColor];
    _listName.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _listName.layer.borderWidth = 1;
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

- (void)setupList
{
    _listView = [UITableView new];
    _listView.translatesAutoresizingMaskIntoConstraints = NO;
    _listView.backgroundColor = [UIColor clearColor];
    _listView.separatorColor = [UIColor whiteColor];
    _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _listView.rowHeight = 40;
    _listView.delegate = self;
    _listView.dataSource = self;
    [_listView registerClass:[CCListConfigTableViewCell class] forCellReuseIdentifier:kCCListConfigTableViewCell];
    [self addSubview:_listView];
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(/*_helpView1, */_listName, _helpView2, _editListButton, _listView);
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_listName(==40)]-[_helpView2]-[_editListButton]-[_listView]|" options:0 metrics:nil views:views];
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

- (void)setDelegate:(id<CCListConfigViewDelegate>) delegate
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
    BOOL newEditing = !_listView.editing;
    [_listView setEditing:newEditing animated:YES];
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
    [_listView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [_listView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    _listName.text = @"";
    
    [self showEditListButton];
    return NO;
}

#pragma mark - CCListConfigTableViewCellDelegate methods

- (void)checkedCell:(id)sender
{
    NSIndexPath *indexPath = [_listView indexPathForCell:sender];
    [_delegate listExpandedAtIndex:indexPath.row];
}

- (void)uncheckedCell:(id)sender
{
    NSIndexPath *indexPath = [_listView indexPathForCell:sender];
    [_delegate listUnexpandedAtIndex:indexPath.row];
}

#pragma mark - UITableViewDelegate/UITableViewDataSource methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCListConfigTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCCListConfigTableViewCell];
    
    cell.textLabel.text = [_delegate listNameAtIndex:indexPath.row];
    [cell initialExpandedState:[_delegate isListExpandedAtIndex:indexPath.row]];
    cell.delegate = self;
    
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
        [_listView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        if ([_delegate numberOfLists] == 0)
            [self hideEditListButton];
    }
}

@end
