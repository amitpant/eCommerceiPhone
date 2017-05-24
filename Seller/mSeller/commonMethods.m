//
//  commonMethods.m
//  mSeller
//
//  Created by Mahendra Pratap Singh on 8/4/16.
//  Copyright © 2016 Williams Commerce Ltd. All rights reserved.
//

#import "commonMethods.h"

@implementation commonMethods

+(NSInteger) findTop20 {
    NSManagedObjectContext *context = [kAppDelegate managedObjectContext];
    NSError *err = nil;
    NSEntityDescription *entity;
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    entity= [NSEntityDescription entityForName:@"OLINESNEW" inManagedObjectContext:context];
    [fetch setEntity:entity];
    NSInteger count = [context countForFetchRequest:fetch /*the one you have above but without limit */ error:&err];
    //[fetch setResultType:NSDictionaryResultType];
    return  count;//[context executeFetchRequest:fetch error:&err];
}

+(NSInteger) findQuote{
    
    NSManagedObjectContext *context = [kAppDelegate managedObjectContext];
    NSError *err = nil;
    NSEntityDescription *entity;
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    entity= [NSEntityDescription entityForName:@"OLINESNEW" inManagedObjectContext:context];
    [fetch setEntity:entity];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"orderlinetype=='Q'"]];
    NSInteger count = [context countForFetchRequest:fetch /*the one you have above but without limit */ error:&err];
    //[fetch setResultType:NSDictionaryResultType];
    return  count;
    
}


#pragma mark - fetch customer obj
+ (NSManagedObject* )fetch_customer :(NSString*)acc_ref deliverId:(NSString*)delId
{
    NSManagedObject*custData;
    NSEntityDescription* entitySquence = [NSEntityDescription entityForName:@"CUST" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entitySquence];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"acc_ref==%@ && delivery_address==%@",acc_ref,delId];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *resultsSeq = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if([resultsSeq count]>0)
        custData = [resultsSeq lastObject];
    
    return custData;
}


+ (NSString*)returnMaxBatchNofromoHeadNew{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init] ;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"OHEADNEW"  inManagedObjectContext:kAppDelegate.managedObjectContext ];
    [request setEntity:entity];
    
    request.predicate = [NSPredicate predicateWithFormat:@"batch_no==max(batch_no)"];
    request.sortDescriptors = [NSArray array];
    
    NSError *error = nil;
    NSArray *array = [kAppDelegate.managedObjectContext executeFetchRequest:request error:&error];
    NSString *maxBatchNo=[[array lastObject] valueForKey:@"batch_no"];
    return maxBatchNo;
}




#pragma mark - Featch invoice/outstanding data

+ (NSArray*)findInvoicesData :(NSManagedObject*)customer{
    
    NSMutableArray *iHeadArr=[[NSMutableArray alloc]init];
    @try {
        NSEntityDescription* entitySquence = [NSEntityDescription entityForName:@"IHEAD" inManagedObjectContext:kAppDelegate.managedObjectContext];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"invoiced_date" ascending:NO];
        NSArray *sortDescriptors = @[sortDescriptor];
        
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setEntity:entitySquence];
        [fetchRequest setReturnsObjectsAsFaults:NO];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"customer_code==%@ ",[customer valueForKey:@"acc_ref"]];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        NSArray *resultsiHead = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        
        [resultsiHead enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSManagedObject *objectnew=obj;
            if ([self findiLines:obj]) {
                NSSet *custILines = [NSSet setWithArray:[self findiLines:obj]];
                [objectnew setValue:custILines forKey:@"invoicelines"];
                [iHeadArr addObject:objectnew];
            }
            
        }];
        
    } @catch (NSException *exception) {
        DebugLog(@"findInvoicesData Exception %@",exception);
    } @finally {
        
    }
    
    return iHeadArr;
}

