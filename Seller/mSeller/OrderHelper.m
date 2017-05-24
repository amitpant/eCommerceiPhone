//
//  OrderHelper.m
//  mSeller
//
//  Created by WCT iMac on 03/11/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "OrderHelper.h"

@implementation OrderHelper


+ (void)getNewOrderNumberWithRepId:(NSString *)repid Company:(NSInteger)compid IsCopying:(BOOL)iscopying CompletionBlock:(void(^__nonnull) (NSString * __nullable newordernumber)) completionblock{
    
    __block NSInteger numOrder = 1;

    NSString *strrepid = repid;
    if([CommonHelper isNumeric:repid])
        strrepid = [NSString stringWithFormat:@"%02li",(long)[repid integerValue]];

    NSEntityDescription *entitySquence = [NSEntityDescription entityForName:@"NEWSEQUENCES" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSFetchRequest *transactionInfo = [[NSFetchRequest alloc] init];
    [transactionInfo setEntity:entitySquence];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rep_id==%@",kAppDelegate.repId];
    [transactionInfo setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *resultsSeq = [kAppDelegate.managedObjectContext executeFetchRequest:transactionInfo error:&error];
    
//    NSManagedObject* sequence = nil;
    if([resultsSeq count]>0){
//        sequence=[resultsSeq lastObject];
        numOrder = [[[resultsSeq lastObject] valueForKey:@"next_transaction_no"] integerValue];
        if(numOrder==0) numOrder++;
    }
    __block NSString *orderNumberString =[NSString stringWithFormat:@"%@%04li",strrepid,(long)numOrder];

    if([AFNetworkReachabilityManager sharedManager].reachable){
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:APIToken,@"token",[NSNumber numberWithInteger:kAppDelegate.selectedCompanyId],@"companyid",kAppDelegate.repId,@"repid",[NSNumber numberWithInteger:0],@"value", nil];
        [CommonHelper DownloadDataWithAPIName:(NSString *)kNextOrderAPI HTTPMethod:HTTTPMethodGET Params:params VirtualSavePath:nil ProgressBlock:nil CompletionBlock:^(BOOL issuccess, NSString * _Nullable errormessage, id  _Nullable response) {
            if(issuccess){
                if([[[response objectForKey:@"status"] objectForKey:@"success"] boolValue]){
                    NSInteger serverorderseq = [[[response objectForKey:@"data"] objectForKey:@"id"] integerValue];
                    if(numOrder<serverorderseq){
                        numOrder = serverorderseq;
                        orderNumberString =[NSString stringWithFormat:@"%@%04li",strrepid,(long)numOrder];
                    }
                }
            }
            if([self checkIfOrderNoAlreadyExistWithOrderNo:orderNumberString IsCopying:iscopying]){
                [self setNextOrderNumberWithRepId:repid CompanyId:compid NextOrderSeqquence:numOrder+1];
                [self getNewOrderNumberWithRepId:repid Company:compid IsCopying:iscopying CompletionBlock:completionblock];
            }
            else{
                completionblock(orderNumberString);
            }
        }];
    }
    else{
        if([self checkIfOrderNoAlreadyExistWithOrderNo:orderNumberString IsCopying:iscopying]){
            [self setNextOrderNumberWithRepId:repid CompanyId:compid NextOrderSeqquence:numOrder+1];
            
            [self getNewOrderNumberWithRepId:repid Company:compid IsCopying:iscopying CompletionBlock:completionblock];
        }
        else{
            completionblock(orderNumberString);
        }
    }
}

+(BOOL)checkIfOrderNoAlreadyExistWithOrderNo:(NSString *)orderno IsCopying:(BOOL)iscopying{
    NSEntityDescription *entitySquence = [NSEntityDescription entityForName:@"OHEADNEW" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSFetchRequest *transactionInfo = [[NSFetchRequest alloc] init];
    [transactionInfo setEntity:entitySquence];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"orderid==%@",orderno];
    if(!iscopying){
        if(kAppDelegate.transactionInfo){
            predicate = [NSPredicate predicateWithFormat:@"orderid==%@ && isopen!=1",orderno];
        }
    }

    [transactionInfo setPredicate:predicate];

    NSError *error = nil;
    NSArray *resultsSeq = [kAppDelegate.managedObjectContext executeFetchRequest:transactionInfo error:&error];

    return [resultsSeq count]>0;
}

+(void)setNextOrderNumberWithRepId:(NSString *)repid CompanyId:(NSInteger)compid NextOrderSeqquence:(NSInteger)nextorderno{
    NSEntityDescription *entitySquence = [NSEntityDescription entityForName:@"NEWSEQUENCES" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSFetchRequest *transactionInfo = [[NSFetchRequest alloc] init];
    [transactionInfo setEntity:entitySquence];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rep_id==%@",kAppDelegate.repId];
    [transactionInfo setPredicate:predicate];

    NSError *error = nil;
    NSArray *resultsSeq = [kAppDelegate.managedObjectContext executeFetchRequest:transactionInfo error:&error];

    NSManagedObject* sequence = nil;
    if([resultsSeq count]>0){
        sequence=[resultsSeq lastObject];
        [sequence setValue:[NSNumber numberWithInteger:nextorderno] forKey:@"next_transaction_no"];

        if (![kAppDelegate.managedObjectContext save:&error]) {
            NSLog(@"Failed to save - error: %@", [error localizedDescription]);
        }
    }

    if([AFNetworkReachabilityManager sharedManager].reachable){
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:APIToken,@"token",[NSNumber numberWithInteger:kAppDelegate.selectedCompanyId],@"companyid",kAppDelegate.repId,@"repid",[NSNumber numberWithInteger:nextorderno],@"value", nil];
        [CommonHelper DownloadDataWithAPIName:(NSString *)kNextOrderAPI HTTPMethod:HTTTPMethodPOST Params:params VirtualSavePath:nil ProgressBlock:nil CompletionBlock:^(BOOL issuccess, NSString * _Nullable errormessage, id  _Nullable response) {
            if(issuccess){

                
                
            }
        }];
    }
}


//Add oLine fron product controller
+ (BOOL)addOLinewithorderNumber:(NSString* )orderNumber productInfo:(NSManagedObject* __nullable)prodInfo orderQty:(NSString*__nullable)qty orderPrice:(double)ordPrice deliveryAdd:(NSString* __nullable)delAdd deliveryDate:(NSDate* __nullable)delDate oLineType:(NSString*__nullable)oLineType oLinePackType:(NSString*__nullable)orderpacktype LineNumber:(NSString*__nullable)lineno  TransactionInfo:(NSManagedObject *)oheadnew
{
    BOOL addStatus=NO;
    NSManagedObject *object;
    //    if (oLineInfo) {
    //        object=oLineInfo;
    //    }else
    //        object= [NSEntityDescription insertNewObjectForEntityForName:@"OLINESNEW" inManagedObjectContext:kAppDelegate.managedObjectContext];
    
    NSError *error = nil;
    NSEntityDescription* entitySquence = [NSEntityDescription entityForName:@"OLINESNEW" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entitySquence];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"orderid==%@ && productid=%@",[oheadnew valueForKey:@"orderid"],[prodInfo valueForKey:@"stock_code"]];
    [fetchRequest setPredicate:predicate];
    
    
    NSArray *resultsSeq = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([resultsSeq count]>0) {
        object=[resultsSeq lastObject];
    }else
        object= [NSEntityDescription insertNewObjectForEntityForName:@"OLINESNEW" inManagedObjectContext:kAppDelegate.managedObjectContext];
    
    
    
    [object setValue:[prodInfo valueForKey:@"barcode"] forKey:@"barcode"];
    [object setValue:[prodInfo valueForKey:@"price1"]   forKey:@"baseprice"];
    [object setValue:[NSNumber numberWithInteger:kAppDelegate.selectedCompanyId] forKey:@"company"];
  //  [object setValue:[dateFormat stringFromDate:delDate] forKey:@"datesold"];
    [object setValue:delAdd forKey:@"deliveryaddresscode"];
    [object setValue:delDate forKey:@"expecteddate"];
    [object setValue:[prodInfo valueForKey:@"inner"] forKey:@"line_inner"];
    [object setValue:[prodInfo valueForKey:@"outer"] forKey:@"line_outer"];
    //    [object setValue:[prodInfo valueForKey:@""] forKey:@"lineno"];
    //    [object setValue:[prodInfo valueForKey:@""] forKey:@"linetext"];
    [object setValue:[NSNumber numberWithDouble:([qty integerValue]*ordPrice)] forKey:@"linetotal"];
    [object setValue:orderNumber forKey:@"orderid"];
    //    [object setValue:[prodInfo valueForKey:@""] forKey:@"orderlinepricetype"];
    [object setValue:oLineType forKey:@"orderlinetype"];
    [object setValue:orderpacktype forKey:@"orderpacktype"];
    
    [object setValue:[prodInfo valueForKey:@"priceband"] forKey:@"priceband"];
    [object setValue:[prodInfo valueForKey:@"stock_code"] forKey:@"productid"];
    [object setValue:[NSNumber numberWithInteger:[qty integerValue]] forKey:@"quantity"];
    [object setValue:delDate forKey:@"requireddate"];
    [object setValue:[NSNumber numberWithDouble:ordPrice] forKey:@"saleprice"];
    [object setValue:[prodInfo valueForKey:@"price1"] forKey:@"unitprice"];
    [object setValue:[NSNumber numberWithInteger:[[prodInfo valueForKey:@"vatcode"] integerValue]] forKey:@"vatcode"];
    // [object setValue:[NSNumber numberWithDouble:[[prodInfo valueForKey:@""]doubleValue]] forKey:@"vattotal"];
    [object setValue:lineno forKey:@"lineno"];
    
    [object setValue:prodInfo forKey:@"product"];
    [object setValue:oheadnew forKey:@"orderheadnew"];
    
    
    if (![kAppDelegate.managedObjectContext save:&error]) {
        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
    }else
        addStatus=YES;
    
    return addStatus;
}


