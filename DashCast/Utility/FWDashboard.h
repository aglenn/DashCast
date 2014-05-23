//
//  FWDashboard.h
//  DashCast
//
//  Created by Alex Glenn on 5/20/14.
//  Copyright (c) 2014 Findaway World. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FWDashboard : NSObject
@property NSString *prettyName;
@property NSURL *dasboardURL;
@property uint64_t displayTime;

-(FWDashboard*)initWithName:(NSString*)name URL:(NSURL*)url displayTime:(uint64_t)displayTime;
-(NSDictionary*)dictionaryRepresentation;
-(FWDashboard*)initWithDictionary:(NSDictionary*) d;
@end
