//
//  CCSearchViewController.m
//  Linotte
//
//  Created by stant on 11/02/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCSearchViewController.h"

#import "CCLinotteCoreDataStack.h"
#import "CCLocationMonitor.h"

#import "CCListOutputViewController.h"
#import "CCOutputViewController.h"

#import "CCSearchView.h"

#import "CCList.h"
#import "CCAddress.h"

@implementation CCSearchViewController
{
    NSString *_lastSearchString;
    
    CCList *_filterList;
    
    NSArray *_lists;
    NSArray *_addresses;
    
    CLLocation *_location;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[CCLocationMonitor sharedInstance] addDelegate: self];
    }
    return self;
}

- (instancetype)initWithList:(CCList *)list
{
    self = [super init];
    if (self) {
        _filterList = list;
        [[CCLocationMonitor sharedInstance] addDelegate: self];
    }
    return self;
}

- (void)dealloc
{
    [[CCLocationMonitor sharedInstance] removeDelegate:self];
}

- (void)loadView
{
    CCSearchView *view = [CCSearchView new];
    view.delegate = self;
    self.view = view;
}

- (NSArray *)fetchResultsForEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate
{
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:20];
    
    NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:@[nameSortDescriptor]];
    
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error != nil) {
        CCLog(@"%@", error);
    }
    return results;
}

- (void)updateListsForSearchString:(NSString *)searchString
{
    if ([searchString length] == 0 || _filterList != nil) {
        _lists = @[];
        return; 
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@ OR author CONTAINS[cd] %@", searchString, searchString];
    _lists = [self fetchResultsForEntityName:[CCList entityName] predicate:predicate];
}

- (void)updateAddressesForSearchString:(NSString *)searchString
{
    if ([searchString length] == 0) {
        _addresses = @[];
        return;
    }
    NSPredicate *predicate = nil;
    if (_filterList != nil) {
        predicate = [NSPredicate predicateWithFormat:@"(name CONTAINS[cd] %@ OR address CONTAINS[cd] %@) AND ANY lists = %@", searchString, searchString, _filterList];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@ OR address CONTAINS[cd] %@", searchString, searchString];
    }
    _addresses = [self fetchResultsForEntityName:[CCAddress entityName] predicate:predicate];
}

- (void)updateSearchString:(NSString *)searchString
{
    if ([searchString isEqualToString:_lastSearchString])
        return;
    _lastSearchString = searchString;
    [self updateListsForSearchString:searchString];
    [self updateAddressesForSearchString:searchString];
    
    CCSearchView *view = (CCSearchView *)self.view;
    [view reloadTableView];
}

#pragma mark - CCSeachViewDelegate methods

- (BOOL)showSections
{
    return _filterList == nil;
}

- (UIImage *)listIconAtIndex:(NSUInteger)index
{
    return [UIImage imageNamed:@"list_pin_neutral"];
}

- (NSString *)listNameAtIndex:(NSUInteger)index
{
    CCList *list = _lists[index];
    return list.name;
}

- (NSString *)listDetailAtIndex:(NSUInteger)index
{
    CCList *list = _lists[index];
    return list.author;
}

-(UIImage *)addressIconAtIndex:(NSUInteger)index
{
    CCAddress *address = _addresses[index];
    CGFloat distance = [_location distanceFromLocation:[[CLLocation alloc] initWithLatitude:address.latitudeValue longitude:address.longitudeValue]];
    NSArray *distanceColors = kCCLinotteColors;
    NSString *imagePath = nil;
    int distanceColorIndex = distance / 500;
    distanceColorIndex = MIN(distanceColorIndex, (int)[distanceColors count] - 1);
    if (distance > 0) {
        NSString *color = distanceColors[distanceColorIndex];
        imagePath = [NSString stringWithFormat:@"gmap_pin_%@", [color substringFromIndex:1]];
    } else
        imagePath = @"gmap_pin_neutral";
    return [UIImage imageNamed:imagePath];
}

- (NSString *)addressNameAtIndex:(NSUInteger)index
{
    CCAddress *address = _addresses[index];
    return address.name;
}

- (NSString *)addressDetailAtIndex:(NSUInteger)index
{
    CCAddress *address = _addresses[index];
    NSString *listDetail = [[[address.lists allObjects] valueForKeyPath:@"@distinctUnionOfObjects.match"] componentsJoinedByString:@", "];
    return [NSString stringWithFormat:@"%@\n%@", address.address, listDetail];
}

- (NSUInteger)numberOfLists
{
    return [_lists count];
}

- (NSUInteger)numberOfAddresses
{
    return [_addresses count];
}

- (void)closeButtonPressed
{
    [_delegate closeSearchViewController];
}

- (void)listSelectedAtIndex:(NSUInteger)index
{
    CCList *list = _lists[index];
    CCListOutputViewController *listOutputViewController = [[CCListOutputViewController alloc] initWithList:list];
    [self.navigationController pushViewController:listOutputViewController animated:YES];
}

- (void)addressSelectedAtIndex:(NSUInteger)index
{
    CCAddress *address = _addresses[index];
    CCOutputViewController *outputViewController = [[CCOutputViewController alloc] initWithAddress:address];
    [self.navigationController pushViewController:outputViewController animated:YES];
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    _location = [locations lastObject];
}

@end