//Add oLine by detail page
+ (BOOL)addOLinewithorderNumber:(NSString* __nullable)orderNumber productInfo:(NSManagedObject* __nullable)prodInfo orderQty:(NSString*__nullable)qty orderPrice:(double)ordPrice discount:(double)ordDis deliveryAdd:(NSString* __nullable)delAdd deliveryDate:(NSDate* __nullable)delDate  expectedDate:(NSDate* __nullable)expDate oLineType:(NSString*__nullable)oLineType oLinePackType:(NSString*__nullable)orderpacktype  LineNumber:(NSString*__nullable)lineno TransactionInfo:(NSManagedObject *__nullable)oheadnew
{
    BOOL addStatus=NO;
   
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yy"];
    
    NSDateFormatter* timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HH:mm:ss"];
    
    NSManagedObject *object;
//    if (oLineInfo) {
//        object=oLineInfo;
//    }else
//        object= [NSEntityDescription insertNewObjectForEntityForName:@"OLINESNEW" inManagedObjectContext:kAppDelegate.managedObjectContext];
    
    NSError *error = nil;
    NSEntityDescription* entitySquence = [NSEntityDescription entityForName:@"OLINESNEW" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entitySquence];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"orderid==%@ && productid=%@ && deliveryaddresscode==%@ && requireddate=%@ ",[oheadnew valueForKey:@"orderid"],[prodInfo valueForKey:@"stock_code"],delAdd,delDate];
    [fetchRequest setPredicate:predicate];
    
    
    NSArray *resultsSeq = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([resultsSeq count]>0) {
        object=[resultsSeq lastObject];
    }else
        object= [NSEntityDescription insertNewObjectForEntityForName:@"OLINESNEW" inManagedObjectContext:kAppDelegate.managedObjectContext];
    
    
    [object setValue:[prodInfo valueForKey:@"barcode"] forKey:@"barcode"];
    [object setValue:[prodInfo valueForKey:@"price1"]   forKey:@"baseprice"];
    [object setValue:[NSNumber numberWithInteger:kAppDelegate.selectedCompanyId] forKey:@"company"];
  //  [object setValue:delDate forKey:@"datesold"];
    [object setValue:delAdd forKey:@"deliveryaddresscode"];
    [object setValue:[NSNumber numberWithDouble: ordDis] forKey:@"disc"];
    [object setValue:expDate forKey:@"expecteddate"];
    [object setValue:[prodInfo valueForKey:@"inner"] forKey:@"line_inner"];
    [object setValue:[prodInfo valueForKey:@"outer"] forKey:@"line_outer"];