+ (NSArray*)findiLines:(NSManagedObject*)iheadObj{
    NSMutableArray *iLineArr=[[NSMutableArray alloc]init];
    @try {
        
        NSEntityDescription* entitySquence = [NSEntityDescription entityForName:@"ILINES" inManagedObjectContext:kAppDelegate.managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entitySquence];
        [fetchRequest setReturnsObjectsAsFaults:NO];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"invoice_num==%@",[iheadObj valueForKey:@"invoice_num"]];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        NSArray *resultsiLine = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        iLineArr=[[NSMutableArray alloc]initWithArray:resultsiLine];
        
       /* [resultsiLine enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSManagedObject *objectnew=obj;
            DebugLog(@"product_code--  %@",[obj valueForKey:@"product_code"]);
            if ([self findproduct:[obj valueForKey:@"product_code"]]) {
                [objectnew setValue:[self findproduct:[obj valueForKey:@"product_code"]] forKey:@"product"];
                [iLineArr addObject:objectnew];
            }
            
        }];*/
        
    } @catch (NSException *exception) {
        DebugLog(@"findiLines Exception %@",exception);
    } @finally {
        
    }
    
    
    return iLineArr;
}


//Find Outstanding data

+ (NSArray*)findOutstandingData:(NSManagedObject*)customer{
    
    NSMutableArray *OHeadArr=[[NSMutableArray alloc]init];
    @try {
        NSEntityDescription* entitySquence = [NSEntityDescription entityForName:@"OHEAD" inManagedObjectContext:kAppDelegate.managedObjectContext];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order_date" ascending:NO];
        NSArray *sortDescriptors = @[sortDescriptor];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setEntity:entitySquence];
        [fetchRequest setReturnsObjectsAsFaults:NO];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"customer_code==%@ ",[customer valueForKey:@"acc_ref"]];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        NSArray *resultsOHead = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        [resultsOHead enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSManagedObject *objectnew=obj;
            
            if ([self findOLines:obj]) {
                NSSet *custILines = [NSSet setWithArray:[self findOLines:obj]];
                [objectnew setValue:custILines forKey:@"orderlines"];
                [OHeadArr addObject:objectnew];
            }
            
        }];
        
    } @catch (NSException *exception) {
        DebugLog(@"findOutstandingData Exception %@",exception);
    } @finally {
        
    }
    
    return OHeadArr;
}

+ (NSArray*)findOLines:(NSManagedObject*)OheadObj{
    NSMutableArray *OLineArr=[[NSMutableArray alloc]init];
    @try {
        NSEntityDescription* entitySquence = [NSEntityDescription entityForName:@"OLINES" inManagedObjectContext:kAppDelegate.managedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entitySquence];
        [fetchRequest setReturnsObjectsAsFaults:NO];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"order_number==%@",[OheadObj valueForKey:@"order_number"]];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *resultsOLine = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        OLineArr=[[NSMutableArray alloc]initWithArray:resultsOLine];
        /*[resultsOLine enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSManagedObject *objectnew=obj;
            if ([self findproduct:[obj valueForKey:@"product_code"]]) {
                [objectnew setValue:[self findproduct:[obj valueForKey:@"product_code"]] forKey:@"product"];
                [OLineArr addObject:objectnew];
            }
        }];*/
    } @catch (NSException *exception) {
        DebugLog(@"findOLines NSException %@",exception);
    } @finally {
        
    }
    
    return OLineArr;
}


+ (NSManagedObject*)findproduct:(NSString*)stockCode{
    
    @try {
        
        NSEntityDescription* entitySquence = [NSEntityDescription entityForName:@"PROD" inManagedObjectContext:kAppDelegate.managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entitySquence];
        [fetchRequest setReturnsObjectsAsFaults:NO];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stock_code==%@",stockCode];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        NSArray *resultsSeq = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        return [resultsSeq lastObject];
        
    } @catch (NSException *exception) {
        DebugLog(@"findproduct NSException %@",exception);
    } @finally {
        
    }
    
    return nil;
}



#pragma mark - last Paid
+ (NSManagedObject*)findLastPaid:(NSManagedObject*)Prod Cust:(NSManagedObject *)cust{

    NSEntityDescription* entitySquence = [NSEntityDescription entityForName:@"CUST" inManagedObjectContext:kAppDelegate.managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entitySquence];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"acc_ref==%@ ",[cust valueForKey:@"acc_ref"],[Prod valueForKey:@"stock_code"] ];// && self.invoicelines.cust_ord_ref=%@],[cust valueForKey:@"acc_ref"]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *resultsOLine = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    //OLineArr=[[NSMutableArray alloc]initWithArray:resultsOLine];
    
    return [resultsOLine firstObject];
}

