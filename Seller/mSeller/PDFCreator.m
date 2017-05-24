//
//  PDFCreator.m
//  mSellerPro
//
//  Created by Satish Kumar on 10/19/12.
//  Copyright (c) 2012 Williams Commerce Ltd. All rights reserved.
//

#import "PDFCreator.h"

#import "NSString+TruncateToWidth.h"

@interface PDFCreator()

@property(nonatomic,assign)CGSize pageSize;
@property(nonatomic,strong)NSMutableData* PDFData;
@end

@implementation PDFCreator

@synthesize pageSize;
@synthesize PDFData;

-(id)initPDFWithPageWidth:(CGFloat)width Height:(CGFloat)height{
    self = [super init];
    if(self){
        self.PDFData = [[NSMutableData alloc] init];
        //pageSize = CGSizeMake(612, 792);
        self.pageSize = CGSizeMake(width, height);
        UIGraphicsBeginPDFContextToData(self.PDFData, CGRectZero, nil);
    }
    return self;
}

-(id)initPDFWithPath:(NSString *)filepath{
    self = [super init];
    if(self){
        //pageSize = CGSizeMake(612, 792);
        self.pageSize = CGSizeMake(595, 842);
        UIGraphicsBeginPDFContextToFile(filepath, CGRectZero, nil);
    }
    return self;
}

/*-(id)initPDFWithPath:(NSString *)filepath AllowCopy:(BOOL)allowcopy AllowPrint:(BOOL)allowprint  IsSecure:(BOOL)issecure OwnerPwd:(NSString *)ownerpwd UserPwd:(NSString *)userpwd{
 self = [super init];
 if(self){
 //pageSize = CGSizeMake(612, 792);
 pageSize = CGSizeMake(595, 842);
 CFMutableDictionaryRef myDictionary = NULL;
 // This dictionary contains extra options mostly for 'signing' the PDF
 
 myDictionary = CFDictionaryCreateMutable(NULL, 0,
 &kCFTypeDictionaryKeyCallBacks,
 &kCFTypeDictionaryValueCallBacks);
 
 if(!allowcopy)
 CFDictionarySetValue(myDictionary, kCGPDFContextAllowsCopying, kCFBooleanFalse);
 if(!allowprint)
 CFDictionarySetValue(myDictionary, kCGPDFContextAllowsPrinting, kCFBooleanFalse);
 if(issecure){
 //CFStringRef* cfownerpwd =(CFStringRef*) [ownerpwd UTF8String];
 //CFDictionarySetValue(myDictionary, kCGPDFContextOwnerPassword, cfownerpwd);
 //CFStringRef* cfuserpwd =(CFStringRef*) [userpwd UTF8String];
 //CFDictionarySetValue(myDictionary, kCGPDFContextUserPassword, cfuserpwd);
 }
 //CFDictionarySetValue(myDictionary, kCGPDFContextTitle, CFSTR("My PDF File"));
 //CFDictionarySetValue(myDictionary, kCGPDFContextCreator, CFSTR("My Name"));
 NSDictionary* mydic = (__bridge NSDictionary *)myDictionary;
 UIGraphicsBeginPDFContextToFile(filepath, CGRectZero,mydic);
 CFRelease(myDictionary);
 }
 return self;
 }*/

#pragma mark - Private Methods
- (void) drawBorderWidth:(CGFloat)borderwidth BorderColor:(UIColor *)bordercolor
{
    @try {
        CGContextRef    currentContext = UIGraphicsGetCurrentContext();
        UIColor *borderColor = [UIColor brownColor];
        if(bordercolor!=nil)
            borderColor = bordercolor;
        
        CGRect rectFrame = CGRectMake(kBorderInset, kBorderInset, pageSize.width-kBorderInset*2, pageSize.height-kBorderInset*2);
        
        CGContextSetStrokeColorWithColor(currentContext, borderColor.CGColor);
        
        CGContextSetLineWidth(currentContext, borderwidth);
        CGContextStrokeRect(currentContext, rectFrame);
    }
    @catch (NSException *exception) {
//        [CommonHelper writeErrorLogWithNo:0 Description:[exception description] Method:[NSString stringWithUTF8String:__func__]];
    }
}

