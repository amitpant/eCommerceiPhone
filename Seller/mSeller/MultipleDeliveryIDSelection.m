//
//  MultipleDeliveryIDSelection.m
//  mSeller
//
//  Created by Ashish Pant on 11/10/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "MultipleDeliveryIDSelection.h"

@implementation MultipleDeliveryIDSelection
-(id)initWithDeliveryValuesSign:(int)deliveryId_Sign
{
    self = [super init];
    if(self)
    {
      
        self.deliveryIDSign = deliveryId_Sign;
    }
    
    return self;
    
}

@end
