//
//  globalObject.h
//  mSeller
//
//  Created by WCT iMac on 05/02/16.
//  Copyright © 2016 Williams Commerce Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#define globalObjectDelegate ((globalObject *)[globalObject sharedInstance])
@interface globalObject : NSObject
@property (nonatomic,strong) NSMutableArray *deliveryAddArray;

+ (globalObject*)sharedInstance;
@end