//    [object setValue:[prodInfo valueForKey:@""] forKey:@"lineno"];
//    [object setValue:[prodInfo valueForKey:@""] forKey:@"linetext"];
    [object setValue:[NSNumber numberWithDouble:([qty integerValue]*ordPrice)] forKey:@"linetotal"];
    [object setValue:orderNumber forKey:@"orderid"];
//    [object setValue:[prodInfo valueForKey:@""] forKey:@"orderlinepricetype"];
    [object setValue:oLineType forKey:@"orderlinetype"];
    [object setValue:orderpacktype forKey:@"orderpacktype"];
    
    [object setValue:[prodInfo valueForKey:@"priceband"] forKey:@"priceband"];
    [object setValue:[prodInfo valueForKey:@"stock_code"] forKey:@"productid"];
    [object setValue:[NSNumber numberWithInteger:[qty integerValue]] forKey:@"quantity"];
    [object setValue:delDate forKey:@"requireddate"];
    [object setValue:[NSNumber numberWithDouble:ordPrice] forKey:@"saleprice"];
    [object setValue:[prodInfo valueForKey:@"price1"] forKey:@"unitprice"];
    [object setValue:[NSNumber numberWithInteger:[[prodInfo valueForKey:@"vatcode"] integerValue]] forKey:@"vatcode"];
   // [object setValue:[NSNumber numberWithDouble:[[prodInfo valueForKey:@""]doubleValue]] forKey:@"vattotal"];
    [object setValue:lineno forKey:@"lineno"];
    
    [object setValue:prodInfo forKey:@"product"];
    [object setValue:oheadnew forKey:@"orderheadnew"];

    
    if (![kAppDelegate.managedObjectContext save:&error]) {
        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
    }else
        addStatus=YES;
    
    return addStatus;
}


