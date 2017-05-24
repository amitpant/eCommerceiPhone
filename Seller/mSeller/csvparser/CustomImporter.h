//
//  CustomImporter.h
//  mSeller
//
//  Created by Satish Kr Singh on 13/10/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomImporter : NSObject

+(NSDictionary *__nullable)initWithFileName:(NSString *__nonnull)fileName ParserType:(CSVParserType)parsertype;

+(BOOL)exportUnsentTransactionsToCSVForRepId:(NSString *__nonnull)repId CompanyId:(NSInteger)compId;
@end
