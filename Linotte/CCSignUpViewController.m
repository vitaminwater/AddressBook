//
//  CCFacebookOverlayViewController.m
//  Linotte
//
//  Created by stant on 08/12/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCSignUpViewController.h"

#import "CCLinotteEngineCoordinator.h"
#import "CCLinotteAPI.h"
#import "CCLinotteCoreDataStack.h"
#import "CCLinotteAuthenticationManager.h"
#import <SSKeychain/SSKeychain.h>

#import "CCSignUpView.h"

#import "CCSocialAccount.h"

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

#pragma mark - CCSignupViewController

- (void)loginSignupButtonPressed:(NSString *)email password:(NSString *)password
{
    [CCLEC.authenticationManager setCredentials:email password:password];
    [CCLEC.authenticationManager syncWithSuccess:^{
        [_delegate signupCompleted];
    } failure:^(NSError *error) {
        if (CCLEC.authenticationManager.needsCredentials == NO)
            [_delegate signupCompleted];
        // TODO check if network failure
    }];
}

#pragma mark - FBLoginViewDelegate methods

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    [CCLEC.authenticationManager setCredentials:user[@"email"] password:[CCLEC.linotteAPI UUID:0]];
    [CCLEC.authenticationManager associateFacebookAccount:user];
    [CCLEC.authenticationManager syncWithSuccess:^{
        [_delegate signupCompleted];
    } failure:^(NSError *error) {
        if (CCLEC.authenticationManager.needsCredentials == NO)
            [_delegate signupCompleted];
        // TODO check if network failure
    }];
    // FBAccessTokenData *accessTokenData = [FBSession activeSession].accessTokenData;
    // NSDictionary *parameters = @{@"social_meda_identifier" : @"facebook", @"social_identifier" : user.objectID, @"oauth_token" : accessTokenData.accessToken, @"refresh_token" : @"", @"expiration_date" : accessTokenData.expirationDate};
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
    NSLog(@"%@", error);
}

@end
