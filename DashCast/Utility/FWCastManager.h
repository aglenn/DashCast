//
//  FWCastManager.h
//  DashCast
//
//  Created by Alex Glenn on 5/21/14.
//  Copyright (c) 2014 Findaway World. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleCast/GoogleCast.h>

@class FWDashChannel;

@interface FWCastManager : NSObject <GCKDeviceManagerDelegate, GCKDeviceScannerListener>
@property GCKDeviceScanner *deviceScanner;
@property GCKDeviceManager *deviceManager;
@property GCKApplicationMetadata *applicationMetadata;
@property FWDashChannel *dashChannel;

+(FWCastManager*)sharedManager;
-(void)connectToDeviceAtIndex:(uint32_t)index;

@end
