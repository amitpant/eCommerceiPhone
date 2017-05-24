//
//  OrderFormats.h
//  mSellerPro
//
//  Created by Satish Kumar on 11/2/12.
//  Copyright (c) 2012 Williams Commerce Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kNormalFont @"ArialMT"
#define kBoldFont   @"Arial-BoldMT"

typedef enum OrderFormatType {
    OrderTextFormat = 1,
    OrderSmallPhotos = 2,
    OrderLargePhotos = 3,
    OrderOfferSheet = 4,
    OrderCSVFile = 6,
    OrderPhotoExcel = 9
    }OrderFormatType;

@interface OrderFormats : NSObject
{
    
}
//@property(nonatomic,strong) NSString *strOlineType;
//+(NSMutableData *)CreateOrderFormat:(NSString *)orderNum Format:(OrderFormatType)orderformat SortIndex:(int)sortidx ValueIndex:(int)validx;
+(NSMutableData *)CreateCallSheetFormat:(NSArray *) arrCallSheet RepTitle:(NSString *)reptitle;
+(NSMutableData *)createCSV:(NSString *)order_no;
+(NSMutableData *)CreateHistoryFormat:(NSMutableArray *)arrHistoryInvc TopLevelObject:(NSMutableArray *)arrHeadingInvc CreateHistoryFormat1:(NSMutableArray *)arrHistoryOut TopLevelObject1:(NSMutableArray *)arrHeadingOut Index:(int)slctdIndx;
+(NSUInteger)getMaxDescLength:(NSString *)description fontName:(UIFont *)fontName size:(CGFloat )descWidth height:(CGFloat)descHeight;

//added by Amit Pant on 201602010

+(NSMutableData *)CreateOrderFormat:(NSManagedObject *)orderObject Format:(OrderFormatType)orderformat SortIndex:(int)sortidx ValueIndex:(int)validx;
//+(void)writeOrderHeadWithOrderNumber:(NSManagedObject *)orderObject PDFRef:(PDFCreator **)pdfref;
@end
/*1           Text
 2           Small Photos
 3           Large Photos
 4           Offer Sheet
 6           Csv file
 9 	    Photo Excel
*/