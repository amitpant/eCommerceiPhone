//
//  LLACircularProgressView.m
//  LLACircularProgressView
//
//  Created by Lukas Lipka on 26/10/13.
//  Copyright (c) 2013 Lukas Lipka. All rights reserved.
//

#import "LLACircularProgressView.h"
#import <QuartzCore/QuartzCore.h>
#import <Availability.h>

@interface LLACircularProgressView ()

@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) UILabel *lblProgress;
@end

@implementation LLACircularProgressView

@synthesize progressTintColor = _progressTintColor;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.contentMode = UIViewContentModeRedraw;
    self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.9];

    _lblProgress = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - (self.frame.size.width-20))/2, (self.frame.size.height - (self.frame.size.height-20))/2, self.frame.size.width-20, self.frame.size.height-20)];
    _lblProgress.textColor = self.tintColor;
    _lblProgress.font = [UIFont systemFontOfSize:15.0];
    _lblProgress.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_lblProgress];

    _progressTintColor = [UIColor blackColor];
    
    _progressLayer = [[CAShapeLayer alloc] init];
    _progressLayer.strokeColor =  self.progressTintColor.CGColor; //[UIColor whiteColor].CGColor;//
    _progressLayer.strokeEnd = 0;
    _progressLayer.fillColor =  nil;//[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.6].CGColor;

    _progressLayer.lineWidth = 3;
    [self.layer addSublayer:_progressLayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame=self.bounds;
    self.progressLayer.frame = frame;

    _lblProgress.frame = CGRectMake((frame.size.width - (frame.size.width-20))/2, (frame.size.height - (frame.size.height-20))/2, frame.size.width-20, frame.size.height-20);

    [self updatePath];
}

- (void)drawRect:(CGRect)rect {

//    CGRect frame=self.bounds;
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(ctx, self.progressTintColor.CGColor);
    CGContextSetStrokeColorWithColor(ctx, self.progressTintColor.CGColor);
//    /CGContextStrokeEllipseInRect(ctx, CGRectInset(self.bounds, 10, 10));

//    CGRect stopRect;
//    stopRect.origin.x = CGRectGetMidX(frame) - frame.size.width / 8;
//    stopRect.origin.y = CGRectGetMidY(frame) - frame.size.height / 8;
//    stopRect.size.width = frame.size.width / 4;
//    stopRect.size.height = frame.size.height / 4;
//    CGContextFillRect(ctx, CGRectIntegral(stopRect));
}

#pragma mark - Accessors

- (void)setProgress:(float)progress {
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(float)progress animated:(BOOL)animated {
    if (progress > 0) {
        if (animated) {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            animation.fromValue = self.progress == 0 ? @0 : nil;
            animation.toValue = [NSNumber numberWithFloat:progress];
            animation.duration = 1;
            self.progressLayer.strokeEnd = progress;
            [self.progressLayer addAnimation:animation forKey:@"animation"];
        } else {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            self.progressLayer.strokeEnd = progress;
            [CATransaction commit];
        }
    } else {
        self.progressLayer.strokeEnd = 0.0f;
        [self.progressLayer removeAnimationForKey:@"animation"];
    }
    
    _progress = progress;

    _lblProgress.text = [NSString stringWithFormat:@"%li %%",(long)(progress * 100)];
}

- (UIColor *)progressTintColor {
#ifdef __IPHONE_7_0
    if ([self respondsToSelector:@selector(tintColor)]) {
        return self.tintColor;
    }
#endif
    return _progressTintColor;
}

- (void)setProgressTintColor:(UIColor *)progressTintColor {
#ifdef __IPHONE_7_0
    if ([self respondsToSelector:@selector(setTintColor:)]) {
        self.tintColor = progressTintColor;
        return;
    }
#endif
    _progressTintColor = progressTintColor;
    self.progressLayer.strokeColor = progressTintColor.CGColor;
    [self setNeedsDisplay];
}

#pragma mark - Other

#ifdef __IPHONE_7_0
- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    self.progressLayer.strokeColor = self.tintColor.CGColor;
    [self setNeedsDisplay];
}
#endif

#pragma mark - Private

- (void)updatePath {
    CGRect frame=self.bounds;
//    frame.size.width=frame.size.width/2;
//    frame.size.height=frame.size.height/2;
//
//    _progressLayer.lineWidth = frame.size.width/2;

    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.progressLayer.path = [UIBezierPath bezierPathWithArcCenter:center radius:frame.size.width / 2 - 2 startAngle:-M_PI_2 endAngle:-M_PI_2 + 2 * M_PI clockwise:YES].CGPath;
}

@end
