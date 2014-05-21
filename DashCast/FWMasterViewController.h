//
//  FWMasterViewController.h
//  DashCast
//
//  Created by Alex Glenn on 5/20/14.
//  Copyright (c) 2014 Findaway World. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FWAddDashboardViewController;

@interface FWMasterViewController : UITableViewController <UIActionSheetDelegate>

@property (strong, nonatomic) FWAddDashboardViewController *addDashboardViewController;

@end