#pragma mark - mSeller Extra methods
+ (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate Hours:(NSInteger)Hr minutes:(NSInteger)min Seconds:(NSInteger)sec{
   
    // Use the user's current calendar and time zone
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [calendar setTimeZone:timeZone];
    
    // Selectively convert the date components (year, month, day) of the input date
    NSDateComponents *dateComps = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:inputDate];//[calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:inputDate];
    
    // Set the time components manually
    [dateComps setHour:Hr];
    [dateComps setMinute:min];
    [dateComps setSecond:sec];
    
    // Convert back
    NSDate *beginningOfDay = [calendar dateFromComponents:dateComps];
   
    /*NSDateFormatter *objDateFormatter = [[NSDateFormatter alloc] init];
    [objDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *newDate = [objDateFormatter stringFromDate:beginningOfDay];
    DebugLog(@"DATE  %@",newDate);*/
    return beginningOfDay;
    
}

+ (NSString *)returnBaseAddress:(NSManagedObject *)CustdelAdd{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init] ;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CUST"  inManagedObjectContext:kAppDelegate.managedObjectContext ];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"acc_ref == %@ && delivery_address=='000'", [CustdelAdd valueForKey:@"acc_ref"]];;
    fetchRequest.predicate = predicate;
    fetchRequest.sortDescriptors = [NSArray array];
    NSError *err=nil;
    NSArray *arrDelAdds = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&err];
    
    if ([arrDelAdds count]>0)
        return [self returnCombinedAdd:[arrDelAdds lastObject]];
    else
        return @"";;
    
}

+ (NSString *)returnCombinedAdd:(NSManagedObject*)custData{
    
    NSString *Address = [custData valueForKey:@"addr1"];
    if([custData valueForKey:@"addr2"] && [[custData valueForKey:@"addr2"] length]>0){
        if([Address length]>0)
            Address = [Address stringByAppendingFormat:@", %@",[custData valueForKey:@"addr2"]];
        else
            Address = [custData valueForKey:@"addr2"];
    }
    if([custData valueForKey:@"addr3"] && [[custData valueForKey:@"addr3"] length]>0){
        if([Address length]>0)
            Address = [Address stringByAppendingFormat:@", %@",[custData valueForKey:@"addr3"]];
        else
            Address = [custData valueForKey:@"addr3"];
    }
    if([custData valueForKey:@"addr4"] && [[custData valueForKey:@"addr4"] length]>0){
        if([Address length]>0)
            Address = [Address stringByAppendingFormat:@", %@",[custData valueForKey:@"addr4"]];
        else
            Address = [custData valueForKey:@"addr4"];
    }
    if([custData valueForKey:@"postcode"] && [[custData valueForKey:@"postcode"] length]>0){
        if([Address length]>0)
            Address = [Address stringByAppendingFormat:@", %@",[custData valueForKey:@"postcode"]];
        else
            Address = [custData valueForKey:@"postcode"];
    }

    return Address;
}

+ (NSString *)returnBasePhoneNumber:(NSManagedObject *)CustdelAdd{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init] ;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CUST"  inManagedObjectContext:kAppDelegate.managedObjectContext ];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"acc_ref == %@ && delivery_address=='000'", [CustdelAdd valueForKey:@"acc_ref"]];;
    fetchRequest.predicate = predicate;
    fetchRequest.sortDescriptors = [NSArray array];
    NSError *err=nil;
    NSArray *arrDelAdds = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&err];
    
    if ([arrDelAdds count]>0)
        return [[arrDelAdds lastObject] valueForKey:@"phone" ];
    else
        return @"";
    
}

+ (NSString *)returnBaseContact:(NSManagedObject *)CustData{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init] ;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CUST"  inManagedObjectContext:kAppDelegate.managedObjectContext ];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"acc_ref == %@ && delivery_address=='000'", [CustData valueForKey:@"acc_ref"]];;
    fetchRequest.predicate = predicate;
    fetchRequest.sortDescriptors = [NSArray array];
    NSError *err=nil;
    NSArray *arrDelAdds = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&err];
    
    if ([arrDelAdds count]>0)
        return [[arrDelAdds lastObject] valueForKey:@"contact" ];
    else
        return @"";
    
}




@end