+ (BOOL)updateOlineFields:(NSString* __nullable)keyName UpdateValue:(id __nullable)updateValue StockCode:(NSString* __nullable)stockCode OrderNumber:(NSString* __nullable)orderNo
{
    BOOL returnStatus=NO;
    NSEntityDescription* entitySquence = [NSEntityDescription entityForName:@"OLINESNEW" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entitySquence];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"orderid==%@ && productid=%@",orderNo,stockCode];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *resultsSeq = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *object in resultsSeq) {
        
        [object setValue:updateValue forKey:keyName];
        
        NSError *error = nil;
        if (![kAppDelegate.managedObjectContext save:&error]) {
            NSLog(@"Failed to save - error: %@", [error localizedDescription]);
        }else
            returnStatus=YES;
    }
    
    return returnStatus;
    
}
//delete oLine
/*+ (BOOL)deleteOLinewithorderNumber:(NSString* )orderNumber productInfo:(NSManagedObject* )prodInfo{
    BOOL deleteStatus=NO;
    
    NSError *error = nil;
    NSEntityDescription* entitySquence = [NSEntityDescription entityForName:@"OLINESNEW" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entitySquence];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"orderid==%@ && productid==%@",orderNumber,[prodInfo valueForKey:@"stock_code"]];
    [fetchRequest setPredicate:predicate];
    
    
    NSArray *resultsSeq = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([resultsSeq count]>0) {
        
        [kAppDelegate.managedObjectContext deleteObject:[resultsSeq lastObject]];
        NSError *error = nil;
        if (![kAppDelegate.managedObjectContext save:&error]) {
            NSLog(@"Failed to save - error: %@", [error localizedDescription]);
        }else
            deleteStatus=YES;

    }
    
    return deleteStatus;
}*/
//End

@end
