//
//  quartzview.m
//  quartz
//
//  Created by Faizan khan on 3/12/13.
//  Copyright (c) 2013 Faizan khan. All rights reserved.
//

#import "quartzview.h"

@implementation quartzview
@synthesize Green;
@synthesize Red;
@synthesize Blue;
- (id)initWithFrame:(CGRect)frame red:(CGFloat)red1 green:(CGFloat)green1 blue:(CGFloat)blue1
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
		self.opaque = YES;
		self.clearsContextBeforeDrawing = YES;
        Red = red1;
        Green = green1;
        Blue = blue1;
    
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = YES;
        self.clearsContextBeforeDrawing = YES;
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame Color:(UIColor *)colorval
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
		self.opaque = YES;
		self.clearsContextBeforeDrawing = YES;
        self.SelColor = colorval;
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)drawRect:(CGRect)rect
{
	
    [self drawInContext:UIGraphicsGetCurrentContext() drawrect:rect];


}


-(void)drawInContext:(CGContextRef)ctx drawrect:(CGRect)rect
{

    CGContextBeginPath(ctx);
    CGContextMoveToPoint   (ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));  // top left
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect));  // mid right
    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect));  // bottom left
    CGContextClosePath(ctx);
    
    if(self.SelColor)
        CGContextSetFillColorWithColor(ctx, self.SelColor.CGColor);
    else
        CGContextSetRGBFillColor(ctx, Red, Green, Blue, 1);
   // [self color:ctx red:Red green:Green blue:Blue];
//    CGContextSetRGBFillColor(ctx, Red, Green, Blue, 1);
   
    // [self color:ctx red:Red green:Green blue:Blue];
    CGContextFillPath(ctx);

}



-(void) color:(CGContextRef)ctx red:(CGFloat)red1 green:(CGFloat)green1 blue:(CGFloat)blue1
{
  CGContextSetRGBFillColor(ctx, Red, Green, Blue, 1);

}


/*-(void)drawInContext:(CGContextRef)context
{
	// Drawing with a white stroke color
	CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
	// And draw with a blue fill color
	CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
	// Draw them with a 2.0 stroke width so they are a bit more visible.
	CGContextSetLineWidth(context, 2.0);
	
	// Add an ellipse circumscribed in the given rect to the current path, then stroke it
	CGContextAddEllipseInRect(context, CGRectMake(30.0, 30.0, 60.0, 60.0));
	CGContextStrokePath(context);
	
	// Stroke ellipse convenience that is equivalent to AddEllipseInRect(); StrokePath();
	CGContextStrokeEllipseInRect(context, CGRectMake(30.0, 120.0, 60.0, 60.0));
	
	// Fill rect convenience equivalent to AddEllipseInRect(); FillPath();
	CGContextFillEllipseInRect(context, CGRectMake(30.0, 210.0, 60.0, 60.0));
	
	// Stroke 2 seperate arcs
	CGContextAddArc(context, 150.0, 60.0, 30.0, 0.0, M_PI/2.0, false);
	CGContextStrokePath(context);
	CGContextAddArc(context, 150.0, 60.0, 30.0, 3.0*M_PI/2.0, M_PI, true);
	CGContextStrokePath(context);
    
	// Stroke 2 arcs together going opposite directions.
	CGContextAddArc(context, 150.0, 150.0, 30.0, 0.0, M_PI/2.0, false);
	CGContextAddArc(context, 150.0, 150.0, 30.0, 3.0*M_PI/2.0, M_PI, true);
	CGContextStrokePath(context);
    
	// Stroke 2 arcs together going the same direction..
	CGContextAddArc(context, 150.0, 240.0, 30.0, 0.0, M_PI/2.0, false);
	CGContextAddArc(context, 150.0, 240.0, 30.0, M_PI, 3.0*M_PI/2.0, false);
	CGContextStrokePath(context);
	
	// Stroke an arc using AddArcToPoint
	CGPoint p[3] =
	{
		CGPointMake(210.0, 30.0),
		CGPointMake(210.0, 60.0),
		CGPointMake(240.0, 60.0),
	};
	CGContextMoveToPoint(context, p[0].x, p[0].y);
	CGContextAddArcToPoint(context, p[1].x, p[1].y, p[2].x, p[2].y, 30.0);
	CGContextStrokePath(context);
	
	// Show the two segments that are used to determine the tangent lines to draw the arc.
	CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
	CGContextAddLines(context, p, sizeof(p)/sizeof(p[0]));
	CGContextStrokePath(context);
	
	// As a bonus, we'll combine arcs to create a round rectangle!
	
	// Drawing with a white stroke color
	CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    
	// If you were making this as a routine, you would probably accept a rectangle
	// that defines its bounds, and a radius reflecting the "rounded-ness" of the rectangle.
	CGRect rrect = CGRectMake(210.0, 90.0, 60.0, 60.0);
	CGFloat radius = 10.0;
	// NOTE: At this point you may want to verify that your radius is no more than half
	// the width and height of your rectangle, as this technique degenerates for those cases.
	
	// In order to draw a rounded rectangle, we will take advantage of the fact that
	// CGContextAddArcToPoint will draw straight lines past the start and end of the arc
	// in order to create the path from the current position and the destination position.
	
	// In order to create the 4 arcs correctly, we need to know the min, mid and max positions
	// on the x and y lengths of the given rectangle.
	CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
	CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
	
	// Next, we will go around the rectangle in the order given by the figure below.
	//       minx    midx    maxx
	// miny    2       3       4
	// midy   1 9              5
	// maxy    8       7       6
	// Which gives us a coincident start and end point, which is incidental to this technique, but still doesn't
	// form a closed path, so we still need to close the path to connect the ends correctly.
	// Thus we start by moving to point 1, then adding arcs through each pair of points that follows.
	// You could use a similar tecgnique to create any shape with rounded corners.
	
	// Start at 1
	CGContextMoveToPoint(context, minx, midy);
	// Add an arc through 2 to 3
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	// Add an arc through 4 to 5
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	// Add an arc through 6 to 7
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	// Add an arc through 8 to 9
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	// Close the path
	CGContextClosePath(context);
	// Fill & stroke the path
	CGContextDrawPath(context, kCGPathFillStroke);
}*/



@end