- (void)drawPageNumber:(NSInteger)pageNum TotalPages:(NSInteger)pages ShowPageNo:(BOOL)showpageno PageNumberPosition:(enum PageNumberPosition)pagepos
{
    @try {
        //Start a new page.
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pageSize.width, pageSize.height), nil);
        
        if(showpageno){
            NSString *pageNumberString = [NSString stringWithFormat:@"Page %ld", (long)pageNum];
            UIFont* theFont = [UIFont fontWithName:kNormalFont size:8.0];//[UIFont systemFontOfSize:8];
            
//            CGSize pageNumberStringSize = [pageNumberString sizeWithFont:theFont
//                                                       constrainedToSize:pageSize
//                                                           lineBreakMode:NSLineBreakByWordWrapping];

            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
//            CGSize pageNumberStringSize = [pageNumberString sizeWithAttributes:
//                           @{NSFontAttributeName: theFont,NSParagraphStyleAttributeName: paragraphStyle}];

            NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:pageNumberString attributes:@{NSFontAttributeName: theFont,NSParagraphStyleAttributeName: paragraphStyle}];
            CGRect rect = [attributedText boundingRectWithSize:pageSize
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                       context:nil];
            // Values are fractional -- you should take the ceilf to get equivalent values
            CGSize pageNumberStringSize = CGSizeMake(ceilf(rect.size.width), ceilf(rect.size.height));
            
            CGRect stringRenderingRect = CGRectMake(kBorderInset+5,
                                                    pageSize.height - 18.0,
                                                    pageSize.width - 4*kBorderInset,
                                                    pageNumberStringSize.height);
            
            if(pagepos<3)
                stringRenderingRect.origin.y = 30.0;

            NSInteger textalignment = NSTextAlignmentRight;
            NSInteger linebreakmode = NSLineBreakByWordWrapping;

            if(pagepos==1 || pagepos==4)
                textalignment = NSTextAlignmentCenter;//[pageNumberString drawInRect:stringRenderingRect withFont:theFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
            else if(pagepos==0 || pagepos==3)
                textalignment = NSTextAlignmentLeft;//[pageNumberString drawInRect:stringRenderingRect withFont:theFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
//            else if(pagepos==6)
//                textalignment = NSTextAlignmentCenter;//[pageNumberString drawInRect:stringRenderingRect withFont:theFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentRight];
//            else
//                textalignment = NSTextAlignmentCenter;//[pageNumberString drawInRect:stringRenderingRect withFont:theFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentRight];

            paragraphStyle.alignment = textalignment;

            [pageNumberString drawInRect:stringRenderingRect withAttributes:@{NSFontAttributeName: theFont,NSParagraphStyleAttributeName: paragraphStyle}];

//            if(pagepos==1 || pagepos==4)
//                [pageNumberString drawInRect:stringRenderingRect withFont:theFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
//            else if(pagepos==0 || pagepos==3)
//                [pageNumberString drawInRect:stringRenderingRect withFont:theFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
//            else if(pagepos==6)
//                [pageNumberString drawInRect:stringRenderingRect withFont:theFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentRight];
//            else
//                [pageNumberString drawInRect:stringRenderingRect withFont:theFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentRight];
        }
    }
    @catch (NSException *exception) {
//        [CommonHelper writeErrorLogWithNo:0 Description:[exception description] Method:[NSString stringWithUTF8String:__func__]];
    }
}

