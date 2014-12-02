//
//  CCStreetAddressAutoComplete.m
//  Linotte
//
//  Created by stant on 24/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCStreetAddressAutoComplete.h"

#import <AFNetworking/AFNetworking.h>

#import "CCAddressAutocompletionResult.h"

@implementation CCStreetAddressAutoComplete
{
    AFHTTPSessionManager *_manager;
    
    NSString *_apiKey;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://maps.googleapis.com"]];
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        _apiKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"google_map_browser_api_key"];
    }
    return self;
}

- (NSDictionary *)argsForText:(NSString *)text
{
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSMutableDictionary *args = [@{@"key" : _apiKey, @"language" : language, @"types" : @"address", @"input" : text} mutableCopy];
    
    return [args copy];
}

- (void)callWebService:(NSString *)text
{
    NSDictionary *args = [self argsForText:text];
    [_manager GET:@"/maps/api/place/autocomplete/json" parameters:args success:^(NSURLSessionDataTask *task, NSDictionary *response) {

        [self clearResults];
        
        for (NSDictionary *prediction in response[@"predictions"]) {
            CCAddressAutocompletionResult *autocompletionResult = [CCAddressAutocompletionResult new];
            autocompletionResult.name = prediction[@"description"];
            autocompletionResult.provider = @"google";
            autocompletionResult.providerId = prediction[@"place_id"];
            [self addResult:autocompletionResult];
        }
        [self requestEnded];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self requestEnded];
    }];
}

- (void)fetchCompleteInfosForResultAtIndex:(NSUInteger)index completionBlock:(void(^)(CCAddressAutocompletionResult *result))completionBlock
{
    CCAddressAutocompletionResult *result = [self autocompletionResultAtIndex:index];
    NSDictionary *args = @{@"key": _apiKey, @"placeid" : result.providerId};
    [_manager GET:@"/maps/api/place/details/json" parameters:args success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        CCAddressAutocompletionResult *infos = [CCAddressAutocompletionResult new];
        
        infos.address = response[@"result"][@"formatted_address"];
        infos.provider = @"google";
        infos.providerId = response[@"result"][@"place_id"];
        
        CGFloat latitude = [response[@"result"][@"geometry"][@"location"][@"lat"] floatValue];
        CGFloat longitude = [response[@"result"][@"geometry"][@"location"][@"lng"] floatValue];
        infos.coordinates = CLLocationCoordinate2DMake(latitude, longitude);
        
        completionBlock(infos);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionBlock(nil);
    }];
}

@end
