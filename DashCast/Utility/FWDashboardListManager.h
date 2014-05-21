//
//  FWDashboardListManager.h
//  DashCast
//
//  Created by Alex Glenn on 5/20/14.
//  Copyright (c) 2014 Findaway World. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FWDashboardListManager : NSObject
@property NSMutableArray *dashboards;

+(FWDashboardListManager*)sharedManager;

-(void)loadDashboards;
-(void)saveDashboards;
@end
