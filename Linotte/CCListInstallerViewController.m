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
#import "CCCompleteListInfoModel+CCList.h"
#import "CCListGeohashZone+CCListZone.h"

#import "CCAlertView.h"
#import "CCActionResultHUD.h"

#import "CCLinotteAPI.h"

#import "CCList.h"
#import "CCListZone.h"

@implementation CCListInstallerViewController
{
    NSString *_identifier;
    CCPublicListModel *_publicListModel;
    CCCompleteListInfoModel *_completeListInfoModel;
}

- (instancetype)initWithIdentifier:(NSString *)identifier
{
    self = [super init];
    if (self) {
        _identifier = identifier;
    }
    return self;
}

- (instancetype)initWithPublicListModel:(CCPublicListModel *)publicListModel
{
    self = [super init];
    if (self) {
        _identifier = publicListModel.identifier;
        _publicListModel = publicListModel;
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
    if (_publicListModel != nil) {
        CCListInstallerView *view = (CCListInstallerView *)self.view;
        
        [view setListName:_publicListModel.name];
        [view setListIconImage:[UIImage imageNamed:@"list_pin_neutral"]];
    }
    [self loadCompleteList:_identifier];
}

- (void)loadCompleteList:(NSString *)identifier
{
    [[CCLinotteAPI sharedInstance] fetchCompleteListInfos:identifier completionBlock:^(BOOL success, CCCompleteListInfoModel *completeListInfoModel) {
        if (success) {
            _completeListInfoModel = completeListInfoModel;
            CCListInstallerView *view = (CCListInstallerView *)self.view;
            
            [view setListName:_completeListInfoModel.name];
            [view setListIconImage:[UIImage imageNamed:@"list_pin_neutral"]];
            [view setListInfos:_completeListInfoModel.author numberOfAddresses:[_completeListInfoModel.numberOfAddresses unsignedIntegerValue] numberOfInstalls:[_completeListInfoModel.numberOfInstalls unsignedIntegerValue] lastUpdate:_completeListInfoModel.lastUpdate];
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
    __block CCList *list = [_completeListInfoModel toInsertedCCListInManagedObjectContext:childManagedObjectContext];
    
    [[CCLinotteAPI sharedInstance] addList:list completionBlock:^(BOOL success) {
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
