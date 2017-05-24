//
//  SignView.m
//  mSeller
//
//  Created by WCT iMac on 25/11/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "SignView.h"

@implementation SignView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];//[UIColor colorWithRed:210.0/255.0 green:214/255.0 blue:219/255.0 alpha:1.0];
        drawingPath = [[UIBezierPath alloc]init];
        drawingPath.lineCapStyle = kCGLineCapRound;
        drawingPath.miterLimit = 0;
        drawingPath.lineWidth = 2;
        drawingColor = [UIColor darkTextColor];
        
    }
    return self;
    }

- (void)drawRect:(CGRect)rect
{
    [drawingColor setStroke];
    [drawingPath strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[touches allObjects] objectAtIndex:0];
    [drawingPath moveToPoint:[touch locationInView:self]];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[touches allObjects] objectAtIndex:0];
    [drawingPath addLineToPoint:[touch locationInView:self]];
    [self setNeedsDisplay];
    //[kNSNotificationCenterpostNotificationName:DrawingSignNotification object:nil];
}



@end
