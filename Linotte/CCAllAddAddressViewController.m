//
//  CCAllAddAddressViewController.m
//  Linotte
//
//  Created by stant on 26/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAllAddAddressViewController.h"

#import "CCAddAddressByNameViewController.h"
#import "CCAddAddressByAddressViewController.h"
#import "CCAddAddressAtLocationViewController.h"

@implementation CCAllAddAddressViewController
{
    CCAddAddressByNameViewController *_addAddressByNameViewController;
    CCAddAddressByAddressViewController *_addAddressByAddressViewController;
    CCAddAddressAtLocationViewController *_addAddressAtLocationViewController;
}

@synthesize delegate = _delegate;

- (instancetype)init
{
    self = [super initWithViewControllers:nil edgeOnly:NO];
    if (self) {
        
    }
    return self;
}

- (void)loadView
{
    _addAddressByNameViewController = [CCAddAddressByNameViewController new];
    _addAddressByNameViewController.delegate = self;
    
    _addAddressByAddressViewController = [CCAddAddressByAddressViewController new];
    _addAddressByAddressViewController.delegate = self;
    
    _addAddressAtLocationViewController = [CCAddAddressAtLocationViewController new];
    _addAddressAtLocationViewController.delegate = self;
    
    self.viewControllers = @[_addAddressByNameViewController, _addAddressByAddressViewController, _addAddressAtLocationViewController];
    
    [super loadView];
}

- (void)setFirstInputAsFirstResponder
{
    [((id<CCAddAddressViewControllerProtocol>)self.currentViewController) setFirstInputAsFirstResponder];
}

#pragma mark - CCViewControllerSwiperViewDelegate

- (void)currentViewControllerChangedToIndex:(NSUInteger)index
{
    [super currentViewControllerChangedToIndex:index];
    [((id<CCAddAddressViewControllerProtocol>)self.currentViewController) setFirstInputAsFirstResponder];
}

#pragma mark - CCAddAddressViewControllerDelegate

- (void)addAddressViewController:(UIViewController<CCAddAddressViewControllerProtocol> *)sender preSaveAddress:(CCAddress *)address
{
    if (sender != self.currentViewController)
        return;
    
    [_delegate addAddressViewController:sender preSaveAddress:address];
}

- (void)addAddressViewController:(UIViewController<CCAddAddressViewControllerProtocol> *)sender postSaveAddress:(CCAddress *)address
{
    if (sender != self.currentViewController)
        return;
    
    [_delegate addAddressViewController:sender postSaveAddress:address];
}

- (void)addAddressViewControllerExpandAddView:(UIViewController<CCAddAddressViewControllerProtocol> *)sender
{
    if (sender != self.currentViewController)
        return;
    
    [_delegate addAddressViewControllerExpandAddView:sender];
}

- (void)addAddressViewControllerReduceAddView:(UIViewController<CCAddAddressViewControllerProtocol> *)sender
{
    if (sender != self.currentViewController)
        return;
    
    [_delegate addAddressViewControllerReduceAddView:sender];
}

@end
