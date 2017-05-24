//
//  commonMethods.h
//  mSeller
//
//  Created by Mahendra Pratap Singh on 8/4/16.
//  Copyright © 2016 Williams Commerce Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface commonMethods : NSObject

+ (NSInteger) findTop20;
+ (NSInteger) findQuote;
+ (NSManagedObject* )fetch_customer :(NSString*)acc_ref deliverId:(NSString*)delId;
+ (NSString*)returnMaxBatchNofromoHeadNew;


+ (NSArray*)findInvoicesData :(NSManagedObject*)customer;
+ (NSArray*)findiLines:(NSManagedObject*)iheadObj;
+ (NSArray*)findOutstandingData:(NSManagedObject*)customer;
+ (NSArray*)findOLines:(NSManagedObject*)OheadObj;
+ (NSManagedObject*)findproduct:(NSString*)stockCode;


+ (NSManagedObject*)findLastPaid:(NSManagedObject*)Prod Cust:(NSManagedObject *)cust;
    
    
#pragma mark - mSeller Extra methods
+ (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate Hours:(NSInteger)Hr minutes:(NSInteger)min Seconds:(NSInteger)sec;

+ (NSString *)returnBaseAddress:(NSManagedObject *)delAdd;
+ (NSString *)returnCombinedAdd:(NSManagedObject*)custData;
+ (NSString *)returnBasePhoneNumber:(NSManagedObject *)CustdelAdd;
+ (NSString *)returnBaseContact:(NSManagedObject *)CustData;

@end