- (void) drawHeaderWithFrame:(CGRect )frame View:(UIView *)headerview
{
    @try {
        CGContextRef    currentContext = UIGraphicsGetCurrentContext();
        CGContextSetRGBFillColor(currentContext, 0.3, 0.7, 0.2, 1.0);
        
        for(UIView* vw in headerview.subviews){
            if([vw isKindOfClass:[UILabel class]]){
                UILabel* lbl = (UILabel *)vw;
                NSString *textToDraw =lbl.text;
                
                CGSize stringSize = [textToDraw sizeWithFont:[lbl font]  constrainedToSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset) lineBreakMode:NSLineBreakByWordWrapping];
                
                CGRect renderingRect = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset, pageSize.width - 2*kBorderInset - 2*kMarginInset, stringSize.height);
                
                [textToDraw drawInRect:renderingRect withFont:[lbl font] lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
            }
            else if([vw isKindOfClass:[UIImageView class]]){
                UIImageView* imgvw = (UIImageView *)vw;
                [self drawImageWithFrame:imgvw.frame Image:[imgvw image]];
            }
        }
        
    }
    @catch (NSException *exception) {
//        [CommonHelper writeErrorLogWithNo:0 Description:[exception description] Method:[NSString stringWithUTF8String:__func__]];
    }
    /*NSString *textToDraw = @"Pdf Demo - iOSLearner.com";
     
     UIFont *font = [UIFont systemFontOfSize:24.0];
     
     CGSize stringSize = [textToDraw sizeWithFont:font constrainedToSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset) lineBreakMode:NSLineBreakByWordWrapping];
     
     CGRect renderingRect = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset, pageSize.width - 2*kBorderInset - 2*kMarginInset, stringSize.height);
     
     [textToDraw drawInRect:renderingRect withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];*/
}
-(void) drawRect:(CGRect)rect color:(UIColor *)clr
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    //UIColor * yellowColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
    
    CGContextSetFillColorWithColor(context, clr.CGColor);
    CGContextFillRect(context, rect);
}
- (void) drawTextWithFrame:(CGRect )frame Text:(NSString *)textval Font:(UIFont *)textfont TextAlignment:(NSTextAlignment)textalignment  Color:(UIColor *)clr IsUnderLine:(BOOL)isLine TruncateToWidth:(CGFloat)trsize
{
    @try {
        if(textval){
            CGContextRef    currentContext = UIGraphicsGetCurrentContext();
            
            CGContextSetFillColorWithColor(currentContext, clr.CGColor);
            
            
            UIFont *font = [UIFont fontWithName:kNormalFont size:12.0];//[UIFont systemFontOfSize:12.0];
            if(textfont!=nil)
                font = textfont;
            
            if(trsize>0)
                textval = [textval stringByTruncatingToWidth:trsize withFont:font];
            
            CGSize stringSize = [textval sizeWithFont:font
                                    constrainedToSize:CGSizeMake(frame.size.width, pageSize.height - 2*kBorderInset - 2*kMarginInset)
                                        lineBreakMode:NSLineBreakByWordWrapping];
            //CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset
            
            CGRect renderingRect = CGRectMake(kBorderInset + kMarginInset+frame.origin.x, kBorderInset + kMarginInset + frame.origin.y,frame.size.width, stringSize.height);
            //pageSize.width - 2*kBorderInset - 2*kMarginInset
            [textval drawInRect:renderingRect
                       withFont:font
                  lineBreakMode:NSLineBreakByWordWrapping
                      alignment:textalignment];
        }
    }
    @catch (NSException *exception) {
//        [CommonHelper writeErrorLogWithNo:0 Description:[exception description] Method:[NSString stringWithUTF8String:__func__]];
    }
}

