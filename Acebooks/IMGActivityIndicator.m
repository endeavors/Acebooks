//
//  IMGActivityIndicator.m
//  IMGActivityIndicator
//
//  Created by Maijid Moujaled on 11/12/14.
//  Copyright (c) 2014 Maijid Moujaled. All rights reserved.
//

#import "IMGActivityIndicator.h"

static const CGFloat IMGCircleLineWidth = 3.50; //1.65
static const CGFloat IMGDuration = 1.4; // Duration for every stroke cycle

// Helper Function to get center of CGRect
CGPoint CGRectGetCenter(CGRect rect)
{
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

@interface IMGActivityIndicator ()

@property (nonatomic, strong) NSMutableArray *shapeLayers;
@property (nonatomic, strong) NSArray *strokeTimings;
@property (nonatomic, strong) CADisplayLink *timer;

@end

@implementation IMGActivityIndicator{
    int intialCount;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _strokeColor = [UIColor whiteColor];
        //[self createLayers];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _strokeColor = [UIColor whiteColor];
        [self createLayers];
    }
    return self;
}

- (void)createLayers
{
    intialCount = 1;
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 ,CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    
    self.shapeLayers = [NSMutableArray new];
    
    // Draw the middle dot.
    UIBezierPath *dot =[UIBezierPath bezierPathWithArcCenter:CGRectGetCenter(backgroundView.frame)
                                                      radius:IMGCircleLineWidth + 8
                                                  startAngle:-3.5 * M_PI
                                                    endAngle:1.5 * M_PI
                                                   clockwise:YES];
    
    CAShapeLayer *dotLayer = [CAShapeLayer layer];
    dotLayer.path = dot.CGPath;
    dotLayer.fillColor = [UIColor colorWithRed:0.027 green:0.482 blue:0.741 alpha:1].CGColor;
    [backgroundView.layer addSublayer:dotLayer];
    
    self.strokeTimings = @[@0.35, @0.50, @0.65, @0.80, @0.95];
   // NSArray *radii = @[@40, @34, @26, @20, @15];
    NSArray *radii = @[@44, @38, @30, @24, @19];
    
    // Draw our looping stroke lines
    for (int i = 0; i < 5; i++) {
        CAShapeLayer *circleLayer = [CAShapeLayer layer];
        CGFloat radius = [radii[i] floatValue];
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGRectGetCenter(backgroundView.frame)
                                                            radius:radius
                                                        startAngle:-0.5 * M_PI
                                                          endAngle:1.5 * M_PI
                                                         clockwise:YES];
        
        circleLayer.path = path.CGPath;
        circleLayer.strokeColor = self.strokeColor.CGColor;
        circleLayer.lineWidth = IMGCircleLineWidth;
        circleLayer.fillColor = nil;
        circleLayer.contentsScale = [UIScreen mainScreen].scale;
        
        [self.shapeLayers addObject:circleLayer];
        [backgroundView.layer addSublayer:circleLayer];
    }
    
    [self addSubview:backgroundView];
   // [self loopAnimations];
    
    // Use a CADisplayLink timer to fire every time we need to reloop both stroke start and end animation.
   // [self validateTimer];
    self.timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(loopAnimations)];
    self.timer.frameInterval = 60 * 2 * IMGDuration;
    [self.timer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}
-(void)validateTimer
{
    [self.timer setPaused:NO];
    NSLog(@"validating");
}
-(void)invalidateTimer
{
    [self.timer setPaused:YES];
    NSLog(@"not validating");
    //[self.timer removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}
/*
 *For every loop (in 3.33s) we add both our strokeStart and strokeEnd animations for the next looping cycle.
 */
- (void)loopAnimations
{
    if (intialCount == 1){
        [self invalidateTimer];
        intialCount = 2;
    }else{
    for (int i = 0; i < 5; i++) {
        
        CAShapeLayer *circleLayer = self.shapeLayers[i];
        CGFloat timeDuration =  [self.strokeTimings[i] floatValue];
        
        CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
        strokeStartAnimation.fromValue = @0;
        strokeStartAnimation.toValue = @1.08;
        strokeStartAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        strokeStartAnimation.beginTime = CACurrentMediaTime() + timeDuration;
        strokeStartAnimation.duration = IMGDuration;
        [circleLayer addAnimation:strokeStartAnimation forKey:nil];
        
        CABasicAnimation *strokEndAnimation  = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        strokEndAnimation.fromValue = @0;
        strokEndAnimation.toValue = @1.08;
        strokEndAnimation.duration = IMGDuration;
        strokEndAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        strokEndAnimation.beginTime = CACurrentMediaTime() + timeDuration + IMGDuration;
        [circleLayer addAnimation:strokEndAnimation forKey:nil];
    }
    }
}

@end
