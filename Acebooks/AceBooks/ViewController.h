//
//  ViewController.h
//  AceBooks
//
//  Created by Gurkirat Singh on 1/17/15.
//  Copyright (c) 2015 AceBooks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "Wit.h"
#import "MainPagerController.h"

#define SCREEN_WIDTH        [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT       [[UIScreen mainScreen] bounds].size.height

@interface ViewController : UIViewController <WitDelegate, ADBannerViewDelegate,UIPageViewControllerDataSource, UIPageViewControllerDelegate>

+(void)goToSecondPageController;
+(void)goToMainPageController;
+(NSString *)getFBID;
@end

