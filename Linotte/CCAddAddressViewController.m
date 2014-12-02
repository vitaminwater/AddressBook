//
//  CCAllAddAddressViewController.m
//  Linotte
//
//  Created by stant on 26/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAddAddressViewController.h"

#import "CCModelChangeMonitor.h"
#import "CCCoreDataStack.h"
#import "CCModelHelper.h"

#import "CCAddAddressView.h"

#import "CCSwapperViewController.h"

#import "CCAddAddressByNameViewController.h"
#import "CCAddAddressByAddressViewController.h"
#import "CCAddAddressAtLocationViewController.h"

#import "CCOutputViewController.h"

#import "CCList.h"
#import "CCAddress.h"

@implementation CCAddAddressViewController
{
    CCSwapperViewController *_swapperViewController;
    
    CCAddAddressByNameViewController *_addAddressByNameViewController;
    CCAddAddressByAddressViewController *_addAddressByAddressViewController;
    CCAddAddressAtLocationViewController *_addAddressAtLocationViewController;
}

@synthesize delegate = _delegate;

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)loadView
{
    self.title = NSLocalizedString(@"ADD_ADDRESS_SCREEN_NAME", @"");
    
    _addAddressByNameViewController = [CCAddAddressByNameViewController new];
    _addAddressByNameViewController.delegate = self;
    
    _addAddressByAddressViewController = [CCAddAddressByAddressViewController new];
    _addAddressByAddressViewController.delegate = self;
    
    _addAddressAtLocationViewController = [CCAddAddressAtLocationViewController new];
    _addAddressAtLocationViewController.delegate = self;
    
    _swapperViewController = [[CCSwapperViewController alloc] initWithFirstViewController:_addAddressByNameViewController];
    _swapperViewController.delegate = self;
    
    [self addChildViewController:_swapperViewController];
    CCAddAddressView *view = [[CCAddAddressView alloc] initWithSwapperView:_swapperViewController.view];
    view.delegate = self;
    self.view = view;
    [_swapperViewController didMoveToParentViewController:self];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_addAddressByNameViewController firstInputResignFirstResponder];
    [_addAddressByAddressViewController firstInputResignFirstResponder];
    [_addAddressAtLocationViewController firstInputResignFirstResponder];
}

#pragma mark - CCAddAddressViewControllerDelegate methods

- (void)addAddressViewController:(id)sender preSaveAddress:(CCAddress *)address
{
    CCList *list = [CCModelHelper defaultList];
    [[CCModelChangeMonitor sharedInstance] addresses:@[address] willMoveToList:list send:YES];
    [list addAddressesObject:address];
    [[CCCoreDataStack sharedInstance] saveContext];
    [[CCModelChangeMonitor sharedInstance] addresses:@[address] didMoveToList:list send:YES];
}

- (void)addAddressViewController:(id)sender postSaveAddress:(CCAddress *)address
{
    CCOutputViewController *outputViewController = [[CCOutputViewController alloc] initWithAddress:address addressIsNew:YES];
    [self.navigationController pushViewController:outputViewController animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCCBackToHomeNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCCShowAddressesPanelNotification object:nil];
}

#pragma mark - CCChildRootViewControllerProtocol methods

- (void)viewWillShow
{
//    id<CCAddAddressViewControllerProtocol> addAddressViewController = (id<CCAddAddressViewControllerProtocol>)_swapperViewController.currentViewController;
//    [addAddressViewController setFirstInputAsFirstResponder];
}

- (void)viewWillHide
{
    id<CCAddAddressViewControllerProtocol> addAddressViewController = (id<CCAddAddressViewControllerProtocol>)_swapperViewController.currentViewController;
    [addAddressViewController firstInputResignFirstResponder];
}

#pragma mark - CCAddAddressViewDelegate methods

- (void)addAddressTypeChangedTo:(CCAddAddressType)addAddressType
{
    NSArray *addAddressViewControllers = @[_addAddressByNameViewController, _addAddressByAddressViewController, _addAddressAtLocationViewController];
    UIViewController<CCAddAddressViewControllerProtocol> *currentAddAddressViewController = (UIViewController<CCAddAddressViewControllerProtocol> *)_swapperViewController.currentViewController;
    UIViewController<CCAddAddressViewControllerProtocol> *addAddressViewController = (UIViewController<CCAddAddressViewControllerProtocol> *)addAddressViewControllers[addAddressType];
    
    if (currentAddAddressViewController == addAddressViewController)
        return;
    
    NSString *nameFieldValue = currentAddAddressViewController.nameFieldValue;
    addAddressViewController.nameFieldValue = nameFieldValue;
    
    [(UIViewController<CCAddAddressViewControllerProtocol> *)_swapperViewController.currentViewController firstInputResignFirstResponder];
    [_swapperViewController swapToViewController:addAddressViewController];
    //[addAddressViewController setFirstInputAsFirstResponder];
}

@end