- (void) drawTextWithFrame:(CGRect )frame Text:(NSString *)textval Font:(UIFont *)textfont TruncateToWidth:(CGFloat)trsize
{
    @try {
        if(textval){
            CGContextRef    currentContext = UIGraphicsGetCurrentContext();
            
            CGContextSetRGBFillColor(currentContext, 0.0, 0.0, 0.0, 1.0);
            
            //NSString *textToDraw = @"Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Nam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Typi non habent claritatem insitam; est usus legentis in iis qui facit eorum claritatem. Investigationes demonstraverunt lectores legere me lius quod ii legunt saepius. Claritas est etiam processus dynamicus, qui sequitur mutationem consuetudium lectorum. Mirum est notare quam littera gothica, quam nunc putamus parum claram, anteposuerit litterarum formas humanitatis per seacula quarta decima et quinta decima. Eodem modo typi, qui nunc nobis videntur parum clari, fiant sollemnes in futurum.";
            
            UIFont *font = [UIFont fontWithName:kNormalFont size:12.0];//[UIFont systemFontOfSize:12.0];
            if(textfont!=nil)
                font = textfont;
            
            if(trsize>0)
                textval = [textval stringByTruncatingToWidth:trsize withFont:font];
            
            CGSize stringSize = [textval sizeWithFont:font
                                    constrainedToSize:CGSizeMake(frame.size.width, pageSize.height - 3*kBorderInset - 2*kMarginInset)
                                        lineBreakMode:NSLineBreakByWordWrapping];
            //CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset
            
            CGRect renderingRect = CGRectMake(kBorderInset + kMarginInset+frame.origin.x, kBorderInset + kMarginInset + frame.origin.y,frame.size.width, stringSize.height);
            //pageSize.width - 2*kBorderInset - 2*kMarginInset
            [textval drawInRect:renderingRect
                       withFont:font
                  lineBreakMode:NSLineBreakByWordWrapping
                      alignment:NSTextAlignmentLeft];
        }
    }
    @catch (NSException *exception) {
//        [CommonHelper writeErrorLogWithNo:0 Description:[exception description] Method:[NSString stringWithUTF8String:__func__]];
    }
}

- (void) drawTextWithFrame:(CGRect )frame Text:(NSString *)textval Font:(UIFont *)textfont Color:(UIColor *)color TruncateToWidth:(CGFloat)trsize
{
    @try {
        if(textval){
            CGContextRef    currentContext = UIGraphicsGetCurrentContext();
            
            CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha =0.0;
            [color getRed:&red green:&green blue:&blue alpha:&alpha];
            CGContextSetRGBFillColor(currentContext, red, green, blue, alpha);
            
            //NSString *textToDraw = @"Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Nam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Typi non habent claritatem insitam; est usus legentis in iis qui facit eorum claritatem. Investigationes demonstraverunt lectores legere me lius quod ii legunt saepius. Claritas est etiam processus dynamicus, qui sequitur mutationem consuetudium lectorum. Mirum est notare quam littera gothica, quam nunc putamus parum claram, anteposuerit litterarum formas humanitatis per seacula quarta decima et quinta decima. Eodem modo typi, qui nunc nobis videntur parum clari, fiant sollemnes in futurum.";
            
            UIFont *font = [UIFont fontWithName:kNormalFont size:12.0];//[UIFont systemFontOfSize:12.0];
            if(textfont!=nil)
                font = textfont;
            
            if(trsize>0)
                textval = [textval stringByTruncatingToWidth:trsize withFont:font];
            
            CGSize stringSize = [textval sizeWithFont:font
                                    constrainedToSize:CGSizeMake(frame.size.width, pageSize.height - 2*kBorderInset - 2*kMarginInset)
                                        lineBreakMode:NSLineBreakByWordWrapping];
            //CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset
            
            CGRect renderingRect = CGRectMake(kBorderInset + kMarginInset+frame.origin.x, kBorderInset + kMarginInset + frame.origin.y,frame.size.width, stringSize.height);
            //pageSize.width - 2*kBorderInset - 2*kMarginInset
            [textval drawInRect:renderingRect
                       withFont:font
                  lineBreakMode:NSLineBreakByWordWrapping
                      alignment:NSTextAlignmentLeft];
        }
    }
    @catch (NSException *exception) {
//        [CommonHelper writeErrorLogWithNo:0 Description:[exception description] Method:[NSString stringWithUTF8String:__func__]];
    }
}

