//
//  FWDashboardListManager.m
//  DashCast
//
//  Created by Alex Glenn on 5/20/14.
//  Copyright (c) 2014 Findaway World. All rights reserved.
//

#import "FWDashboardListManager.h"
#import "FWDashboard.h"

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
    NSUserDefaults *sharedDefaults = [NSUserDefaults standardUserDefaults];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_dashboards];
    [sharedDefaults setObject:data forKey:@"dashboards"];
    
    [sharedDefaults synchronize];
}

-(void)loadDashboards {
    NSUserDefaults *sharedDefaults = [NSUserDefaults standardUserDefaults];
    
    NSData *data = [sharedDefaults objectForKey:@"dashboards"];
    _dashboards = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
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
