//
//  FWDashboard.m
//  DashCast
//
//  Created by Alex Glenn on 5/20/14.
//  Copyright (c) 2014 Findaway World. All rights reserved.
//

#import "FWDashboard.h"

@implementation FWDashboard
-(FWDashboard*)initWithName:(NSString*)name URL:(NSURL*)url displayTime:(uint64_t)displayTime {
    self= [super init];
    if (self) {
        _prettyName = name;
        _dasboardURL = url;
        _displayTime = displayTime;
    }
    return self;
}

- (FWDashboard*)initWithDictionary:(NSDictionary*) d {
    self = [super init];
    if (self) {
        self.prettyName = [d objectForKey:@"name"];
        self.dasboardURL = [NSURL URLWithString:[d objectForKey:@"url"]];
        self.displayTime = [[d objectForKey:@"duration"] longLongValue];
    }
    return self;
}

-(NSDictionary*)dictionaryRepresentation {
    return @{@"name":_prettyName,@"url":_dasboardURL.absoluteString,@"duration":@(_displayTime)};
}

@end
