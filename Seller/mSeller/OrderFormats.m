//
//  OrderFormats.m
//  mSellerPro
//
//  Created by Satish Kumar on 11/2/12.
//  Copyright (c) 2012 Williams Commerce Ltd. All rights reserved.
//

#import "OrderFormats.h"
#import "PDFCreator.h"
#import "NSString+TruncateToWidth.h"
#import <ImageIO/ImageIO.h>
#import "commonMethods.h"



#define queteWidth1 425
#define queteWidth2 585
#define imageratioSmall 35
#define imageratioLarge 91

@implementation OrderFormats
//@synthesize strOlineType;
static NSMutableString *strval = nil;

+(void)writeCompanyDetailsWithLogo:(BOOL)showlogo PDFRef:(PDFCreator **)pdfref{
    /////
    NSDictionary* featureDict;//   fetch feature
    NSDictionary* companyConfigDict;//   fetch CompanyConfig
    NSDictionary* priceConfigDict;//   fetch PriceConfig
    
    // fetch Feature config
    featureDict = nil;
    NSDictionary *dic=[CommonHelper loadFileDataWithVirtualFilePath:FeaturesConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        featureDict = [dic objectForKey:@"data"];
    
    //   fetch CompanyConfig
    companyConfigDict = nil;
    dic=[CommonHelper loadFileDataWithVirtualFilePath:CompanyConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        companyConfigDict = [dic objectForKey:@"data"];
    
    //   fetch priceConfig
    priceConfigDict = nil;
    dic=[CommonHelper loadFileDataWithVirtualFilePath:PricingConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        priceConfigDict = [dic objectForKey:@"data"];
    ////////////
    UIFont* customFont = [UIFont fontWithName:kNormalFont size:9.0];
    UIFont* customBoldFont = [UIFont fontWithName:kBoldFont size:9.0];
    UIFont* customBoldFontComp = [UIFont fontWithName:kBoldFont size:10.0];
    
    NSString *tradeNameString= [companyConfigDict valueForKey:@"tradename"];
    NSString *companyAddress= @"";
    NSString *companyPhone= [companyConfigDict valueForKey:@"phone2"];
    NSString *companyFax= [[companyConfigDict valueForKey:@"addressinfo"] valueForKey:@"fax"];
    NSString *companyEmail= @"";
    NSString *companyEmail1= [companyConfigDict valueForKey:@"email1"];
    NSString *companyWebsite= [[companyConfigDict valueForKey:@"addressinfo"] valueForKey:@"weburl"];
    
    NSString *strVatNum= [companyConfigDict valueForKey:@"VATno"];//[CompanyConfigDelegate.dicGenInfo objectForKey:@"VatNo"];
    NSString *strRegNum= [companyConfigDict valueForKey:@"registrationno"];//[CompanyConfigDelegate.dicGenInfo objectForKey:@"RegNo"];
    NSString* repsemail=@"";
    NSString* repsphone=@"";
    
    NSString* repsEmailValue=@"";
    NSArray* repsArray = [repsemail componentsSeparatedByString: @","];
    if (repsArray.count>0) {
        repsEmailValue = [repsArray objectAtIndex: 0];
    }
    CGFloat leftPos = 0;
    @try {
        if(showlogo){
            
            // DebugLog(@"%@",[[[kAppDelegate applicationDocumentsDirectory] path] stringByAppendingPathComponent:[NSString stringWithFormat:@"%li/%@",(long)kAppDelegate.selectedCompanyId,[companyConfigDict valueForKey:@"logo"]]]);
            NSString *imageurl= [[[kAppDelegate applicationDocumentsDirectory] path] stringByAppendingPathComponent:[NSString stringWithFormat:@"%li/%@",(long)kAppDelegate.selectedCompanyId,[companyConfigDict valueForKey:@"logo"]]];
           
            //            DebugLog(@"%@",[NSString stringWithFormat:@"%@/%@",CompanyConfigDelegate.LocalPath,CompanyConfigDelegate.CompInfo.ReportLogo]);
            UIImage* image = [UIImage imageWithContentsOfFile:imageurl];
            if(image!=nil){
                CGSize imgSize = [image size];
                CGSize newImageSize = CGSizeMake(0, 0);
                double percent;
                if(imgSize.height>95){
                    percent = 95/imgSize.height;
                    newImageSize.height = 95;
                    newImageSize.width = imgSize.width*percent;
                }
                if(newImageSize.width>0)
                    imgSize = newImageSize;
                if(imgSize.width>150){
                    percent = 150/imgSize.width;
                    newImageSize.width = 150;
                    newImageSize.height = imgSize.height*percent;
                }
                else
                    newImageSize = imgSize;
                // write company logo
                [*pdfref drawImageWithFrame:CGRectMake(leftPos, 2, newImageSize.width, newImageSize.height) Image:image];
                //leftPos+=newImageSize.width+10;
            }
        }
    }
    @catch (NSException *exception) {
        //        [CommonHelper writeErrorLogWithNo:0 Description:[exception description] Method:[NSString stringWithUTF8String:__func__]];
    }
    @finally {
        // write company name
        leftPos = 200;
        [*pdfref drawTextWithFrame:CGRectMake(leftPos, 2, 200, 22) Text:tradeNameString Font:customBoldFontComp TruncateToWidth:200.0];
        NSString* addr1 =[[companyConfigDict valueForKey:@"addressinfo"] valueForKey:@"address1"];
        NSString* addr2 =[[companyConfigDict valueForKey:@"addressinfo"] valueForKey:@"address2"];
        NSString* addr3 =[[companyConfigDict valueForKey:@"addressinfo"] valueForKey:@"address3"];
        NSString* addr4 =[[companyConfigDict valueForKey:@"addressinfo"] valueForKey:@"address4"];
        NSString* addr5 =[[companyConfigDict valueForKey:@"addressinfo"] valueForKey:@"address5"];
        
        NSString* strAddress = [NSString stringWithString:addr1];
        if([addr2 length]>0) strAddress = [strAddress stringByAppendingFormat:@"\n%@",addr2];
        if([addr3 length]>0) strAddress = [strAddress stringByAppendingFormat:@"\n%@",addr3];
        if([addr4 length]>0) strAddress = [strAddress stringByAppendingFormat:@"\n%@",addr4];
        if([addr5 length]>0) strAddress = [strAddress stringByAppendingFormat:@"\n%@",addr5];
        
        companyAddress=strAddress;
        // write company address
        [*pdfref drawTextWithFrame:CGRectMake(leftPos, 20, 180, 90) Text:companyAddress Font:customFont TruncateToWidth:900.0];
        
        // write company detail headings
        //commented by Ashish
        //leftPos = 390;
        //added  by Ashish
        leftPos = 370;
        //commented by Ashish
        //[*pdfref drawLineWithFrame:CGRectMake(leftPos, 12, 180, 22) LineWidth:20.0 LineColor:[UIColor lightGrayColor]];
        //added by Ashish
        [*pdfref drawLineWithFrame:CGRectMake(leftPos, 12, 200, 22) LineWidth:20.0 LineColor:[UIColor lightGrayColor]];
        [*pdfref drawTextWithFrame:CGRectMake(leftPos, 22, 40, 12) Text:@"Tel: " Font:customBoldFont TruncateToWidth:40.0];
        [*pdfref drawTextWithFrame:CGRectMake(leftPos, 34, 40, 12) Text:@"Fax: " Font:customBoldFont TruncateToWidth:40.0];
        [*pdfref drawTextWithFrame:CGRectMake(leftPos, 46, 40, 12) Text:@"Email: " Font:customBoldFont TruncateToWidth:40.0];
        [*pdfref drawTextWithFrame:CGRectMake(leftPos, 58, 40, 12) Text:@"Web: " Font:customBoldFont TruncateToWidth:40.0];
        
        //        NSString* strphone = [CompanyConfigDelegate.dicContactInfo objectForKey:@"Phone2"];
        //        if(strphone==nil || [strphone isEqualToString:@"(null)"] || [strphone length]==0)
        //            strphone= [CompanyConfigDelegate.dicContactInfo objectForKey:@"Phone1"];
        //code comment by Ashish
        // leftPos+=40;
        //code added by Ashish
        leftPos+=52.5;
        
        // write company details
        [*pdfref drawTextWithFrame:CGRectMake(leftPos, 22, 200, 15) Text:companyPhone Font:customFont TruncateToWidth:200.0];
        [*pdfref drawTextWithFrame:CGRectMake(leftPos, 34, 200, 15) Text:companyFax Font:customFont TruncateToWidth:200.0];
        [*pdfref drawTextWithFrame:CGRectMake(leftPos, 46, 200, 15) Text:companyEmail Font:customFont TruncateToWidth:200.0];
        [*pdfref drawTextWithFrame:CGRectMake(leftPos, 58, 200, 15) Text:companyWebsite Font:customFont TruncateToWidth:200.0];
        if ([strVatNum length]>0)
        {   //changed x axis from -40 to 52.5 by Ashish
            [*pdfref drawTextWithFrame:CGRectMake(leftPos-52.5, 70, 40, 12) Text:@"VAT No: " Font:customBoldFont TruncateToWidth:40.0];
            [*pdfref drawTextWithFrame:CGRectMake(leftPos, 70, 200, 12) Text:strVatNum Font:customFont TruncateToWidth:200.0];
        }
        if ([strRegNum length]>0)
        {   //changed x axis from -40 to 52.5 by Ashish
            [*pdfref drawTextWithFrame:CGRectMake(leftPos-52.5, 82, 40, 12) Text:@"Reg. No: " Font:customBoldFont TruncateToWidth:40.0];
            [*pdfref drawTextWithFrame:CGRectMake(leftPos, 82, 200, 12) Text:strRegNum Font:customFont TruncateToWidth:200.0];
        }
        //code added by Ashish
        if (kAppDelegate.selectedCompanyId==47)
        {
            BOOL IsSalesPersonEmail=[[[priceConfigDict valueForKey:@"emailprintconfigs"] valueForKey:@"includesalespersonemail"] boolValue];;
            BOOL IsSalesPersonPhone=[[[priceConfigDict valueForKey:@"emailprintconfigs"] valueForKey:@"includesalespersonphone"] boolValue];;
            if (IsSalesPersonEmail){
                [*pdfref drawTextWithFrame:CGRectMake(leftPos-52.5, 70, 200, 12) Text:@"Rep Email: " Font:customBoldFont TruncateToWidth:200.0];
                [*pdfref drawTextWithFrame:CGRectMake(leftPos, 70, 200, 12) Text:repsEmailValue Font:customFont TruncateToWidth:200.0];
            }
            
            if (IsSalesPersonPhone){
                [*pdfref drawTextWithFrame:CGRectMake(leftPos-52.5, 82, 200, 12) Text:@"Rep Phone: " Font:customBoldFont TruncateToWidth:200.0];
                [*pdfref drawTextWithFrame:CGRectMake(leftPos, 82, 200, 12) Text:repsphone Font:customFont TruncateToWidth:200.0];
            }
            
        }
        //end of code added
        // draw line below all the details
        [*pdfref drawLineWithFrame:CGRectMake(0, 97, 570, 1) LineWidth:2.0 LineColor:[UIColor grayColor]];
        
        if (kAppDelegate.selectedCompanyId== 51)
            [strval appendFormat:@"\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\r\n",tradeNameString,addr1,addr2,addr3,addr4,addr5,companyPhone,companyFax,companyWebsite,companyEmail1];
        
        
    }
}



//CGSizeMake(612, 792);
+(void)ordTypeHeader:(NSString*)strordtype PDF:(PDFCreator**)pdfref
{
    //  DebugLog(@"ordTypeHeader2");
    @try {
        
        
        UIFont* customBoldFont = [UIFont fontWithName:kBoldFont size:12.0];
        //commented by Ashish
        // CGFloat leftPos = 390;
        //added by Ashish
        CGFloat leftPos = 370;
        NSString* strordtypedesc = @"ORDER";
        UIColor* color = [UIColor blackColor];
        if([[strordtype uppercaseString] isEqualToString:@"Q"]){
            strordtypedesc = @"QUOTATION";
            color = [UIColor redColor];
        }
        else if([[strordtype uppercaseString] isEqualToString:@"P"]){
            strordtypedesc = @"PROFORMA";
            color = [UIColor blueColor];
        }
        else if([[strordtype uppercaseString] isEqualToString:@"C"]){
            strordtypedesc = @"CALL LOG";
            color = [UIColor colorWithRed:0/255.f green:141.0/255.f blue:20.0/255.f alpha:1.0];
        }
        else if([[strordtype uppercaseString] isEqualToString:@"S"]){
            strordtypedesc = @"SAMPLE ORDER";
        }
        else if([[strordtype uppercaseString] isEqualToString:@"M"]){
            strordtypedesc = @"MASTER";
            color = [UIColor blueColor];
        }
        else if ([[strordtype uppercaseString] isEqualToString:@"I"])//[[CompanyConfigDelegate.dicGenInfo objectForKey:@"isInvoiceActive"] boolValue])
        {
            strordtypedesc = @"Invoice";
            color = [UIColor blueColor];
        }
        else if([[strordtype uppercaseString] isEqualToString:@"N"]){//added by Ashish
            strordtypedesc = @"NINGBO";
            color = [UIColor blueColor];
        }//end of code
        if([[strordtype uppercaseString] isEqualToString:@"O"] || [[strordtype uppercaseString] isEqualToString:@"S"]){
            //commented by Ashish
            // [*pdfref drawTextWithFrame:CGRectMake(leftPos, 5, 180, 20) Text:strordtypedesc Font:customBoldFont TextAlignment:NSTextAlignmentCenter TruncateToWidth:200.0];
            //added by Ashish
            [*pdfref drawTextWithFrame:CGRectMake(leftPos, 5, 200, 20) Text:strordtypedesc Font:customBoldFont TextAlignment:NSTextAlignmentCenter TruncateToWidth:200.0];
        }
        else{
            //commented by Ashish
            // [*pdfref drawTextWithFrame:CGRectMake(leftPos+50, 5, 180-50, 20) Text:strordtypedesc Font:customBoldFont Color:color TruncateToWidth:200.0];
            //added by Ashish
            [*pdfref drawTextWithFrame:CGRectMake(leftPos+64, 5, 180, 20) Text:strordtypedesc Font:customBoldFont Color:color TruncateToWidth:200.0];
        }
    }
    @catch (NSException *exception) {
        //        [CommonHelper writeErrorLogWithNo:0 Description:[exception description] Method:[NSString stringWithUTF8String:__func__]];
    }
}

+(void)writeTableHeadingWithTopPos:(CGFloat)topPos PDFRef:(PDFCreator **)objpdf ColumnKeys:(NSArray *)arrCols ColumnLabels:(NSDictionary *)dicCols{
    // DebugLog(@"writeTableHeadingWithTopPos4");
    
    @try {
        topPos+=1;
        UIFont* customBoldFont = [UIFont fontWithName:kBoldFont size:8.0];
        for(NSString* key in arrCols){
            NSArray* arrvals = [[dicCols objectForKey:key] componentsSeparatedByString:@"|"];
            NSString* strLabel=[arrvals objectAtIndex:0];
            CGFloat leftPos=[[arrvals objectAtIndex:1] floatValue];
            CGFloat colWidth=[[arrvals objectAtIndex:2] floatValue];
            
            
            
            if([key isEqualToString:@"Description"] || [key isEqualToString:@"Code"] || [key isEqualToString:@"Del Id"]){
                if([key isEqualToString:@"Description"])
                    [*objpdf drawTextWithFrame:CGRectMake(leftPos+2, topPos, colWidth-2, 12) Text:strLabel Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:colWidth-2];
                else if([key isEqualToString:@"Del Id"])
                    [*objpdf drawTextWithFrame:CGRectMake(leftPos+7, topPos, colWidth-7, 12) Text:strLabel Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:colWidth-7];
                else
                    [*objpdf drawTextWithFrame:CGRectMake(leftPos, topPos, colWidth, 12) Text:strLabel Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:colWidth];
            }
            else{
                
                
                if([key isEqualToString:@"Inner"] || [key isEqualToString:@"Outer"] || [key hasSuffix:@"Prc"] || [key hasSuffix:@"Val"] || [key hasSuffix:@"Qty"]|| [key hasSuffix:@"CBM"]||[key hasPrefix:@"RRP"]){
                    if (kAppDelegate.selectedCompanyId== 51 && [[key lowercaseString] hasPrefix:@"tot val"]){//*******  condition for squirrels 2 26 Aug 2015
                        [*objpdf drawTextWithFrame:CGRectMake(leftPos-22, topPos, colWidth, 12) Text:strLabel Font:customBoldFont TextAlignment:NSTextAlignmentRight TruncateToWidth:colWidth];
                    }else if (kAppDelegate.selectedCompanyId == 51 && [[key lowercaseString] hasPrefix:@"ord prc"]){//*******  condition for squirrels 2 26 Aug 2015
                        [*objpdf drawTextWithFrame:CGRectMake(leftPos-13, topPos, colWidth, 12) Text:strLabel Font:customBoldFont TextAlignment:NSTextAlignmentRight TruncateToWidth:colWidth];
                    }else
                        [*objpdf drawTextWithFrame:CGRectMake(leftPos, topPos, colWidth, 12) Text:strLabel Font:customBoldFont TextAlignment:NSTextAlignmentRight TruncateToWidth:colWidth];
                    
                }else if ([key isEqualToString:@"Innr"]){
                    
                    if (kAppDelegate.selectedCompanyId == 51){//*******  condition for squirrels 2 26 Aug 2015
                        [*objpdf drawTextWithFrame:CGRectMake(leftPos-52, topPos, colWidth, 12) Text:@"Inner" Font:customBoldFont TextAlignment:NSTextAlignmentCenter TruncateToWidth:colWidth];
                    }else
                        [*objpdf drawTextWithFrame:CGRectMake(leftPos, topPos, colWidth, 12) Text:@"Inner" Font:customBoldFont TextAlignment:NSTextAlignmentCenter TruncateToWidth:colWidth];
                    
                    
                }else if ([key isEqualToString:@"Outr"]){
                    
                    if (kAppDelegate.selectedCompanyId == 51){//*******  condition for squirrels 2 26 Aug 2015
                        [*objpdf drawTextWithFrame:CGRectMake(leftPos-22, topPos, colWidth, 12) Text:@"Outer" Font:customBoldFont TextAlignment:NSTextAlignmentCenter TruncateToWidth:colWidth];
                    }else
                        [*objpdf drawTextWithFrame:CGRectMake(leftPos, topPos, colWidth, 12) Text:@"Outer" Font:customBoldFont TextAlignment:NSTextAlignmentCenter TruncateToWidth:colWidth];
                    
                }else  if (kAppDelegate.selectedCompanyId == 51 && [key isEqualToString:@"Tot Packs"]){//*******  condition for squirrels 2 26 Aug 2015
                    [*objpdf drawTextWithFrame:CGRectMake(leftPos+5, topPos, colWidth, 12) Text:@"Tot Pks" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:colWidth];
                } //Ended
                else if (kAppDelegate.selectedCompanyId == 51 && [key hasSuffix:@"Del Date"]){//*******  condition for squirrels 2 26 Aug 2015
                    [*objpdf drawTextWithFrame:CGRectMake(leftPos-26, topPos, colWidth, 12) Text:strLabel Font:customBoldFont TextAlignment:NSTextAlignmentCenter TruncateToWidth:colWidth];
                }
                else
                    [*objpdf drawTextWithFrame:CGRectMake(leftPos, topPos, colWidth, 12) Text:strLabel Font:customBoldFont TextAlignment:NSTextAlignmentCenter TruncateToWidth:colWidth];
            }
        }
        
        // draw line below all the details
        [*objpdf drawLineWithFrame:CGRectMake(0, topPos+11, 570, 1) LineWidth:2.0 LineColor:[UIColor grayColor]];//current heading bottom line add comment by Ashish
    }
    @catch (NSException *exception) {
        //[CommonHelper writeErrorLogWithNo:0 Description:[exception description] Method:[NSString stringWithUTF8String:__func__]];
    }
}

+(void)includeSignature:(NSString *)ordernum PDFRef:(PDFCreator **)pdfref TopPos:(CGFloat)totpos LeftPos:(CGFloat)leftpos{
    // DebugLog(@"includeSignature5");
    @try {
        //        if([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/ImgFolder/%@.png",CompanyConfigDelegate.LocalPath,ordernum]]){
        
        UIImage* image = nil;//[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/ImgFolder/%@.png",CompanyConfigDelegate.LocalPath,ordernum]];
        if(image!=nil){
            CGSize imgSize = [image size];
            CGSize newImageSize;
            double percent;
            if(imgSize.width>140){
                percent = 140/imgSize.width;
                newImageSize.width = 140;
                newImageSize.height = imgSize.height*percent;
            }
            else
                newImageSize = imgSize;
            
            // write signature image
            [*pdfref drawImageWithFrame:CGRectMake(leftpos, totpos, newImageSize.width, newImageSize.height) Image:image];
        }
        
        //        }
    }
    @catch (NSException *exception) {
        //        [CommonHelper writeErrorLogWithNo:0 Description:[exception description] Method:[NSString stringWithUTF8String:__func__]];
    }
}
//added by Ashish
+(NSUInteger)getMaxDescLength:(NSString *)description fontName:(UIFont *)fontName size:(CGFloat )descWidth height:(CGFloat)descHeight{
    CGRect label1Frame = CGRectMake(0, 0, descWidth, descHeight);
    NSUInteger numberOfCharsInLabel1 = NSNotFound;
    for (int i = [description length]; i >= 0; i--) {
        NSString *substring = [description substringToIndex:i];
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:substring
                                                                             attributes:@{ NSFontAttributeName : fontName }];
        CGSize size = CGSizeMake(label1Frame.size.width, CGFLOAT_MAX);
        CGRect textFrame = [attributedText boundingRectWithSize:size
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                        context:nil];
        
        if (CGRectGetHeight(textFrame) <= CGRectGetHeight(label1Frame)) {
            numberOfCharsInLabel1 = i;
            break;
        }
    }
    
    if (numberOfCharsInLabel1 == NSNotFound) {
        // TODO: Handle this case.
        return numberOfCharsInLabel1=0;
    }
    // DebugLog(@"desc length is %d",numberOfCharsInLabel1);
    
    numberOfCharsInLabel1=[description substringToIndex:numberOfCharsInLabel1].length ;
    return numberOfCharsInLabel1;
}
//end of code added

+ (UIImage *)resizeImageAtPath:(NSString *)imagePath thumbnailSize:(CGFloat)thumbsize {
    if(![[NSFileManager defaultManager] fileExistsAtPath:imagePath]) return nil;
    
    // Create the image source
    CGImageSourceRef src = CGImageSourceCreateWithURL((__bridge CFURLRef) [NSURL fileURLWithPath:imagePath], NULL);
    // Create thumbnail options
    CFDictionaryRef options = (__bridge CFDictionaryRef) @{
                                                           (id) kCGImageSourceCreateThumbnailWithTransform : @YES,
                                                           (id) kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                                           (id) kCGImageSourceThumbnailMaxPixelSize : @(thumbsize)
                                                           };
    // Generate the thumbnail
    CGImageRef thumbnail = CGImageSourceCreateThumbnailAtIndex(src, 0, options);
    CFRelease(src);
    
    UIImage *img =[UIImage imageWithCGImage:thumbnail];
    CFRelease(thumbnail);
    
    return img;
    
    //    // Write the thumbnail at path
    //    NSString *newimgpath = [[imagePath stringByDeletingLastPathComponent] stringByAppendingFormat:@"/%li",(long)thumbsize] ;
    //    if(![[NSFileManager defaultManager] fileExistsAtPath:newimgpath]){
    //        [[NSFileManager defaultManager] createDirectoryAtPath:newimgpath withIntermediateDirectories:NO attributes:nil error:nil];
    //    }
    //    NSString *newimgfullpath = [newimgpath stringByAppendingPathComponent:[imagePath lastPathComponent]];
    //    CGImageWriteToFile(thumbnail, newimgfullpath);
}

void CGImageWriteToFile(CGImageRef image, NSString *path) {
    CFURLRef url = (__bridge CFURLRef) [NSURL fileURLWithPath:path];
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, kUTTypeJPEG, 1, NULL);
    CGImageDestinationAddImage(destination, image, nil);
    
    if (!CGImageDestinationFinalize(destination)) {
        DebugLog(@"Failed to write image to %@", path);
    }
    
    CFRelease(destination);//Comment for remove leakes
    CGImageRelease(image);//Comment for remove leakes
}


//added by Amit Pant on 201602010

+(NSMutableData *)CreateOrderFormat:(NSManagedObject *)orderObject Format:(OrderFormatType)orderformat SortIndex:(int)sortidx ValueIndex:(int)validx{
    
    
    NSString *orderNum=[orderObject valueForKey:@"orderid"];
    
    NSDictionary* featureDict;//   fetch feature
    NSDictionary* companyConfigDict;//   fetch CompanyConfig
    NSDictionary* priceConfigDict;//   fetch PriceConfig
    
    // fetch Feature config
    featureDict = nil;
    NSDictionary *dic=[CommonHelper loadFileDataWithVirtualFilePath:FeaturesConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        featureDict = [dic objectForKey:@"data"];
    
    //   fetch CompanyConfig
    companyConfigDict = nil;
    dic=[CommonHelper loadFileDataWithVirtualFilePath:CompanyConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        companyConfigDict = [dic objectForKey:@"data"];
    
    //   fetch priceConfig
    priceConfigDict = nil;
    dic=[CommonHelper loadFileDataWithVirtualFilePath:PricingConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        priceConfigDict = [dic objectForKey:@"data"];
    ////////////
    
    
    NSArray *fieldsLabel=[NSArray arrayWithArray:[[priceConfigDict valueForKey:@"emailprintconfigs"] valueForKey:@"printformats"]];
    
    
    NSMutableData* PDFData;
    //Added by Rajesh Pandey on 4 Feb 2015
    if (strval !=nil)
        strval=nil;
    if (strval == nil)
        strval = [[NSMutableString alloc] init];
    int rwCnt=0;
    int photoFooterCount=1; //added by Ashish
    
    ///added by Amit Pant on 20160210
    NSString *Print_Format=@"1";
    int pageCount=0;
    ///
    //Default Page Size for A4(595x842);
    PDFCreator* objpdf =[[PDFCreator alloc] initPDFWithPageWidth:595.0 Height:842.0];
    @try {
        BOOL isLeftSideData=YES;
        
        NSString *cust_name = nil;
        NSString *cust_Code = nil;
        NSString *ordType = nil;
        NSString *strcurr = nil;
        NSString *strtyperef = nil;
        double totalVat=0;
        NSString *NextCallDate = nil;
        
        // To get information for page footer
        
        
        cust_Code=[orderObject valueForKey:@"customerid"];
        cust_name=[orderObject valueForKey:@"custname"];
        ordType  = [orderObject valueForKey:@"ordtype"];
        strcurr  = [orderObject valueForKey:@"curr"];
        strtyperef = [orderObject valueForKey:@"typeref"];
        totalVat = [[orderObject valueForKey:@"totalvat"] doubleValue];
        NextCallDate = [orderObject valueForKey:@"nextcall_date"];
        if(strcurr==nil || [strcurr length]==0)
            strcurr = @"GBP";
        
        
        NSString *strcurrsymbol = @"";//[CommonHelper getCurrSymbolWithCurrCode:strcurr];
        
        // To get information to set heading
        
        
        int orderlinecount=[[orderObject valueForKey:@"orderlinesnew"] count];
        int maxProdCodeLen=9;//[[arr objectAtIndex:1] intValue];
        int maxProdDescLen=20;//[[arr objectAtIndex:2] intValue];
        int maxBarCodeLen=13;//[[arr objectAtIndex:3] intValue];
        double discountavailable = 0;
        
        if([[[companyConfigDict valueForKey:@"companyname"]lowercaseString] hasPrefix:@"cimc"] && orderformat==OrderSmallPhotos) {
            
            int descLength=25;
            int extorderlinecount = 0;//[[SQLHelper getValueWithQuery:[NSString stringWithFormat:@"SELECT COUNT(line_no) FROM T_Olines LEFT OUTER JOIN T_Prod ON Stock_Code=Product_Code Where length(ifnull(Description,''))> %d and Order_Number='%@'",descLength,orderNum] Database:CompanyConfigDelegate.database] intValue];
            double temp=ceil(extorderlinecount/4 +.1);
            
            orderlinecount +=temp;
            
            if (maxProdCodeLen>15) {
                maxProdCodeLen=15;
            }
        }
        
        //end of the code
        
        
        
        //need to implement later on
        if([[[priceConfigDict valueForKey:@"orderconfigs"] valueForKey:@"showdiscountboxenabled"]boolValue])
            discountavailable = 0;//[[arr objectAtIndex:4] doubleValue];
        
        NSMutableArray* arrHeadings = [[NSMutableArray alloc] init];
        NSMutableDictionary* dicHeads = [[NSMutableDictionary alloc] init];
       //[CompanyConfigDelegate.dicPacksInfo objectForKey:@"PackLabels_Sidebar"];
        int startfrompack = 1;
        NSArray* arrpacks = [[priceConfigDict objectForKey:@"orderpanellabels"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.includeinsidebar==1"]];
        NSDictionary* dicPrices;
        if (orderformat==OrderLargePhotos)
            dicPrices=[arrpacks objectAtIndex:startfrompack];
        else
         dicPrices = [[priceConfigDict valueForKey:@"orderpanellabels"]  objectAtIndex:startfrompack];
        if(![[dicPrices valueForKey:@"label"] isEqualToString:@""] && ([[[dicPrices valueForKey:@"label"] lowercaseString] isEqualToString:@"single"] || [[[dicPrices valueForKey:@"label"] lowercaseString] isEqualToString:@"unit"]))
            startfrompack++;
        
        
        NSDictionary* dicPrices1 = [[priceConfigDict valueForKey:@"orderpanellabels"]  objectAtIndex:startfrompack+1];
        if(orderlinecount>0){
            [arrHeadings addObject:@"Image"];
            [arrHeadings addObject:@"Code"];
            [arrHeadings addObject:@"Description"];
            //code added by Ashish
            
            if (kAppDelegate.selectedCompanyId==47){
                [arrHeadings addObject:@"CBM"];
                [arrHeadings addObject:@"Pallet"];
            }
            //end of code added
            
            //*******     RE TestyTab acknowledgement  17 JUN 2015
            if(!(orderformat == OrderTextFormat && [[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"tasty"])){
                
                if(kAppDelegate.selectedCompanyId== 51)
                {
                    [arrHeadings addObject:@"Innr"];
                    [arrHeadings addObject:@"Outr"];
                    
                }else
                {
                    [arrHeadings addObject:@"Barcode"];
                    [arrHeadings addObject:@"Type"];
                }
            }
            
            //            [arrHeadings addObject:@"Barcode"];
            //            [arrHeadings addObject:@"Type"];
            
            //added by Amit Pant
            if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"ardale"]) {
                [arrHeadings addObject:@"Ctns"];
            }
            [arrHeadings addObject:@"Inner"];
            if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]  hasPrefix:@"ryder imports ltd"]) {
                [arrHeadings addObject:@"CBM"];
                [arrHeadings addObject:@"Weight"];
            }
            else
                [arrHeadings addObject:@"Outer"];
            if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]  hasPrefix:@"otl"]) {
                [arrHeadings addObject:@"Qty Cases"];
            }
            if (kAppDelegate.selectedCompanyId== 51)
                [arrHeadings addObject:@"Tot Packs"];
            else
                [arrHeadings addObject:@"Tot Qty"];
            if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]  hasPrefix:@"tallon"])
                [arrHeadings addObject:@"Cases"];
            
            
            if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]  hasPrefix:@"ryder"])
                [arrHeadings addObject:@"RRP"];
            
            [arrHeadings addObject:@"Unt Prc"];
            
            [arrHeadings addObject:@"Disc"];
            
            //*******  TestyTab acknowledgement  30 Apr 2015
            //DebugLog(@"%@      %@      %@      %@",[companyConfigDict valueForKey:@"companyname"],[CompanyConfigDelegate.dicGenInfo objectForKey:@"Invoice"],UserConfigDelegate.strOlineType,ordType);
            if ([ordType isEqualToString:@"I"]){ //&& [[UserConfigDelegate.strOlineType uppercaseString] isEqualToString:@"I"]){
                
                //*******     RE TestyTab acknowledgement  17 JUN 2015
                if(!(orderformat == OrderTextFormat && [[[companyConfigDict valueForKey:@"companyname"]lowercaseString]  hasPrefix:@"tasty"])){
                    [arrHeadings addObject:@"Vat Code"];
                }
                //                    [arrHeadings addObject:@"Vat Code"];
                [arrHeadings addObject:@"Vat Amt"];
            }
            [arrHeadings addObject:@"Ord Prc"];
            
            [arrHeadings addObject:@"Tot Val"];
            if (![[[companyConfigDict valueForKey:@"companyname"]lowercaseString]  hasPrefix:@"ryder imports ltd"]){
                
                //*******     RE TestyTab acknowledgement  17 JUN 2015
                if(!(orderformat == OrderTextFormat && [[[companyConfigDict valueForKey:@"companyname"]lowercaseString]  hasPrefix:@"tasty"])){
                    if (kAppDelegate.selectedCompanyId== 51 && orderformat == OrderCSVFile)
                        [arrHeadings addObject:@"Del Id"];
                    [arrHeadings addObject:@"Del Date"];
                    
                }
            }
            //if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]  hasPrefix:@"squirrels_UK Ltd"])
            [arrHeadings addObject:@"Exp Date"];
            
            
            
            
            if(orderformat!=OrderSmallPhotos) [arrHeadings removeObject:@"Image"];
            //  if(maxBarCodeLen==0 || [[CompanyConfigDelegate.dicGenInfo objectForKey:@"IsFurnitureModuleActive"]boolValue]) [arrHeadings removeObject:@"Barcode"];
            if(maxProdDescLen==0) [arrHeadings removeObject:@"Description"];
            if(validx==0) [arrHeadings removeObject:@"Tot Val"];
            
            if([Print_Format isEqualToString:@"2"])
                [arrHeadings removeObject:@"Disc"];
            else{
                if(discountavailable==0){
                    if(![Print_Format isEqualToString:@"1"]) [arrHeadings removeObject:@"Unt Prc"];
                    [arrHeadings removeObject:@"Disc"];
                }
            }
            if(![Print_Format isEqualToString:@"4"]) [arrHeadings removeObject:@"Exp Date"];
            
            //need to change later on
            if(![[dicPrices valueForKey:@"label"] isEqualToString:@""] && [dicPrices valueForKey:@"label"] != nil){
             }
             else
                 [arrHeadings removeObject:@"Inner"];
            
            
            if(![[dicPrices1 valueForKey:@"label"] isEqualToString:@""] && [dicPrices1 valueForKey:@"label"] != nil){
             }
             else
                 [arrHeadings removeObject:@"Outer"];
            
            //code added by Amit Pant on 2014-06-23
            if([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]  hasPrefix:@"cimc"]) {
                [arrHeadings removeObject:@"Outer"];
            }
            //end of the code by Amit Pant
            
            //added by Amit Pant
            if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]  hasPrefix:@"ardale"]) {
                [arrHeadings removeObject:@"Unt Prc"];
            }
            
            //Beamfeature custmisation
            if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]  hasPrefix:@"beamfeature"]) {
                [arrHeadings removeObject:@"Unt Prc"];
            }
            
            
            
            
            float colWidth=0;
            float colLeftPos = 570;
            
            
            for(int i=[arrHeadings count]-1;i>=0;i--){
                NSString* key  =  [arrHeadings objectAtIndex:i];
                NSString* strLabel = key;
                colWidth = 38;
                if([key isEqualToString:@"Description"]){
                    colWidth=maxProdDescLen * 6;
                    
                    int tmpWidth = 0;
                    if(orderformat==OrderSmallPhotos) tmpWidth = 38;
                    //code added by Amit Pant on 2014-06-23
                    if([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]  hasPrefix:@"cimc"]) {
                        if(orderformat==OrderSmallPhotos)
                            tmpWidth -= 10;
                        else
                            tmpWidth -= 15;
                    }
                    //end of code added by Amit Pant
                    
                    if(colLeftPos-colWidth - (maxProdCodeLen * 6)-tmpWidth<0)
                        colWidth = colLeftPos - (maxProdCodeLen * 6)-tmpWidth;
                    
                }
                else if([key isEqualToString:@"Code"]){
                    colWidth=maxProdCodeLen * 6;
                    //code added by Amit Pant on 2014-06-23
                    if([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]  hasPrefix:@"cimc"]) {
                        if(orderformat==OrderSmallPhotos)
                            colWidth -=10;
                        else
                            colWidth -= 15;
                    }
                    //end of the code by Amit Pant
                }
                else if([key isEqualToString:@"Barcode"])
                    colWidth=60;
                else if([key isEqualToString:@"Type"])
                    colWidth=20;
                else if([key isEqualToString:@"Del Id"]){
                    colWidth=45;
                    if (kAppDelegate.selectedCompanyId== 51 && orderformat == OrderCSVFile)
                        strLabel=@"Layers";
                }
                else if([key isEqualToString:@"Inner"]){
                    strLabel = [dicPrices valueForKey:@"label"];
                    colWidth=26;
                    if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]  hasPrefix:@"ardale"]){
                        strLabel=@"Ctn Qty";
                        colWidth=30;
                    }
                    if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]  hasPrefix:@"otl"])
                        colWidth=30;
                    
                    if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]  hasPrefix:@"beamfeature"]) {
                       strLabel=@"Inner";
                    }
                    
                }
                else if([key isEqualToString:@"Outer"]){
                    strLabel = [dicPrices1 valueForKey:@"label"];
                    colWidth=26;
                    
                    if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]  hasPrefix:@"beamfeature"]) {
                        strLabel=@"Outer";
                    }
                    
                }
                else if([key hasSuffix:@"Prc"] ||[key hasSuffix:@"Val"]||[key hasPrefix:@"RRP"]){
                    if (![key isEqualToString:@"RRP"])
                        colWidth=52;
                    else
                        colWidth=30;
                    strLabel = [NSString stringWithFormat:@"%@(%@)",key,strcurrsymbol];
                }
                else if([key isEqualToString:@"Disc"]){
                    strLabel = [NSString stringWithFormat:@"%@(%%)",key];
                }
                if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]  hasPrefix:@"otl"] && [key isEqualToString:@"Qty Cases"]){
                    strLabel=@"Qty Cases";
                    colWidth=50;
                }
                
                //Changed by Rajesh Pandey on 19/08/2014
                else if ([key isEqualToString:@"Colour desc"])
                    colWidth=55;
                else if ([key isEqualToString:@"Pallet qty"]||[key isEqualToString:@"Pallet"])//add Pallet by Ashish for benross
                    colWidth=40;
                else if ([key isEqualToString:@"Prsize"])
                    colWidth=40;
                else if ([key isEqualToString:@"CBM"])
                    colWidth=21;
                else if ([key isEqualToString:@"Weight"])
                    colWidth=32;
                else if ([key isEqualToString:@"Del Date"])
                {
                    if (kAppDelegate.selectedCompanyId== 51)
                        strLabel=@"BBE";
                    else
                        strLabel=@"Del Date";
                }
                colLeftPos-=colWidth;
                [dicHeads setObject:[NSString stringWithFormat:@"%@|%f|%f",strLabel,colLeftPos,colWidth] forKey:key];
            }
            
            if(colLeftPos>0){
                int indexOfDesc =(int) [arrHeadings indexOfObject:@"Description"];
                if(indexOfDesc<INT32_MAX){
                    for(int j=indexOfDesc;j>=0;j--){
                        NSString* key = [arrHeadings objectAtIndex:j];
                        NSArray* arrpos = [[dicHeads objectForKey:key] componentsSeparatedByString:@"|"];
                        float fLeftPos = [[arrpos objectAtIndex:1] floatValue];
                        float fWidth = [[arrpos objectAtIndex:2] floatValue];
                        if(j==indexOfDesc)
                            fWidth+=colLeftPos;
                        fLeftPos-=colLeftPos;
                        [dicHeads setObject:[NSString stringWithFormat:@"%@|%f|%f",[arrpos objectAtIndex:0],fLeftPos,fWidth] forKey:key];
                    }
                }
            }
        }
        
        enum PageNumberPosition pagePosition;
        int firstPageLineCount = 42;
        // int otherPageLineCount = 56; comment by Ashish
        int otherPageLineCount = 50;//added by Ashish
        int count=0;
        CGFloat leftPos = 0;
        CGFloat topPos = 219;
        if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"gallery"] )
            topPos = 235;//added by Ashish //current top posiiton for array heading
        
        UIFont* customFont = [UIFont fontWithName:kNormalFont size:8.0];
        UIFont* customBoldFont = [UIFont fontWithName:kBoldFont size:8.0];
        
        CGFloat rowHeight = 0;
        CGFloat leftPoslinetext = 0;
        CGFloat leftPosTot = 0;
        double totalOrderVal = 0;
        
        int allowedRowsPerPage = firstPageLineCount;
        int rowCount = 0;
        int currentPage = 1;
        int totalPages = 1;
        
        CGFloat extRowHeight = 0;//added by Amit Pant
        
        if(orderformat==OrderSmallPhotos){
            firstPageLineCount = 16;
            //  otherPageLineCount = 22;//comment by Ashish
            otherPageLineCount = 19;//added by Ashish
            
            allowedRowsPerPage = firstPageLineCount;
            pagePosition=PageNumberPositionBottomRihgt; //Added by Laxman
            
        }
        else if(orderformat == OrderTextFormat)
            pagePosition=PageNumberPositionBottomRihgt2;
        else if(orderformat == OrderLargePhotos) //Added by Laxman
        {
            firstPageLineCount =10;
            otherPageLineCount =12;
            
            //if(orderlinecount==firstPageLineCount || orderlinecount==firstPageLineCount-1)
            //    firstPageLineCount -=2;
            
            pagePosition=PageNumberPositionBottomRihgt;
            topPos = 209;
            if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"gallery"] )
                topPos = 225;//addedby Ashish
            allowedRowsPerPage = firstPageLineCount;
            rowHeight=110;
        }
        
        if(orderlinecount>firstPageLineCount){
            int  othercount = (orderlinecount-firstPageLineCount);
            if(orderformat == OrderLargePhotos){
                if (othercount>otherPageLineCount)
                {
                    totalPages+=(othercount/otherPageLineCount);
                    if (othercount%otherPageLineCount!=0)
                        totalPages++;
                }
                else
                    totalPages++;
            }
            else
            {
                //int minusSet = 4;
                //if(orderformat==OrderSmallPhotos) minusSet = 2;
                while (othercount>0) {
                    totalPages++;
                    if (othercount>otherPageLineCount)
                        othercount -= otherPageLineCount;
                    else if (othercount>otherPageLineCount)
                        othercount -= (otherPageLineCount);
                    else{
                        othercount = 0;
                        break;
                    }
                }
            }
            pageCount=totalPages;
            kAppDelegate.pageCount=totalPages;
        }
        
        
        //PDFCreator* objpdf =[[PDFCreator alloc] initPDFWithPath:strpdfpath]; //[[PDFCreator alloc] initPDFWithPath:strpdfpath AllowCopy:NO AllowPrint:NO IsSecure:NO OwnerPwd:@"" UserPwd:@""];
        
        [objpdf drawPageNumber:1 TotalPages:totalPages ShowPageNo:YES PageNumberPosition:pagePosition];
        
        
        [self writeCompanyDetailsWithLogo:YES PDFRef:&objpdf];
        [self writeOrderHeadWithOrderNumber:orderObject PDFRef:&objpdf];
        
        
        // write table heading for the first time
        if(orderformat==OrderSmallPhotos || orderformat==OrderTextFormat || orderformat== OrderCSVFile){
            if(orderlinecount>0)
            {
                //  [self writeTableHeadingWithTopPos:205.0 PDFRef:&objpdf ColumnKeys:arrHeadings ColumnLabels:dicHeads];//comment by Ashish
                if (orderformat!=OrderCSVFile) {
                    
                    if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"gallery"] )
                        [self writeTableHeadingWithTopPos:220.0 PDFRef:&objpdf ColumnKeys:arrHeadings ColumnLabels:dicHeads];//added by Ashish //array heading
                    else
                        [self writeTableHeadingWithTopPos:205.0 PDFRef:&objpdf ColumnKeys:arrHeadings ColumnLabels:dicHeads];
                }
                //Code added by Rajesh Pandey on 4 Feb 2015 to create CSV according to PDF
                else{
                    if (kAppDelegate.selectedCompanyId== 51){
                        for(int i=9;i>=6;i--){
                            id tempObj = [arrHeadings objectAtIndex:i];
                            id tempObj1= [arrHeadings objectAtIndex:i-1];
                            [arrHeadings replaceObjectAtIndex:i-1 withObject:tempObj];
                            [arrHeadings replaceObjectAtIndex:i withObject:tempObj1];
                        }
                    }
                    if (rwCnt==0)
                        for(int i=0;i<[arrHeadings count];i++){
                            NSString* key=[arrHeadings objectAtIndex:i];
                            if([key isEqualToString:@"Inner"]){
                                key = [dicPrices objectForKey:[NSString stringWithFormat:@"Pack%d",startfrompack]];
                                if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"ardale"]){
                                    key=@"Ctn Qty";
                                }
                            }
                            else if([key isEqualToString:@"Outer"]){
                                key = [dicPrices objectForKey:[NSString stringWithFormat:@"Pack%d",startfrompack+1]];
                            }
                            else if ([key isEqualToString:@"Del Date"] && (kAppDelegate.selectedCompanyId== 51)){
                                key=@"BBE";
                            }
                            else if ([key isEqualToString:@"Del Id"] && (kAppDelegate.selectedCompanyId== 51) && (orderformat == OrderCSVFile)){
                                key=@"Layers";
                            }
                            else if ([key isEqualToString:@"Innr"] && (kAppDelegate.selectedCompanyId== 51) && (orderformat == OrderCSVFile))
                                key=@"Inner";
                            else if ([key isEqualToString:@"Outr"] && (kAppDelegate.selectedCompanyId== 51) && (orderformat == OrderCSVFile))
                                key=@"Outer";
                            NSString *temp;
                            if (i==[arrHeadings count]-1)
                                temp= [NSString stringWithFormat:@"\"%@\"\r\n",key];
                            else
                                temp= [NSString stringWithFormat:@"\"%@\",",key];
                            [strval appendString:temp];
                        }
                    rwCnt=1;
                }
            }
            //[self writeTableHeadingWithConfig:dicPrices Format:orderformat CurrencySymbol:strcurrsymbol TopPosition:205.0 PDFRef:objpdf ShowDiscount:discountavailable>0 ValueIndex:validx OrderConfig:CompanyConfigDelegate.dicOrderInfo MaxProdLength:maxProdCodeLen];
        }
        
        
        NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        
        NSNumberFormatter* decimalFormatter = [[NSNumberFormatter alloc] init];
        [decimalFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        
        if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"ardale"]) {
            [decimalFormatter setMaximumFractionDigits:3];
        }
        else{
            [decimalFormatter setMaximumFractionDigits:2];
            [decimalFormatter setMinimumFractionDigits:2];
        }
        int remainRecCount = orderlinecount;
        
        NSString* strSort=@"ORDER BY L.Line_No";
        //code added by Ashish
        if (kAppDelegate.selectedCompanyId==47)
            strSort=@"ORDER BY IFNULL(P.grp2,''),IFNULL(P.PalletQty3,'') ";
        //end of code added
        
        int totOlinesQty = 0;
        int totOlinesCount = 0;
        double totCartons = 0;
        double totCBM = 0;
        

        NSArray *arrItems;
        arrItems=[orderObject valueForKey:@"orderlinesnew"];
       
         if(sortidx>0)
         {
             if (sortidx==1)
                 strSort=@"productid";
             else
                 strSort=@"product.gdescription";
             
             NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:strSort   ascending:YES] ;
             NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
             arrItems = [arrItems sortedArrayUsingDescriptors:sortDescriptors];
         }else{
             
             strSort=@"requireddate";
             NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:strSort   ascending:NO] ;
             NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
             arrItems = [arrItems sortedArrayUsingDescriptors:sortDescriptors];
         }

        for (NSDictionary *item in arrItems) {
            NSDictionary *product=[item valueForKey:@"product"];
            ////items writing
            
        //while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                NSString* prodcode =[item valueForKey:@"productid"];
                NSString* proddesc =[product valueForKey:@"gdescription"];
                NSString* barcode =[item valueForKey:@"barcode"];
                NSString* olinetype =[item valueForKey:@"orderlinetype"];
                
                double lineinner = [[item valueForKey:@"line_inner"] doubleValue];
                double lineouter = [[item valueForKey:@"line_outer"] doubleValue];
                int totordqty = [[item valueForKey:@"quantity"] intValue];
                int ctnordqty=0;
                
                
                double unitprice = [[item valueForKey:@"unitprice"] doubleValue];
                double prcperctn = 0.0;
                double discount = [[item valueForKey:@"disc"] doubleValue];
                double soldprice = [[item valueForKey:@"saleprice"] doubleValue];
                double totvalue = [[item valueForKey:@"linetotal"] doubleValue];
                if([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"bonn"]){
                    
                    soldprice = round(soldprice  * 100.0) / 100.0;
                    totvalue = totordqty * soldprice;
                }
                
                if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"ardale"]) {
                    ctnordqty=totordqty/lineinner;
                    prcperctn=unitprice*lineinner;
                }
                //Code added by Rajesh Pandey on 23 Jan 2015 for Ryder.
                if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"otl"]|| [[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"ryder imports ltd"]) {
                    ctnordqty=totordqty/lineinner;
                }
                if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"tallon"]) {
                    ctnordqty=totordqty/lineouter;
                }
                //added by Amit Pant on 11-12-13
                if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"swift"]) {
                    unitprice=soldprice;
                    soldprice=soldprice-((soldprice*discount)/100);
                }
                NSString* strdeladdcode =[item valueForKey:@"deliveryaddresscode"];
                NSString* strdeldate =[CommonHelper showDateWithCustomFormat:@"dd/MM/yy" Date:[item valueForKey:@"requireddate"]];
                
                NSString* strlinetext =[item valueForKey:@"linetext"];
                NSString* strCol =[product valueForKey:@"longdesc"];
                
                //code added by Amit Pant on 2014-06-23
                if([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"cimc"]) {
                    strCol=proddesc;
                }
                int packqty3 =0;// [[product valueForKey:@"packqty3"] integerValue];
                NSString* strCat =[product valueForKey:@"category"] ;
                NSString* strExpDate =[item valueForKey:@"expecteddate"];
                //Changed by Rajesh Pandey on 19/08/2014
                NSString* prodcolordesc =[product valueForKey:@"colour_desc"] ;//[NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 26)];
                NSString* prodpltqty =[product valueForKey:@"palletqty"] ;//[NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 27)];
                NSString* prodprsize =[product valueForKey:@"prsize"] ;//[NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 28)];
                
                
                NSString* strPRC1 = nil;
                NSString* strPRC2 = nil;
                NSString* strPRC3 = nil;
                NSString* strPRC4 = nil;
                NSString* strPRC5 = nil;
                NSString* strPRC6 = nil;
                double itemcbm = 0;
                double rRP=0;
                double weight=0;
                rRP = [[product valueForKey:@"price2"] doubleValue];//sqlite3_column_double(statement, 29);
                weight = [[product valueForKey:@"weight"] doubleValue];//sqlite3_column_double(statement, 30);
                //*******     Mahendra  invoice acknowledgement  30 Apr 2015
                NSString* vatCode = [item valueForKey:@"vatcode"];
                double vatTotal = [[item valueForKey:@"vattotal"] doubleValue];
                
                NSString *outerBarcode=[product valueForKey:@"outerbarcode"];
                int prlaypall = [[product valueForKey:@"prlaypall"] intValue];
                NSString *sellUnit=[product valueForKey:@"sellunit"];
                
                
                itemcbm =[[product valueForKey:@"prd_carton_cbm"] doubleValue]; //
                
                //![[olinetype uppercaseString] isEqualToString:@"Q"]
                
                if (kAppDelegate.selectedCompanyId==47) {
                    proddesc=[proddesc stringByAppendingFormat:@" - %@",strCol];
                }
                
                
                if(![Print_Format isEqualToString:@"5"]){
                    //added by Amit Pant on 11 March 2014
                    //if (![[olinetype uppercaseString] isEqualToString:@"Q"]) {
                    totalOrderVal+=totvalue;
                    //}
                    totOlinesQty+=totordqty;
                    
                    if(YES){
                        if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"ardale"] || [[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"otl"]) {
                            totCBM += (double)ctnordqty*itemcbm;
                            totCartons+= (double)ctnordqty;
                        }
                        else if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"squirrels"]) {
                            totCBM += ((double)totordqty/(double)lineouter)*itemcbm;
                            totCartons+= (double)totordqty;
                        }
                        //Code added by Rajesh Pandey on 9 Jan 2015 for Gallery.
                        else if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"gallery"] ){
                            totCBM += ((double)totordqty/(double)lineinner)*itemcbm;
                            totCartons+= (double)lineinner;
                        }
                        //Code added by Rajesh Pandey on 23 Jan 2015 for Ryder.
                        else if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"ryder imports ltd"])
                        {
                            totCBM += ((double)totordqty/(double)lineinner)*itemcbm;
                            totCartons+= (double)ctnordqty;
                            
                        }
                        else{
                            totCBM += ((double)totordqty/(double)lineouter)*itemcbm;
                            totCartons+= (double)totordqty/(double)lineouter;
                        }
                    }
                    else
                        totCBM+=itemcbm*totordqty;
                    totOlinesCount++;
                }
                
                UIImage* image = nil;
                count++;
                //code added by ashish
                if (photoFooterCount==1) {
                    photoFooterCount++;
                    //code to show footer in first page by defualt
                    //[self largePhotoFooter:0.0 TopPosition:710.0 PDF:&objpdf OrdNum:orderNum Cust:cust_name CustCode:cust_Code CBMPosition:0];
                }
                //end of code added
                
                if(orderformat==OrderSmallPhotos || orderformat==OrderTextFormat || orderformat==OrderCSVFile){
                    //   by faizan on 21 jul for boyz toyz
                    if(![[dicPrices valueForKey:@"label"] isEqualToString:@""] && ([[[dicPrices valueForKey:@"label"] lowercaseString] isEqualToString:@"single"] || [[[dicPrices valueForKey:@"label"] lowercaseString] isEqualToString:@"unit"])){
                        //startfrompack++;
                        lineinner = lineouter;
                        lineouter = packqty3;
                    }
                    //----
                    //code added by Ashish
                    CGFloat descHeight=0;
                    CGFloat colWidthDesc=0;
                    NSArray* tarr =[[dicHeads objectForKey:@"Description"] componentsSeparatedByString:@"|"];
                    if([tarr count]>0)
                        colWidthDesc = [[tarr objectAtIndex:2] floatValue];
                    colWidthDesc=350;
                    
                    
                    if ( proddesc.length>5) {
                        NSUInteger maxlength=[self getMaxDescLength:proddesc fontName:customFont size:colWidthDesc height:12];
                        NSUInteger descMaxLength=maxlength-4;
                        int lblCount=0;
                        if (proddesc.length % descMaxLength==0) {
                            lblCount=proddesc.length / descMaxLength;
                        }
                        else
                            lblCount=(proddesc.length / descMaxLength)+1;
                        
                        
                        descHeight=lblCount*8;
                    }
                    else
                        descHeight=8;
                    //end of code added
                    
                    
                    rowCount++;
                    //code added by ashish by adding descHeight
                    if ((topPos+descHeight>770 && totalPages>currentPage && orderformat==OrderSmallPhotos)||(topPos+descHeight>770 && totalPages>currentPage && orderformat==OrderTextFormat)) {
                        rowCount++;
                    }
                    //code added by ashish by adding topPos+descHeight>770 and removing rowCount>allowedRowsPerPage
                    if(topPos+descHeight>770){
                        currentPage++;
                        pageCount=currentPage;//code added by Ashish as page is changing by rowheight
                        kAppDelegate.pageCount=currentPage;
                        [objpdf drawPageNumber:currentPage TotalPages:totalPages ShowPageNo:YES PageNumberPosition:pagePosition];
                        
                        //  if(currentPage>1 && currentPage<totalPages)//commented by Ashish
                        // [self largePhotoFooter:0.0 TopPosition:710.0 PDF:&objpdf OrdNum:orderNum Cust:cust_name CustCode:cust_Code CBMPosition:0];
                        
                        
                        allowedRowsPerPage = otherPageLineCount;
                        
                        //code change by Ashish Pant
                        if (orderformat!=OrderCSVFile){
                            rowCount = 1;
                            [self writeCompanyDetailsWithLogo:YES PDFRef:&objpdf];
                            topPos=97;
                            [self ordTypeHeader:ordType PDF:&objpdf];
                            [self writeTableHeadingWithTopPos:topPos PDFRef:&objpdf ColumnKeys:arrHeadings ColumnLabels:dicHeads];
                            topPos =topPos+15;
                        }//end of code change
                        else{
                            rowCount = 1;
                            topPos = 0;
                            [self writeTableHeadingWithTopPos:topPos PDFRef:&objpdf ColumnKeys:arrHeadings ColumnLabels:dicHeads];
                            topPos = 19;
                        }
                    }
                    
                    int colcount=0;
                    int extDescHeight=0;
                    for(NSString* key in arrHeadings){
                        NSArray* tarr = [[dicHeads objectForKey:key] componentsSeparatedByString:@"|"];
                        CGFloat leftPos = [[tarr objectAtIndex:1] floatValue];
                        CGFloat colWidth = [[tarr objectAtIndex:2] floatValue];
                        
                        if([key isEqualToString:@"Image"]){
                            @try{
                                image=[self resizeImageAtPath:[NSString stringWithFormat:@"%@/%li/images/%@.jpg",[[kAppDelegate applicationDocumentsDirectory] path],kAppDelegate.selectedCompanyId,[[CommonHelper getStringByRemovingSpecialChars:prodcode] lowercaseString]] thumbnailSize:imageratioSmall*2];
                                UIImage* imgt = image;
                                if(image && [image imageOrientation]!=UIImageOrientationUp)
                                    imgt = [UIImage imageWithCGImage:image.CGImage scale:1.0 orientation:UIImageOrientationUp];
                                
                                
                                if(image!=nil){
                                    CGSize imgSize = [imgt size];
                                    CGSize newImageSize = CGSizeMake(0, 0);
                                    double percent;
                                    if(imgSize.height>imageratioSmall){
                                        percent = imageratioSmall/imgSize.height;
                                        newImageSize.height = imageratioSmall;
                                        newImageSize.width = imgSize.width*percent;
                                    }
                                    if(newImageSize.width>0)
                                        imgSize = newImageSize;
                                    if(imgSize.width>imageratioSmall){
                                        percent = imageratioSmall/imgSize.width;
                                        newImageSize.width = imageratioSmall;
                                        newImageSize.height = imgSize.height*percent;
                                    }
                                    else
                                        newImageSize = imgSize;
                                    
                                    [objpdf drawImageWithFrame:CGRectMake(leftPos+2, topPos, newImageSize.width, newImageSize.height) Image:imgt];
                                }
                                
                            }
                            @catch (NSException *exception) {
                                //  [CommonHelper writeErrorLogWithNo:0 Description:[exception description] Method:[NSString stringWithUTF8String:__func__]];
                            }
                            rowHeight = 34.0;
                        }
                        else{
                            if(colcount==0){
                                
                                if([[strlinetext stringByReplacingOccurrencesOfString:@" " withString:@""] length]>0 ){
                                    
                                    rowHeight = 26.0;
                                    allowedRowsPerPage--;
                                    
                                }
                                else{
                                    CGSize stringSizetemp = [proddesc sizeWithFont:customFont];
                                    rowHeight = 13.0;
                                    NSArray* tarr = [[dicHeads objectForKey:@"Description"] componentsSeparatedByString:@"|"];
                                    if([tarr count]>0){
                                        CGFloat colDescWidth = [[tarr objectAtIndex:2] floatValue];
                                        if(stringSizetemp.width>colDescWidth-5){
                                            rowHeight+=13;
                                            allowedRowsPerPage--;
                                        }
                                    }
                                }
                            }
                        }
                        if([key isEqualToString:@"Description"]){
                            
                            if (kAppDelegate.selectedCompanyId== 51){//*******  condition for squirrels 2 26 Aug 2015
                                
                                if (orderformat == OrderTextFormat ) {
                                    colWidth=190;
                                }else if(orderformat==OrderSmallPhotos)
                                    colWidth=135;
                                
                                
                            }
                            
                            
                            //code added by Ashish
                            
                            if ((orderformat==OrderSmallPhotos && proddesc.length>5)||(orderformat==OrderTextFormat && proddesc.length>5)) {
                                
                                
                                if(orderformat == OrderTextFormat ||orderformat==OrderSmallPhotos) {
                                    
                                    [objpdf drawTextWithFrame:CGRectMake(leftPos, topPos, colWidth, 12) Text:proddesc Font:customFont TruncateToWidth:((colWidth+15)*3)-10];
                                    continue;
                                    
                                }
                                
                                //code ended
                                NSUInteger maxlength=[self getMaxDescLength:proddesc fontName:customFont size:colWidth height:12];
                                NSUInteger descMaxLength=maxlength-4;
                                int lblCount=0;
                                if (proddesc.length % descMaxLength==0) {
                                    lblCount=proddesc.length / descMaxLength;
                                }
                                else
                                    lblCount=(proddesc.length / descMaxLength)+1;
                                
                                CGFloat tempTopPos=topPos;
                                
                                
                                int istrCount=0;
                                for (int i=1; i<=lblCount; i++) {
                                    NSArray *arr=[proddesc componentsSeparatedByString:@" "];
                                    NSString *desc=@"";
                                    NSString *strtemp=@"";
                                    NSString *descName=@"";
                                    for (int i=istrCount; i<arr.count; i++) {
                                        
                                        if ([strtemp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length>descMaxLength) {
                                            if ([strtemp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length>descMaxLength) {
                                                
                                                NSMutableArray *arr1=[[strtemp componentsSeparatedByString:@" "] mutableCopy];
                                                [arr1 removeLastObject];
                                                int tmpCount=0;
                                                
                                                for (NSString *str in arr1) {
                                                    tmpCount++;
                                                    if (tmpCount<arr1.count) {
                                                        desc=[desc stringByAppendingFormat:@"%@ ",str];
                                                        
                                                    }
                                                    else{
                                                        tmpCount =0;
                                                        istrCount -=1;
                                                        descName=str;
                                                    }
                                                }
                                            }
                                            else
                                                desc=strtemp;
                                            
                                            
                                            strtemp=@"";
                                            break;
                                        }
                                        else{
                                            strtemp=[strtemp stringByAppendingFormat:@"%@ ",[arr objectAtIndex:i]];
                                            istrCount=i+1;
                                        }
                                    }
                                    if ([desc isEqualToString:@""]) {
                                        if (strtemp.length>descMaxLength) {
                                            NSMutableArray *arr1=[[strtemp componentsSeparatedByString:@" "] mutableCopy];
                                            [arr1 removeLastObject];
                                            int tmpCount=0;
                                            for (NSString *str in arr1) {
                                                tmpCount++;
                                                if (tmpCount<arr1.count) {
                                                    desc=[desc stringByAppendingFormat:@"%@ ",str];
                                                    
                                                }
                                                else{
                                                    tmpCount =0;
                                                    istrCount -=1;
                                                    descName=str;
                                                }
                                            }
                                        }
                                        else
                                            desc=strtemp;
                                    }
                                    // DebugLog(@"%@  %d",desc,[desc stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length);
                                    if (desc.length==0){
                                        desc=descName;
                                        istrCount+=1;
                                        NSUInteger discLength=[self getMaxDescLength:desc fontName:customFont size:colWidth height:12];
                                        if (desc.length>discLength){
                                            if (desc.length>=3) {
                                                desc=[[desc substringToIndex:discLength-3] stringByAppendingString:@"..."];
                                            }
                                        }
                                    }
                                    else
                                    {
                                        NSUInteger discLength=[self getMaxDescLength:desc fontName:customFont size:colWidth height:12];
                                        if (desc.length>discLength){
                                            if (desc.length>=3) {
                                                desc=[[desc substringToIndex:discLength-3] stringByAppendingString:@"..."];
                                            }
                                        }
                                    }
                                    //change by Ashish TruncateToWidth:((colWidth+5)*2)-5]change to 0
                                    [objpdf drawTextWithFrame:CGRectMake(leftPos, tempTopPos, colWidth, 12) Text:desc Font:customFont TruncateToWidth:0];
                                    
                                    if (![desc isEqualToString:@""]) {
                                        tempTopPos=tempTopPos+8;
                                        extDescHeight+=8;
                                    }
                                }
                                
                            }
                            else
                                [objpdf drawTextWithFrame:CGRectMake(leftPos, topPos, colWidth, 12) Text:proddesc Font:customFont TruncateToWidth:((colWidth+15)*3)-10];
                            //end of code added by Ashish
                            
                            if (orderformat==OrderCSVFile){
                                proddesc=[proddesc stringByReplacingOccurrencesOfString:@"\"" withString:@"''"];
                                [strval appendFormat:@"\"%@\",",proddesc];
                            }
                            
                            leftPoslinetext = leftPos+colWidth;
                        }
                        else{
                            CGFloat incDecPos=2;
                            if([key isEqualToString:@"Code"])
                                incDecPos=0;
                            
                            CGRect frame=CGRectMake(leftPos+incDecPos, topPos, colWidth-incDecPos, 12);
                            CGFloat truncWidth = colWidth-incDecPos;
                            if([key hasPrefix:@"Ctns"] && [[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"ardale"]){
                                frame=CGRectMake(leftPos+incDecPos, topPos, colWidth-12, 12);
                            }
                            if([key isEqualToString:@"Code"]){
                                if (prodcode.length>15) {
                                    UIFont* customFont1 = [UIFont fontWithName:kNormalFont size:7.0];
                                    [objpdf drawTextWithFrame:frame Text:prodcode Font:customFont1 TruncateToWidth:0.0];
                                }
                                else{
                                    [objpdf drawTextWithFrame:frame Text:prodcode Font:customFont TruncateToWidth:0.0];
                                    
                                    
                                }
                                if (orderformat==OrderCSVFile)
                                    prodcode=[prodcode stringByReplacingOccurrencesOfString:@"\"" withString:@"''"];
                                [strval appendFormat:@"\"%@\",",prodcode];
                            }
                            else if([key isEqualToString:@"Barcode"] || [key isEqualToString:@"Innr"])
                            {
                                
                                if (kAppDelegate.selectedCompanyId== 51){//*******  condition for squirrels 2 26 Aug 2015
                                    
                                    CGRect frm=frame;
                                    frm.origin.x=220;
                                    frm.size.width=58;
                                    truncWidth=58;
                                    [objpdf drawTextWithFrame:frm Text:barcode Font:customFont TextAlignment:NSTextAlignmentCenter TruncateToWidth:truncWidth];
                                }else
                                    [objpdf drawTextWithFrame:frame Text:barcode Font:customFont TextAlignment:NSTextAlignmentCenter TruncateToWidth:truncWidth];
                                
                                if (orderformat==OrderCSVFile)
                                    [strval appendFormat:@"\"%@\",",barcode];
                            }
                            else if([key isEqualToString:@"Type"] || [key isEqualToString:@"Outr"])
                            {
                                if (kAppDelegate.selectedCompanyId== 51){//*******  condition for squirrels 2 26 Aug 2015
                                    
                                    CGRect frm=frame;
                                    frm.origin.x=284;
                                    frm.size.width=58;
                                    truncWidth=58;
                                    
                                    [objpdf drawTextWithFrame:frm Text:outerBarcode Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:truncWidth];
                                } else
                                    [objpdf drawTextWithFrame:frame Text:olinetype Font:customFont TextAlignment:NSTextAlignmentCenter TruncateToWidth:truncWidth];
                                
                                
                                if (kAppDelegate.selectedCompanyId== 51 && orderformat==OrderCSVFile)
                                    [strval appendFormat:@"\"%@\",",outerBarcode];
                                else
                                    [strval appendFormat:@"\"%@\",",olinetype];
                                
                            }
                            else if([key isEqualToString:@"Inner"])
                            {
                                if (kAppDelegate.selectedCompanyId== 51){
                                    [objpdf drawTextWithFrame:frame Text:sellUnit Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:truncWidth];
                                }else
                                    [objpdf drawTextWithFrame:frame Text:[numberFormatter stringFromNumber:[NSNumber numberWithInt:lineinner]] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:truncWidth];
                                
                                
                                if (kAppDelegate.selectedCompanyId== 51 && orderformat==OrderCSVFile)
                                    [strval appendFormat:@"\"%@\",",sellUnit];
                                else
                                    [strval appendFormat:@"\"%@\",",[numberFormatter stringFromNumber:[NSNumber numberWithInt:lineinner]]];
                            }
                            else if([key isEqualToString:@"Outer"])
                            {
                                [objpdf drawTextWithFrame:frame Text:[numberFormatter stringFromNumber:[NSNumber numberWithInt:lineouter]] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:truncWidth];
                                if (orderformat==OrderCSVFile)
                                    [strval appendFormat:@"\"%@\",",[numberFormatter stringFromNumber:[NSNumber numberWithInt:lineouter]]];
                            }
                            else if ([key isEqualToString:@"CBM"])
                            {
                                [objpdf drawTextWithFrame:frame Text:[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:itemcbm]] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:truncWidth];
                                if (orderformat==OrderCSVFile)
                                    [strval appendFormat:@"\"%@\",",[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:itemcbm]]];
                            }
                            else if ([key isEqualToString:@"Weight"])
                            {
                                [objpdf drawTextWithFrame:frame Text:[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:weight]] Font:customFont TextAlignment:NSTextAlignmentCenter TruncateToWidth:truncWidth];
                                if (orderformat==OrderCSVFile)
                                    [strval appendFormat:@"\"%@\",",[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:weight]]];
                            }
                            else if ([key isEqualToString:@"RRP"])
                            {
                                [objpdf drawTextWithFrame:frame Text:[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:rRP]] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:truncWidth];
                                if (orderformat==OrderCSVFile)
                                    [strval appendFormat:@"\"%@\",",[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:rRP]]];
                            }
                            
                            else if([key isEqualToString:@"Qty Cases"] && [[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"otl"])
                            {
                                [objpdf drawTextWithFrame:frame Text:[numberFormatter stringFromNumber:[NSNumber numberWithInt:ctnordqty]] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:truncWidth];
                                if (orderformat==OrderCSVFile)
                                    [strval appendFormat:@"\"%@\",",[numberFormatter stringFromNumber:[NSNumber numberWithInt:ctnordqty]]];
                            }
                            
                            else if([key isEqualToString:@"Tot Qty"] || [key isEqualToString:@"Ord Qty"] || [key isEqualToString:@"Tot Packs"])
                            {
                                if (kAppDelegate.selectedCompanyId== 51 ){//*******  condition for squirrels 2 26 Aug 2015
                                    
                                    CGRect frm=frame;
                                    frm.origin.x=400;
                                    frm.size.width=20;
                                    [objpdf drawTextWithFrame:frm Text:[numberFormatter stringFromNumber:[NSNumber numberWithInt:totordqty]] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:truncWidth];
                                }else
                                    [objpdf drawTextWithFrame:frame Text:[numberFormatter stringFromNumber:[NSNumber numberWithInt:totordqty]] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:truncWidth];
                                
                                if (orderformat==OrderCSVFile)
                                    [strval appendFormat:@"\"%@\",",[numberFormatter stringFromNumber:[NSNumber numberWithInt:totordqty]]];
                            }
                            
                            else if([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"tallon"] &&[key isEqualToString:@"Cases"]){//******* Tallon Add CASE 12 MAY 2015
                                
                                [objpdf drawTextWithFrame:frame Text:[numberFormatter stringFromNumber:[NSNumber numberWithInt:ctnordqty]] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:truncWidth];
                                if (orderformat==OrderCSVFile)
                                    [strval appendFormat:@"\"%@\",",[numberFormatter stringFromNumber:[NSNumber numberWithInt:ctnordqty]]];
                            }
                            
                            //added By Amit Pant
                            else if([key isEqualToString:@"Ctns"] && [[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"ardale"])
                            {
                                [objpdf drawTextWithFrame:frame Text:[numberFormatter stringFromNumber:[NSNumber numberWithInt:ctnordqty]] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:truncWidth];
                                if (orderformat==OrderCSVFile)
                                    [strval appendFormat:@"\"%@\",",[numberFormatter stringFromNumber:[NSNumber numberWithInt:ctnordqty]]];
                            }
                            else if([key isEqualToString:@"Unt Prc"])
                            {
                                [objpdf drawTextWithFrame:frame Text:[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:unitprice]] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:truncWidth];
                                if (orderformat==OrderCSVFile)
                                    [strval appendFormat:@"\"%@\",",[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:unitprice]]];
                            }
                            else if([key isEqualToString:@"Disc"])
                            {
                                [objpdf drawTextWithFrame:frame Text:[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:discount]] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:truncWidth];
                                if (orderformat==OrderCSVFile)
                                    [strval appendFormat:@"\"%@\",",[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:discount]]];
                            }
                            
                            else if ([ordType isEqualToString:@"I"] && [key isEqualToString:@"Vat Code"]){ //*******       invoice acknowledgement  30 Apr 2015
                                [objpdf drawTextWithFrame:frame Text:vatCode Font:customFont TextAlignment:NSTextAlignmentCenter TruncateToWidth:truncWidth];
                                if (orderformat==OrderCSVFile)
                                    [strval appendFormat:@"\"%@\",",vatCode];
                                
                            }
                            else if ([ordType isEqualToString:@"I"] && [key isEqualToString:@"Vat Amt"]){ //*******       invoice acknowledgement  30 Apr 2015
                                [objpdf drawTextWithFrame:frame Text:[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:vatTotal]] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:truncWidth];
                                if (orderformat==OrderCSVFile)
                                    [strval appendFormat:@"\"%@\",",[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:vatTotal]]];
                                
                            }//ended
                            else if([key isEqualToString:@"Ord Prc"]){
                                if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"floralsilk"]) [decimalFormatter setMaximumFractionDigits:4];
                                
                                
                                
                                if (kAppDelegate.selectedCompanyId== 51 ){//*******  condition for squirrels 2 26 Aug 2015
                                    CGRect frm=frame;
                                    frm.origin.x=427;
                                    frm.size.width=36;
                                    [objpdf drawTextWithFrame:frm Text:[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:soldprice]] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:truncWidth];
                                }else//ended
                                    [objpdf drawTextWithFrame:frame Text:[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:soldprice]] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:truncWidth];
                                
                                if (orderformat==OrderCSVFile)
                                    [strval appendFormat:@"\"%@\",",[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:soldprice]]];
                                if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"floralsilk"]) [decimalFormatter setMaximumFractionDigits:2];
                                
                                
                                
                            }
                            else if([key isEqualToString:@"Tot Val"])
                            {
                                if (kAppDelegate.selectedCompanyId== 51 ){//*******  condition for squirrels 2 26 Aug 2015
                                    CGRect frm=frame;
                                    frm.origin.x=470;
                                    frm.size.width=33;
                                    [objpdf drawTextWithFrame:frm Text:[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:totvalue]] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:truncWidth];
                                }else//ended
                                    [objpdf drawTextWithFrame:frame Text:[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:totvalue]] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:truncWidth];
                                
                                if (orderformat==OrderCSVFile)
                                    [strval appendFormat:@"\"%@\",",[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:totvalue]]];
                            }
                            else if([key isEqualToString:@"Del Id"]){
                                frame.origin.x+=5;
                                frame.size.width-=5;
                                [objpdf drawTextWithFrame:frame Text:strdeladdcode Font:customFont TruncateToWidth:truncWidth-5];
                                if (orderformat==OrderCSVFile)
                                    strdeladdcode=[strdeladdcode stringByReplacingOccurrencesOfString:@"\"" withString:@"''"];
                                if (kAppDelegate.selectedCompanyId== 51 && orderformat==OrderCSVFile)
                                    [strval appendFormat:@"\"%d\",",prlaypall];
                                else
                                    [strval appendFormat:@"\"%@\",",strdeladdcode];
                            }
                            else if([key isEqualToString:@"Del Date"])
                            {
                                if (kAppDelegate.selectedCompanyId== 51){//*******  condition for squirrels 2 26 Aug 2015
                                    CGRect frm=frame;
                                    frm.origin.x=508;
                                    frm.size.width=72;
                                    truncWidth=72;
                                    
                                    [objpdf drawTextWithFrame:frm Text:strCol Font:customFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:truncWidth];
                                } else
                                    [objpdf drawTextWithFrame:frame Text:strdeldate Font:customFont TextAlignment:NSTextAlignmentCenter TruncateToWidth:truncWidth];
                                
                                
                                if (kAppDelegate.selectedCompanyId== 51 && orderformat==OrderCSVFile)
                                    [strval appendFormat:@"\"%@\",",strCol];
                                else
                                    [strval appendFormat:@"\"%@\",",strdeldate];
                            }
                            else if([key isEqualToString:@"Exp Date"])
                            {
                                [objpdf drawTextWithFrame:frame Text:strExpDate Font:customFont TextAlignment:NSTextAlignmentCenter TruncateToWidth:truncWidth];
                                if (orderformat==OrderCSVFile)
                                    [strval appendFormat:@"\"%@\",",strExpDate];
                            }
                            
                            //Changed by Rajesh Pandey on 19/08/2014
                            else if([key isEqualToString:@"Colour desc"])
                            {
                                [objpdf drawTextWithFrame:frame Text:prodcolordesc Font:customFont TextAlignment:NSTextAlignmentCenter TruncateToWidth:truncWidth];
                                if (orderformat==OrderCSVFile)
                                    prodcolordesc=[prodcolordesc stringByReplacingOccurrencesOfString:@"\"" withString:@"''"];
                                [strval appendFormat:@"\"%@\",",prodcolordesc];
                            }
                            else if([key isEqualToString:@"Pallet qty"]||[key isEqualToString:@"Pallet"])//add Pallet by Ashish for benross
                            {
                                //code added by Ashish
                                if (kAppDelegate.selectedCompanyId==47)
                                    [objpdf drawTextWithFrame:CGRectMake(frame.origin.x-9, frame.origin.y, frame.size.width, frame.size.height) Text:prodpltqty Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:truncWidth];
                                //end of code added
                                else
                                    [objpdf drawTextWithFrame:frame Text:prodpltqty Font:customFont TextAlignment:NSTextAlignmentCenter TruncateToWidth:truncWidth];
                                if (orderformat==OrderCSVFile)
                                    [strval appendFormat:@"\"%@\",",prodpltqty];
                            }
                            else if([key isEqualToString:@"Prsize"])
                            {
                                [objpdf drawTextWithFrame:frame Text:prodprsize Font:customFont TextAlignment:NSTextAlignmentCenter TruncateToWidth:truncWidth];
                                if (orderformat==OrderCSVFile)
                                    [strval appendFormat:@"\"%@\",",prodprsize];
                            }
                            
                            
                            if(NO)//[[CompanyConfigDelegate.dicGenInfo objectForKey:@"IsFurnitureModuleActive"]boolValue]
                            {
                                if([key isEqualToString:@"Main"])
                                {
                                    [objpdf drawTextWithFrame:frame Text:strPRC1 Font:customFont TextAlignment:NSTextAlignmentCenter TruncateToWidth:truncWidth];
                                    if (orderformat==OrderCSVFile)
                                        [strval appendFormat:@"\"%@\",",strPRC1];
                                }
                                else if([key isEqualToString:@"Top"])
                                {
                                    [objpdf drawTextWithFrame:frame Text:strPRC2 Font:customFont TextAlignment:NSTextAlignmentCenter TruncateToWidth:truncWidth];
                                    if (orderformat==OrderCSVFile)
                                        [strval appendFormat:@"\"%@\",",strPRC2];
                                }
                                else if([key isEqualToString:@"Inside"])
                                {
                                    [objpdf drawTextWithFrame:frame Text:strPRC3 Font:customFont TextAlignment:NSTextAlignmentCenter TruncateToWidth:truncWidth];
                                    if (orderformat==OrderCSVFile)
                                        [strval appendFormat:@"\"%@\",",strPRC3];
                                }
                                else if([key isEqualToString:@"Trim"])
                                {
                                    [objpdf drawTextWithFrame:frame Text:strPRC4 Font:customFont TextAlignment:NSTextAlignmentCenter TruncateToWidth:truncWidth];
                                    if (orderformat==OrderCSVFile)
                                        [strval appendFormat:@"\"%@\",",strPRC4];
                                }
                                else if([key isEqualToString:@"Artwork"])
                                {
                                    [objpdf drawTextWithFrame:frame Text:strPRC5 Font:customFont TextAlignment:NSTextAlignmentCenter TruncateToWidth:truncWidth];
                                    if (orderformat==OrderCSVFile)
                                        [strval appendFormat:@"\"%@\",",strPRC5];
                                }
                                else if([key isEqualToString:@"Distressed"])
                                {
                                    [objpdf drawTextWithFrame:frame Text:strPRC6 Font:customFont TextAlignment:NSTextAlignmentCenter TruncateToWidth:truncWidth];
                                    if (orderformat==OrderCSVFile)
                                        [strval appendFormat:@"\"%@\",",strPRC6];
                                }
                                else if([key isEqualToString:@"CBM"])
                                {
                                    [objpdf drawTextWithFrame:frame Text:[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:itemcbm]] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:truncWidth];
                                    if (orderformat==OrderCSVFile)
                                        [strval appendFormat:@"\"%@\",",[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:itemcbm]]];
                                }
                            }
                        }
                        colcount++;
                    }
                    
                    //code added by Ashish
                    float minSpaceBwRows=0;
                    if (extDescHeight>=rowHeight)
                        minSpaceBwRows=extDescHeight-rowHeight;
                    
                    topPos +=minSpaceBwRows;
                    extRowHeight +=extDescHeight;
                    if (extRowHeight>33.0) {
                        rowCount++;
                        remainRecCount--;
                        extRowHeight=0;
                    }//end of code added
                    if([strlinetext length]>0){
                        [objpdf drawTextWithFrame:CGRectMake(leftPoslinetext, topPos+13, 570-leftPoslinetext, 12) Text:[strlinetext  stringByReplacingOccurrencesOfString:@"\n" withString:@", "] Font:customFont TruncateToWidth:570-leftPoslinetext];
                        
                    }
                    
                    topPos+=rowHeight;
                    [strval appendFormat:@"\r\n"];
                }
                else if(orderformat==OrderLargePhotos)// added by Laxman
                {
                    if (isLeftSideData)
                    {
                        leftPos=0;
                        rowCount++;
                        if(rowCount>(allowedRowsPerPage/2)){
                            isLeftSideData=YES;
                            currentPage++;
                            [objpdf drawPageNumber:currentPage TotalPages:totalPages ShowPageNo:YES PageNumberPosition:pagePosition];
                            // if(currentPage>1 && currentPage<totalPages)//code commented by Ashish
                            //[self largePhotoFooter:0.0 TopPosition:710.0 PDF:&objpdf OrdNum:orderNum Cust:cust_name CustCode:cust_Code CBMPosition:0];
                            
                            allowedRowsPerPage = otherPageLineCount;
                            
                            rowCount = 1;
                            
                            [self writeCompanyDetailsWithLogo:YES PDFRef:&objpdf];
                            if ([[strtyperef lowercaseString] hasPrefix:@"samples"]) {
                                ordType=@"S";
                            }
                            [self ordTypeHeader:ordType PDF:&objpdf];
                            topPos = 100;
                        }
                    }
                    else if (!isLeftSideData) //added by Laxman
                        leftPos+=290;
                    @try{
                        
                        image=[self resizeImageAtPath:[NSString stringWithFormat:@"%@/%li/images/%@.jpg",[[kAppDelegate applicationDocumentsDirectory] path],kAppDelegate.selectedCompanyId,[[CommonHelper getStringByRemovingSpecialChars:prodcode] lowercaseString]] thumbnailSize:imageratioSmall*2];
                        UIImage* imgt = image;
                        if(image && [image imageOrientation]!=UIImageOrientationUp)
                            imgt = [UIImage imageWithCGImage:image.CGImage scale:1.0 orientation:UIImageOrientationUp];
                        
                        if(image!=nil){
                            CGSize imgSize = [imgt size];
                            CGSize newImageSize = CGSizeMake(0, 0);
                            double percent;
                            if(imgSize.height>imageratioLarge){
                                percent = imageratioLarge/imgSize.height;
                                newImageSize.height = imageratioLarge;
                                newImageSize.width = imgSize.width*percent;
                            }
                            if(newImageSize.width>0)
                                imgSize = newImageSize;
                            if(imgSize.width>imageratioLarge){
                                percent = imageratioLarge/imgSize.width;
                                newImageSize.width = imageratioLarge;
                                newImageSize.height = imgSize.height*percent;
                            }
                            else
                                newImageSize = imgSize;
                            
                            
                            CGRect rect=CGRectMake(leftPos, topPos+16, newImageSize.width, newImageSize.height);
                            // CGRect rect=CGRectMake(leftPos, topPos+16, imgt.size.width, imgt.size.height);
                            [objpdf drawImageWithFrame:rect Image:imgt];
                            
                        }
                        
                    }
                    @catch (NSException *exception) {
                        //[CommonHelper writeErrorLogWithNo:0 Description:[exception description] Method:[NSString stringWithUTF8String:__func__]];
                    }
                    CGFloat XMargin=leftPos+92;
                    CGFloat YMargin;
                    
                    
                    YMargin=topPos+16;
                    
                    CGFloat tempHeightAdd = 0;
                    CGFloat largeRowHeight = 10;
                    
                    [objpdf drawLineWithFrame:CGRectMake(leftPos, topPos+rowHeight-2, 280, 1) LineWidth:2.0 LineColor:[UIColor grayColor]];
                    
                    [objpdf drawTextWithFrame:CGRectMake(leftPos+2, topPos, 280, largeRowHeight) Text:proddesc Font:customBoldFont TextAlignment:NSTextAlignmentLeft IsUnderLine:YES TruncateToWidth:280.0];
                    
                    
                    
                    
                    if (kAppDelegate.selectedCompanyId== 51)
                        [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 45, largeRowHeight) Text:@"Inner:" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:45.0];
                    else
                        [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 45, largeRowHeight) Text:@"Barcode:" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:45.0];
                    
                    [objpdf drawTextWithFrame:CGRectMake(XMargin+45, YMargin, 142, largeRowHeight) Text:barcode Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:142.0];
                    
                    
                    YMargin+=largeRowHeight;
                    
                    [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 45, largeRowHeight) Text:@"Code:" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:45.0];
                    
                    [objpdf drawTextWithFrame:CGRectMake(XMargin+45, YMargin, 142, largeRowHeight) Text:prodcode Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:142.0];
                    
                    YMargin+=largeRowHeight;
                    
                    if(NO)//[[CompanyConfigDelegate.dicGenInfo objectForKey:@"IsFurnitureModuleActive"]boolValue]
                    {
                        [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 45, largeRowHeight) Text:@"Col:" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:45.0];
                        
                        [objpdf drawTextWithFrame:CGRectMake(XMargin+45, YMargin, 142, largeRowHeight) Text:strCol Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:142.0];
                        YMargin+=largeRowHeight;
                    }
                    
                    tempHeightAdd+=largeRowHeight;
                    
                    if (kAppDelegate.selectedCompanyId== 51)
                    {
                        [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 45, largeRowHeight) Text:@"Outer:" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:45.0];
                        [objpdf drawTextWithFrame:CGRectMake(XMargin+22, YMargin, 70, largeRowHeight) Text:outerBarcode Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                    }
                    else
                    {
                        [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 45, largeRowHeight) Text:@"Type:" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:45.0];
                        [objpdf drawTextWithFrame:CGRectMake(XMargin+45, YMargin, 47, largeRowHeight) Text:olinetype Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                    }
                    
                    [objpdf drawLineWithFrame:CGRectMake(XMargin+95, YMargin+(largeRowHeight * 3), 2,1) LineWidth:largeRowHeight*6 LineColor:[UIColor blackColor]];
                    
                    
                    YMargin+=largeRowHeight;
                    tempHeightAdd+=largeRowHeight;
                    
                    
                    if([Print_Format isEqualToString:@"1"]){
                       
                        
                        if (![[[companyConfigDict valueForKey:@"companyname"]lowercaseString]  hasPrefix:@"beamfeature"]) {
                            [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 45, largeRowHeight) Text:@"Unit Price:" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:45.0];
                            [objpdf drawTextWithFrame:CGRectMake(XMargin+45, YMargin, 47, largeRowHeight) Text:[CommonHelper getCurrencyFormatWithCurrency:strcurr Value:unitprice] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                            
                            YMargin+=largeRowHeight;

                        }
                        
                        
                        
                        tempHeightAdd+=largeRowHeight;
                        
                        if(discountavailable>0 && discount>0){
                            
                            [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 45, largeRowHeight) Text:@"Disc (%):" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:0.0];
                            
                            [objpdf drawTextWithFrame:CGRectMake(XMargin+45, YMargin, 47, largeRowHeight) Text:[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:discount]] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                            
                            
                            YMargin+=largeRowHeight;
                            tempHeightAdd+=largeRowHeight;
                        }
                        
                    }
                    else if([Print_Format isEqualToString:@"2"]){
                        if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"ardale"]) {}
                        else{
                            
                            
                            [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 45, largeRowHeight) Text:@"Unit Price:" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:45.0];
                            // [objpdf drawTextWithFrame:CGRectMake(XMargin+45, YMargin, 47, largeRowHeight) Text:[CommonHelper getCurrencyFormatWithCurrency:strcurr Value:unitprice DefaultCurrency:strcurr] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                            
                            YMargin+=largeRowHeight;
                            tempHeightAdd+=largeRowHeight;
                            
                        }
                    }
                    else{
                        if(discountavailable>0 && discount>0){
                            [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 45, largeRowHeight) Text:@"Unit Price:" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:45.0];
                            //[objpdf drawTextWithFrame:CGRectMake(XMargin+45, YMargin, 47, largeRowHeight) Text:[CommonHelper getCurrencyFormatWithCurrency:strcurr Value:unitprice DefaultCurrency:strcurr] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                            
                            [objpdf drawTextWithFrame:CGRectMake(XMargin+45, YMargin, 47, largeRowHeight) Text:[CommonHelper getCurrencyFormatWithCurrency:strcurr Value:unitprice] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                            
                            
                            
                            YMargin+=largeRowHeight;
                            tempHeightAdd+=largeRowHeight;
                            
                            [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 45, largeRowHeight) Text:@"Disc (%):" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:0.0];
                            
                            [objpdf drawTextWithFrame:CGRectMake(XMargin+45, YMargin, 47, largeRowHeight) Text:[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:discount]] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                            YMargin+=largeRowHeight;
                            tempHeightAdd+=largeRowHeight;
                        }
                    }
                    
                    [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 45, largeRowHeight) Text:@"Ord. Price:" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:0.0];
                    
                    if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"floralsilk"]) {
                   //  [objpdf drawTextWithFrame:CGRectMake(XMargin+45, YMargin, 47, largeRowHeight) Text:[CommonHelper getCurrencyFormatWithCurrency:strcurr Value:soldprice DefaultCurrency:strcurr decimalPlace:4] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                     }
                     else
                     [objpdf drawTextWithFrame:CGRectMake(XMargin+45, YMargin, 47, largeRowHeight) Text:[CommonHelper getCurrencyFormatWithCurrency:strcurr Value:soldprice] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                     
                     YMargin+=largeRowHeight;
                     tempHeightAdd+=largeRowHeight;
                    
                    //******* Tallon Add CASE 12 MAY 2015
                    if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"tallon"]){
                        [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 45, largeRowHeight) Text:@"Cases:" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:0.0];
                        [objpdf drawTextWithFrame:CGRectMake(XMargin+45, YMargin, 47, largeRowHeight) Text:[numberFormatter stringFromNumber:[NSNumber numberWithInt:ctnordqty]] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                        
                        YMargin+=largeRowHeight;
                        tempHeightAdd+=largeRowHeight;
                    }
                    
                    
                    
                    if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"otl"] ){
                        
                        [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 45, largeRowHeight) Text:@"Qty Cases:" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:0.0];
                        
                        [objpdf drawTextWithFrame:CGRectMake(XMargin+45, YMargin, 47, largeRowHeight) Text:[numberFormatter stringFromNumber:[NSNumber numberWithInt:ctnordqty]] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                        
                        YMargin+=largeRowHeight;
                        tempHeightAdd+=largeRowHeight;
                    }
                    
                    [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 45, largeRowHeight) Text:@"Order Qty:" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:0.0];
                    [objpdf drawTextWithFrame:CGRectMake(XMargin+45, YMargin, 47, largeRowHeight) Text:[numberFormatter stringFromNumber:[NSNumber numberWithInt:totordqty]] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                    
                    YMargin+=largeRowHeight;
                    tempHeightAdd+=largeRowHeight;
                    
                    
                     if(validx!=0){
                     
                     [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 45, largeRowHeight) Text:@"Line Total:" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:0.0];
                     
                     [objpdf drawTextWithFrame:CGRectMake(XMargin+45, YMargin, 47, largeRowHeight) Text:[CommonHelper getCurrencyFormatWithCurrency:strcurr Value:totvalue] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:50.0];
                     
                     
                     }
                    //code added by Ashish
                    if (kAppDelegate.selectedCompanyId==47){
                        YMargin+=largeRowHeight;
                        tempHeightAdd+=largeRowHeight;
                        [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 45, largeRowHeight) Text:@"CBM:" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:0.0];
                        
                        [objpdf drawTextWithFrame:CGRectMake(XMargin+45, YMargin, 47, largeRowHeight) Text:[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:itemcbm]] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                        
                    }
                    //end of code added
                    tempHeightAdd+=largeRowHeight;
                    
                    
                    
                    if ([ordType isEqualToString:@"I"]){//*******     Mahendra  invoice acknowledgement  30 Apr 2015
                        YMargin+=largeRowHeight;
                        [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 45, largeRowHeight) Text:@"Vat Code:" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:0.0];
                        [objpdf drawTextWithFrame:CGRectMake(XMargin+45, YMargin, 47, largeRowHeight) Text:vatCode Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:50.0];
                        tempHeightAdd+=largeRowHeight;
                    }
                    
                    YMargin+=largeRowHeight;
                    tempHeightAdd+=largeRowHeight;
                    //}
                    
                    if(tempHeightAdd==largeRowHeight*6)
                        YMargin+=largeRowHeight;
                    else if (tempHeightAdd==largeRowHeight*5)
                        YMargin+=largeRowHeight*2;
                    else if (tempHeightAdd==largeRowHeight*4)
                        YMargin+=largeRowHeight*3;
                    
                    float temph1=topPos+rowHeight-15;
                    
                    [objpdf drawTextWithFrame:CGRectMake(XMargin, temph1, 45, largeRowHeight) Text:@"Line Notes:" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:0.0];
                    
                    [objpdf drawTextWithFrame:CGRectMake(XMargin+45, temph1, 140, largeRowHeight) Text:strlinetext Font:customFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:140.0];
                    
                    // put right heading
                    XMargin+=100;
                    YMargin=topPos+36;
                    
                    {
                        if([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"avron"]){
                            [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 90, largeRowHeight) Text:strCol Font:customFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:90.0];
                        }
                        else{
                            if([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"white"]){
                                [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 20, largeRowHeight) Text:@"Cat:" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:20.0];
                                
                                [objpdf drawTextWithFrame:CGRectMake(XMargin+20, YMargin, 67, largeRowHeight) Text:strCat Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:67.0];
                            }
                            else
                            {
                                // by faizan col -> expiry on 3/10/2013 for squirrels
                                if([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"squirrels"])
                                    if (kAppDelegate.selectedCompanyId== 51)
                                        [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 30, largeRowHeight) Text:@"BBE:" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:30.0];
                                    else
                                        [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 30, largeRowHeight) Text:@"Expiry:" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:30.0];
                                    else
                                    {
                                        if([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"ryder imports ltd"])
                                        {
                                            [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 30, largeRowHeight) Text:@"CBM:" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:30.0];
                                        }
                                        else{
                                            
                                            if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"benross"])
                                                [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 30, largeRowHeight) Text:@"Style:" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:30.0];
                                            else
                                                [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 20, largeRowHeight) Text:@"Col:" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:20.0];
                                        }
                                    }
                                
                                //code added by Amit Pant on 2014-06-23
                                if([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"cimc"]) {
                                    
                                    if ( strCol.length>14) {
                                        //DebugLog(@"Added extra label for Description");
                                        int lblCount=0;
                                        if (strCol.length % 13==0)
                                            lblCount=strCol.length / 14;
                                        else
                                            lblCount=(strCol.length / 14)+1;
                                        
                                        int istrCount=0;
                                        for (int i=1; i<=lblCount; i++) {
                                            NSArray *arr=[strCol componentsSeparatedByString:@" "];
                                            NSString *desc=@"";
                                            NSString *strtemp=@"";
                                            for (int i=istrCount; i<arr.count; i++) {
                                                
                                                if (strtemp.length>14) {
                                                    if (strtemp.length>15) {
                                                        
                                                        NSMutableArray *arr1=[[strtemp componentsSeparatedByString:@" "] mutableCopy];
                                                        [arr1 removeLastObject];
                                                        
                                                        int tmpCount=0;
                                                        
                                                        for (NSString *str in arr1) {
                                                            tmpCount++;
                                                            if (tmpCount<arr1.count) {
                                                                desc=[desc stringByAppendingFormat:@"%@ ",str];
                                                            }
                                                            else{
                                                                tmpCount =0;
                                                                istrCount -=1;
                                                            }
                                                        }
                                                    }
                                                    else
                                                        desc=strtemp;
                                                    strtemp=@"";
                                                    break;
                                                }
                                                else{
                                                    strtemp=[strtemp stringByAppendingFormat:@"%@ ",[arr objectAtIndex:i]];
                                                    istrCount=i+1;
                                                }
                                            }
                                            if ([desc isEqualToString:@""]) {
                                                if (strtemp.length>15) {
                                                    NSMutableArray *arr1=[[strtemp componentsSeparatedByString:@" "] mutableCopy];
                                                    [arr1 removeLastObject];
                                                    
                                                    int tmpCount=0;
                                                    for (NSString *str in arr1) {
                                                        if (tmpCount<arr1.count-1) {
                                                            desc=[desc stringByAppendingFormat:@"%@ ",str];
                                                            tmpCount++;
                                                        }
                                                        else{
                                                            tmpCount =0;
                                                            istrCount -=1;
                                                        }
                                                    }
                                                }
                                                else
                                                    desc=strtemp;
                                            }
                                            DebugLog(@"WWW--%@  %d",desc,desc.length);
                                            
                                            [objpdf drawTextWithFrame:CGRectMake(XMargin+20, YMargin, 67, largeRowHeight) Text:desc Font:customFont  TextAlignment:NSTextAlignmentRight  TruncateToWidth:67.0];
                                            
                                            
                                            YMargin=YMargin+8;
                                            //extDescHeight+=5;
                                        }
                                        
                                    }
                                    
                                }
                                //end of code
                                else{
                                    if([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"ryder imports ltd"])
                                    {
                                        
                                        [objpdf drawTextWithFrame:CGRectMake(XMargin+20, YMargin, 67, largeRowHeight) Text:[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:itemcbm]] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:67.0];
                                    }
                                    else{
                                        DebugLog(@"gaga-%@",strCol);
                                        [objpdf drawTextWithFrame:CGRectMake(XMargin+18, YMargin, 72, largeRowHeight) Text:strCol Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:72.0];
                                    }
                                }
                            }
                        }
                        
                        ///description
                        
                        
                        //
                        if([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"cimc"] && strCol.length>15)
                            YMargin+=1;
                        else
                            YMargin+=largeRowHeight;
                        
                        ///Del Id
                        /* if ([CompanyConfigDelegate.dicOrderInfo objectForKey:@"Email_Formate_Field"]!=nil ) {
                         if ( [[[CompanyConfigDelegate.dicOrderInfo objectForKey:@"Email_Formate_Field"] allKeys] containsObject:@"Del Id"]) {
                         [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 40, largeRowHeight) Text:@"Del Id:" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:40.0];
                         
                         [objpdf drawTextWithFrame:CGRectMake(XMargin+40, YMargin, 48, largeRowHeight) Text:strdeladdcode Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:48.0];
                         // YMargin+=largeRowHeight;
                         }
                         }
                         else{*/
                        if (kAppDelegate.selectedCompanyId!= 51) {
                            [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 40, largeRowHeight) Text:@"Del Id:" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:40.0];
                            
                            [objpdf drawTextWithFrame:CGRectMake(XMargin+40, YMargin, 48, largeRowHeight) Text:strdeladdcode Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:48.0];
                            
                            //YMargin+=largeRowHeight;
                            //}
                            
                            
                            // Changed by Rajesh on 18-Aug-2014
                            /*if (! [[[CompanyConfigDelegate.dicOrderInfo objectForKey:@"Email_Formate_Field"] allKeys] containsObject:@"Del Id"])
                             YMargin+=largeRowHeight-10;
                             else*/
                            YMargin+=largeRowHeight;
                        }
                        ///Del Date
                        /*if ([CompanyConfigDelegate.dicOrderInfo objectForKey:@"Email_Formate_Field"]!=nil ) {
                         if ( [[[CompanyConfigDelegate.dicOrderInfo objectForKey:@"Email_Formate_Field"] allKeys] containsObject:@"Del Date"]) {
                         [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 40, largeRowHeight) Text:@"Del Date:" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:40.0];
                         
                         [objpdf drawTextWithFrame:CGRectMake(XMargin+40, YMargin, 48, largeRowHeight) Text:strdeldate Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:48.0];
                         // YMargin+=largeRowHeight;
                         }
                         }
                         else{*/
                        if (kAppDelegate.selectedCompanyId!= 51)
                        {
                            [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 40, largeRowHeight) Text:@"Del Date:" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:40.0];
                            [objpdf drawTextWithFrame:CGRectMake(XMargin+40, YMargin, 48, largeRowHeight) Text:strdeldate Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:48.0];
                            
                            
                            //YMargin+=largeRowHeight;
                            //}
                            ///
                            
                            // Changed by Rajesh on 18-Aug-2014
                            /*if (! [[[CompanyConfigDelegate.dicOrderInfo objectForKey:@"Email_Formate_Field"] allKeys] containsObject:@"Del Date"])
                             YMargin+=largeRowHeight-10;
                             else*/
                            YMargin+=largeRowHeight;
                        }
                        //pallet
                        //code added by Ashish
                        if (kAppDelegate.selectedCompanyId==47){
                            [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 40, largeRowHeight) Text:@"Pallet:" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:40.0];
                            
                            [objpdf drawTextWithFrame:CGRectMake(XMargin+40, YMargin, 48, largeRowHeight) Text:prodpltqty Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:48.0];
                            YMargin+=largeRowHeight;
                        }
                        //end of code added
                        //RRP
                        //code added by Ashish
                        if(validx!=0){
                            if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"ryder imports ltd"] ){
                                [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 40, largeRowHeight) Text:@"RRP" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:0.0];
                                
                                //[objpdf drawTextWithFrame:CGRectMake(XMargin+40, YMargin, 48, largeRowHeight) Text:[CommonHelper getCurrencyFormatWithCurrency:strcurr Value:rRP DefaultCurrency:strcurr] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:50.0];//code added by Ashish.
                                
                                [objpdf drawTextWithFrame:CGRectMake(XMargin+40, YMargin, 47, largeRowHeight) Text:[CommonHelper getCurrencyFormatWithCurrency:strcurr Value:rRP] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                                
                                
                                
                                YMargin+=largeRowHeight;
                            }
                        }//end of code added
                        
                        
                        if([Print_Format isEqualToString:@"4"]){
                            /*
                             if ([CompanyConfigDelegate.dicOrderInfo objectForKey:@"Email_Formate_Field"]!=nil ) {
                             if ( [[[CompanyConfigDelegate.dicOrderInfo objectForKey:@"Email_Formate_Field"] allKeys] containsObject:@"Exp Date"]) {
                             [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 40, largeRowHeight) Text:@"Exp Date:" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:40.0];
                             
                             [objpdf drawTextWithFrame:CGRectMake(XMargin+40, YMargin, 48, largeRowHeight) Text:strExpDate Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:48.0];
                             //YMargin+=largeRowHeight;
                             }
                             }
                             else{*/
                            [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 40, largeRowHeight) Text:@"Exp Date:" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:40.0];
                            
                            [objpdf drawTextWithFrame:CGRectMake(XMargin+40, YMargin, 48, largeRowHeight) Text:strExpDate Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:48.0];
                            //YMargin+=largeRowHeight;
                            //}
                            YMargin+=largeRowHeight;
                        }
                        
                        //if(![Print_Format isEqualToString:@"2"] || validx!=0){
                        startfrompack = 1;
                        dicPrices=[arrpacks objectAtIndex:0];
                        if(![[dicPrices objectForKey:@"Pack1"] isEqualToString:@""] && ([[[dicPrices objectForKey:@"Pack1"] lowercaseString] isEqualToString:@"single"] || [[[dicPrices objectForKey:@"Pack1"] lowercaseString] isEqualToString:@"unit"])){
                            startfrompack++;
                            lineinner = lineouter;
                            lineouter = packqty3;
                        }
                        if(![[dicPrices objectForKey:@"label"] isEqual:[NSNull null]]){
                            if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"ardale"] ){
                                
                                [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 40, largeRowHeight) Text:@"Ctn Qty" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:0.0];
                                
                                [objpdf drawTextWithFrame:CGRectMake(XMargin+40, YMargin, 48, largeRowHeight) Text:[numberFormatter stringFromNumber:[NSNumber numberWithInt:lineinner]] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                            }
                            else{
                                
                                /*if ([CompanyConfigDelegate.dicOrderInfo objectForKey:@"Email_Formate_Field"]!=nil ) {
                                 if ( [[[CompanyConfigDelegate.dicOrderInfo objectForKey:@"Email_Formate_Field"] allKeys] containsObject:[NSString stringWithFormat:@"%@",[dicPrices objectForKey:[NSString stringWithFormat:@"Pack%d",startfrompack]]]]) {
                                 [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 40, largeRowHeight) Text:[NSString stringWithFormat:@"%@:",[dicPrices objectForKey:[NSString stringWithFormat:@"Pack%d",startfrompack]]] Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:0.0];
                                 DebugLog(@"Text %@ ",[NSString stringWithFormat:@"%@:",[dicPrices objectForKey:[NSString stringWithFormat:@"Pack%d",startfrompack]]]);
                                 [objpdf drawTextWithFrame:CGRectMake(XMargin+40, YMargin, 48, largeRowHeight) Text:[numberFormatter stringFromNumber:[NSNumber numberWithInt:lineinner]] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                                 }
                                 }
                                 else{*/
                                if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]  hasPrefix:@"beamfeature"]) {
                                    [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 40, largeRowHeight) Text:[NSString stringWithFormat:@"Inner:" ] Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:0.0];
                                }else
                                    [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 40, largeRowHeight) Text:[NSString stringWithFormat:@"%@:",[dicPrices objectForKey:@"label"] ] Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:0.0];
                                
                                DebugLog(@"Title %@",[NSString stringWithFormat:@"%@:",[dicPrices objectForKey:[NSString stringWithFormat:@"Pack%d",startfrompack]]]);
                                if (kAppDelegate.selectedCompanyId== 51)
                                    [objpdf drawTextWithFrame:CGRectMake(XMargin+40, YMargin, 48, largeRowHeight) Text:sellUnit Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                                else
                                    [objpdf drawTextWithFrame:CGRectMake(XMargin+40, YMargin, 48, largeRowHeight) Text:[NSString stringWithFormat:@"%@",[product valueForKey:[dicPrices objectForKey:@"field"]]] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                                //}

                                DebugLog(@"Title value %@",[numberFormatter stringFromNumber:[NSNumber numberWithInt:lineinner]]);
                            }
                        }
                        YMargin+=largeRowHeight;
                        //Add by Amit Pant
                        if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"ardale"] ) {
                            
                            [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 60, largeRowHeight) Text:@"Ctns" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:0.0];
                            
                            [objpdf drawTextWithFrame:CGRectMake(XMargin+40, YMargin, 48, largeRowHeight) Text:[numberFormatter stringFromNumber:[NSNumber numberWithInt:totordqty/lineinner]] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                            YMargin+=largeRowHeight;
                        }
                        //code added by Amit Pant on 2014-06-23
                        dicPrices=[arrpacks objectAtIndex:1];
                        if(![[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"cimc"]) {
                            if(![[dicPrices objectForKey:@"label"] isEqual:[NSNull null]]){
                                // by faizan width 45 instead of 40
                                /*if ([CompanyConfigDelegate.dicOrderInfo objectForKey:@"Email_Formate_Field"]!=nil ) {
                                 if ( [[[CompanyConfigDelegate.dicOrderInfo objectForKey:@"Email_Formate_Field"] allKeys] containsObject:[NSString stringWithFormat:@"%@",[dicPrices objectForKey:[NSString stringWithFormat:@"Pack%d",startfrompack]]]]) {
                                 [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 45, largeRowHeight) Text:[NSString stringWithFormat:@"%@:",[dicPrices objectForKey:[NSString stringWithFormat:@"Pack%d",startfrompack+1]]] Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:0.0];
                                 DebugLog(@"Text11 %@ ",[NSString stringWithFormat:@"%@:",[dicPrices objectForKey:[NSString stringWithFormat:@"Pack%d",startfrompack+1]]]);
                                 [objpdf drawTextWithFrame:CGRectMake(XMargin+40, YMargin, 48, largeRowHeight) Text:[numberFormatter stringFromNumber:[NSNumber numberWithInt:lineouter]] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                                 
                                 // YMargin+=largeRowHeight;
                                 }
                                 }
                                 else{*/
                                if(![[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"ryder imports ltd"])
                                {
                                    
                                    if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]  hasPrefix:@"beamfeature"]) {
                                        
                                        [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 45, largeRowHeight) Text:[NSString stringWithFormat:@"Outer:" ] Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:0.0];
                                    }else
                                    [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 45, largeRowHeight) Text:[NSString stringWithFormat:@"%@:",[dicPrices objectForKey:@"label"] ] Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:0.0];
                                    
                                    DebugLog(@"Title %@",[NSString stringWithFormat:@"%@:",[dicPrices objectForKey:[NSString stringWithFormat:@"Pack%d",startfrompack+1]]]);
                                    [objpdf drawTextWithFrame:CGRectMake(XMargin+40, YMargin, 48, largeRowHeight) Text:[NSString stringWithFormat:@"%@",[product valueForKey:[dicPrices objectForKey:@"field"]]] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                                    DebugLog(@"Title value %@",[numberFormatter stringFromNumber:[NSNumber numberWithInt:lineouter]]);
                                }
                                else{
                                    
                                    [objpdf drawTextWithFrame:CGRectMake(XMargin, YMargin, 45, largeRowHeight) Text:@"Weight" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:0.0];
                                    
                                    [objpdf drawTextWithFrame:CGRectMake(XMargin+40, YMargin, 48, largeRowHeight) Text:[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:weight]] Font:customFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                                    
                                    
                                }
                                
                                // YMargin+=largeRowHeight;
                                //}
                                //if ((! [[[CompanyConfigDelegate.dicOrderInfo objectForKey:@"Email_Formate_Field"] allKeys] containsObject:[NSString stringWithFormat:@"%@",[dicPrices objectForKey:[NSString stringWithFormat:@"Pack%d",startfrompack]]]])||(! [[[CompanyConfigDelegate.dicOrderInfo objectForKey:@"Email_Formate_Field"] allKeys] containsObject:[NSString stringWithFormat:@"%@",[dicPrices objectForKey:[NSString stringWithFormat:@"Pack%d",startfrompack]]]]))
                                //    YMargin+=largeRowHeight-20;
                                //else
                                YMargin+=largeRowHeight;
                                
                                YMargin+=largeRowHeight;
                                
                                YMargin+=largeRowHeight;
                                
                            }
                        }
                        //end of the code by Amit Pant
                        
                        
                        
                        YMargin+=largeRowHeight;
                    }
                    
                    if(!isLeftSideData)
                    {
                        isLeftSideData=YES;
                        topPos+=rowHeight;
                    }
                    else
                        isLeftSideData=NO;
                }
                remainRecCount--;
                rwCnt++;
            }
            
            
        }
        
        //items loop ended here
        
        
        if (kAppDelegate.selectedCompanyId== 51 && orderformat == OrderCSVFile) {
            [strval appendFormat:@"\r\n"];
            NSString *strfreetext=@"Quote test";
            [strval appendFormat:@"\"Notes: %@\",\r\n\r\n",[strfreetext stringByReplacingOccurrencesOfString:@"\n" withString:@", "]];
        }
        
        
        //code added by Ashish Pant
        //ApplicationDelegate.isLastPagedFooter=NO;
        //end of code added
        
        if(orderformat==OrderLargePhotos && !isLeftSideData)
            topPos+=rowHeight;
        
        if(orderformat==OrderLargePhotos)
            [self includeSignature:orderNum PDFRef:&objpdf TopPos:topPos+15 LeftPos:0];
        else
            [self includeSignature:orderNum PDFRef:&objpdf TopPos:topPos+10 LeftPos:0];
        
        if(validx!=0  ){
            if(totOlinesCount>0){
                
                leftPosTot=435;
                
                float tmpTopPos;
                
                tmpTopPos =topPos+5;
                //code added by Ashish Pant
                //ApplicationDelegate.isLastPagedFooter=YES;
                //end of code added
                
                //*******     TestyTab acknowledgement  30 Apr 2015
                if ([ordType isEqualToString:@"I"]){
                    
                    double inclVatOrder=totalOrderVal+totalVat;
                    
                    [objpdf drawTextWithFrame:CGRectMake(leftPosTot, tmpTopPos, 70, 11) Text:@"Total (excl) :" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:0.0];
                    [objpdf drawTextWithFrame:CGRectMake(leftPosTot+72, tmpTopPos, 60, 11) Text:[NSString stringWithFormat:@"%@ %@",strcurrsymbol,[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:totalOrderVal]]] Font:customBoldFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                    
                    tmpTopPos+=11;
                    [objpdf drawTextWithFrame:CGRectMake(leftPosTot, tmpTopPos, 70, 11) Text:@"Vat Total :" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:0.0];
                    [objpdf drawTextWithFrame:CGRectMake(leftPosTot+72, tmpTopPos, 60, 11) Text:[NSString stringWithFormat:@"%@ %@",strcurrsymbol,[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:totalVat]]] Font:customBoldFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                    
                    tmpTopPos+=11;
                    [objpdf drawTextWithFrame:CGRectMake(leftPosTot, tmpTopPos, 70, 11) Text:@"Total (incl . vat) :" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:0.0];
                    [objpdf drawTextWithFrame:CGRectMake(leftPosTot+72, tmpTopPos, 60, 11) Text:[NSString stringWithFormat:@"%@ %@",strcurrsymbol,[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:inclVatOrder]]] Font:customBoldFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                    
                    tmpTopPos+=11;
                    
                }
                else{
                    [objpdf drawTextWithFrame:CGRectMake(leftPosTot, tmpTopPos, 70, 11) Text:@"Total (excl. vat) :" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:0.0];
                    [objpdf drawTextWithFrame:CGRectMake(leftPosTot+72, tmpTopPos, 60, 11) Text:[NSString stringWithFormat:@"%@ %@",strcurrsymbol,[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:totalOrderVal]]] Font:customBoldFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                    
                    tmpTopPos+=11;
                    if (kAppDelegate.selectedCompanyId== 51 && orderformat == OrderCSVFile){
                        [strval appendFormat:@"\"Total Excl.VAT: %@\"\r\n",[NSString stringWithFormat:@" %@",[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:totalOrderVal]]]];
                    }
                }
                
                
                
                if(YES){
                    //Code added by Rajesh Pandey on 9 Jan 2015 for Gallery.
                    if (![[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"gallery"] ){
                        [objpdf drawTextWithFrame:CGRectMake(leftPosTot, tmpTopPos, 70, 11) Text:@"No of outers :" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:0.0];
                        //Add by Amit Pant
                        //*******        Tasty tubs Changes 16 JUN 2015
                        if([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"tasty"]){
                            
                            [objpdf drawTextWithFrame:CGRectMake(leftPosTot+72, tmpTopPos, 60, 11) Text:[NSString stringWithFormat:@"%i",totOlinesQty] Font:customBoldFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                            
                            //[objpdf drawTextWithFrame:CGRectMake(leftPosTot+72, tmpTopPos, 60, 11) Text:[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:totOlinesQty]] Font:customBoldFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                        }else if ([[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"ardale"] ) {
                            [objpdf drawTextWithFrame:CGRectMake(leftPosTot+72, tmpTopPos, 60, 11) Text:[numberFormatter stringFromNumber:[NSNumber numberWithDouble:totCartons]] Font:customBoldFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                        }
                        else{
                            [objpdf drawTextWithFrame:CGRectMake(leftPosTot+72, tmpTopPos, 60, 11) Text:[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:totCartons]] Font:customBoldFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                            if (kAppDelegate.selectedCompanyId== 51 && orderformat == OrderCSVFile)
                                [strval appendFormat:@"\"Total No of Outers: %@\"\r\n",[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:totCartons]]];
                        }
                    }else
                    {
                        [objpdf drawTextWithFrame:CGRectMake(leftPosTot, tmpTopPos, 70, 11) Text:@"No of packs :" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:0.0];
                        
                        [objpdf drawTextWithFrame:CGRectMake(leftPosTot+72, tmpTopPos, 60, 11) Text:[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:totCartons]] Font:customBoldFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                    }
                    tmpTopPos+=11;
                }
                
                [objpdf drawTextWithFrame:CGRectMake(leftPosTot, tmpTopPos, 70, 11) Text:@"No of lines :" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:0.0];
                
                [objpdf drawTextWithFrame:CGRectMake(leftPosTot+72, tmpTopPos, 60, 11) Text:[numberFormatter stringFromNumber:[NSNumber numberWithInt:totOlinesCount]] Font:customBoldFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                tmpTopPos+=11;
                if (kAppDelegate.selectedCompanyId== 51 && orderformat == OrderCSVFile)
                    [strval appendFormat:@"\"Total No of Lines: %@\"\r\n",[numberFormatter stringFromNumber:[NSNumber numberWithInt:totOlinesCount]]];
                
                /*if([[CompanyConfigDelegate.dicOrderInfo objectForKey:@"Cube_Size_By"] isEqualToString:@"Cubic Feet (cuft)"])
                 {
                 
                 [objpdf drawTextWithFrame:CGRectMake(leftPosTot, tmpTopPos, 70, 11) Text:@"Total CBF :" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:0.0];
                 }
                 else{
                 [objpdf drawTextWithFrame:CGRectMake(leftPosTot, tmpTopPos, 70, 11) Text:@"Total CBM :" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:0.0];
                 }*/
                [objpdf drawTextWithFrame:CGRectMake(leftPosTot+72, tmpTopPos, 60, 11) Text:[decimalFormatter stringFromNumber:[NSNumber numberWithDouble:totCBM]] Font:customBoldFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                tmpTopPos+=11;
                
                //*******     RE TestyTab acknowledgement  18 JUN 2015
                if((orderformat == OrderTextFormat && [[[companyConfigDict valueForKey:@"companyname"]lowercaseString]   hasPrefix:@"tasty"])){
                    
                    [objpdf drawTextWithFrame:CGRectMake(leftPosTot, tmpTopPos, 70, 11) Text:@"Next Call Date :" Font:customBoldFont TextAlignment:NSTextAlignmentLeft TruncateToWidth:0.0];
                    [objpdf drawTextWithFrame:CGRectMake(leftPosTot+72, tmpTopPos, 60, 11) Text:NextCallDate Font:customBoldFont TextAlignment:NSTextAlignmentRight TruncateToWidth:0.0];
                }
            }
        }
        
        
        //[self largePhotoFooter:0.0 TopPosition:710.0 PDF:&objpdf OrdNum:orderNum Cust:cust_name CustCode:cust_Code CBMPosition:topPos];
        //code added by Ashish Pant
        //ApplicationDelegate.isLastPagedFooter=NO;
        
        
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        PDFData =  [objpdf finalizePDF];
        
        
    }
    if (orderformat==OrderCSVFile){
        return [[strval dataUsingEncoding:NSUTF8StringEncoding]mutableCopy];
        
    }
    else
        return PDFData;
    //////
    
}



+(void)writeOrderHeadWithOrderNumber:(NSManagedObject *)orderObject PDFRef:(PDFCreator **)pdfref{
    
    @try {
        NSString *orderNum=[orderObject valueForKey:@"orderid"];
        
        
        NSDictionary* featureDict;//   fetch feature
        NSDictionary* companyConfigDict;//   fetch CompanyConfig
        NSDictionary* priceConfigDict;//   fetch PriceConfig
        
        // fetch Feature config
        featureDict = nil;
        NSDictionary *dic=[CommonHelper loadFileDataWithVirtualFilePath:FeaturesConfigFileName];
        if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
            featureDict = [dic objectForKey:@"data"];
        
        //   fetch CompanyConfig
        companyConfigDict = nil;
        dic=[CommonHelper loadFileDataWithVirtualFilePath:CompanyConfigFileName];
        if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
            companyConfigDict = [dic objectForKey:@"data"];
        
        //   fetch priceConfig
        priceConfigDict = nil;
        dic=[CommonHelper loadFileDataWithVirtualFilePath:PricingConfigFileName];
        if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
            priceConfigDict = [dic objectForKey:@"data"];
        ////////////
        
        
        
        UIFont* customFont = [UIFont fontWithName:kNormalFont size:9.0];
        UIFont* customFont1 = [UIFont fontWithName:kNormalFont size:8.0];
        UIFont* customBoldFont = [UIFont fontWithName:kBoldFont size:9.0];
        
        NSString* strCustCode = nil;
        NSString* strDelAddCode = nil;
        
        BOOL blOrdFound = NO;
        
        NSString *strordtype = nil;
        NSString *strorddate = nil;
        NSString *strdeldate = nil;
        NSString *strcustordref = nil;
        NSString *strdefrep = nil;
        NSString *strfreetext = nil;
        NSString *strtakenby = nil;
        NSString *strtyperef = nil;
        //code added by Ashish
        
        NSString* repsFirstname=@"";
        NSString* repsLastname=@"";
        NSString *repsFnameSubstring=@"";
        NSString *repsLnameSubstring=@"";
        NSString *repSales=@"";
        
        //need to complete later on
        
        if (repsFirstname.length>1 && repsLastname.length>1) {
            repsFnameSubstring=[repsFirstname substringToIndex:1];
            repsLnameSubstring=[repsLastname substringToIndex:1];
            repSales=[NSString stringWithFormat:@"%@%@ - %@ %@",repsFnameSubstring,repsLnameSubstring,repsFirstname,repsLastname];
        }
        
        //end of code added
        
        // Order head details
        
        blOrdFound = YES;
        
        strordtype = [orderObject valueForKey:@"ordtype"];
        strCustCode =[orderObject valueForKey:@"customerid"];
        strDelAddCode = [orderObject valueForKey:@"deliveryaddressid"];
        strorddate = [CommonHelper showDateWithCustomFormat:@"dd/MM/yy" Date:[orderObject valueForKey:@"orderdate"]];
        strdeldate = [CommonHelper showDateWithCustomFormat:@"dd/MM/yy" Date:[orderObject valueForKey:@"required_bydate"]];
        strcustordref = [orderObject valueForKey:@"purchaseordernumber"];
        strdefrep = @"";//[orderObject valueForKey:@"Def_Rep"];
        strfreetext = [orderObject valueForKey:@"freetext"];
        strtakenby = [orderObject valueForKey:@"employeeid"];
        strtyperef =  [orderObject valueForKey:@"typeref"];
        
        
        if(blOrdFound){
            if ([[strtyperef lowercaseString] hasPrefix:@"samples"]) {
                strordtype=@"S";
            }
            [self ordTypeHeader:strordtype PDF:&*pdfref];
            
            //[pdfref drawTextWithFrame:CGRectMake(450, 1, 200, 20) Text:strordtypedesc Font:customBoldFont];
            
            CGFloat leftPos = 5;
            // Write order detail headings
            [*pdfref drawTextWithFrame:CGRectMake(leftPos, 100, 70, 15) Text:@"Order No.: " Font:customBoldFont TruncateToWidth:75.0];
            [*pdfref drawTextWithFrame:CGRectMake(leftPos, 115, 70, 15) Text:@"Order Date: " Font:customBoldFont TruncateToWidth:70.0];
            [*pdfref drawTextWithFrame:CGRectMake(leftPos, 130, 70, 15) Text:@"Required: " Font:customBoldFont TruncateToWidth:70.0];
            [*pdfref drawTextWithFrame:CGRectMake(leftPos, 145, 70, 15) Text:@"Sales Rep: " Font:customBoldFont TruncateToWidth:70.0];
            [*pdfref drawTextWithFrame:CGRectMake(leftPos, 160, 70, 15) Text:@"Taken By: " Font:customBoldFont TruncateToWidth:70.0];
            [*pdfref drawTextWithFrame:CGRectMake(leftPos, 175, 70, 15) Text:@"Cust. Ref: " Font:customBoldFont TruncateToWidth:70.0];
            [*pdfref drawTextWithFrame:CGRectMake(leftPos, 190, 70, 15) Text:@"Notes: " Font:customBoldFont TruncateToWidth:70.0];
            
            // Write order details
            leftPos = 80;
            [*pdfref drawTextWithFrame:CGRectMake(leftPos, 100, 100, 15) Text:orderNum Font:customBoldFont TruncateToWidth:100.0];
            [*pdfref drawTextWithFrame:CGRectMake(leftPos, 115, 100, 15) Text:strorddate Font:customFont TruncateToWidth:100.0];
            [*pdfref drawTextWithFrame:CGRectMake(leftPos, 130, 100, 15) Text:strdeldate Font:customFont TruncateToWidth:100.0];
            //code commented by Ashish
            
            //code added by Ashish
            BOOL IsSalesPersonName=[[[priceConfigDict valueForKey:@"emailprintconfigs"] valueForKey:@"includesalespersonname"] boolValue];
            if (IsSalesPersonName)
                [*pdfref drawTextWithFrame:CGRectMake(leftPos, 145, 100, 15) Text:repSales Font:customFont TruncateToWidth:100.0];
            //end of  code
            
            [*pdfref drawTextWithFrame:CGRectMake(leftPos, 160, 100, 15) Text:strtakenby Font:customFont TruncateToWidth:100.0];
            [*pdfref drawTextWithFrame:CGRectMake(leftPos, 175, 100, 15) Text:strcustordref Font:customFont TruncateToWidth:100.0];
            
            // [*pdfref drawTextWithFrame:CGRectMake(leftPos, 190, 400, 15) Text:[strfreetext stringByReplacingOccurrencesOfString:@"\n" withString:@", "] Font:customFont TruncateToWidth:400.0];//code comment by Ashish
            
            if ([[[companyConfigDict valueForKey:@"companyname"] lowercaseString] hasPrefix:@"gallery"] ){
                NSString *newStr = [strfreetext stringByReplacingOccurrencesOfString:@"\n" withString:@", "];
                if (newStr.length>=251)
                    newStr = [newStr substringToIndex:250];
                
                // [*pdfref drawTextWithFrame:CGRectMake(leftPos, 190, 400, 15) Text:[strfreetext stringByReplacingOccurrencesOfString:@"\n" withString:@", "] Font:customFont TruncateToWidth:400.0];//code comment by Ashish
                [*pdfref drawTextWithFrame:CGRectMake(leftPos, 190, 490, 15) Text:newStr Font:customFont TruncateToWidth:0.0];//code added by Ashish
                
            }
            else
                [*pdfref drawTextWithFrame:CGRectMake(leftPos, 190, 400, 15) Text:[strfreetext stringByReplacingOccurrencesOfString:@"\n" withString:@", "] Font:customFont TruncateToWidth:400.0];//code comment by Ashish
            
            
            NSString *strFwdInvoice=@"";
            if (kAppDelegate.selectedCompanyId == 51)
                [strval appendFormat:@"\"Quote No. %@\",\"Quote Date: %@\",\"Required: %@\",\"Fwd Invoice: %@\",\"Sales Rep: %@\",\"Taken By: %@\",\"Cust Ref: %@\",\r\n",orderNum,strorddate,strdeldate,strFwdInvoice,repSales,strtakenby,strcustordref];
        }
        
        if(strCustCode!=nil && [strCustCode length]>0){
            BOOL blAddrFound = NO;
            NSString* addr1 = nil;
            NSString* addr2 = nil;
            NSString* addr3 = nil;
            NSString* addr4 = nil;
            NSString* addr5 = nil;
            NSString* strpostcode = nil;
            NSString* strphone = nil;
            NSString* strname = nil;
            
            // Order Customer
            
            blAddrFound = YES;
            addr1 =[[orderObject valueForKey:@"customer"] valueForKey:@"addr1"];
            addr2 =[[orderObject valueForKey:@"customer"] valueForKey:@"addr2"];
            addr3 =[[orderObject valueForKey:@"customer"] valueForKey:@"addr3"];
            addr4 =[[orderObject valueForKey:@"customer"] valueForKey:@"addr4"];
            addr5 =[[orderObject valueForKey:@"customer"] valueForKey:@"addr5"];
            strpostcode =[[orderObject valueForKey:@"customer"] valueForKey:@"postcode"];
            strphone =[[orderObject valueForKey:@"customer"] valueForKey:@"phone"];
            strname =[orderObject valueForKey:@"custname"] ;
            
            
            if(blAddrFound){
                NSString* strAddress = [NSString stringWithString:addr1];
                if([addr2 length]>0){
                    if([addr1 length]>0)
                        strAddress = [strAddress stringByAppendingFormat:@", %@",addr2];
                    else
                        strAddress = [strAddress stringByAppendingString:addr2];
                }
                if([addr3 length]>0) strAddress = [strAddress stringByAppendingFormat:@"\n%@",addr3];
                if([addr4 length]>0) {
                    if([addr3 length]>0)
                        strAddress = [strAddress stringByAppendingFormat:@", %@",addr4];
                    else
                        strAddress = [strAddress stringByAppendingFormat:@"\n%@",addr4];
                }
                if([addr5 length]>0) strAddress = [strAddress stringByAppendingFormat:@"\n%@",addr5];
                if([strpostcode length]>0) {
                    if([addr5 length]>0)
                        strAddress = [strAddress stringByAppendingFormat:@" - %@",strpostcode];
                    else
                        strAddress = [strAddress stringByAppendingFormat:@"\n%@",strpostcode];
                }
                //        if ([[strAddress uppercaseString] isEqualToString:strAddress])
                //            font2=8.0;
                
                
                
                strAddress=@"";
                strAddress=[commonMethods returnBaseAddress:[orderObject valueForKey:@"customer"]];
                strphone=@"";
                strphone=[commonMethods returnBasePhoneNumber:[orderObject valueForKey:@"customer"]];
                
                
                CGFloat leftPos = 200;
                CGFloat leftPos1 = 200;
                // Write order detail headings
                [*pdfref drawTextWithFrame:CGRectMake(leftPos, 100, 70, 15) Text:@"Customer: " Font:customBoldFont TruncateToWidth:70.0];
                [*pdfref drawTextWithFrame:CGRectMake(leftPos, 175, 70, 15) Text:@"Phone: " Font:customBoldFont TruncateToWidth:70.0];
                
                // Write order details
                leftPos = 280;
                [*pdfref drawTextWithFrame:CGRectMake(leftPos, 100, 120, 15) Text:strCustCode Font:customBoldFont TruncateToWidth:120.0];
                [*pdfref drawTextWithFrame:CGRectMake(leftPos1, 112, 190, 15) Text:strname Font:customFont TruncateToWidth:190.0];
                [*pdfref drawTextWithFrame:CGRectMake(leftPos1, 124, 190, 45) Text:strAddress Font:customFont1 TruncateToWidth:760.0];
                [*pdfref drawTextWithFrame:CGRectMake(leftPos, 175, 120, 15) Text:strphone Font:customFont TruncateToWidth:120.0];
                
                if([strDelAddCode isEqualToString:@"000"] || [strDelAddCode length]==0){
                    leftPos = 400;
                    leftPos1 = 400;
                    // Write order detail headings
                    [*pdfref drawTextWithFrame:CGRectMake(leftPos, 100, 70, 15) Text:@"Del To: " Font:customBoldFont TruncateToWidth:70.0];
                    [*pdfref drawTextWithFrame:CGRectMake(leftPos, 175, 70, 15) Text:@"Phone: " Font:customBoldFont TruncateToWidth:70.0];
                    
                    // Write order details
                    leftPos = 480;
                    [*pdfref drawTextWithFrame:CGRectMake(leftPos, 100, 120, 15) Text:strDelAddCode Font:customBoldFont TruncateToWidth:120.0];
                    [*pdfref drawTextWithFrame:CGRectMake(leftPos1, 112, 180, 15) Text:strname Font:customFont TruncateToWidth:180.0];
                    [*pdfref drawTextWithFrame:CGRectMake(leftPos1, 124, 180, 45) Text:strAddress Font:customFont1 TruncateToWidth:720.0];
                    [*pdfref drawTextWithFrame:CGRectMake(leftPos, 175, 120, 15) Text:strphone Font:customFont TruncateToWidth:120.0];
                }
            }
            
//========== if delivery address other than main address
            if(strDelAddCode!=nil && [strDelAddCode length]>0 && ![strDelAddCode isEqualToString:@"000"]){
                blAddrFound = NO;
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                NSString *entityName=@"CUST";
                NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:kAppDelegate.managedObjectContext];
                [fetchRequest setEntity:entity];
                NSString *filterDeliveryAddress = [NSString stringWithFormat:@"acc_ref=='%@' && delivery_address =='%@'",[[orderObject valueForKey:@"customer"] valueForKey:@"acc_ref"],[orderObject valueForKey:@"deliveryaddressid"]];
                NSPredicate* predicate=[NSPredicate predicateWithFormat:filterDeliveryAddress];
                [fetchRequest setPredicate:predicate];
                NSError *error = nil;
                NSArray *arrayDel=[kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
                
                if (arrayDel.count>0) {
                    blAddrFound = YES;
                    addr1 =[[arrayDel lastObject] valueForKey:@"addr1"];
                    addr2 =[[arrayDel lastObject] valueForKey:@"addr2"];
                    addr3 =[[arrayDel lastObject] valueForKey:@"addr3"];
                    addr4 =[[arrayDel lastObject] valueForKey:@"addr4"];
                    addr5 =[[arrayDel lastObject] valueForKey:@"addr5"];
                    strpostcode =[[arrayDel lastObject] valueForKey:@"postcode"];
                    strphone =[[arrayDel lastObject] valueForKey:@"phone"];
                    strname =[[arrayDel lastObject] valueForKey:@"name"];
                }
                
                if(blAddrFound){
                    NSString* strAddress = [NSString stringWithString:addr1];
                    if([addr2 length]>0){
                        if([addr1 length]>0)
                            strAddress = [strAddress stringByAppendingFormat:@", %@",addr2];
                        else
                            strAddress = [strAddress stringByAppendingString:addr2];
                    }
                    if([addr3 length]>0) strAddress = [strAddress stringByAppendingFormat:@"\n%@",addr3];
                    if([addr4 length]>0) {
                        if([addr3 length]>0)
                            strAddress = [strAddress stringByAppendingFormat:@", %@",addr4];
                        else
                            strAddress = [strAddress stringByAppendingFormat:@"\n%@",addr4];
                    }
                    if([addr5 length]>0) strAddress = [strAddress stringByAppendingFormat:@"\n%@",addr5];
                    if([strpostcode length]>0) {
                        if([addr5 length]>0)
                            strAddress = [strAddress stringByAppendingFormat:@" - %@",strpostcode];
                        else
                            strAddress = [strAddress stringByAppendingFormat:@"\n%@",strpostcode];
                    }
                    //            if ([[strAddress uppercaseString] isEqualToString:strAddress])
                    //                font2=8.0;
                    CGFloat leftPos = 400;
                    CGFloat leftPos1 = 400;
                    // Write order detail headings
                    [*pdfref drawTextWithFrame:CGRectMake(leftPos, 100, 70, 15) Text:@"Del To: " Font:customBoldFont TruncateToWidth:70.0];
                    [*pdfref drawTextWithFrame:CGRectMake(leftPos, 175, 70, 15) Text:@"Phone: " Font:customBoldFont TruncateToWidth:70.0];
                    
                    // Write order details
                    leftPos = 480;
                    [*pdfref drawTextWithFrame:CGRectMake(leftPos, 100, 120, 15) Text:strDelAddCode Font:customBoldFont TruncateToWidth:120.0];
                    [*pdfref drawTextWithFrame:CGRectMake(leftPos1, 112, 180, 15) Text:strname Font:customFont TruncateToWidth:180.0];
                    [*pdfref drawTextWithFrame:CGRectMake(leftPos1, 124, 180, 45) Text:strAddress Font:customFont1 TruncateToWidth:720.0];
                    [*pdfref drawTextWithFrame:CGRectMake(leftPos, 175, 120, 15) Text:strphone Font:customFont TruncateToWidth:120.0];
                }
            }
            
            if (kAppDelegate.selectedCompanyId == 51)
                [strval appendFormat:@"\"Cust: %@\",\"Name: %@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\r\n\r\n",strCustCode,strname,addr1,addr2,addr3,addr4,addr5,strphone,strpostcode];
        }
        // draw line below all the details
        // [*pdfref drawLineWithFrame:CGRectMake(0, 205, 570, 1) LineWidth:2.0 LineColor:[UIColor grayColor]];//comment by Ashish
        if ([[[companyConfigDict valueForKey:@"companyname"] lowercaseString] hasPrefix:@"gallery"] )
            [*pdfref drawLineWithFrame:CGRectMake(0, 220, 570, 1) LineWidth:2.0 LineColor:[UIColor grayColor]];//added by Ashish //top line
        else
            [*pdfref drawLineWithFrame:CGRectMake(0, 205, 570, 1) LineWidth:2.0 LineColor:[UIColor grayColor]];
    }
    @catch (NSException *exception) {
        //[CommonHelper writeErrorLogWithNo:0 Description:[exception description] Method:[NSString stringWithUTF8String:__func__]];
    }
}
//code ended here.
@end
