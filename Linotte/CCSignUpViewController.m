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

#import "CCSignUpView.h"

#import "CCAuthMethod.h"

@interface CCSignUpViewController ()

@end

@implementation CCSignUpViewController

- (void)loadView
{
    CCSignUpView *view = [CCSignUpView new];
    view.delegate = self;
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

- (void)processAccountCreationWithAuthMethod:(CCAuthMethod *)authMethod failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    if ([AFNetworkReachabilityManager sharedManager].isReachable) {
        [CCLEC.authenticationManager createAccountOrLoginWithAuthMethod:authMethod success:^{
            [_delegate signupCompleted];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            CCLog(@"%@", error);
            NSDictionary *response = [CCLEC.linotteAPI errorDescription:task error:error];
            NSLog(@"%@", response);
            
            NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
            [managedObjectContext deleteObject:authMethod];
            [[CCLinotteCoreDataStack sharedInstance] saveContext];
            
            failureBlock(task, error);
        }];
    }
}

#pragma mark - CCSignupViewController

- (void)loginSignupButtonPressed:(NSString *)email password:(NSString *)password
{
    CCAuthMethod *authMethod = [CCLEC.authenticationManager addAuthMethodWithEmail:email password:password];
    
    [self processAccountCreationWithAuthMethod:authMethod failure:^(NSURLSessionDataTask *task, NSError *error) {
    }];
}

#pragma mark - FBLoginViewDelegate methods

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    CCAuthMethod *authMethod = [CCLEC.authenticationManager addAuthMethodWithFacebookAccount:user];
    
    [self processAccountCreationWithAuthMethod:authMethod failure:^(NSURLSessionDataTask *task, NSError *error) {
    }];
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
    NSLog(@"%@", error);
}

@end
