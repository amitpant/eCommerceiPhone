//
//  CustomImporter.m
//  mSeller
//
//  Created by Satish Kr Singh on 13/10/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "CustomImporter.h"
#import "EntryReceiver.h"
#import "CSVParser.h"
#import "NSManagedObjectContext+FetchAdditions.h"
#import "ZipUnzip.h"

@implementation CustomImporter

+(NSDictionary *)initWithFileName:(NSString *)fileName ParserType:(CSVParserType)parsertype{
    static NSString *fieldSeparator = @"~";
    BOOL isSuccess = NO;
    NSString *errorMessage = @"";
    @try {
        BOOL hasHeader = YES;
        // to check if upd files coming
        NSArray *tablenamesplitted=[[[[fileName lastPathComponent] stringByDeletingPathExtension] uppercaseString] componentsSeparatedByString:@"_"];

        NSString *tableNameString=[tablenamesplitted firstObject];
        // only for notes eg - Cnotes, Lnotes or Inotes
        NSString *strnotestype = nil;
        if(parsertype==ParserTypeNotes){
            tableNameString = @"NOTES";
            strnotestype = [[[fileName lastPathComponent] substringToIndex:1] uppercaseString];
        }
        //end of code for notes

        NSDate *startDate = [NSDate date];
        NSManagedObjectContext *context = [kAppDelegate managedObjectContext];
        EntryReceiver *receiver = [[EntryReceiver alloc] initWithContext:context entityName:tableNameString];

        NSString *csvString = [CommonHelper loadFileDataWithVirtualFilePath:fileName];

        NSArray *arrFields = nil;
        NSArray *arrCompareFields = nil;
        NSArray *arrDefaultFields = nil;
        switch (parsertype) {
            case ParserTypeProd:{
                arrCompareFields = [NSArray arrayWithObjects:@"stock_code",nil];
            }
                break;
            case ParserTypeCust:
              //  arrCompareFields = [NSArray arrayWithObjects:@"acc_ref and",@"delivery_address",nil];
                break;
            case ParserTypeGroup:{
                if([tableNameString hasPrefix:@"EXTRAGROUP"])
                    arrCompareFields = [NSArray arrayWithObjects:@"extragroupcode",nil];
                else if([tableNameString hasPrefix:@"GROUP2"])
                    arrCompareFields = [NSArray arrayWithObjects:@"group2code",nil];
                else
                    arrCompareFields = [NSArray arrayWithObjects:@"group1code",nil];
            }
                break;
            case ParserTypePurchaseOrder:{
                arrCompareFields = [NSArray arrayWithObjects:@"po_no",nil];
            }
                break;
            case ParserTypeIhead:
//                arrCompareFields = [NSArray arrayWithObjects:@"invoice_num",nil];
                break;
            case ParserTypeIlines:
//                arrCompareFields = [NSArray arrayWithObjects:@"invoice_num and",@"product_code",nil];
                break;
            case ParserTypeOhead:
//                arrCompareFields = [NSArray arrayWithObjects:@"order_number",nil];
                break;
            case ParserTypeOlines:
//                arrCompareFields = [NSArray arrayWithObjects:@"order_number and",@"line_no and",@"product_code",nil];
                break;
            case ParserTypeNotes:{
                hasHeader = NO;
                arrDefaultFields = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:@"notetype",@"name",strnotestype,@"value",nil]];
                arrFields = [NSArray arrayWithObjects:@"notetext", nil];
            }
                break;
            case ParserTypeConv:
            case ParserTypeCallLogs:
            case ParserTypeTargets:
            case ParserTypePrices:
            case ParserTypeStockband:
            case ParserTypeBar:
            default:
                break;
        }

        NSMutableArray *myObjectsToDelete = nil;

        // clear table only if csv with full data has been downloaded.
        if(![[fileName lowercaseString] containsString:@"custloc."]){
            NSEntityDescription *entity = [NSEntityDescription entityForName:tableNameString inManagedObjectContext:context];
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:entity];

            if(parsertype==ParserTypeNotes)
                [request setPredicate:[NSPredicate predicateWithFormat:@"notetype==%@",strnotestype]];

            myObjectsToDelete = [[context executeFetchRequest:request error:nil] mutableCopy];

            if(!arrCompareFields){
                if(parsertype==ParserTypeCust)
                {
                    myObjectsToDelete = [[myObjectsToDelete filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isaddedondevice!=1"]] mutableCopy];
                }
                [myObjectsToDelete enumerateObjectsUsingBlock:^(id  _Nonnull objectToDelete, NSUInteger idx, BOOL * _Nonnull stop) {
                    [context deleteObject:objectToDelete];
                }];
                NSError *err = nil;
                if (![context save:&err])
                {
                    printf("Error while deleting\n%s",
                           [[err localizedDescription] ?
                            [err localizedDescription] : [err description] UTF8String]);
                }
            }
        }

        NSString* csvStr= [csvString stringByReplacingOccurrencesOfString:@"\"" withString:@""];//mahendra Added for loading data
        
        CSVParser *parser = [[CSVParser alloc] initWithString:csvStr separator:fieldSeparator hasHeader:hasHeader fieldNames:arrFields CompareWithFields:arrCompareFields DefaultFieldValues:arrDefaultFields existingRecords:myObjectsToDelete];
        [parser parseRowsForReceiver:receiver selector:@selector(receiveRecord:)];

        NSDate *endDate = [NSDate date];

        DebugLog(@"%@ Deleted: %lu %s entries successfully imported in %f seconds.",
              receiver.modifiedRecord, myObjectsToDelete?[myObjectsToDelete count]:0,[tableNameString UTF8String],
              [endDate timeIntervalSinceDate:startDate]);

        // delete record if deleted from CSV
        if(myObjectsToDelete && ![[fileName lowercaseString] containsString:@"_upd."] && ![[fileName lowercaseString] containsString:@"_new."] ){
            if(parsertype==ParserTypeCust)
            {
                myObjectsToDelete = [[myObjectsToDelete filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isaddedondevice!=1"]] mutableCopy];
            }

            [myObjectsToDelete enumerateObjectsUsingBlock:^(id  _Nonnull objectToDelete, NSUInteger idx, BOOL * _Nonnull stop) {
                [context deleteObject:objectToDelete];
            }];
        }

        NSError *error;
        if (![context save:&error])
        {
            printf("Error while saving\n%s",
                   [[error localizedDescription] ?
                    [error localizedDescription] : [error description] UTF8String]);
        }
    }
    @catch (NSException *exception) {
        DebugLog(@"Error while saving\n%@",exception.description);
    }
    @finally {
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        [result setObject:[NSNumber numberWithBool:isSuccess] forKey:@"success"];
        [result setObject:errorMessage forKey:@"error"];
        
        return result;
    }
}

+(BOOL)exportUnsentTransactionsToCSVForRepId:(NSString *__nonnull)repId CompanyId:(NSInteger)compId{
    NSString *uploadPathString = [[[kAppDelegate applicationDocumentsDirectory] path] stringByAppendingFormat:@"/%li/uploads/%@",(long)compId,repId];

    //*******************************************
    // to get transactions information
    __block NSEntityDescription *entity = [NSEntityDescription entityForName:@"OHEADNEW" inManagedObjectContext:kAppDelegate.managedObjectContext];
    __block NSFetchRequest *tableInfo = [[NSFetchRequest alloc] init];
    [tableInfo setEntity:entity];

    __block NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(batch_no==null || batch_no=='') && isopen==0 && held_status=='N'"];
    [tableInfo setPredicate:predicate];

    [tableInfo setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"orderid" ascending:YES]]];

    __block NSError *error = nil;
    __block NSArray *results = [kAppDelegate.managedObjectContext executeFetchRequest:tableInfo error:&error];

    __block NSMutableArray *transactionIds = [NSMutableArray array];

    __block NSMutableArray *fileContents = [NSMutableArray array];
    if(!error && [results count]>0){
        NSArray *columnNames = [NSArray arrayWithObjects:@"OrderID",
                                @"DeliveryAddressID",
                                @"CustomerID",
                                @"EmployeeID",
                                @"OrderDate",
                                @"PurchaseOrderNumber",
                                @"Hold-ProForma",
                                @"Hold-NewCust",
                                @"Required-byDate",
                                @"OrderTotal",
                                @"ScannerID",
                                @"OrdTime",
                                @"Processed",
                                @"FreeText",
                                @"QuoteLayoutID",
                                @"Company",
                                @"DISCPER",
                                @"ORDTYPE",
                                @"ORDSOURCE",
                                @"CUSTDISC",
                                @"CURR",
                                @"OrderTotalGross",
                                @"EmailConfirm",
                                @"EmailAddress",
                                @"Invoice-Date",
                                @"Start-Date",
                                @"Start-Time",
                                @"End-Time",
                                @"Longitude",
                                @"Latitude",
                                @"Payment",
                                @"Payment-Type",
                                @"Payment-Note",
                                @"Payment-Amount",
                                @"Payment-Date",
                                @"NextCall-Date",
                                @"OrderRep",
                                @"Printed",
                                @"Emailrep",
                                @"Creditemail",
                                @"Typeref", nil];


        // to set header in oheads_xx_xxxxx.csv
        [fileContents addObject:[@"\"" stringByAppendingString:[[columnNames componentsJoinedByString:@"\",\""] stringByAppendingString:@"\""]]];

        // to write values in oheads_xx_xxxxx.csv
        [results enumerateObjectsUsingBlock:^(NSManagedObject * _Nonnull record, NSUInteger idxfield, BOOL * _Nonnull stopfield) {
            NSMutableArray *fieldValues = [NSMutableArray array];
            [columnNames enumerateObjectsUsingBlock:^(NSString * _Nonnull fieldname, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *finalFieldName=[[fieldname stringByReplacingOccurrencesOfString:@"-" withString:@"_"] lowercaseString];

                id fieldvalue=[record valueForKey:finalFieldName];

                // to set specific format if field name matching
                if([finalFieldName hasSuffix:@"date"]){
                    fieldvalue = [CommonHelper showDateWithCustomFormat:@"dd/MM/yy" Date:[record valueForKey:finalFieldName]];
                }
                else if([finalFieldName hasSuffix:@"time"]){
                    if([finalFieldName isEqualToString:@"end_time"])
                        fieldvalue = [CommonHelper showDateWithCustomFormat:@"HH:mm" Date:[record valueForKey:finalFieldName]];
                       else
                           fieldvalue = [CommonHelper showDateWithCustomFormat:@"HH:mm:ss" Date:[record valueForKey:finalFieldName]];
                }
                else if([finalFieldName isEqualToString:@"ordsource"]){
                    fieldvalue=[NSString stringWithFormat:@"%d%@",0,fieldvalue];
                }
                // end of specific case

                if(fieldvalue){
                    [fieldValues addObject:[NSString stringWithFormat:@"\"%@\"",fieldvalue]];
                    if([[fieldname lowercaseString] isEqualToString:@"orderid"])
                        [transactionIds addObject:fieldvalue];
                }
                else
                    [fieldValues addObject:@"\"\""];
            }];
            [fileContents addObject:[fieldValues componentsJoinedByString:@","]];
        }];
    }

    if([fileContents count]>0){
        __block NSMutableArray *batchFiles = [NSMutableArray array];
        __block NSMutableArray *batchFilesPath = [NSMutableArray array];
        // to create directory if not exist
        if(![[NSFileManager defaultManager] fileExistsAtPath:uploadPathString])
            [[NSFileManager defaultManager] createDirectoryAtPath:uploadPathString withIntermediateDirectories:YES attributes:nil error:NULL];

        __block BOOL isCompleted = NO;
        __block BOOL isBatchCreated = NO;
        [CommonHelper getNewBatchNumberWithRepId:repId Company:compId CompletionBlock:^(NSInteger newbatchnumber) {
            [results enumerateObjectsUsingBlock:^(NSManagedObject * _Nonnull record, NSUInteger idx, BOOL * _Nonnull stop) {
                [record setValue:[NSNumber numberWithInteger:newbatchnumber] forKey:@"batch_no"];
            }];

            // writing ohead file to the directory
            NSString *filePathString = [uploadPathString stringByAppendingFormat:@"/OHeads_%@_%li.csv",repId,newbatchnumber];
            [[fileContents componentsJoinedByString:@"\r\n"] writeToFile:[uploadPathString stringByAppendingFormat:@"/OHeads_%@_%li.csv",repId,newbatchnumber] atomically:NO encoding:NSUTF8StringEncoding error:&error];

            [batchFilesPath addObject:filePathString];
            NSUInteger filesize = 0;
            NSDictionary *fileinfo = [[NSFileManager defaultManager] attributesOfItemAtPath:filePathString error:&error];
            if(!error) filesize = [fileinfo fileSize];

            NSArray *arrDetails = [NSArray arrayWithObjects:[filePathString lastPathComponent],[NSNumber numberWithLongLong:filesize], nil];
            [batchFiles addObject:[arrDetails componentsJoinedByString:@","]];

            #pragma mark - update Next Batch Helper
            if([kAppDelegate.managedObjectContext save:&error]){
                [CommonHelper setNextBatchNumberWithRepId:repId CompanyId:compId NextBatchSequence:newbatchnumber+1];
                DebugLog(@"Batch updated for sent/pending order");
            }

            //*******************************************
            // to get olines data and write into csv file
            [fileContents removeAllObjects];
            entity = [NSEntityDescription entityForName:@"OLINESNEW" inManagedObjectContext:kAppDelegate.managedObjectContext];
            tableInfo = [[NSFetchRequest alloc] init];
            [tableInfo setEntity:entity];

            predicate = [NSPredicate predicateWithFormat:@"orderid IN %@",transactionIds];
            [tableInfo setPredicate:predicate];
            [tableInfo setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"orderid" ascending:YES]]];

            results = [kAppDelegate.managedObjectContext executeFetchRequest:tableInfo error:&error];
            if(!error && [results count]>0){
                NSArray *columnNames = [NSArray arrayWithObjects:@"OrderID",
                                        @"LineNo",
                                        @"Barcode",
                                        @"ProductID",
                                        @"DateSold",
                                        @"Quantity",
                                        @"BasePrice",
                                        @"UnitPrice",
                                        @"SalePrice",
                                        @"LineTotal",
                                        @"Disc",
                                        @"RequiredDate",
                                        @"ExpectedDate",
                                        @"Company",
                                        @"Linetext",
                                        @"DeliveryAddressCode",
                                        @"OrderLineType",
                                        @"OrderLinePriceType",
                                        @"Line_Inner",
                                        @"Line_Outer",
                                        @"Priceband",nil];
                                        

                // to set header in olines_xx_xxxxx.csv
                [fileContents addObject:[@"\"" stringByAppendingString:[[columnNames componentsJoinedByString:@"\",\""] stringByAppendingString:@"\""]]];

                // to write values in olines_xx_xxxxx.csv
                [results enumerateObjectsUsingBlock:^(NSManagedObject * _Nonnull record, NSUInteger idxfield, BOOL * _Nonnull stopfield) {
                    NSMutableArray *fieldValues = [NSMutableArray array];
                    [columnNames enumerateObjectsUsingBlock:^(NSString * _Nonnull fieldname, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSString *finalFieldName=[[fieldname stringByReplacingOccurrencesOfString:@"-" withString:@"_"] lowercaseString];

                        id fieldvalue=[record valueForKey:finalFieldName];

                        // to set specific format if field name matching
                        if([finalFieldName hasSuffix:@"date"]){
                            fieldvalue = [CommonHelper showDateWithCustomFormat:@"dd/MM/yy" Date:[record valueForKey:finalFieldName]];
                        }
                        // end of specific case

                        if(fieldvalue){
                            [fieldValues addObject:[NSString stringWithFormat:@"\"%@\"",fieldvalue]];
                            if([[fieldname lowercaseString] isEqualToString:@"orderid"])
                                [transactionIds removeObject:fieldvalue];
                        }
                        else
                            [fieldValues addObject:@"\"\""];
                    }];
                    [fileContents addObject:[fieldValues componentsJoinedByString:@","]];
                }];
            }

            if([fileContents count]>0){
                // writing olines file to the directory
                filePathString = [uploadPathString stringByAppendingFormat:@"/OLines_%@_%li.csv",repId,newbatchnumber];
                [[fileContents componentsJoinedByString:@"\r\n"] writeToFile:filePathString atomically:NO encoding:NSUTF8StringEncoding error:&error];

                [batchFilesPath addObject:filePathString];
                filesize = 0;
                fileinfo = [[NSFileManager defaultManager] attributesOfItemAtPath:filePathString error:&error];
                if(!error) filesize = [fileinfo fileSize];

                arrDetails = [NSArray arrayWithObjects:[filePathString lastPathComponent],[NSNumber numberWithLongLong:filesize], nil];
                [batchFiles addObject:[arrDetails componentsJoinedByString:@","]];
            }

            //*********************************************
            // to create customer csv if new customer added
            NSArray *columnNames = [NSArray arrayWithObjects:@"COMPANY",
                                    @"ACC_REF",
                                    @"DELIVERY_ADDRESS",
                                    @"NAME",
                                    @"ADDR1",
                                    @"ADDR2",
                                    @"ADDR3",
                                    @"ADDR4",
                                    @"POSTCODE",
                                    @"PHONE",
                                    @"CONTACT",
                                    @"REP1",
                                    @"Curr",
                                    @"IsNew",
                                    @"NewDeliveryAddr",
                                    @"EmailAddress",
                                    @"Cusgroup",
                                    @"Pricegroup",
                                    @"FaxNo",
                                    @"REP2", nil];

            [fileContents removeAllObjects];
            entity = [NSEntityDescription entityForName:@"CUST" inManagedObjectContext:kAppDelegate.managedObjectContext];
            tableInfo = [[NSFetchRequest alloc] init];
            [tableInfo setEntity:entity];

            predicate = [NSPredicate predicateWithFormat:@"(batch_no==null || batch_no=='') && isaddedondevice==1 && isnew=='Y'"];
            [tableInfo setPredicate:predicate];

            results = [kAppDelegate.managedObjectContext executeFetchRequest:tableInfo error:&error];
            if(!error && [results count]>0){
                // to set header in newcustomers_xx_xxxxx.csv
                [fileContents addObject:[@"\"" stringByAppendingString:[[columnNames componentsJoinedByString:@"\",\""] stringByAppendingString:@"\""]]];

                // to write values in newcustomers_xx_xxxxx.csv
                [results enumerateObjectsUsingBlock:^(NSManagedObject * _Nonnull record, NSUInteger idxfield, BOOL * _Nonnull stopfield) {
                    NSMutableArray *fieldValues = [NSMutableArray array];
                    [columnNames enumerateObjectsUsingBlock:^(NSString * _Nonnull fieldname, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSString *tmpfieldname = [[fieldname stringByReplacingOccurrencesOfString:@"-" withString:@"_"] lowercaseString];
                        if([tmpfieldname hasPrefix:@"faxno"]) tmpfieldname = @"fax";

                        id fieldvalue=[record valueForKey:tmpfieldname];
                        if(fieldvalue){
                            [fieldValues addObject:[NSString stringWithFormat:@"\"%@\"",fieldvalue]];
                        }
                        else
                            [fieldValues addObject:@"\"\""];
                    }];
                    [fileContents addObject:[fieldValues componentsJoinedByString:@","]];

                    [record setValue:[NSNumber numberWithInteger:newbatchnumber] forKey:@"batch_no"];
                }];
            }

            if([fileContents count]>0){
                // writing newcustomers file to the directory
                filePathString = [uploadPathString stringByAppendingFormat:@"/Newcustomers_%@_%li.csv",repId,newbatchnumber];
                [[fileContents componentsJoinedByString:@"\r\n"] writeToFile:filePathString atomically:NO encoding:NSUTF8StringEncoding error:&error];

                [batchFilesPath addObject:filePathString];
                filesize = 0;
                fileinfo = [[NSFileManager defaultManager] attributesOfItemAtPath:filePathString error:&error];
                if(!error) filesize = [fileinfo fileSize];

                arrDetails = [NSArray arrayWithObjects:[filePathString lastPathComponent],[NSNumber numberWithLongLong:filesize], nil];
                [batchFiles addObject:[arrDetails componentsJoinedByString:@","]];

                if([kAppDelegate.managedObjectContext save:&error]){
                    DebugLog(@"Batch updated for sent/pending order");
                }

            }

            //*********************************************
            // to create new delivery address csv if new delivery added
            [fileContents removeAllObjects];
            entity = [NSEntityDescription entityForName:@"CUST" inManagedObjectContext:kAppDelegate.managedObjectContext];
            tableInfo = [[NSFetchRequest alloc] init];
            [tableInfo setEntity:entity];

            predicate = [NSPredicate predicateWithFormat:@"(batch_no==null || batch_no=='') && isaddedondevice==1 && newdeliveryaddr=='Y'"];
            [tableInfo setPredicate:predicate];

            results = [kAppDelegate.managedObjectContext executeFetchRequest:tableInfo error:&error];
            if(!error && [results count]>0){
                // to set header in newdelivery_xx_xxxxx.csv
                [fileContents addObject:[@"\"" stringByAppendingString:[[columnNames componentsJoinedByString:@"\",\""] stringByAppendingString:@"\""]]];

                // to write values in newdelivery_xx_xxxxx.csv
                [results enumerateObjectsUsingBlock:^(NSManagedObject * _Nonnull record, NSUInteger idxfield, BOOL * _Nonnull stopfield) {
                    NSMutableArray *fieldValues = [NSMutableArray array];
                    [columnNames enumerateObjectsUsingBlock:^(NSString * _Nonnull fieldname, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSString *tmpfieldname = [[fieldname stringByReplacingOccurrencesOfString:@"-" withString:@"_"] lowercaseString];
                        if([tmpfieldname hasPrefix:@"faxno"]) tmpfieldname = @"fax";

                        id fieldvalue=[record valueForKey:tmpfieldname];
                        if(fieldvalue){
                            [fieldValues addObject:[NSString stringWithFormat:@"\"%@\"",fieldvalue]];
                        }
                        else
                            [fieldValues addObject:@"\"\""];
                    }];
                    [fileContents addObject:[fieldValues componentsJoinedByString:@","]];

                    [record setValue:[NSNumber numberWithInteger:newbatchnumber] forKey:@"batch_no"];
                }];
            }

            if([fileContents count]>0){
                // writing newdelivery file to the directory
                filePathString = [uploadPathString stringByAppendingFormat:@"/NewDelivery_%@_%li.csv",repId,newbatchnumber];
                [[fileContents componentsJoinedByString:@"\r\n"] writeToFile:filePathString atomically:NO encoding:NSUTF8StringEncoding error:&error];

                [batchFilesPath addObject:filePathString];
                filesize = 0;
                fileinfo = [[NSFileManager defaultManager] attributesOfItemAtPath:filePathString error:&error];
                if(!error) filesize = [fileinfo fileSize];

                arrDetails = [NSArray arrayWithObjects:[filePathString lastPathComponent],[NSNumber numberWithLongLong:filesize], nil];
                [batchFiles addObject:[arrDetails componentsJoinedByString:@","]];

                if([kAppDelegate.managedObjectContext save:&error]){
                    DebugLog(@"Batch updated for sent/pending order");
                }
            }

            // write batch files to the directory
            if([batchFiles count]>0){
                // writing newdelivery file to the directory
                filePathString = [uploadPathString stringByAppendingFormat:@"/Batch_%@_%li.csv",repId,newbatchnumber];
                [[batchFiles componentsJoinedByString:@"\r\n"] writeToFile:filePathString atomically:NO encoding:NSUTF8StringEncoding error:&error];

                [batchFilesPath addObject:filePathString];

                isBatchCreated = [ZipUnzip createZipFileAtPath:[filePathString stringByReplacingOccurrencesOfString:@"csv" withString:@"zip"] withFilesAtPaths:batchFilesPath];

                if(isBatchCreated){
                    [batchFilesPath enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        [[NSFileManager defaultManager] removeItemAtPath:obj error:NULL];
                    }];
                }
            }


            isCompleted = YES;
        }];
        while(!isCompleted) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
        }
        return isBatchCreated;
    }
    else
        return NO;
}

@end
