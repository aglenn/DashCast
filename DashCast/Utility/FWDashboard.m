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

- (FWDashboard*)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.prettyName = [decoder decodeObjectForKey:@"prettyName"];
        self.dasboardURL = [decoder decodeObjectForKey:@"dasboardURL"];
        self.displayTime = [[decoder decodeObjectForKey:@"displayTime"] longLongValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.prettyName forKey:@"prettyName"];
    [encoder encodeObject:self.dasboardURL forKey:@"dasboardURL"];
    [encoder encodeObject:@(self.displayTime) forKey:@"displayTime"];
}

-(NSDictionary*)dictionaryRepresentation {
    return @{@"name":_prettyName,@"url":_dasboardURL.absoluteString,@"duration":@(_displayTime)};
}

@end
