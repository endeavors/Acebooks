//
//  AppDelegate.h
//  AceBooks
//
//  Created by Gurkirat Singh on 1/17/15.
//  Copyright (c) 2015 AceBooks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

#define kAppDelegate (AppDelegate *)[[UIApplication sharedApplication] delegate]

@end

