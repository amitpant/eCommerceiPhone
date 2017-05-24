//
//  EntryReceiver.m
//  CSVImporter
//
//  Created by Matt Gallagher on 2009/11/30.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  This software is provided 'as-is', without any express or implied
//  warranty. In no event will the authors be held liable for any damages
//  arising from the use of this software. Permission is granted to anyone to
//  use this software for any purpose, including commercial applications, and to
//  alter it and redistribute it freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source
//     distribution.
//

#import "EntryReceiver.h"

@implementation EntryReceiver

//
// initWithContext:
//
// Parameters:
//    aContext - the context into which records will be added.
//    entityName - the name of the NSEntityDescription to use for new
//		managedObjects added to the context.
//
// returns the initialized object.
//
- (id)initWithContext:(NSManagedObjectContext *)aContext
           entityName:(NSString *)entityName
{
    self = [super init];
    if (self)
    {
        context = aContext;
        entityDescription =
        [NSEntityDescription
         entityForName:entityName
         inManagedObjectContext:context];

        _modifiedRecord = [NSMutableDictionary dictionary];
    }
    return self;
}

//
// receiveRecord:
//
// Receives a row from the CSVParser
//
// Parameters:
//    aRecord - the row
//
- (void)receiveRecord:(NSDictionary *)aRecordAndComapareFields
{
    NSDictionary *attributesByName = [entityDescription attributesByName];

    NSDictionary *aRecord = [aRecordAndComapareFields objectForKey:@"record"];
//    NSMutableDictionary *aRecord =[[NSMutableDictionary alloc]initWithDictionary: [aRecordAndComapareFields objectForKey:@"record"]];
//    if ([[aRecordAndComapareFields valueForKey:@"comparefield"] isEqualToString:@"stock_code"]) {
//        DebugLog(@"AAAA   stock_code");
//       // [aRecord setObject:@"1" forKey:@"unit"];
//    }
    
    NSManagedObject *managedObject =nil;

    // To check if record already exist
    if([aRecordAndComapareFields objectForKey:@"comparefield"] && [[aRecordAndComapareFields objectForKey:@"existingrecords"] count]>0){
        NSArray *compfields = [aRecordAndComapareFields objectForKey:@"comparefield"];

//        NSFetchRequest *request = [[NSFetchRequest alloc] init];
//        [request setEntity:entityDescription];
        NSString *strCond=@"";
        for(NSString* field in compfields){
            NSArray *arrtmp = [field componentsSeparatedByString:@" "];

            NSString* fieldname = [[[arrtmp firstObject]  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];

            if([fieldname containsString:@"=="]){
                strCond = [strCond stringByAppendingString:fieldname];
            }
            else{
                // create condition
                NSAttributeDescription *attributeDescriptiontemp = [attributesByName objectForKey:fieldname];

                if([attributeDescriptiontemp attributeType] == NSStringAttributeType)
                    strCond=[strCond stringByAppendingFormat:@"%@ == '%@'",fieldname,[[aRecord objectForKey:fieldname] stringByReplacingOccurrencesOfString:@"\'" withString:@"\\'"]];
                else
                    strCond=[strCond stringByAppendingFormat:@"%@ == %@",fieldname,[aRecord objectForKey:fieldname]];
            }

            if([arrtmp count]>1){
                NSString *strss=[[[arrtmp lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
                if([strss isEqualToString:@"and"]){
                    strCond=[strCond stringByAppendingString:@" && "];
                }
            }
        }
        NSArray *results = nil;
        if([strCond length]>0){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:strCond];
            results = [[NSArray arrayWithArray:[[aRecordAndComapareFields objectForKey:@"existingrecords"] copy]] filteredArrayUsingPredicate:predicate];
//            [request setPredicate:predicate];
        }

//        NSError *error = nil;
//        NSArray *results = [context executeFetchRequest:request error:&error];
        if(results && [results count]>0){
            managedObject =  [results objectAtIndex:0];
            NSInteger icount = [[_modifiedRecord objectForKey:@"updated"] integerValue];
            icount++;
            [_modifiedRecord setObject:[NSNumber numberWithInteger:icount] forKey:@"updated"];

            [[aRecordAndComapareFields objectForKey:@"existingrecords"] removeObject:[results objectAtIndex:0]];
        }
        else{
            NSInteger icount = [[_modifiedRecord objectForKey:@"added"] integerValue];
            icount++;
            [_modifiedRecord setObject:[NSNumber numberWithInteger:icount] forKey:@"added"];

            managedObject =
            [[NSManagedObject alloc]
             initWithEntity:entityDescription
             insertIntoManagedObjectContext:context];
        }
    }
    else{
        NSInteger icount = [[_modifiedRecord objectForKey:@"added"] integerValue];
        icount++;
        [_modifiedRecord setObject:[NSNumber numberWithInteger:icount] forKey:@"added"];

        managedObject =
        [[NSManagedObject alloc]
         initWithEntity:entityDescription
         insertIntoManagedObjectContext:context];
    }

    for (NSString *key in aRecord)
    {
        //NSString *key = [key1 lowercaseString];
        NSAttributeDescription *attributeDescription =
        [attributesByName objectForKey:key];
        if (attributeDescription)
        {
            switch([attributeDescription attributeType])
            {
                case NSInteger64AttributeType:
                case NSInteger32AttributeType:
                case NSInteger16AttributeType:
                    [managedObject
                     setValue:
                     [NSNumber numberWithLongLong:[[aRecord objectForKey:key] longLongValue]]
                     forKey:key];
                    break;
                case NSDecimalAttributeType:
                    [managedObject
                     setValue:
                     [NSDecimalNumber decimalNumberWithString:[aRecord objectForKey:key]]
                     forKey:key];
                    break;
                case NSDoubleAttributeType:
                case NSFloatAttributeType:
                    [managedObject
                     setValue:
                     [NSNumber numberWithDouble:[[aRecord objectForKey:key] doubleValue]]
                     forKey:key];
                    break;
                case NSDateAttributeType:
                    if([[entityDescription name] isEqualToString:@"IHEAD"] && [key isEqualToString:@"invoiced_date"]){ // To set date time value from string in IHEAD
                        NSDate *convertedDate = [self getDateWithCustomFormat:@"dd/MM/yyyy" DateString:[aRecord objectForKey:key]];
                        [managedObject setValue:convertedDate forKey:key];
                    }
                    else if([[entityDescription name] isEqualToString:@"OHEAD"] && ([key isEqualToString:@"order_date"] || [key isEqualToString:@"delivery_date"])){// To set date time value from string in OHEAD
                        NSDate *convertedDate = [self getDateWithCustomFormat:@"dd/MM/yyyy" DateString:[aRecord objectForKey:key]];
                        [managedObject setValue:convertedDate forKey:key];
                    }
                    else if([[entityDescription name] isEqualToString:@"OLINES"] && [key isEqualToString:@"req_delv_date"]){ // To set date time value from string in OLINES
                        NSDate *convertedDate = [self getDateWithCustomFormat:@"dd/MM/yyyy" DateString:[aRecord objectForKey:key]];
                        [managedObject setValue:convertedDate forKey:key];
                    }
                    else if([[entityDescription name] isEqualToString:@"OHEADNEW"] && ([key isEqualToString:@"invoice_date"] || [key isEqualToString:@"nextcall_date"] || [key isEqualToString:@"orderdate"] || [key isEqualToString:@"payment_date"] || [key isEqualToString:@"required_bydate"] || [key isEqualToString:@"start_date"] || [key isEqualToString:@"start_time"] || [key isEqualToString:@"end_time"] || [key isEqualToString:@"ordtime"])){ // To set date time value from string in OLINES
                        NSDate *convertedDate = [self getDateWithCustomFormat:@"dd/MM/yy" DateString:[aRecord objectForKey:key]];
                        [managedObject setValue:convertedDate forKey:key];
                    }
                    else if([[entityDescription name] isEqualToString:@"OLINESNEW"] && ([key isEqualToString:@"expecteddate"] || [key isEqualToString:@"requireddate"])){ // To set date time value from string in OLINES
                        NSDate *convertedDate = [self getDateWithCustomFormat:@"dd/MM/yy" DateString:[aRecord objectForKey:key]];
                        [managedObject setValue:convertedDate forKey:key];
                    }
                    else if([[entityDescription name] isEqualToString:@"PURCHASEORDERS"] && [key isEqualToString:@"due_date"]){// To set date time value from string in PURCHASEORDERS
                        NSDate *convertedDate = [self getDateWithCustomFormat:@"dd/MM/yyyy" DateString:[aRecord objectForKey:key]];
                        [managedObject setValue:convertedDate forKey:key];
                    }
                    else
                        [managedObject setValue:[aRecord objectForKey:key] forKey:key];
                    
                    break;
                default:
                    if([[entityDescription name] isEqualToString:@"CUST"] && ([key isEqualToString:@"name"] || [key isEqualToString:@"acc_ref"])){
                        NSString *strFieldValue =[aRecord objectForKey:key];
                        if([strFieldValue length]>0 && ![[strFieldValue uppercaseString] hasPrefix:[strFieldValue substringToIndex:1]])
                            strFieldValue = [[[[aRecord objectForKey:key] substringToIndex:1] uppercaseString] stringByAppendingString:[[aRecord objectForKey:key] substringFromIndex:1]];
                        [managedObject setValue:[strFieldValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:key];
                    }
                    else
                        [managedObject setValue:[aRecord objectForKey:key] forKey:key];
                    break;
            }
        }
    }

    // to set relationship - code added by Satish on 24 Feb 2016
    /*if([[entityDescription name] isEqualToString:@"IHEAD"]){
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"ILINES" inManagedObjectContext:kAppDelegate.managedObjectContext];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"invoice_num==%@",[managedObject valueForKey:@"invoice_num"]]];

        NSError *error = nil;
        NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
        if(!error){
            [managedObject setValue:[NSSet setWithArray:results] forKey:@"invoicelines"];
        }
    }
    else if([[entityDescription name] isEqualToString:@"OHEAD"]){
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"OLINES" inManagedObjectContext:kAppDelegate.managedObjectContext];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"order_number==%@",[managedObject valueForKey:@"order_number"]]];

        NSError *error = nil;
        NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
        if(!error){
            [managedObject setValue:[NSSet setWithArray:results] forKey:@"orderlines"];
        }
    }*/
    // end of code

}

-(NSDate*)getDateWithCustomFormat:(NSString *)sourceformat DateString:(NSString *)datestr{
    if(!datestr) return nil;
    sourceformat = [sourceformat stringByAppendingString:@" V"];
    //    NSTimeZone [NSTimeZone localTimeZone];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    if(sourceformat){
        if([datestr length]<=10) datestr = [datestr stringByAppendingString:@" +0000"];
        [formatter setDateFormat:sourceformat];
    }
    else{
        [formatter setDateStyle:NSDateFormatterLongStyle];
    }

    return [formatter dateFromString:datestr];
}

@end
