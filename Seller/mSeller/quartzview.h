//
//  quartzview.h
//  quartz
//
//  Created by Faizan khan on 3/12/13.
//  Copyright (c) 2013 Faizan khan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface quartzview : UIView
{
}
@property(nonatomic,unsafe_unretained)CGFloat Red;
@property(nonatomic,unsafe_unretained)CGFloat Green;
@property(nonatomic,unsafe_unretained)CGFloat Blue;
@property(nonatomic,unsafe_unretained) UIColor* SelColor;

- (id)initWithFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame red:(CGFloat)red1 green:(CGFloat)green1 blue:(CGFloat)blue1;
- (id)initWithFrame:(CGRect)frame Color:(UIColor *)colorval;
-(void) color:(CGContextRef)ctx red:(CGFloat)red1 green:(CGFloat)green1 blue:(CGFloat)blue1; 

@end
