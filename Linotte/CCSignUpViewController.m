//
//  CCFacebookOverlayViewController.m
//  Linotte
//
//  Created by stant on 08/12/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCSignUpViewController.h"

#import "CCLinotteAPI.h"
#import "CCCoreDataStack.h"
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
    [[CCLinotteAPI sharedInstance] createAndAuthenticateUser:email password:password completionBlock:^(BOOL success) {
        if (success == YES) {
            [_delegate signupCompleted];
        }
    }];
}

#pragma mark - FBLoginViewDelegate methods

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    FBAccessTokenData *accessTokenData = [FBSession activeSession].accessTokenData;
    [[CCLinotteAPI sharedInstance] createAndAuthenticateUserWithSocialAccount:@"facebook" socialIdentifier:user.objectID oauthToken:accessTokenData.accessToken refreshToken:@"" expirationDate:accessTokenData.expirationDate userName:user.username firstName:user.first_name lastName:user.last_name email:user[@"email"] completionBlock:^(BOOL success, NSString *identifier) {
        if (success) {
            NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
            CCSocialAccount *socialAccount = [CCSocialAccount insertInManagedObjectContext:managedObjectContext];
            socialAccount.socialIdentifier = user.objectID;
            socialAccount.mediaIdentifier = @"facebook";
            socialAccount.authToken = accessTokenData.accessToken;
            socialAccount.expirationDate = accessTokenData.expirationDate;
            socialAccount.identifier = identifier;
            [[CCCoreDataStack sharedInstance] saveContext];
            
            [_delegate signupCompleted];
        } else {
            [[FBSession activeSession] closeAndClearTokenInformation];
        }
    }];
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
    NSLog(@"%@", error);
}

@end
