//
//  FWCastManager.m
//  DashCast
//
//  Created by Alex Glenn on 5/21/14.
//  Copyright (c) 2014 Findaway World. All rights reserved.
//

#import "FWCastManager.h"
#import "FWDashChannel.h"
#import "FWDashboardListManager.h"

@implementation FWCastManager

static FWCastManager *sharedManager = nil;
static dispatch_once_t onceToken;

-(FWCastManager*)init {
    self = [super init];
    if (self) {
        _deviceScanner = [[GCKDeviceScanner alloc] init];
        [_deviceScanner addListener:self];
        [_deviceScanner startScan];
    }
    return self;
}

+(FWCastManager*)sharedManager {
    dispatch_once(&onceToken, ^{
        sharedManager = [[FWCastManager alloc] init];
    });
    return sharedManager;
}

-(void)connectToDeviceAtIndex:(uint32_t)index {
    GCKDevice *selectedDevice = self.deviceScanner.devices[index];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *info = [bundle infoDictionary];
    _deviceManager = [[GCKDeviceManager alloc] initWithDevice:selectedDevice clientPackageName:[info objectForKey:@"CFBundleIdentifier"]];
    
    _deviceManager.delegate = self;
    [_deviceManager connect];
}

#pragma mark - GCKDeviceScannerListener
- (void)deviceDidComeOnline:(GCKDevice *)device {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DevicesUpdated" object:self];
}

- (void)deviceDidGoOffline:(GCKDevice *)device {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DevicesUpdated" object:self];
}

#pragma mark - GCKDeviceManagerDelegate
- (void)deviceManagerDidConnect:(GCKDeviceManager *)deviceManager {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ConnectionUpdated" object:self];
    
    [self.deviceManager launchApplication:@"8989B5DB"];
    NSLog(@"Connected to %@", deviceManager.device.friendlyName);
}

-(void)deviceManager:(GCKDeviceManager *)deviceManager didDisconnectWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ConnectionUpdated" object:self];
    
    NSLog(@"Disconnected from %@ with error: %@", deviceManager.device.friendlyName, error.localizedDescription);
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
didReceiveStatusForApplication:(GCKApplicationMetadata *)applicationMetadata {
    _applicationMetadata = applicationMetadata;
    
    NSLog(@"Received device status: %@", applicationMetadata);
}


- (void)deviceManager:(GCKDeviceManager *)deviceManager
didConnectToCastApplication:(GCKApplicationMetadata *)applicationMetadata
            sessionID:(NSString *)sessionID
  launchedApplication:(BOOL)launchedApplication {
    NSLog(@"application has launched %hhd", launchedApplication);
    
    _dashChannel = [[FWDashChannel alloc] initWithNamespace:@"urn:x-cast:com.findawayworld.dashcast"];
    [self.deviceManager addChannel:self.dashChannel];
    
    [self.dashChannel sendTextMessage:[[FWDashboardListManager sharedManager] jsonStringRepresentation]];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
didFailToConnectToApplicationWithError:(NSError *)error {
    NSLog(@"Failed to connect to application with ERROR: %@", error.localizedDescription);
}

@end
