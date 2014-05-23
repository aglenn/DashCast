//
//  FWDashboardListManager.m
//  DashCast
//
//  Created by Alex Glenn on 5/20/14.
//  Copyright (c) 2014 Findaway World. All rights reserved.
//

#import "FWDashboardListManager.h"
#import "FWDashboard.h"
#import <Parse/Parse.h>

@implementation FWDashboardListManager

static FWDashboardListManager *sharedManager = nil;
static dispatch_once_t onceToken;

-(FWDashboardListManager*)init {
    self = [super init];
    if (self) {
        [self loadDashboards];
    }
    return self;
}

+(FWDashboardListManager*)sharedManager {
    dispatch_once(&onceToken, ^{
        sharedManager = [[FWDashboardListManager alloc] init];
    });
    return sharedManager;
}

-(void)saveDashboards {
//    NSUserDefaults *sharedDefaults = [NSUserDefaults standardUserDefaults];
//    
//    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_dashboards];
//    [sharedDefaults setObject:data forKey:@"dashboards"];
//    
//    [sharedDefaults synchronize];
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"DashboardsData"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count) {
                
                //NSLog(@"Count is %d", objects.count);
                PFObject *dashboardsObject = objects[0];
                dashboardsObject[@"dashboards"] = [self jsonStringRepresentation];
                [dashboardsObject saveInBackground];
            }
            else {
                //NSLog(@"No count");
                PFObject *dashboardsObject = [PFObject objectWithClassName:@"DashboardsData"];
                dashboardsObject[@"dashboards"] = [self jsonStringRepresentation];
                [dashboardsObject saveInBackground];
            }
        }
        else {
            NSLog(@"Error");
        }
    }];
}

-(void)loadDashboards {

    PFQuery *query = [PFQuery queryWithClassName:@"DashboardsData"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error && objects.count) {

            PFObject *dashboardsObject = objects[0];
            NSString *data = dashboardsObject[@"dashboards"];
            NSArray *dashboardsArray = [NSJSONSerialization JSONObjectWithData:[data dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            
            _dashboards = [[NSMutableArray alloc] init];
            
            for (NSDictionary *d in dashboardsArray) {
                FWDashboard *dash = [[FWDashboard alloc] initWithDictionary:d];
                [_dashboards addObject:dash];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DashboardsUpdated" object:self];
        }
    }];
    
    
    
    if (!_dashboards) {
        _dashboards = [[NSMutableArray alloc] init];
    }

}

-(NSString*)jsonStringRepresentation {
    NSMutableArray *dictionaryArray = [[NSMutableArray alloc] init];
    
    for (FWDashboard *d in _dashboards) {
        [dictionaryArray addObject:[d dictionaryRepresentation]];
    }
    
    NSData *jsonDict = [NSJSONSerialization dataWithJSONObject:dictionaryArray options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonDict encoding:NSUTF8StringEncoding];
    return jsonString;
}

@end
