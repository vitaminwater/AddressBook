//
//  CCFacebookOverlayViewController.m
//  Linotte
//
//  Created by stant on 08/12/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCSignUpViewController.h"

#import <SSKeychain/SSKeychain.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>

#import "CCLinotteEngineCoordinator.h"
#import "CCLinotteAPI.h"
#import "CCLinotteCoreDataStack.h"
#import "CCLinotteAuthenticationManager.h"

#import "CCActionResultHUD.h"

#import "CCSignUpView.h"

#import "CCAuthMethod.h"

@interface CCSignUpViewController ()

@end

@implementation CCSignUpViewController

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChangeNotification:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView
{
    CCSignUpView *view = [CCSignUpView new];
    view.delegate = self;
    view.reachable = [AFNetworkReachabilityManager sharedManager].reachable;
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)checkSignupFailure
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAuthMethod entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"signup = %@", @YES];
    [fetchRequest setPredicate:predicate];
    
    NSArray *authMethods = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error != nil) {
        CCLog(@"%@", error);
        return;
    }
    
    if ([authMethods count] == 0)
        return;
    
    CCAuthMethod *authMethod = [authMethods firstObject];
    
    [self processAccountCreationWithAuthMethod:authMethod failure:^(NSURLSessionDataTask *task, NSError *error) {}];
}

- (void)processAccountCreationWithAuthMethod:(CCAuthMethod *)authMethod failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    if ([AFNetworkReachabilityManager sharedManager].isReachable) {
        CCSignUpView *view = (CCSignUpView *)self.view;
        [view showLoadingView];
        [CCLEC.authenticationManager createAccountOrLoginWithAuthMethod:authMethod success:^{
            [_delegate signupCompleted];
            [view hideLoadingView];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            CCLog(@"%@", error);
            
            NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
            [managedObjectContext deleteObject:authMethod];
            [[CCLinotteCoreDataStack sharedInstance] saveContext];
            
            failureBlock(task, error);
            [view hideLoadingView];
            [CCActionResultHUD showActionResultWithImage:[UIImage imageNamed:@"sad_icon"] inView:self.view text:NSLocalizedString(@"SIGNUP_ERROR", @"") delay:3];
        }];
    }
}

#pragma mark - CCSignupViewController

- (void)loginSignupButtonPressed:(NSString *)email password:(NSString *)password
{
    CCSignUpView *view = (CCSignUpView *)self.view;
    if (view.loading)
        return;
    
    CCAuthMethod *authMethod = [CCLEC.authenticationManager addAuthMethodWithEmail:email password:password];
    authMethod.signupValue = YES;
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
    
    [self processAccountCreationWithAuthMethod:authMethod failure:^(NSURLSessionDataTask *task, NSError *error) {}];
}

#pragma mark - FBLoginViewDelegate methods

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    CCSignUpView *view = (CCSignUpView *)self.view;
    if (view.loading)
        return;
    
    CCAuthMethod *authMethod = [CCLEC.authenticationManager addAuthMethodWithFacebookAccount:user];
    authMethod.signupValue = YES;
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
    
    [self processAccountCreationWithAuthMethod:authMethod failure:^(NSURLSessionDataTask *task, NSError *error) {}];
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
    CCLog(@"%@", error);
}

#pragma mark - AFNetworkingReachabilityManager target methods

- (void)reachabilityDidChangeNotification:(NSNotification *)note
{
    BOOL reachable = [AFNetworkReachabilityManager sharedManager].reachable;
    CCSignUpView *view = (CCSignUpView *)self.view;
    view.reachable = reachable;
    
    if (reachable) {
        [self checkSignupFailure];
    }
}

@end
