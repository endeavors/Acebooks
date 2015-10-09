//
//  SpeechInput.m
//  AceBooks
//
//  Created by Gurkirat Singh on 2/27/15.
//  Copyright (c) 2015 AceBooks. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SpeechInput.h"
#import "Wit.h"
#import "IMGActivityIndicator.h"
#import "ViewController.h"

@interface SpeechInput ()
@end

@implementation SpeechInput{
    UIButton* witButton;
    UIView * waveform_view;
    SCSiriWaveformView *waveformView;
    CADisplayLink *displaylink;
    IMGActivityIndicator *spinner;

}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
        
    }
    return self;
}

-(void)initialize
{

    
    CGRect rect = CGRectMake((SCREEN_WIDTH/2) - ((SCREEN_WIDTH * 0.25)/2), 0, SCREEN_WIDTH * 0.25, SCREEN_WIDTH * 0.25);
    
    witButton = [[UIButton alloc] initWithFrame:rect];
    [witButton setBackgroundImage:[UIImage imageNamed:@"mic-icon.png"] forState:UIControlStateNormal];
    [witButton addTarget:self action:@selector(speechAnimation:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:witButton];
    

    spinner = [[IMGActivityIndicator alloc] initWithFrame:rect];
    [spinner setHidden:YES];
    UITapGestureRecognizer *cancelPress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelPressed)];
    [spinner addGestureRecognizer:cancelPress];
    [self addSubview:spinner];
    [spinner createLayers];
    CGAffineTransform trans = CGAffineTransformScale(spinner.transform, 0.01, 0.01);
    spinner.transform = trans;

    waveformView = [[SCSiriWaveformView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGHT * 0.11)];
    waveform_view = [[UIView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGHT * 0.11)];
    
    displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
    [displaylink setPaused:YES];
    
    [displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    [self addWaveFormObject];
}

- (void)updateMeters
{
    CGFloat normalizedValue = pow (0, 0 / 20);
    [waveformView updateWithLevel:normalizedValue];
}

-(void)addWaveFormObject
{
    
    [waveform_view addSubview:waveformView];
    [waveformView setBackgroundColor:[UIColor clearColor]];
    
    [waveform_view setHidden:YES];
    [waveform_view setUserInteractionEnabled:NO];
    [self addSubview:waveform_view];
    
    CGAffineTransform wave_trans = CGAffineTransformScale(waveform_view.transform, 0.01, 0.01);
    waveform_view.transform = wave_trans;
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [waveform_view addGestureRecognizer:singleFingerTap];
 
}
-(void)cancelPressed
{
    [[Wit sharedInstance]stop];
    
    self.endRequestCalled = YES;
    
    [UIView animateWithDuration:0.20 delay:0.0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         spinner.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.01, 0.01);
                         witButton.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                         
                     }
                     completion:^(BOOL finished) {
                         if (finished){
                             witButton.hidden = NO;
                             [spinner invalidateTimer];
                             [spinner setHidden:YES];
                         }
                         
                     }];
    
}

-(void)getBackToMicrophone
{
    
    [UIView animateWithDuration:0.20 delay:0.0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         spinner.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.01, 0.01);
                         witButton.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                         
                     }
                     completion:^(BOOL finished) {
                         if (finished){
                             witButton.hidden = NO;
                             [spinner invalidateTimer];
                             [spinner setHidden:YES];
                         }
                         
                     }];
    
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    [[Wit sharedInstance] toggleCaptureVoiceIntent:witButton];
    [spinner setHidden:NO];
    [spinner validateTimer];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         waveform_view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.01, 0.01);
                         spinner.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                         
                     }
                     completion:^(BOOL finished) {
                         if (finished){
                             [waveform_view setUserInteractionEnabled:NO];
                             [waveform_view setHidden:YES];
                             [displaylink setPaused:YES];
                         }
                         
                     }];
    
    
}

-(IBAction)speechAnimation:(id)sender
{
    
    [displaylink setPaused:NO];
    NSLog(@"yes");
    [[Wit sharedInstance] toggleCaptureVoiceIntent:witButton];
    [waveform_view setHidden:NO];
    [UIView animateWithDuration:0.20 delay:0.0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         witButton.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.01, 0.01);
                         waveform_view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                         
                     }
                     completion:^(BOOL finished) {
                         if (finished){
                             [witButton setHidden:YES];
                             [waveform_view setUserInteractionEnabled:YES];
                             
                         }
                         
                     }];
    
}

-(void)dealloc
{
    [displaylink invalidate];
}
@end