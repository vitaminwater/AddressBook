//
//  CCListInstallerViewController.m
//  Linotte
//
//  Created by stant on 26/10/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListInstallerViewController.h"

#import <HexColors/HexColor.h>

#import "UINavigationController+CCRemoveViewController.h"

#import "CCLinotteAPI.h"
#import "CCLinotteEngineCoordinator.h"
#import "CCLinotteAuthenticationManager.h"
#import "CCLinotteCoreDataStack.h"
#import "CCModelChangeMonitor.h"

#import "CCModelHelper.h"

#import "CCListInstallerView.h"

#import "CCAlertView.h"
#import "CCActionResultHUD.h"

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
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *color = @"#6b6b6b";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithHexString:color], NSFontAttributeName: [UIFont fontWithName:@"Montserrat-Bold" size:23]};
    
    { // left bar button items
        CGRect backButtonFrame = CGRectMake(0, 0, 30, 30);
        UIButton *backButton = [UIButton new];
        [backButton setImage:[UIImage imageNamed:@"back_icon.png"] forState:UIControlStateNormal];
        backButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        backButton.frame = backButtonFrame;
        [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        
        UIBarButtonItem *emptyBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        emptyBarButtonItem.width = -10;
        self.navigationItem.leftBarButtonItems = @[emptyBarButtonItem, barButtonItem];
    }
    
    // right bar button item
    {
        CGRect rightButtonFrame = CGRectMake(0, 0, 120, 30);
        UIButton *rightButton = [UIButton new];
        [rightButton setTitle:NSLocalizedString(@"ADD_LIST_TO_LINOTTE", @"") forState:UIControlStateNormal];
        [rightButton setTitleColor:[UIColor colorWithHexString:@"#037AFF"] forState:UIControlStateNormal];
        rightButton.frame = rightButtonFrame;
        rightButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:24];
        [rightButton addTarget:self action:@selector(addToLinotteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        
        UIBarButtonItem *emptyBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        emptyBarButtonItem.width = -10;
        self.navigationItem.rightBarButtonItems = @[barButtonItem, emptyBarButtonItem];
    }
    
    self.navigationItem.hidesBackButton = YES;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    if (_publicListDict != nil) {
        CCListInstallerView *view = (CCListInstallerView *)self.view;
        
        [view setListName:_publicListDict[@"name"]];
        [view loadListIconWithUrl:_publicListDict[@"icon"]];
    }
    [self loadCompleteList:_identifier];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)loadCompleteList:(NSString *)identifier
{
    [CCLEC.linotteAPI fetchCompleteListInfos:identifier success:^(NSDictionary *completeListInfoDict) {
        _completeListInfoDict = completeListInfoDict;
        CCListInstallerView *view = (CCListInstallerView *)self.view;
        
        NSDate *lastUpdateDate = [CCLEC.linotteAPI dateFromString:_completeListInfoDict[@"last_update"]];
        [view setListName:_completeListInfoDict[@"name"]];
        [view loadListIconWithUrl:_completeListInfoDict[@"icon"]];
        [view setListInfos:_completeListInfoDict[@"author"] numberOfAddresses:[_completeListInfoDict[@"n_addresses"] unsignedIntegerValue] numberOfInstalls:[_completeListInfoDict[@"n_installs"] unsignedIntegerValue] lastUpdate:lastUpdateDate];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
}

- (BOOL)alreadyInstalled
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
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

#pragma mark - UIBarButtons target methods

- (void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addToLinotteButtonPressed:(id)sender
{
    if ([self alreadyInstalled])
        [self removeFromLinotteButtonPressed];
    else
        [self addToLinotteButtonPressed];
}

- (void)addToLinotteButtonPressed
{
    NSManagedObjectContext *managedObjectContext = [[CCLinotteCoreDataStack sharedInstance] managedObjectContext];
    CCList *list = [CCList insertOrUpdateInManagedObjectContext:managedObjectContext fromLinotteAPIDict:_completeListInfoDict];
    list.identifier = _identifier;
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
    
    [[CCModelChangeMonitor sharedInstance] listsDidAdd:@[list] send:YES];
    [CCLEC forceListSynchronization:list];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kCCShowListOutputNotification object:list];
    //[[NSNotificationCenter defaultCenter] postNotificationName:kCCBackToHomeNotification object:nil];
    //[[NSNotificationCenter defaultCenter] postNotificationName:kCCShowBookPanelNotification object:nil];
    [self.navigationController removeViewController:self];
}

- (void)removeFromLinotteButtonPressed
{
    NSString *alertTitle = NSLocalizedString(@"NOTIF_LIST_DELETE", @"");
    
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
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

#pragma mark - CCAlertView target methods

- (void)alertViewDidSayYesForList:(CCAlertView *)sender
{
    [CCModelHelper deleteList:sender.userInfo];
    [CCActionResultHUD showActionResultWithImage:[UIImage imageNamed:@"completed"] inView:[CCActionResultHUD applicationRootView] text:NSLocalizedString(@"NOTIF_LIST_DELETE_CONFIRM", @"") delay:1];
    
    [CCAlertView closeAlertView:sender];
}

- (void)alertViewDidSayNo:(CCAlertView *)sender
{
    [CCAlertView closeAlertView:sender];
}

@end
