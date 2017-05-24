//
//  PushNoAnimationSegue.m
//  mSeller
//
//  Created by WCT iMac on 04/11/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "PushNoAnimationSegue.h"

@implementation PushNoAnimationSegue
-(void) perform{
    [[[self sourceViewController] navigationController] pushViewController:[self   destinationViewController] animated:NO];
}
@end
