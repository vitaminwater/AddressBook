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
            
            NSDate *lastUpdateDate = [[CCLinotteAPI sharedInstance] dateFromString:_completeListInfoDict[@"last_update"]];
            [view setListName:_completeListInfoDict[@"name"]];
            [view setListIconImage:[UIImage imageNamed:@"list_pin_neutral"]];
            [view setListInfos:_completeListInfoDict[@"author"] numberOfAddresses:[_completeListInfoDict[@"n_addresses"] unsignedIntegerValue] numberOfInstalls:[_completeListInfoDict[@"n_installs"] unsignedIntegerValue] lastUpdate:lastUpdateDate];
        }
    }];
}

- (BOOL)alreadyInstalled
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier = %@", _identifier];
    [fetchRequest setPredicate:predicate];
    
    BOOL installed = [managedObjectContext countForFetchRequest:fetchRequest error:&error] > 0;
    
    if (error != nil) {
        CCLog(@"%@", error);
        return NO;
    }
    
    return installed;
}

#pragma mark - CCListInstallerViewDelegate methods

- (void)addToLinotteButtonPressed
{
    NSManagedObjectContext *managedObjectContext = [[CCCoreDataStack sharedInstance] managedObjectContext];
    CCList *list = [CCList insertOrUpdateInManagedObjectContext:managedObjectContext fromLinotteAPIDict:_completeListInfoDict];
    list.identifier = _identifier;
    list.ownedValue = [list.authorIdentifier isEqualToString:[CCLinotteAPI sharedInstance].identifier];
    [[CCCoreDataStack sharedInstance] saveContext];
    
    [[CCModelChangeMonitor sharedInstance] listsDidAdd:@[list] send:YES];
    [[CCSynchronizationHandler sharedInstance] performSynchronizationsWithMaxDuration:0 list:list completionBlock:^(BOOL didSync){}];
    
    [_delegate closeListInstaller:self];
    [_delegate listInstaller:self listInstalled:list];
}

- (void)removeFromLinotteButtonPressed
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
