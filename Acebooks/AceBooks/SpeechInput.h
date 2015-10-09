//
//  SpeechInput.h
//  AceBooks
//
//  Created by Gurkirat Singh on 2/27/15.
//  Copyright (c) 2015 AceBooks. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "SCSiriWaveformView.h"

@interface SpeechInput : UIView

@property BOOL endRequestCalled;
-(void)getBackToMicrophone;
@end