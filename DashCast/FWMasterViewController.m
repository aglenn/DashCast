//
//  FWMasterViewController.m
//  DashCast
//
//  Created by Alex Glenn on 5/20/14.
//  Copyright (c) 2014 Findaway World. All rights reserved.
//

#import "FWMasterViewController.h"
#import "FWAddDashboardViewController.h"

#import "FWDashboard.h"
#import "FWDashboardListManager.h"
#import "FWCastManager.h"

#import <GoogleCast/GoogleCast.h>

@interface FWMasterViewController()
@property uint8_t castImageNumber;
@property UIActionSheet *sheet;
@end

@implementation FWMasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.addDashboardViewController = (FWAddDashboardViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    [[FWDashboardListManager sharedManager] loadDashboards];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkCast) name:@"DevicesUpdated" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:@"DashboardsUpdated" object:nil];
    
    _castImageNumber = 0;
    
    [FWCastManager sharedManager];
}

-(void)viewDidAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AddDashboard" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addObject:) name:@"AddDashboard" object:nil];
    [self performSegueWithIdentifier:@"AddDashboard" sender:self];
}

-(void)addObject:(NSNotification*)n {
    FWDashboard *dashboard = [[FWDashboard alloc] initWithName:n.userInfo[@"name"] URL:n.userInfo[@"url"] displayTime:[(NSNumber*)n.userInfo[@"duration"] longLongValue]];
    [[FWDashboardListManager sharedManager].dashboards insertObject:dashboard atIndex:0];
    [[FWDashboardListManager sharedManager] saveDashboards];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [[FWCastManager sharedManager] sendUpdatedDashboards];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [FWDashboardListManager sharedManager].dashboards.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    FWDashboard *dashboard = [FWDashboardListManager sharedManager].dashboards[indexPath.row];
    cell.textLabel.text = dashboard.prettyName;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[FWDashboardListManager sharedManager].dashboards removeObjectAtIndex:indexPath.row];
        [[FWDashboardListManager sharedManager] saveDashboards];
        [[FWCastManager sharedManager] sendUpdatedDashboards];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        FWDashboard *dashboard = [FWDashboardListManager sharedManager].dashboards[indexPath.row];
        self.addDashboardViewController.dashboard = dashboard;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"UpdateDashboard"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        FWDashboard *dashboard = [FWDashboardListManager sharedManager].dashboards[indexPath.row];
        [[segue destinationViewController] setDashboard:dashboard];
    }
}

-(void)checkCast {
    if ([FWCastManager sharedManager].deviceScanner.devices.count) {
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
        
        UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 29, 22)]
        ;
        [b addTarget:self action:@selector(pickCast) forControlEvents:UIControlEventTouchUpInside];
        
        if ([FWCastManager sharedManager].deviceManager) { // we've tried to connect
            if ([FWCastManager sharedManager].deviceManager.isConnected) { // connected
                [b setBackgroundImage:[UIImage imageNamed:@"cast_on.png"] forState:UIControlStateNormal];
            }
            else { // still connecting
                [b setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"cast_on%d.png", _castImageNumber]] forState:UIControlStateNormal];
                _castImageNumber++;
                _castImageNumber %= 3;
                [self performSelector:@selector(checkCast) withObject:nil afterDelay:.75];
            }
        }
        else {
            [b setBackgroundImage:[UIImage imageNamed:@"cast_off.png"] forState:UIControlStateNormal];
        }
        
        UIBarButtonItem *castButton = [[UIBarButtonItem alloc] initWithCustomView:b];
        [self.navigationItem setRightBarButtonItems:@[castButton, addButton]];
    }
    else {
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
        self.navigationItem.rightBarButtonItem = addButton;
    }
}

-(void)pickCast {
    _sheet = [[UIActionSheet alloc] initWithTitle:@"Select a Device" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
    
    [_sheet addButtonWithTitle:@"Disconnect"];
    for( GCKDevice* device in [FWCastManager sharedManager].deviceScanner.devices ){
        [_sheet addButtonWithTitle:device.friendlyName];
    }
    
    [_sheet addButtonWithTitle:@"Cancel"];
    
    [_sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"Touched %d", buttonIndex);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ConnectionUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkCast) name:@"ConnectionUpdated" object:nil];
    
    if (buttonIndex == 0) {
        [[FWCastManager sharedManager].deviceManager disconnect];
        [FWCastManager sharedManager].deviceManager = nil;
    }
    else if(buttonIndex == actionSheet.numberOfButtons - 1) {
        
    }
    else {
        [[FWCastManager sharedManager] connectToDeviceAtIndex:buttonIndex - 1];
    }
    
}

@end
