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

- (void)processAccountCreationWithFailure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    if ([AFNetworkReachabilityManager sharedManager].isReachable) {
        [CCLEC.authenticationManager createAccountOrLoginWithSuccess:^{
            [_delegate signupCompleted];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            CCLog(@"%@", error);
            NSDictionary *response = [CCLEC.linotteAPI errorDescription:task error:error];
            NSLog(@"%@", response);
            failureBlock(task, error);
        }];
    }
}

#pragma mark - CCSignupViewController

- (void)loginSignupButtonPressed:(NSString *)email password:(NSString *)password
{
    [CCLEC.authenticationManager addAuthMethodWithEmail:email password:password];
    
    [self processAccountCreationWithFailure:^(NSURLSessionDataTask *task, NSError *error) {
        // TODO already taken
    }];
}

#pragma mark - FBLoginViewDelegate methods

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    [CCLEC.authenticationManager addAuthMethodWithFacebookAccount:user];
    
    [self processAccountCreationWithFailure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
    NSLog(@"%@", error);
}

@end
