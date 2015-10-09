//
//  ViewController.m
//  AceBooks
//
//  Created by Gurkirat Singh on 1/17/15.
//  Copyright (c) 2015 AceBooks. All rights reserved.
//

#import <iAd/iAd.h>
#import <Parse/Parse.h>
#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"
#import "AppDelegate.h"
#import "MainPagerController.h"
#import "SecondPageController.h"
#import "BarcodeViewController.h"
#import "SetupController.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>

static NSString *fbid;

@interface ViewController ()
@end

static UIPageViewController *pageViewController;
static NSArray *viewControllerArray;
static SecondPageController *secondPageController;

@implementation ViewController{
    
    UILabel *speechLabelView;
    
    NSDictionary *witOutcome;
    BOOL bannerIsVisible;
    ADBannerView *adBanner;
}

- (void)_presentUserDetailsViewControllerAnimated:(BOOL)animated {
    SetupController *setupController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SetupController"];
    [self presentViewController:setupController animated:animated completion:NULL];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [SetupController class];
    
    
    [self addBackgroundViews];
    [self initializePageViewController];
    
}


-(void)requestFacebookID
{
    if (FBSession.activeSession.isOpen){
        FBRequest *request = [FBRequest requestForMe];
        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            
            if (!error) {
                NSDictionary *userData = (NSDictionary *)result;
                fbid = userData[@"id"];
                NSLog(@"fbid: %@ ", fbid);
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                [currentInstallation setObject:fbid forKey:@"fbid"];
                [currentInstallation saveInBackground];
            }else{
                [self showAlertView:@"Main Error" withMessage:[error localizedDescription]];
                
            }
        }];
    }else{
        NSLog(@"session is not active");
    }
    
}
+(NSString *)getFBID
{
    return fbid;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{

}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    adBanner = [[ADBannerView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 50)];
    adBanner.delegate = self;

    
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        NSLog(@"User is linked to Facebook");
        [self requestFacebookID];
    }else{
        NSLog(@"User not linked to Facebook");
        [self _presentUserDetailsViewControllerAnimated:YES];
    }
    
}

-(void)addBackgroundViews
{
    UIView *topview = [[UIView alloc]initWithFrame: CGRectMake(0, -SCREEN_HEIGHT * 0.035, SCREEN_WIDTH, SCREEN_HEIGHT * 0.11)];
    [topview setBackgroundColor:[UIColor colorWithRed:0.141 green:0.141 blue:0.141 alpha:1] ];
    [self.view addSubview:topview];
    
}

-(void)initializePageViewController
{
    pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    pageViewController.dataSource = self;
    pageViewController.delegate = self;
    
    MainPagerController *mainpageController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainPagerController"];
    secondPageController = [self.storyboard instantiateViewControllerWithIdentifier:@"SecondPageController"];
    
    BarcodeViewController *barcodeController = [self.storyboard instantiateViewControllerWithIdentifier:@"BarcodeViewController"];
    
    viewControllerArray = @[barcodeController,mainpageController,secondPageController];
    [pageViewController setViewControllers:@[mainpageController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50);
    
    [self addChildViewController:pageViewController];
    [self.view addSubview:pageViewController.view];
    [pageViewController didMoveToParentViewController:self];
    
}
#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    
    NSInteger index = [viewControllerArray indexOfObject:viewController];
    if (index <= 0) return nil;
    return viewControllerArray[index-1];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    
    NSInteger index = [viewControllerArray indexOfObject:viewController];
    if (index >= [viewControllerArray count]-1) return nil;
    return viewControllerArray[index+1];

}

+(void) goToSecondPageController
{
    [pageViewController setViewControllers:@[[viewControllerArray objectAtIndex:2]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];

}
+(void)goToMainPageController
{
    [pageViewController setViewControllers:@[[viewControllerArray objectAtIndex:1]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}
- (BOOL)prefersStatusBarHidden{
    return YES;
}



- (void)witDidGraspIntent:(NSArray *)outcomes messageId:(NSString *)messageId customData:(id) customData error:(NSError*)e {
    
    /*if (speechInput){
        if (speechInput.endRequestCalled){
            NSLog(@"endRequestCalled Boolean");
            speechInput.endRequestCalled = NO;
            return;
        }
        [speechInput getBackToMicrophone];
    }
    
    if (e) {
        NSLog(@"[Wit] error: %@", [e localizedDescription]);
        [self showAlertView:@"Error" withMessage:[e localizedDescription]];
        return;
    }
    
    NSDictionary *firstOutcome = [outcomes objectAtIndex:0];
    NSString *intent = [firstOutcome objectForKey:@"intent"];
    
    witOutcome = firstOutcome;
    [self actOnIntent:intent];*/
}
-(void)actOnIntent:(NSString *)intent
{
    if ([intent isEqualToString:@"book_quantity"]){
        [self bookQuantity];
    }

}
-(void)bookQuantity
{
   /* NSDictionary * entities = [witOutcome objectForKey:@"entities"];
    NSString *coursename = [([entities objectForKey:@"coursename"][0])objectForKey:@"value"];
    NSString *raw_coursename = coursename;
    coursename = [coursename stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSCharacterSet *notAllowedChars = [NSCharacterSet punctuationCharacterSet];
    coursename = [[coursename componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
    
    NSLog(@"coursename: %@", coursename);
    NSRange   searchedRange = NSMakeRange(0, [coursename length]);
    NSString *pattern = @"([A-Za-z]+)(\\d+.*)";
    
    @try{
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
        NSTextCheckingResult *match = [regex firstMatchInString:coursename options:0 range: searchedRange];
        coursename = [[[coursename substringWithRange:[match rangeAtIndex:1]] stringByAppendingString:@"."]stringByAppendingString:[coursename substringWithRange:[match rangeAtIndex:2]]];
        NSDictionary *coursedict = [textbookjson objectForKey:coursename];
        NSLog(@"mod coursename: %@", coursename);
        if (coursedict){
            if ([coursedict count] == 1){
                NSInteger txtbookCount = [[[coursedict objectForKey:([coursedict allKeys])[0]]objectForKey:@"textbooks"]count];
                NSLog(@"Numbe of books: %ld", (long)txtbookCount);
            }else{
                
            }
        }else{
            NSLog(@"Could not find coursename: %@", raw_coursename);
        }
    }@catch (NSException *e){
        NSLog(@"error is %@", e);
    }
    */
   /* NSDictionary * entities = [witOutcome objectForKey:@"entities"];
    if (![entities objectForKey:@"professor_name"]){
        
    }
    */
}


- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"Failed to retrieve ad");
    
    if (bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        banner.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 50); //CGRectOffset(banner.frame, 0, banner.frame.size.height);
        [UIView commitAnimations];
        
        bannerIsVisible = NO;
    }
}
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!bannerIsVisible)
    {
        if (adBanner.superview == nil)
        {
            [self.view addSubview:adBanner];
        }
        
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        banner.frame = CGRectMake(0, SCREEN_HEIGHT-50, SCREEN_WIDTH, 50); //CGRectOffset(banner.frame, 0, -banner.frame.size.height);
        [UIView commitAnimations];
        bannerIsVisible = YES;
    }
}


-(void)showAlertView:(NSString *)title withMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc {

}
@end
