//
//  CCAutoCompleteAddressName.m
//  Linotte
//
//  Created by stant on 22/10/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAddressNameAutoCompleter.h"

#import <AFNetworking/AFNetworking.h>

#import "CCAddressAutocompletionResult.h"
#import "CCAddressAutocompletionResultCategorie.h"

#import "CCGeohashHelper.h"

#import "CCLocationMonitor.h"

@implementation CCAddressNameAutoCompleter
{
    AFHTTPSessionManager *_manager;
    
    NSString *_clientSecret;
    NSString *_clientId;
    NSString *_version;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.foursquare.com"]];
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        _clientSecret = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"foursquare_client_secret"];
        _clientId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"foursquare_client_id"];
        _version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"foursquare_version"];
    }
    return self;
}

#pragma mark - Foursquare methods

- (NSDictionary *)argsForText:(NSString *)text
{
    NSMutableDictionary *args = [@{@"client_id" : _clientId, @"client_secret" : _clientSecret, @"v" : _version, @"intent" : @"checkin", @"query" : text} mutableCopy];
    
    NSString *locationString = [NSString stringWithFormat:@"%f,%f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude];
    args[@"ll"] = locationString;
    args[@"radius"] = @"1000000000000";
    
    return [args copy];
}

- (void)callWebService:(NSString *)text
{
    NSDictionary *args = [self argsForText:text];
    [_manager GET:@"/v2/venues/search/" parameters:args success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        // exclude categories
        NSArray *excludedCategories = @[@"50aa9e094b90af0d42d5de0d", @"5345731ebcbc57f1066c39b2", @"530e33ccbcbc57f1066bbff7", @"4f2a25ac4b909258e854f55f", @"530e33ccbcbc57f1066bbff8", @"530e33ccbcbc57f1066bbff3", @"530e33ccbcbc57f1066bbff9"];
        NSArray *venues = [response[@"response"][@"venues"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SUBQUERY(categories, $category, $category.identifier IN %@).@count = 0", excludedCategories]];
        
        [self clearResults];
        
        for (NSDictionary *venue in venues) {
            CCAddressAutocompletionResult *autocompletionResult = [CCAddressAutocompletionResult new];
            NSString *addressString = [venue[@"location"][@"formattedAddress"] componentsJoinedByString:@", "];
            
            NSMutableArray *categories = [@[] mutableCopy];
            for (NSDictionary *categorie in venue[@"categories"]) {
                CCAddressAutocompletionResultCategorie *autocompletionCategorie = [CCAddressAutocompletionResultCategorie new];
                autocompletionCategorie.identifier = categorie[@"id"];
                autocompletionCategorie.name = categorie[@"name"];
                [categories addObject:autocompletionCategorie];
            }
            
            autocompletionResult.name = venue[@"name"];
            autocompletionResult.address = addressString;
            autocompletionResult.categories = categories;
            autocompletionResult.provider = @"foursquare";
            autocompletionResult.providerId = venue[@"id"];
            autocompletionResult.coordinates = CLLocationCoordinate2DMake([venue[@"location"][@"lat"] doubleValue], [venue[@"location"][@"lng"] doubleValue]);
            [self addResult:autocompletionResult];
        }
        [self requestEnded];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self requestEnded];
    }];
}

@end