- (void) drawTextWithFrame:(CGRect )frame Text:(NSString *)textval Font:(UIFont *)textfont TextAlignment:(NSTextAlignment)textalignment TruncateToWidth:(CGFloat)trsize
{// Ashish old
    @try {
        if(textval){
            CGContextRef    currentContext = UIGraphicsGetCurrentContext();
            
            CGContextSetRGBFillColor(currentContext, 0.0, 0.0, 0.0, 1.0);
            
            //NSString *textToDraw = @"Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Nam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Typi non habent claritatem insitam; est usus legentis in iis qui facit eorum claritatem. Investigationes demonstraverunt lectores legere me lius quod ii legunt saepius. Claritas est etiam processus dynamicus, qui sequitur mutationem consuetudium lectorum. Mirum est notare quam littera gothica, quam nunc putamus parum claram, anteposuerit litterarum formas humanitatis per seacula quarta decima et quinta decima. Eodem modo typi, qui nunc nobis videntur parum clari, fiant sollemnes in futurum.";
            
            UIFont *font = [UIFont fontWithName:kNormalFont size:12.0];//[UIFont systemFontOfSize:12.0];
            if(textfont!=nil)
                font = textfont;
            
            if(trsize>0)
                textval = [textval stringByTruncatingToWidth:trsize withFont:font];
            
            CGSize stringSize = [textval sizeWithFont:font
                                    constrainedToSize:CGSizeMake(frame.size.width, pageSize.height - 2*kBorderInset - 2*kMarginInset)
                                        lineBreakMode:NSLineBreakByWordWrapping];
            //CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset
            
            CGRect renderingRect = CGRectMake(kBorderInset + kMarginInset+frame.origin.x, kBorderInset + kMarginInset + frame.origin.y,frame.size.width, stringSize.height);
            //pageSize.width - 2*kBorderInset - 2*kMarginInset
            [textval drawInRect:renderingRect
                       withFont:font
                  lineBreakMode:NSLineBreakByWordWrapping
                      alignment:textalignment];
        }
    }
    @catch (NSException *exception) {
//        [CommonHelper writeErrorLogWithNo:0 Description:[exception description] Method:[NSString stringWithUTF8String:__func__]];
    }
}
- (void) drawTextWithFrameWithoutTruncate:(CGRect )frame Text:(NSString *)textval Font:(UIFont *)textfont TextAlignment:(NSTextAlignment)textalignment TruncateToWidth:(CGFloat)trsize
{
    @try {
        if(textval){
            CGContextRef    currentContext = UIGraphicsGetCurrentContext();
            
            CGContextSetRGBFillColor(currentContext, 0.0, 0.0, 0.0, 1.0);
            
            //NSString *textToDraw = @"Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Nam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Typi non habent claritatem insitam; est usus legentis in iis qui facit eorum claritatem. Investigationes demonstraverunt lectores legere me lius quod ii legunt saepius. Claritas est etiam processus dynamicus, qui sequitur mutationem consuetudium lectorum. Mirum est notare quam littera gothica, quam nunc putamus parum claram, anteposuerit litterarum formas humanitatis per seacula quarta decima et quinta decima. Eodem modo typi, qui nunc nobis videntur parum clari, fiant sollemnes in futurum.";
            
            UIFont *font = [UIFont fontWithName:kNormalFont size:12.0];//[UIFont systemFontOfSize:12.0];
            if(textfont!=nil)
                font = textfont;
            /*
            if(trsize>0)
                textval = [textval stringByTruncatingToWidth:trsize withFont:font];
            */
            CGSize stringSize = [textval sizeWithFont:font
                                    constrainedToSize:CGSizeMake(frame.size.width, pageSize.height - 2*kBorderInset - 2*kMarginInset)
                                        lineBreakMode:NSLineBreakByWordWrapping];
            //CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset
            
            CGRect renderingRect = CGRectMake(kBorderInset + kMarginInset+frame.origin.x, kBorderInset + kMarginInset + frame.origin.y,frame.size.width, stringSize.height);
            //pageSize.width - 2*kBorderInset - 2*kMarginInset
            [textval drawInRect:renderingRect
                       withFont:font
                  lineBreakMode:NSLineBreakByWordWrapping
                      alignment:textalignment];
        }
    }
    @catch (NSException *exception) {
//        [CommonHelper writeErrorLogWithNo:0 Description:[exception description] Method:[NSString stringWithUTF8String:__func__]];
    }
}
- (void) drawTextWithFrame:(CGRect )frame Text:(NSString *)textval Font:(UIFont *)textfont TextAlignment:(NSTextAlignment)textalignment IsUnderLine:(BOOL)isLine TruncateToWidth:(CGFloat)trsize
{
    @try {
        if(textval){
            CGContextRef    currentContext = UIGraphicsGetCurrentContext();
            CGContextSetRGBFillColor(currentContext, 0.0, 0.0, 0.0, 1.0);
            UIFont *font = [UIFont fontWithName:kNormalFont size:12.0];//[UIFont systemFontOfSize:12.0];
            if(textfont!=nil)
                font = textfont;
            
            if(trsize>0)
                textval = [textval stringByTruncatingToWidth:trsize withFont:font];
            
            CGSize stringSize = [textval sizeWithFont:font
                                    constrainedToSize:CGSizeMake(frame.size.width, pageSize.height - 2*kBorderInset - 2*kMarginInset)
                                        lineBreakMode:NSLineBreakByWordWrapping];
            if (isLine)
            {
                CGRect rect=frame;
                rect.size=stringSize;
                rect.origin.y+=rect.size.height;
                [self drawLineWithFrame:rect LineWidth:0.5f LineColor:[UIColor blackColor]];
            }
            CGRect renderingRect = CGRectMake(kBorderInset + kMarginInset+frame.origin.x, kBorderInset + kMarginInset + frame.origin.y,frame.size.width, stringSize.height);
            [textval drawInRect:renderingRect
                       withFont:font
                  lineBreakMode:NSLineBreakByWordWrapping
                      alignment:textalignment];
        }
    }
    @catch (NSException *exception) {
//        [CommonHelper writeErrorLogWithNo:0 Description:[exception description] Method:[NSString stringWithUTF8String:__func__]];
    }
}
- (void) drawLineWithFrame:(CGRect )frame LineWidth:(CGFloat)linewidth LineColor:(UIColor *)linecolor
{
    @try {
        CGContextRef    currentContext = UIGraphicsGetCurrentContext();
        
        CGContextSetLineWidth(currentContext, linewidth);
        
        if(linecolor!=nil)
            CGContextSetStrokeColorWithColor(currentContext, linecolor.CGColor);
        else
            CGContextSetStrokeColorWithColor(currentContext, [UIColor grayColor].CGColor);
        
        //CGPoint startPoint = CGPointMake(kMarginInset + kBorderInset, kMarginInset + kBorderInset + 40.0);
        CGPoint startPoint = CGPointMake(kMarginInset + kBorderInset+frame.origin.x, kMarginInset + kBorderInset + frame.origin.y);
        //CGPoint endPoint = CGPointMake(pageSize.width - 2*kMarginInset -2*kBorderInset, kMarginInset + kBorderInset + 40.0);
        CGPoint endPoint = CGPointMake(kMarginInset + kBorderInset+frame.origin.x+frame.size.width, kMarginInset + kBorderInset + frame.origin.y);
        
        CGContextBeginPath(currentContext);
        CGContextMoveToPoint(currentContext, startPoint.x, startPoint.y);
        CGContextAddLineToPoint(currentContext, endPoint.x, endPoint.y);
        
        CGContextClosePath(currentContext);
        CGContextDrawPath(currentContext, kCGPathFillStroke);
    }
    @catch (NSException *exception) {
//        [CommonHelper writeErrorLogWithNo:0 Description:[exception description] Method:[NSString stringWithUTF8String:__func__]];
    }
}
- (void) drawHrLineWithFrame:(CGRect )frame LineHeight:(CGFloat)lineheight LineColor:(UIColor *)linecolor
{
    @try {
        CGContextRef    currentContext = UIGraphicsGetCurrentContext();
        
        CGContextSetLineWidth(currentContext, 2);
        
        if(linecolor!=nil)
            CGContextSetStrokeColorWithColor(currentContext, linecolor.CGColor);
        else
            CGContextSetStrokeColorWithColor(currentContext, [UIColor grayColor].CGColor);
        
        //CGPoint startPoint = CGPointMake(kMarginInset + kBorderInset, kMarginInset + kBorderInset + 40.0);
        CGPoint startPoint = CGPointMake(kMarginInset + kBorderInset+frame.origin.x, kMarginInset + kBorderInset + frame.origin.y);
        //CGPoint endPoint = CGPointMake(pageSize.width - 2*kMarginInset -2*kBorderInset, kMarginInset + kBorderInset + 40.0);
        CGPoint endPoint = CGPointMake(kMarginInset + kBorderInset+frame.origin.x+frame.size.width, kMarginInset + kBorderInset + frame.origin.y);
        
        CGContextBeginPath(currentContext);
        CGContextMoveToPoint(currentContext, startPoint.x, startPoint.y);
        CGContextAddLineToPoint(currentContext, endPoint.x, endPoint.y);
        
        CGContextClosePath(currentContext);
        CGContextDrawPath(currentContext, kCGPathFillStroke);
    }
    @catch (NSException *exception) {
//        [CommonHelper writeErrorLogWithNo:0 Description:[exception description] Method:[NSString stringWithUTF8String:__func__]];
    }
}
- (void) drawImageWithFrame:(CGRect )frame ImagePath:(NSString *)imgpath
{
    @try {
        if(imgpath){
            UIImage * demoImage = [UIImage imageWithContentsOfFile:imgpath]; //[UIImage imageNamed:@"demo.png"];
            //[demoImage drawInRect:CGRectMake( (pageSize.width - demoImage.size.width/2)/2, 350, demoImage.size.width/2, demoImage.size.height/2)];
            [demoImage drawInRect:CGRectMake(kBorderInset + kMarginInset+frame.origin.x, kBorderInset + kMarginInset + frame.origin.y,frame.size.width, frame.size.height)];
            demoImage = nil;
        }
    }
    @catch (NSException *exception) {
//        [CommonHelper writeErrorLogWithNo:0 Description:[exception description] Method:[NSString stringWithUTF8String:__func__]];
    }
}

- (void) drawImageWithFrame:(CGRect )frame Image:(UIImage *)img
{
    @try {
        if(img){
            UIImage * demoImage = img;//[UIImage imageWithContentsOfFile:imgpath]; //[UIImage imageNamed:@"demo.png"];
            //[demoImage drawInRect:CGRectMake( (pageSize.width - demoImage.size.width/2)/2, 350, demoImage.size.width/2, demoImage.size.height/2)];
            DebugLog(@"%f",frame.size.height);
            [demoImage drawInRect:CGRectMake(kBorderInset + kMarginInset+frame.origin.x, kBorderInset + kMarginInset + frame.origin.y,frame.size.width, frame.size.height)];
            demoImage = nil;
             //CGContextDrawImage(pdfContext, mediaBox, [image CGImage]);
        }
    }
    @catch (NSException *exception) {
//        [CommonHelper writeErrorLogWithNo:0 Description:[exception description] Method:[NSString stringWithUTF8String:__func__]];
    }
}

- (NSMutableData *)finalizePDF{
    // Close the PDF context and write the contents out.
    UIGraphicsEndPDFContext();
    
    return self.PDFData;
}




@end
