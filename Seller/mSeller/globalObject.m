//
//  globalObject.m
//  mSeller
//
//  Created by WCT iMac on 05/02/16.
//  Copyright © 2016 Williams Commerce Ltd. All rights reserved.
//

#import "globalObject.h"

@implementation globalObject
static globalObject* sharedInstanceManager;

+ (globalObject*)sharedInstance{
    if (sharedInstanceManager == nil) {
        @synchronized(self) {
            if (sharedInstanceManager == nil) {
                sharedInstanceManager = [[super allocWithZone:NULL] init];
            }
        }
    }
    return sharedInstanceManager;
}

+(id)allocWithZone:(NSZone *)zone{
    return [self sharedInstance];
}

+(id)copyWithZone:(NSZone *)zone{
    return self;
}

@end
