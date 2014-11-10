//
//  CCListInstallerViewController.m
//  Linotte
//
//  Created by stant on 26/10/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListInstallerViewController.h"

#import "CCCoreDataStack.h"
#import "CCModelChangeMonitor.h"

#import "CCSynchronizationHandler.h"

#import "CCModelHelper.h"

#import "CCListInstallerView.h"

#import "CCAlertView.h"
#import "CCActionResultHUD.h"

#import "CCLinotteAPI.h"

#import "CCList.h"
#import "CCListZone.h"

@implementation CCListInstallerViewController
{
    NSString *_identifier;
    NSDictionary *_publicListDict;
    NSDictionary *_completeListInfoDict;
}

- (instancetype)initWithIdentifier:(NSString *)identifier
{
    self = [super init];
    if (self) {
        _identifier = identifier;
    }
    return self;
}

- (instancetype)initWithpublicListDict:(NSDictionary *)publicListDict
{
    self = [super init];
    if (self) {
        _identifier = publicListDict[@"identifier"];
        _publicListDict = publicListDict;
    }
    return self;
}

- (void)loadView
{
    CCListInstallerView *view = [CCListInstallerView new];
    view.delegate = self;
    if ([self alreadyInstalled])
        [view setAlreadyInstalled];
    self.view = view;
}

- (void)viewDidLoad
{
    if (_publicListDict != nil) {
        CCListInstallerView *view = (CCListInstallerView *)self.view;
        
        [view setListName:_publicListDict[@"name"]];
        [view setListIconImage:[UIImage imageNamed:@"list_pin_neutral"]];
    }
    [self loadCompleteList:_identifier];
}

- (void)loadCompleteList:(NSString *)identifier
{
    [[CCLinotteAPI sharedInstance] fetchCompleteListInfos:identifier completionBlock:^(BOOL success, NSDictionary *completeListInfoDict) {
        if (success) {
            _completeListInfoDict = completeListInfoDict;
            CCListInstallerView *view = (CCListInstallerView *)self.view;
            
            [view setListName:_completeListInfoDict[@"name"]];
            [view setListIconImage:[UIImage imageNamed:@"list_pin_neutral"]];
            [view setListInfos:_completeListInfoDict[@"author"] numberOfAddresses:[_completeListInfoDict[@"n_addresses"] unsignedIntegerValue] numberOfInstalls:[_completeListInfoDict[@"n_installs"] unsignedIntegerValue] lastUpdate:_completeListInfoDict[@"last_update"]];
        }
    }];
}

- (BOOL)alreadyInstalled
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier = %@", _identifier];
    [fetchRequest setPredicate:predicate];
    return [managedObjectContext countForFetchRequest:fetchRequest error:NULL] > 0;
}

#pragma mark - CCListInstallerViewDelegate methods

- (void)addToLinotteButtonPressed
{
    NSManagedObjectContext *childManagedObjectContext = [[CCCoreDataStack sharedInstance] childManagedObjectContext];
    __block CCList *list = [CCList insertInManagedObjectContext:childManagedObjectContext fromLinotteAPIDict:_completeListInfoDict];
    list.identifier = _identifier;
    
    [[CCLinotteAPI sharedInstance] addList:@{@"list" : list.identifier} completionBlock:^(BOOL success) {
        if (success) {
            [[CCCoreDataStack sharedInstance] saveChildManagedObjectContext:childManagedObjectContext];
            
            // Get CCList object from main managed object context
            NSManagedObjectContext *managedObjectContext = [[CCCoreDataStack sharedInstance] managedObjectContext];
            list = (CCList *)[managedObjectContext objectWithID:[list objectID]];
            
            [[CCModelChangeMonitor sharedInstance] listDidAdd:list send:NO];
            [[CCSynchronizationHandler sharedInstance] performListSynchronization:list completionBlock:^{}];

            [_delegate closeListInstaller:self];
            [CCActionResultHUD showActionResultWithImage:[UIImage imageNamed:@"completed"] text:NSLocalizedString(@"NOTIF_LIST_DELETE_INSTALL", @"") delay:1];
        } else {
            [childManagedObjectContext rollback];
        }
    }];
}

- (void)removeToLinotteButtonPressed
{
    NSString *alertTitle = NSLocalizedString(@"NOTIF_LIST_DELETE", @"");
    
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier = %@", _identifier];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *lists = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil && [lists count] == 0)
        return;
    
    CCAlertView *alertView = [CCAlertView showAlertViewWithText:alertTitle target:self leftAction:@selector(alertViewDidSayYesForList:) rightAction:@selector(alertViewDidSayNo:)];
    alertView.userInfo = [lists firstObject];
}

- (void)closeButtonPressed
{
    [_delegate closeListInstaller:self];
}

#pragma mark - CCAlertView target methods

- (void)alertViewDidSayYesForList:(CCAlertView *)sender
{
    [CCModelHelper deleteList:sender.userInfo];
    [CCActionResultHUD showActionResultWithImage:[UIImage imageNamed:@"completed"] text:NSLocalizedString(@"NOTIF_LIST_DELETE_CONFIRM", @"") delay:1];
    
    [CCAlertView closeAlertView:sender];
    
    [_delegate closeListInstaller:self];
}

- (void)alertViewDidSayNo:(CCAlertView *)sender
{
    [CCAlertView closeAlertView:sender];
    
    [((CCListInstallerView *)self.view) cancelInstallAction];
}

@end
