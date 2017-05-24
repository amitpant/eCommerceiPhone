//
//  MultipleDeliveryIDSelection.h
//  mSeller
//
//  Created by Ashish Pant on 11/10/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MultipleDeliveryIDSelection : NSObject

@property ( nonatomic,assign) int deliveryIDSign;
-(id)initWithDeliveryValuesSign:(int)deliveryId_Sign;

@end
