//
//  PDFCreator.h
//  mSellerPro
//
//  Created by Satish Kumar on 10/19/12.
//  Copyright (c) 2012 Williams Commerce Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kBorderInset            5.0
#define kMarginInset            5.0
#define kNormalFont @"ArialMT"

enum PageNumberPosition {
    PageNumberPositionTopLeft = 0,
    PageNumberPositionTopCenter = 1,
    PageNumberPositionTopRight = 2,
    PageNumberPositionBottomLeft = 3,
    PageNumberPositionBottomCenter = 4,
    PageNumberPositionBottomRihgt = 5,
    PageNumberPositionBottomRihgt2 = 6
    };

@interface PDFCreator : NSObject{
    CGSize pageSize;
}


-(id)initPDFWithPath:(NSString *)filepath;
//-(id)initPDFWithPath:(NSString *)filepath AllowCopy:(BOOL)allowcopy AllowPrint:(BOOL)allowprint  IsSecure:(BOOL)issecure OwnerPwd:(NSString *)ownerpwd UserPwd:(NSString *)userpwd;
-(id)initPDFWithPageWidth:(CGFloat)width Height:(CGFloat)height;

- (void)drawPageNumber:(NSInteger)pageNum TotalPages:(NSInteger)pages ShowPageNo:(BOOL)showpageno PageNumberPosition:(enum PageNumberPosition)pagepos;

- (void) drawBorderWidth:(CGFloat)borderwidth BorderColor:(UIColor *)bordercolor;
- (void) drawTextWithFrame:(CGRect)frame Text:(NSString *)textval Font:(UIFont *)textfont TruncateToWidth:(CGFloat)trsize;
- (void) drawTextWithFrame:(CGRect )frame Text:(NSString *)textval Font:(UIFont *)textfont Color:(UIColor *)color TruncateToWidth:(CGFloat)trsize;
- (void) drawTextWithFrame:(CGRect )frame Text:(NSString *)textval Font:(UIFont *)textfont TextAlignment:(NSTextAlignment)textalignment TruncateToWidth:(CGFloat)trsize;
- (void) drawLineWithFrame:(CGRect)frame LineWidth:(CGFloat)linewidth LineColor:(UIColor *)linecolor;
- (void) drawHeaderWithFrame:(CGRect)frame View:(UIView *)headerview;
- (void) drawImageWithFrame:(CGRect)frame ImagePath:(NSString *)imgpath;
- (void) drawImageWithFrame:(CGRect)frame Image:(UIImage *)img;
- (void) drawTextWithFrame:(CGRect )frame Text:(NSString *)textval Font:(UIFont *)textfont TextAlignment:(NSTextAlignment)textalignment IsUnderLine:(BOOL)isLine TruncateToWidth:(CGFloat)trsize;
- (void) drawTextWithFrame:(CGRect )frame Text:(NSString *)textval Font:(UIFont *)textfont TextAlignment:(NSTextAlignment)textalignment  Color:(UIColor *)clr IsUnderLine:(BOOL)isLine TruncateToWidth:(CGFloat)trsize;
-(void) drawRect:(CGRect)rect color:(UIColor *)clr;

- (NSMutableData *)finalizePDF;
- (void) drawTextWithFrameWithoutTruncate:(CGRect )frame Text:(NSString *)textval Font:(UIFont *)textfont TextAlignment:(NSTextAlignment)textalignment TruncateToWidth:(CGFloat)trsize;
@end
