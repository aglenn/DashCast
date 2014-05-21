//
//  FWAddDashboardViewController.m
//  DashCast
//
//  Created by Alex Glenn on 5/20/14.
//  Copyright (c) 2014 Findaway World. All rights reserved.
//

#import "FWAddDashboardViewController.h"
#import "FWDashboard.h"

@interface FWAddDashboardViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UITextField *durationTextField;
@property (weak, nonatomic) IBOutlet UIButton *addButton;

@end

@implementation FWAddDashboardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (_dashboard) {
        [_nameTextField setText:_dashboard.prettyName];
        [_urlTextField setText:_dashboard.dasboardURL.absoluteString];
        [_durationTextField setText:[NSString stringWithFormat:@"%llu", _dashboard.displayTime]];
        
        [_addButton setTitle:@"Update" forState:UIControlStateNormal];
        [_addButton addTarget:self action:@selector(updateDashboard:) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationItem setTitle:@"Update the dashboard"];
        self.navigationItem.leftBarButtonItem = nil;
    }
}

-(void)setDashboard:(FWDashboard *)dashboard {
    
    NSLog(@"Update the dashboard");
    _dashboard = dashboard;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)addDashboard:(id)sender {
    if (_nameTextField.text.length && [_urlTextField.text componentsSeparatedByString:@"http://"].count > 1 && _durationTextField.text.longLongValue > 0 && _durationTextField.text.longLongValue < 1440) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddDashboard" object:self userInfo:@{@"name":_nameTextField.text, @"url":[NSURL URLWithString:_urlTextField.text], @"duration":@(_durationTextField.text.longLongValue)}];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Dashboard" message:@"The dashboard must have a name, vaild URL, and a duration between 1 and 1440 seconds" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)updateDashboard:(id)sender {
    if (_nameTextField.text.length && [_urlTextField.text componentsSeparatedByString:@"http://"].count > 1 && _durationTextField.text.longLongValue > 0 && _durationTextField.text.longLongValue < 1440) {
        [_dashboard setPrettyName:_nameTextField.text];
        [_dashboard setDasboardURL:[NSURL URLWithString:_urlTextField.text]];
        [_dashboard setDisplayTime:_durationTextField.text.longLongValue];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Dashboard" message:@"The dashboard must have a name, vaild URL, and a duration between 1 and 1440 seconds" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
