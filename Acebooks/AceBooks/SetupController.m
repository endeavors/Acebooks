//
//  SetupController.m
//  AceBooks
//
//  Created by Gurkirat Singh on 3/12/15.
//  Copyright (c) 2015 AceBooks. All rights reserved.
//

#import "SetupController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "IMGActivityIndicator.h"

@interface SetupController ()
@property (weak, nonatomic) IBOutlet UIButton *facebookLogin;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UITextField *textfield;

@end

@implementation SetupController{
    BOOL emailNotCorrect;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.textfield.delegate = self;
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
    self.facebookLogin.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
   
}

- (IBAction)fbButtonPressed:(id)sender {

    [self doEmailValidation];
    if (!emailNotCorrect){
    [PFFacebookUtils logInWithPermissions:@[ @"public_profile"] block:^(PFUser *user, NSError *error) {
        [self.spinner stopAnimating]; 
        
        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                errorMessage = @"Unauthorized session. Can't read permissions from your Facebook profile.";
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Got it", nil];
            [alert show];
        } else {
            FBRequest *request = [FBRequest requestForMe];
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
               
                if (!error) {
                    NSDictionary *userData = (NSDictionary *)result;
                    PFUser * user = [PFUser currentUser];
                    NSString *facebookID = userData[@"id"];
                    if (facebookID) {
                        user[@"fbid"] = facebookID;
                    }
                    
                    NSString *name = userData[@"name"];
                    if (name) {
                        user.username = name;
                    }
                    user.email = [self.textfield.text lowercaseString];;
                    
                    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error){
                        if (!error){
                            [self dismissViewControllerAnimated:YES completion:nil];
                        }else{
                            NSString * errorString = [error userInfo][@"error"];
                            [self showAlertViewError:errorString];
                        }
                    }];
                
                } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                            isEqualToString: @"OAuthException"]) {
                    [self showAlertViewError:@"The facebook session was invalidated"];
                } else {
                    [self showAlertViewError:[error localizedDescription]];
                }
            }];

        }
    }];
        [self.spinner startAnimating];

    }
    
}



-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self doEmailValidation];
    
    return NO;
}
-(void)doEmailValidation
{
    NSString * input = [self.textfield.text lowercaseString];
    input = [input stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSRange whiteSpaceRange = [input rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    if (whiteSpaceRange.location != NSNotFound) {
        [self showAlertViewError:@"Invalid email."];
        emailNotCorrect = YES;
    }else{
        if ([input hasSuffix:@"@ucsd.edu"]){
            emailNotCorrect = NO;
            [self.textfield resignFirstResponder];
            
        }else{
            emailNotCorrect = YES;
            [self showAlertViewError:@"Invalid email."];
            
        }
    }
}
-(void)showAlertViewError:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [self.textfield resignFirstResponder];
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
