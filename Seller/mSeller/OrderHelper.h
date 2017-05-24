//
//  OrderHelper.h
//  mSeller
//
//  Created by WCT iMac on 03/11/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderHelper : NSObject

+ (void)getNewOrderNumberWithRepId:(NSString * __nullable)repid Company:(NSInteger)compid IsCopying:(BOOL)iscopying CompletionBlock:(void(^__nonnull) (NSString * __nullable newordernumber)) completionblock;
+(void)setNextOrderNumberWithRepId:(NSString *__nullable)repid CompanyId:(NSInteger)compid NextOrderSeqquence:(NSInteger)nextorderno;

+ (BOOL)addOLinewithorderNumber:(NSString* __nullable)orderNumber productInfo:(NSManagedObject* __nullable)prodInfo orderQty:(NSString*__nullable)qty orderPrice:(double)ordPrice discount:(double)ordDis deliveryAdd:(NSString* __nullable)delAdd deliveryDate:(NSDate*__nullable)delDate   expectedDate:(NSDate* __nullable)expDate oLineType:(NSString*__nullable)oLineType oLinePackType:(NSString*__nullable)orderpacktype LineNumber:(NSString*__nullable)lineno TransactionInfo:(NSManagedObject *__nullable)oheadnew;

//Add oLine from product controller
+ (BOOL)addOLinewithorderNumber:(NSString*__nullable )orderNumber productInfo:(NSManagedObject* __nullable )prodInfo orderQty:(NSString*__nullable)qty orderPrice:(double)ordPrice deliveryAdd:(NSString* __nullable)delAdd deliveryDate:(NSDate* __nullable)delDate  oLineType:(NSString*__nullable)oLineType oLinePackType:(NSString*__nullable)orderpacktype LineNumber:(NSString*__nullable)lineno  TransactionInfo:(NSManagedObject *__nullable)oheadnew;


//+ (BOOL)deleteOLinewithorderNumber:(NSString* )orderNumber productInfo:(NSManagedObject* )prodInfo;

//update data Address
+ (BOOL)updateOlineFields:(NSString* __nullable)keyName  UpdateValue:(id __nullable)updateValue   StockCode:(NSString* __nullable)stockCode OrderNumber:(NSString* __nullable)orderNo ;


@end
