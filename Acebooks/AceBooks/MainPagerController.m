//
//  MainPagerController.m
//  AceBooks
//
//  Created by Gurkirat Singh on 3/3/15.
//  Copyright (c) 2015 AceBooks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainPagerController.h"
#import "ViewController.h"
#import "CollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "CardTableViewCell.h"
#import "M13ProgressHUD.h"
#import "M13ProgressViewRing.h"
#import "AppDelegate.h"
#import "BuyBooksCollectionView.h"
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>
#import <Bolts/Bolts.h>

@interface MainPagerController ()

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *nilOutputLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *topCollectionView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundLogo;

@end

static NSString * const reuseIdentifier = @"CollectionCell";
static NSDictionary *textbookjson;
static NSDictionary * isbnDataJson;

@implementation MainPagerController{
    UISearchBar *searchBar;
    UIButton * btn_settings;
    UIButton * btn_search;
    UINavigationItem *nav_title;
    UIView *professorListView;
    UILabel * profInstruction;
    NSMutableDictionary *profDict;
    NSArray *profArray;
    NSArray *txtbookArray;
    M13ProgressHUD *HUD;
    CardTableViewCell *fakeCell;
    NSIndexPath *selectedItemIndexPath;
    NSArray *topCollViewItemArray;
    NSDictionary *tempItemDict;
    NSMutableArray *pickerData;
    UIView *makeOfferBackground;
    UILabel *setPriceLabel;
    UIRefreshControl *refreshControl;
    UILabel *noBooksLabel;
    PFObject *makeOfferPFObject;
    BOOL needToDownloadJSON;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    textbookjson = nil;
    selectedItemIndexPath = [self indexPathForFirstRowItem];
    self.backgroundLogo.frame = CGRectMake(0, (SCREEN_HEIGHT -SCREEN_WIDTH)/2, SCREEN_WIDTH, SCREEN_WIDTH);
    
    needToDownloadJSON = YES;
    [self createJsonFile];
    
    profDict = [[NSMutableDictionary alloc]init];
    profArray =  [[NSArray alloc]init];
    topCollViewItemArray = [[NSArray alloc]init];
    [self configCollectionView];
    [self configTableView];
    [self addToolbar];
    /*for (NSString *familyName in [UIFont familyNames]){
        NSLog(@"Family name: %@", familyName);
        for (NSString *fontName in [UIFont fontNamesForFamilyName:familyName]) {
            NSLog(@"--Font name: %@", fontName);
        }
    }*/
    
    pickerData = [[NSMutableArray alloc]init];
    for (int i = 1; i <= 500; i++){
        [pickerData addObject:[NSString stringWithFormat:@"$%d",i]];
    }

    fakeCell = [self.tableView dequeueReusableCellWithIdentifier:@"TableCell"];
    [self createMakeOfferPopupView];
    [self initHUD];
   
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (needToDownloadJSON)
        [self showHUD];
}
-(void)initHUD
{
    M13ProgressViewRing * progRing =[[M13ProgressViewRing alloc] init];
    HUD = [[M13ProgressHUD alloc] initWithProgressView:progRing];
    HUD.progressViewSize = CGSizeMake(SCREEN_WIDTH * 0.1875, SCREEN_WIDTH * 0.1875);
    HUD.animationPoint = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
    [progRing setBackgroundRingWidth:5];
    [HUD setIndeterminate:YES];
    [self.view addSubview:HUD];
}
-(void)showHUD
{
    HUD.status = @"Loading";
    [HUD show:YES];
}
-(void)hideHUD:(M13ProgressViewAction)action
{
    [HUD hide:YES];
    [HUD performAction:action animated:YES];
}


-(void)addToolbar
{
    
    UINavigationBar *navbar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, -SCREEN_HEIGHT * 0.035, SCREEN_WIDTH, SCREEN_HEIGHT * 0.11)];
    [navbar setBarTintColor:[UIColor colorWithRed:0.141 green:0.141 blue:0.141 alpha:1] ];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, [UIFont fontWithName:@"BankGothicBold" size:28.0f],NSFontAttributeName, nil]];
    
    nav_title = [[UINavigationItem alloc]init];
    
    UIImageView * imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"acebooks1.png"]];
    nav_title.titleView = imgView;
    nav_title.titleView.frame = CGRectMake(0,0,SCREEN_WIDTH * 0.70, SCREEN_WIDTH * 0.10);
    
    btn_settings = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img_settings = [UIImage imageNamed:@"menu.png"];
    [btn_settings setImage:img_settings forState:UIControlStateNormal];
    btn_settings.frame = CGRectMake(0, SCREEN_WIDTH - ((SCREEN_WIDTH * 0.08)+20), SCREEN_WIDTH * 0.09, SCREEN_WIDTH * 0.09);
    [btn_settings setShowsTouchWhenHighlighted:YES];
    [btn_settings addTarget:self action:@selector(settingsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    nav_title.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn_settings];
    
    
    btn_search = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img_search = [UIImage imageNamed:@"search.png"];
    [btn_search setImage:img_search forState:UIControlStateNormal];
    btn_search.frame = CGRectMake(0, 10, SCREEN_WIDTH * 0.07, SCREEN_WIDTH * 0.07);
    [btn_search addTarget:self action:@selector(toggleSearch) forControlEvents:UIControlEventTouchUpInside];
    [btn_search setShowsTouchWhenHighlighted:YES];
    nav_title.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn_search];
    
    [navbar setItems:@[nav_title]];
    [self.view addSubview:navbar];
    
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(SCREEN_WIDTH *0.02, 10 ,0, SCREEN_HEIGHT * 0.06)];
    searchBar.delegate = self;
    [searchBar setShowsCancelButton:YES animated:YES];
    [searchBar setBarTintColor:[UIColor whiteColor]];
    [searchBar setTintColor:[UIColor whiteColor]];
    searchBar.placeholder = @"Coursename (ex: CSE 12)";
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    searchBar.keyboardAppearance = UIKeyboardAppearanceDark;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searchBar.hidden = YES;
    [self.view addSubview: searchBar];
    
}
-(void)toggleSearch {
    btn_settings.hidden = YES;
    btn_search.hidden = YES;
    nav_title.titleView.hidden = YES;
    self.backgroundLogo.alpha = 1;
    
    float height = searchBar.frame.size.height;
    [searchBar becomeFirstResponder];
    if ([searchBar isHidden]){
        // if search bar was hidden then make it visible
        searchBar.hidden = NO;
        [UIView animateWithDuration:0.2 delay: 0.0 options: UIViewAnimationOptionCurveEaseIn animations:^{
            
            searchBar.frame = CGRectMake(searchBar.frame.origin.x,searchBar.frame.origin.y, SCREEN_WIDTH * 0.98, height);
        } completion:^(BOOL finished) {
            
        }];
        
        if (![self.tableView isHidden]){
            [self animateDownBooksTableView];
        }
        if (![self.collectionView isHidden])
            [self animateDownProfCollectionView];
        if (![self.nilOutputLabel isHidden])
            self.nilOutputLabel.hidden = YES;
    }
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchbar
{
    [searchbar resignFirstResponder];
    [self retractSearchBar];
    
}
-(void)retractSearchBar
{
    [UIView animateWithDuration:0.2 delay: 0.0 options: UIViewAnimationOptionLayoutSubviews animations:^{
        
        searchBar.frame = CGRectMake(searchBar.frame.origin.x , searchBar.frame.origin.y , 0, searchBar.frame.size.height);
    } completion:^(BOOL finished) {
        btn_settings.hidden = NO;
        btn_search.hidden = NO;
        nav_title.titleView.hidden = NO;
        searchBar.hidden = YES;
    }];
}

-(void)createJsonFile
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),^{
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *answer = [defaults objectForKey:@"dirExists"];
        
        NSString *appSupportDir = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
        NSString *directory = [appSupportDir stringByAppendingPathComponent:@"MyData"];
        
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:[NSDate date]];
        
        if (answer == nil){
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            if ([fileManager fileExistsAtPath:directory] == NO) {
                NSError *error = nil;
                
                if ([fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error]){
                    
                    NSURL *url = [NSURL fileURLWithPath:directory];
                    [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
                    [defaults setObject:@"YES" forKey:@"dirExists"];
                }
            }
        }
        NSString *textbookJsonpath = [[NSString alloc] initWithString: [directory stringByAppendingPathComponent:@"textbook.json"]];
        NSString *isbnJsonpath = [[NSString alloc] initWithString: [directory stringByAppendingPathComponent:@"isbnData.json"]];
        
        //make sure file is not updated twice in a single day
        NSInteger lastdate = [defaults integerForKey:@"LastUpdated"];
        
        PFQuery *query = [PFQuery queryWithClassName:@"EmergencyUpdate"];
        [query getObjectInBackgroundWithId:@"i0eJs18iii" block:^(PFObject *object, NSError *error) {
            
            if (!error){
                NSLog(@"object: %@", object);
                BOOL emergencyUpdate = [object[@"requireUpdate"] boolValue];
                NSLog(@"emergency: %d", emergencyUpdate);
                
                if (emergencyUpdate){
                    NSLog(@"emergency update");
                    [self getTextbookDataFromParse:textbookJsonpath withISBNPath:isbnJsonpath withDate:components];
                }else{
                    NSLog(@"not emergency update");
                    
                    //don't allow an update twice a day
                    if ( lastdate == 0 || lastdate != [components day]){
                        
                        
                        NSLog(@"file: %@",[[NSFileManager defaultManager] fileExistsAtPath:textbookJsonpath]? @"YES":@"NO" );
                        
                        //every odd date, json file is updated
                        if ([components day] % 2 != 0 || ![[NSFileManager defaultManager] fileExistsAtPath:textbookJsonpath] || ![[NSFileManager defaultManager] fileExistsAtPath:isbnJsonpath]){
                            NSLog(@"got in");
                            
                            [self getTextbookDataFromParse:textbookJsonpath withISBNPath:isbnJsonpath withDate:components];
                            
                        }
                    }
                }
                [self fillJsonDicts:textbookJsonpath withISBNPath:isbnJsonpath];
                [self hideHUD:M13ProgressViewActionSuccess];
                needToDownloadJSON = NO;
            }else{
                [self hideHUD:M13ProgressViewActionFailure];
                [self showAlertView:@"Error" withMessage:@"Cannot query the database. Try restarting the application."];
            }
            
            
        }];
        
        
    });
}

-(void)getTextbookDataFromParse:(NSString*)textbookJsonPath withISBNPath:(NSString*)isbnJsonPath withDate:(NSDateComponents *)components
{
    @try{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData * textbookJsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://acebooks.parseapp.com/textbookInfo.json"]];
        [textbookJsonData writeToFile:textbookJsonPath atomically:YES];
        
        NSData * isbnJsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://acebooks.parseapp.com/isbnData.json"]];
        [isbnJsonData writeToFile:isbnJsonPath atomically:YES];
        
        [defaults setInteger:[components day] forKey:@"LastUpdated"];
        [defaults synchronize];
        NSLog(@"getting new json file");
    }@catch(NSException *exception){
        [self showAlertView:@"Error" withMessage:[exception description]];
    }

}
-(void)fillJsonDicts:(NSString*)textbookJsonPath withISBNPath:(NSString*)isbnJsonPath
{
    @try {
        NSLog(@"file already exists");
        if ([[NSFileManager defaultManager] fileExistsAtPath:textbookJsonPath]){
            NSString *jsonString = [[NSString alloc] initWithContentsOfFile:textbookJsonPath encoding:NSUTF8StringEncoding error:nil];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
            textbookjson = json;
            
        }
        if ([[NSFileManager defaultManager] fileExistsAtPath:isbnJsonPath]){
            NSString *jsonString = [[NSString alloc] initWithContentsOfFile:isbnJsonPath encoding:NSUTF8StringEncoding error:nil];
            NSDictionary *isbnJson = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
            isbnDataJson = isbnJson;
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"Error retrieving json file: %@", exception);
        [self showAlertView:@"Error" withMessage:@"Failure in retrieving data. Please restart application."];
        
    }
}

+(NSDictionary *)getISBNData
{
    return isbnDataJson;
}
+(NSDictionary *)getTextbookJson
{
    return textbookjson;
}
/*-----------------------------UITableView------------------------------------*/

-(void)configTableView
{
    self.tableView.separatorColor = [UIColor clearColor];
    [self.tableView setFrame:CGRectMake(0,(-SCREEN_HEIGHT * 0.035)+(SCREEN_HEIGHT * 0.12),SCREEN_WIDTH,SCREEN_HEIGHT - ((-SCREEN_HEIGHT * 0.035)+(SCREEN_HEIGHT * 0.12)+50) )];
    CGAffineTransform trans = CGAffineTransformScale(self.tableView.transform, 0.01, 0.01);
    self.tableView.transform = trans;

    self.tableView.hidden = YES;
    UIImageView *topTableViewLogo = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - (SCREEN_HEIGHT *0.352))/2, (-SCREEN_HEIGHT *0.352)+20, SCREEN_HEIGHT * 0.352, SCREEN_HEIGHT * 0.352)];
    topTableViewLogo.image = [UIImage imageNamed:@"backgroundLogo.png"];
    [self.tableView addSubview:topTableViewLogo];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refreshControlStatus)
             forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    UICollectionViewFlowLayout *booksFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    booksFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.topCollectionView setFrame:CGRectMake(0,0,SCREEN_WIDTH, TOP_MARGIN + (IMG_HEIGHT * 0.85) + (SCREEN_HEIGHT *0.12))];
    [self.topCollectionView setCollectionViewLayout:booksFlowLayout];
    self.topCollectionView.dataSource = self;
    self.topCollectionView.delegate = self;
    self.topCollectionView.tag = 2;

}

-(void)refreshControlStatus
{
    [self getBooksforSelectedBook:[topCollViewItemArray objectAtIndex:selectedItemIndexPath.item][@"isbn"]];
}
#pragma mark - Table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try
    {
        NSDictionary * eachIndex = [txtbookArray objectAtIndex:indexPath.section];
        
        fakeCell.title.text = [eachIndex objectForKey:@"title"];
        fakeCell.author.text =[eachIndex objectForKey:@"author"];
        fakeCell.price.text = [NSString stringWithFormat:@"$%@",@"43"];
        fakeCell.conditionLabel.text = @"Minor Wear";
        NSLog(@"height called");
        [fakeCell layoutSubviews];
        
        return fakeCell.cellHeight;
    }
    
    @catch (NSException *e)
    {
        NSLog(@"Table Row Height Exception: %@", e);
        return 200.0f; //average height for a row
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (textbookjson == nil){
        return 0;
    }
    return [txtbookArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    [view setBackgroundColor:[UIColor clearColor]];
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    [view setBackgroundColor:[UIColor clearColor]];
    return view;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (textbookjson == nil) return nil;
    
    CardTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"TableCell"];

    cell.buynow.tag = indexPath.section;
    [cell.buynow addTarget:self action:@selector(buyNowPressed:)forControlEvents:UIControlEventTouchUpInside];
    cell.makeoffer.tag = indexPath.section;
    [cell.makeoffer addTarget:self action:@selector(makeOfferPressed:)forControlEvents:UIControlEventTouchUpInside];
    
    NSDictionary * eachIndex = [txtbookArray objectAtIndex:indexPath.section];
    
    if (ICLICKER_ISBN == [[eachIndex objectForKey:@"isbn"]integerValue]){
        [cell.imgView sd_setImageWithURL:nil
                        placeholderImage:[UIImage imageNamed:@"iclicker2.png"]];
    }else{
        NSString *imgurl = [eachIndex objectForKey:@"image_url"];
        if (![imgurl isEqualToString: @"null"]){
            [cell.imgView sd_setImageWithURL:[NSURL URLWithString:imgurl]
                            placeholderImage:[UIImage imageNamed:@"noimagepl.png"]];
        }else{
            [cell.imgView sd_setImageWithURL:nil
                            placeholderImage:[UIImage imageNamed:@"noimagepl.png"]];
        }

    }
    
    cell.title.text = [eachIndex objectForKey:@"title"];
    cell.author.text = [eachIndex objectForKey:@"author"];
    cell.conditionLabel.text = [eachIndex objectForKey:@"condition"];
    NSLog(@"txtbook array: %@", txtbookArray);
    
    NSNumber *price = [eachIndex objectForKey:@"price"];
    if ([price isEqual:[NSNumber numberWithInt:0]]){
        cell.price.text = @"Free";
    }else{
        cell.price.text = [NSString stringWithFormat:@"$%@",[price stringValue]];
    }
    
    
    return cell;
}


- (void)buyNowPressed:(id)sender
{
    UIButton *buttonPressed = (UIButton *)sender;
    tempItemDict = [txtbookArray objectAtIndex:buttonPressed.tag];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(![defaults objectForKey:@"buynowpressed"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info"
                                                        message:@"You will now be directed to the seller's Facebook profile where you can contact him/her about any final details, such as time and location for the book exchange."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        
        alert.tag = 1;
        [alert show];
        [defaults setObject:@"YES" forKey:@"buynowpressed"];
        [defaults synchronize];
    }else{
        [self openFacebookMessenger];
    }
}

-(void)openFacebookMessenger
{
    if([tempItemDict objectForKey:@"fbid"]){
        
        NSString *fbid = [NSString stringWithFormat:@"fb-messenger://user-thread/%@",[tempItemDict objectForKey:@"fbid"]];
    
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:fbid]])
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:fbid]];
        }else{
            NSString *fbString = [NSString stringWithFormat:@"fb://profile/%@", [tempItemDict objectForKey:@"fbid"]];
            NSURL *nsurl =[NSURL URLWithString:fbString];
            if ([[UIApplication sharedApplication] canOpenURL:nsurl]){
                [[UIApplication sharedApplication] openURL:nsurl];
            }else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.facebook.com/%@", [tempItemDict objectForKey:@"fbid"]]]]){
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.facebook.com/%@", [tempItemDict objectForKey:@"fbid"]]]];
            }else{
                 [self showAlertView:@"Error" withMessage:@"Having trouble directing you to seller's profile. Please try again."];
            }
           
        }
    }else{
        [self showAlertView:@"Error" withMessage:@"Unable to retrieve seller info. Please try again."];
    }

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 1){
        if (buttonIndex == [alertView cancelButtonIndex]){
            [self openFacebookMessenger];
        }
    }else if (alertView.tag == 2){
        if (buttonIndex == 1){ //pressed OK button
            [self removeAnimateMakeOfferview];
            [self showHUD];
            
            PFQuery *localQuery = [PFQuery queryWithClassName:@"BookOffers"];
            [localQuery fromLocalDatastore];
            [localQuery whereKey:@"fbid" equalTo:[ViewController getFBID]];
            [localQuery whereKey:@"parent_offer" equalTo:makeOfferPFObject];
            [[localQuery findObjectsInBackground] continueWithBlock:^id(BFTask *task) {
                
                if (task.error) {
                    [self hideHUD:M13ProgressViewActionFailure];
                    [self showAlertView:@"Query Error" withMessage:task.error.localizedDescription];
                    return task;
                }
                NSArray *resultArray = (NSArray *)(task.result);
                NSInteger resultCount = [resultArray count];
                NSLog(@"count is: %ld", (long)resultCount);
                
                [makeOfferPFObject setObject:[NSDate date] forKey:@"offerLastUpdated"];
                [makeOfferPFObject saveInBackground];
                
                /*not in local datastore. It is a new offer to a new item, not the same item, hence it is not in the local database already*/
                if (resultCount == 0){
                    NSLog(@"result is 0 if");
                    PFObject *offerObject = [PFObject objectWithClassName:@"BookOffers"];
                    NSString *offerString = [setPriceLabel.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
                    
                    
                    offerObject[@"current_offer"] = @([offerString intValue]);
                    offerObject[@"fbid"] =  [ViewController getFBID];
                    offerObject[@"parent_offer"] = makeOfferPFObject;

                    
                    /*Save in local database*/
                    [offerObject pinInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if(succeeded){
                            NSLog(@"succeeding in storing info in local database");
                            
                            /* save in remote database also */
                            
                            [offerObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *offerError) {
                                if(succeeded){
                                    
                                    NSLog(@"succeeding in making offer");
                                    [HUD performAction:M13ProgressViewActionSuccess animated:YES];
                                    [self performSelector:@selector(hideHUDAfterMakingOffer:) withObject:nil afterDelay:0.4];
                                }else{
                                    NSLog(@"failed in making offer");
                                    [HUD performAction:M13ProgressViewActionFailure animated:YES];
                                    [self performSelector:@selector(hideHUDAfterMakingOffer:) withObject:[offerError localizedDescription] afterDelay:0.4];
                                }
                            }];
                        }else{
                            NSLog(@"failed in storing info in local database");
                            [HUD performAction:M13ProgressViewActionFailure animated:YES];
                            [self performSelector:@selector(hideHUDAfterMakingOffer:) withObject:[error localizedDescription] afterDelay:0.4];
                        }
                    }];
                    
                    
                }else{
                    /*key already is in the local datastore. So only update the values in the remote database. We don't care about updating in local datastore. It is only used as a way to see if a offer to the same book was previously made or not. */
                    
                    NSString *objectID = ((PFObject*)[resultArray objectAtIndex:0]).objectId;
                    NSLog(@"objectID %@", objectID);
                    
                    PFQuery *remoteQuery = [PFQuery queryWithClassName:@"BookOffers"];
                    [remoteQuery getObjectInBackgroundWithId:objectID block:^(PFObject *returnedOfferObject, NSError *error) {
                        
                         NSLog(@"returned object %@", returnedOfferObject);
                        
                         NSString *offerString = [setPriceLabel.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
                       
                        
                        //update it
                        returnedOfferObject[@"current_offer"] = @([offerString intValue]);
                        
                        [returnedOfferObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (succeeded){
                                NSLog(@"succeeding in updating offer");
                                [HUD performAction:M13ProgressViewActionSuccess animated:YES];
                                [self performSelector:@selector(hideHUDAfterMakingOffer:) withObject:nil afterDelay:0.4];
                            }else{
                                NSLog(@"failed in updating offer");
                                [HUD performAction:M13ProgressViewActionFailure animated:YES];
                                [self performSelector:@selector(hideHUDAfterMakingOffer:) withObject:[error localizedDescription] afterDelay:0.4];
                            }
                        }];
                        
                    }];
                }
                
                
                
                NSLog(@"Retrieved %@", task.result);
                return task;
            }];
            

        }
    }
    
}
-(void)hideHUDAfterMakingOffer:(NSString *)errorDescription
{
    [HUD hide:YES];
    if (errorDescription != nil){
        [self showAlertView:@"Error in sending offer" withMessage:errorDescription];
    }else{
        [self updateOfferHasBeenMade];
        NSLog(@"called once");
        [self showAlertView:@"Success" withMessage:@"The seller has received your offer."];
        
        PFQuery *pushQuery = [PFInstallation query];
        [pushQuery whereKey:@"fbid" hasPrefix:makeOfferPFObject[@"fbid"]];
        
        NSDictionary *data = @{
                               @"alert" : [NSString stringWithFormat:@"You have a new offer of %@ on a book!",setPriceLabel.text],
                               @"badge" : @"Increment"
                               };
        PFPush *push = [[PFPush alloc] init];
        [push setQuery:pushQuery];
        [push setData:data];
        [push sendPushInBackground];
    }
    
   
}

-(void)updateOfferHasBeenMade
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *sellingBooksDict = [[defaults objectForKey:@"sellingBooksDict"]mutableCopy];
    if (sellingBooksDict == nil){
        sellingBooksDict = [[NSMutableDictionary alloc]init];
    }
    
    [sellingBooksDict setObject:@"YES" forKey:makeOfferPFObject.objectId];
    [defaults setObject:sellingBooksDict forKey:@"sellingBooksDict"];
    [defaults synchronize];
}

-(void)makeOfferPressed:(id)sender
{
    UIButton *buttonPressed = (UIButton *)sender;
    makeOfferPFObject = [txtbookArray objectAtIndex:buttonPressed.tag];
  
    [self animateMakeOfferPopupView];
   
}

-(void)createMakeOfferPopupView
{
    makeOfferBackground = [[UIView alloc]initWithFrame:CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGHT-50)];
    makeOfferBackground.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.7];
    [self.view addSubview:makeOfferBackground];
    
    UIView *makeOfferPopupView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-100, SCREEN_HEIGHT *0.6)];
    makeOfferPopupView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    makeOfferPopupView.backgroundColor = [UIColor colorWithRed:0.098 green:0.318 blue:0.639 alpha:1]; /*#1951a3*///[UIColor colorWithRed:0.031 green:0.125 blue:0.255 alpha:0.7]; /*#082041*/
    makeOfferPopupView.layer.cornerRadius = 10;
    makeOfferPopupView.clipsToBounds = YES;
    [makeOfferBackground addSubview: makeOfferPopupView];
    
    UIButton *closeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [closeButton setImage:[UIImage imageNamed:@"closebutton.png"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeMakeOfferView:) forControlEvents:UIControlEventTouchUpInside];
    [makeOfferPopupView addSubview:closeButton];
    
    UILabel *enterOfferLabel = [[UILabel alloc]initWithFrame:CGRectMake(((SCREEN_WIDTH-100)-(SCREEN_WIDTH-150))/2, closeButton.frame.origin.y + closeButton.frame.size.height-TOP_MARGIN, SCREEN_WIDTH-150, 50)];
    enterOfferLabel.textAlignment = NSTextAlignmentCenter;
    enterOfferLabel.numberOfLines = 2;
    enterOfferLabel.textColor = [UIColor whiteColor];
    enterOfferLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:16];
    enterOfferLabel.text = @"Place your offer below";
    [makeOfferPopupView addSubview:enterOfferLabel];
    
    setPriceLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,enterOfferLabel.frame.origin.y + enterOfferLabel.frame.size.height-TOP_MARGIN, makeOfferPopupView.frame.size.width, 30)];
    setPriceLabel.textAlignment = NSTextAlignmentCenter;
    setPriceLabel.textColor = [UIColor whiteColor];
    setPriceLabel.text = @"$0";
    setPriceLabel.font = [UIFont fontWithName:@"Avenir-Black" size:24];
    [makeOfferPopupView addSubview:setPriceLabel];
    
    UIPickerView *myPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, setPriceLabel.frame.origin.y + setPriceLabel.frame.size.height-TOP_MARGIN, makeOfferPopupView.frame.size.width, makeOfferPopupView.frame.size.height - (setPriceLabel.frame.origin.y + setPriceLabel.frame.size.height))];
    myPickerView.delegate = self;
    myPickerView.showsSelectionIndicator = YES;
    [makeOfferPopupView addSubview:myPickerView];
    
    UIButton *submitButton = [[UIButton alloc]initWithFrame:CGRectMake(0, myPickerView.frame.origin.y + myPickerView.frame.size.height-15, makeOfferPopupView.frame.size.width, 20)];
    [submitButton setTitle:@"SUBMIT" forState:UIControlStateNormal];
    [submitButton.titleLabel setFont:[UIFont fontWithName:@"Avenir-Black" size:20]];
    [submitButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(makeOfferSubmitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [submitButton setShowsTouchWhenHighlighted:YES];
    [makeOfferPopupView addSubview:submitButton];
    
    [makeOfferBackground setHidden: YES];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    [self animateMakeOfferPriceLabel];
    setPriceLabel.text = pickerData[row];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [pickerData count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString * price = pickerData[row];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:price attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"Avenir-Medium" size:21]}];
    
    return attString;
    
}

-(void)animateMakeOfferPriceLabel
{
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut |UIViewAnimationOptionBeginFromCurrentState  animations:^{
         setPriceLabel.transform = CGAffineTransformMakeScale(1.3, 1.3);
    } completion:^(BOOL finished){
        if(finished){
            [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseIn |UIViewAnimationOptionBeginFromCurrentState  animations:^{
                setPriceLabel.transform = CGAffineTransformMakeScale(1.0,1.0);
            } completion:nil];
            
        }
    }];
    
}
-(void)makeOfferSubmitButtonPressed:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm"
                                                    message: [NSString stringWithFormat:@"By submitting this offer of %@, I am abiding by Acebook's community rule to only make legitimate offers.", setPriceLabel.text]
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Confirm", nil];
    alert.tag = 2;
    [alert show];
}
-(void)closeMakeOfferView:(id)sender
{
    [self removeAnimateMakeOfferview];
    
}
- (void)animateMakeOfferPopupView
{
    [makeOfferBackground setHidden:NO];
    makeOfferBackground.transform = CGAffineTransformMakeScale(1.3, 1.3);
    makeOfferBackground.alpha = 0;
    [UIView animateWithDuration:.25 animations:^{
        makeOfferBackground.alpha = 1;
        makeOfferBackground.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)removeAnimateMakeOfferview
{
    [UIView animateWithDuration:.25 animations:^{
        makeOfferBackground.transform = CGAffineTransformMakeScale(1.3, 1.3);
        makeOfferBackground.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [makeOfferBackground setHidden:YES];
        }
    }];
}
/*-----------------------------------UICollectionVIew-------------------------------------*/

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView.tag == 1){
        return [profArray count];
    }
    return [topCollViewItemArray count];
}

-(NSIndexPath*)indexPathForFirstRowItem
{
    return [NSIndexPath indexPathForRow:0 inSection:0];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    if (collectionView.tag == 1){
        CollectionViewCell *cell = (CollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        cell.backgroundColor = [UIColor colorWithRed:0.18 green:0.173 blue:0.173 alpha:0.8];
        [cell setLabelText: [profArray objectAtIndex:indexPath.item]];
        
        return cell;
    }
    
    BuyBooksCollectionView *buyBooksCell = (BuyBooksCollectionView *)[collectionView dequeueReusableCellWithReuseIdentifier:@"BuyBooksCell" forIndexPath:indexPath];
    
    if (selectedItemIndexPath != nil && [indexPath compare:selectedItemIndexPath] == NSOrderedSame){

        [buyBooksCell setBackgroundColor:[UIColor colorWithRed:0.212 green:0.392 blue:0.545 alpha:1]]; //select it
    }else{
        [buyBooksCell setBackgroundColor:[UIColor colorWithRed:0.231 green:0.216 blue:0.216 alpha:1]]; //deselect it
    }

  
    NSDictionary * eachIndex = [topCollViewItemArray objectAtIndex:indexPath.item];
    
    if (ICLICKER_ISBN == [[eachIndex objectForKey:@"isbn"]integerValue]){
        [buyBooksCell.imgView sd_setImageWithURL:nil
                        placeholderImage:[UIImage imageNamed:@"iclicker2.png"]];
    }else{
        NSDictionary *imgDict = [eachIndex objectForKey:@"image_url"];
        if (imgDict){
            NSURL *url = nil;
            if ([imgDict objectForKey:@"large"]){
                url = [NSURL URLWithString:[imgDict objectForKey:@"large"]];
            }else{
                url = [NSURL URLWithString:[imgDict objectForKey:@"small"]];
            }
            [buyBooksCell.imgView sd_setImageWithURL:url
                            placeholderImage:[UIImage imageNamed:@"noimagepl.png"]];
        }else{
            [buyBooksCell.imgView sd_setImageWithURL:nil
                            placeholderImage:[UIImage imageNamed:@"noimagepl.png"]];
        }
        
    }

    buyBooksCell.bookTitle.text = [eachIndex objectForKey:@"title"];
    
    return buyBooksCell;
}
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self showHUD];
    if (collectionView.tag == 2){
        NSMutableArray *indexPaths = [NSMutableArray arrayWithObject:indexPath];
        
        if (selectedItemIndexPath)
        {
            if (![indexPath compare:selectedItemIndexPath] == NSOrderedSame)
            {
                
                [indexPaths addObject:selectedItemIndexPath];
                selectedItemIndexPath = indexPath;
                

            }
        }
        else
        {
            
            selectedItemIndexPath = indexPath;
        }
        [collectionView reloadItemsAtIndexPaths:indexPaths];

        [self getBooksforSelectedBook:[topCollViewItemArray objectAtIndex:indexPath.item][@"isbn"]];

        
    }else{
        
        NSString *profNameSelected = [profArray objectAtIndex:indexPath.item];
        [self loadTableViewWithNewValues:profNameSelected];
    }
    
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {

   
}
-(void) collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    //change color when tapped
    if (collectionView.tag == 1){
        CollectionViewCell *cell = (CollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
        cell.backgroundColor = [UIColor grayColor];
    }
    
}

-(void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    //change back on touch up
    if (collectionView.tag == 1){
        CollectionViewCell *cell = (CollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
        cell.backgroundColor = [UIColor colorWithRed:0.18 green:0.173 blue:0.173 alpha:1];

    }
}

#pragma mark – UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView.tag == 1){
        return CGSizeMake(145, 120);
    }
    return CGSizeMake(IMG_WIDTH,TOP_MARGIN + IMG_HEIGHT*0.85 + (SCREEN_HEIGHT * 0.12)); //buy books collection view
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (collectionView.tag == 1){
        return UIEdgeInsetsMake(10, 0, 10, 0);
    }
    
    return UIEdgeInsetsMake(10, 0, 0, 0);

}

-(void)showNoBooksFoundLabel
{
    noBooksLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,TOP_MARGIN + (IMG_HEIGHT * 0.85) + (SCREEN_HEIGHT *0.12)+ 2*BOTTOM_MARGIN, SCREEN_WIDTH, SCREEN_HEIGHT * 0.2)];
    noBooksLabel.font = [UIFont fontWithName:@"Avenir-Black" size:24];
    noBooksLabel.text = @"No seller is selling this item currently.";
    noBooksLabel.numberOfLines = 0;
    noBooksLabel.textAlignment = NSTextAlignmentCenter;
    noBooksLabel.textColor = [UIColor whiteColor];
    noBooksLabel.backgroundColor = [UIColor colorWithRed:0.231 green:0.216 blue:0.216 alpha:0.5];
    [self.tableView addSubview:noBooksLabel];
 
}
-(void)removeNoBooksLabel
{
    [noBooksLabel removeFromSuperview];
    noBooksLabel = nil;
}
-(void)getBooksforSelectedBook:(NSString *)isbn
{
    PFQuery *query = [PFQuery queryWithClassName:@"Selling"];
    [query whereKey:@"isbn" hasPrefix:isbn];
    [query whereKey:@"sold" notEqualTo:[NSNumber numberWithBool:YES]];
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self hideHUD:M13ProgressViewActionNone];
        if (!error) {
            /*
             Array of dicts that has all keys stored in the database
             */
            for (NSDictionary *dict in objects){
                NSLog(@"OBJECT: %@", dict);
                NSLog(@"key array is: %@", [dict allKeys]);
            }
            txtbookArray = objects;
            [self.tableView reloadData];
            //[self.topCollectionView reloadData];
            if ([objects count] == 0){
                if (noBooksLabel == nil){
                    [self showNoBooksFoundLabel];
                }
                
            }else{
                [self removeNoBooksLabel];
            }
            
            
        } else {
            
            [self showAlertView:@"Search Error" withMessage:[error localizedDescription]];
        }
        [refreshControl endRefreshing];
    }];

}
-(void)loadTableViewWithNewValues:(NSString *)profNameSelected
{
    
    topCollViewItemArray = [profDict objectForKey:profNameSelected][@"textbooks"];
    if([topCollViewItemArray count] == 0){
        [self hideHUD:M13ProgressViewActionNone];
        [self showAlertView:@"Alert" withMessage:[NSString stringWithFormat:@"No textbooks posted for Professor %@ as of yet.",profNameSelected]];
    }else{
        NSDictionary *firstBookDict = topCollViewItemArray[0];
        if (firstBookDict[@"isbn"]){
            PFQuery *query = [PFQuery queryWithClassName:@"Selling"];
            [query whereKey:@"isbn" hasPrefix:firstBookDict[@"isbn"]];
            [query whereKey:@"sold" notEqualTo:[NSNumber numberWithBool:YES]];
            [query orderByDescending:@"createdAt"];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                [self hideHUD:M13ProgressViewActionNone];
                if (!error) {
                    /*
                     Array of dicts that has all keys stored in the database
                     */
                    for (NSDictionary *dict in objects){
                        NSLog(@"OBJECT: %@", dict);
                        NSLog(@"key array is: %@", [dict allKeys]);
                    }
                    txtbookArray = objects;
                    [self.tableView reloadData];
                    [self.topCollectionView reloadData];
                    
                    if ([objects count] == 0){
                        if (noBooksLabel == nil){
                            [self showNoBooksFoundLabel];
                        }
                    }else{
                        [self removeNoBooksLabel];
                    }
                        

                    if (![self.collectionView isHidden]){
                        NSLog(@"called from load");
                        [self animateDownProfCollectionView];
                    }
                    [self animateUpBooksTableView];
                } else {
                    // Log details of the failure
                    [self showAlertView:@"Search Error" withMessage:[error localizedDescription]];
                }
            }];
            
        }else{
            [self hideHUD:M13ProgressViewActionNone];
            [self showAlertView:@"Error" withMessage:@"ISBN not found. Cannot execute query."];
        }
        
    }
    

}
-(void)animateUpBooksTableView
{
    [self.tableView setHidden:NO];
    [UIView animateWithDuration:0.20 delay:0.0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                       //  self.tableView.frame =
                        self.tableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                         NSLog(@"tableview y: %f", self.tableView.frame.origin.y);
                         NSLog(@"tableview height: %f", self.tableView.frame.size.height
                               
                               );
                         if([self.tableView isHidden]){
                              NSLog(@"is hidden");
                         }else{
                             NSLog(@"not hidden");
                         }
                        

                     }
                     completion:nil];
}
-(void)animateDownBooksTableView
{
    
    [UIView animateWithDuration:0.20 delay:0.0 options:UIViewAnimationOptionCurveEaseIn |UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.tableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.01, 0.01);
                         
                     }
                     completion:^(BOOL finished){
                         if (finished){
                             [self.tableView setHidden:YES];
                         }
                     }];
}
-(void)configCollectionView
{
  
    profInstruction = [[UILabel alloc]initWithFrame:CGRectMake(0, -50, SCREEN_WIDTH, 50)];
    [profInstruction setFont:[UIFont fontWithName:@"Avenir-Black" size:17]];
    profInstruction.textAlignment = NSTextAlignmentCenter;
    profInstruction.textColor = [UIColor whiteColor];
    [profInstruction setNumberOfLines:0];
    [profInstruction setLineBreakMode:NSLineBreakByWordWrapping];
    profInstruction.adjustsFontSizeToFitWidth = YES;
    profInstruction.hidden = YES;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [self.collectionView setFrame:CGRectMake(0,(-SCREEN_HEIGHT * 0.035)+(SCREEN_HEIGHT * 0.13),SCREEN_WIDTH,SCREEN_HEIGHT -((-SCREEN_HEIGHT * 0.035)+(SCREEN_HEIGHT * 0.13) + 50) /*50 for the adbanner*/)];
    [self.collectionView setCollectionViewLayout:flowLayout];
    [self.collectionView setHidden:YES];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.tag = 1;
    [self.collectionView addSubview:profInstruction];


}

/*----------------------------------------------------------------------------------------*/


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchbar
{
    
    NSString * coursename = [self validSearch:searchbar.text];
    self.backgroundLogo.alpha = 0.2;
    selectedItemIndexPath = [self indexPathForFirstRowItem]; //reset selection
    
    if (coursename != nil){
        
        
        
        if (textbookjson != nil || [textbookjson count] != 0){
           
            coursename = [coursename uppercaseString];
            NSString * virginInput = [coursename stringByReplacingOccurrencesOfString:@"." withString:@" "];
            profDict = [textbookjson objectForKey:coursename];
            NSLog(@"dict is %@", profDict);
            if (profDict != nil){
                
                [searchBar resignFirstResponder];
                [self retractSearchBar];
                //[self animateDownProfCollectionView];
                profArray = [profDict allKeys];
                
                if ([profArray count] == 1){
                    NSDictionary * sampleProfDict = [profDict objectForKey:profArray[0]];
                    
                    if ([sampleProfDict objectForKey:@"Error"]){
                        if (![self.collectionView isHidden])
                            [self animateDownProfCollectionView];
                        self.nilOutputLabel.hidden = NO;
                        self.nilOutputLabel.text = [NSString stringWithFormat:@"No Booklist Found for %@", virginInput];
                        
                    }else if ([sampleProfDict objectForKey:@"NA"]){
                        if (![self.collectionView isHidden])
                            [self animateDownProfCollectionView];
                        self.nilOutputLabel.hidden = NO;
                        self.nilOutputLabel.text = [NSString stringWithFormat:@"No Textbook(s) Required for %@",virginInput];
                    }else{
                        self.nilOutputLabel.hidden = YES;
                        [self showHUD];
                        [self loadTableViewWithNewValues:profArray[0]];
                        NSLog(@"Only one professor: go straight to tableview");
                    }
                    
                }else{
                    [self.collectionView reloadData];
                    
                    if ([self.collectionView isHidden]){
                        if (![self.nilOutputLabel isHidden]){
                            self.nilOutputLabel.hidden = YES;
                        }
                        [profInstruction setText:[NSString stringWithFormat:@"Please select your professor for %@",virginInput]];
                        [profInstruction setHidden:NO];
                        [self animateUpProfCollectionView];
                        
                    }
                }
                
                
            }else{
                
                [self showAlertView:@"Error" withMessage:[NSString stringWithFormat:@"%@ is not offered this quarter.",searchbar.text]];
          
            }
        }else{
            [searchBar resignFirstResponder];
            [self retractSearchBar];
            [self showHUD];
            [self createJsonFile];
            NSLog(@"failure");
            NSLog(@"TEXTBOOK: %@", textbookjson);
            //[self showAlertView:@"Error" withMessage:@"Unable to query data. Please try terminating and then starting the app again."];
        }

        
    }
}

-(void)animateUpProfCollectionView
{
    self.collectionView.transform = CGAffineTransformMakeScale(0.2, 0.2);
    [self.collectionView setHidden:NO];
    
    [UIView animateWithDuration:0.20 delay:0.0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.collectionView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         
                     }
                     completion:nil];
}

-(void)animateDownProfCollectionView
{
     
    [UIView animateWithDuration:0.20 delay:0.0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.collectionView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.01, 0.01);
                         
                     }
                     completion:^(BOOL finished){
                         self.collectionView.hidden = YES;
                     }];
}
-(NSString *)validSearch:(NSString *) inputString
{
    inputString = [inputString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *pattern = @"([A-Za-z]+)(\\d+.*)";
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:inputString options:0 range: NSMakeRange(0, [inputString length])];
    NSLog(@"result %@", [inputString substringWithRange:[match rangeAtIndex:0]]);
    if (match){
         inputString = [[[inputString substringWithRange:[match rangeAtIndex:1]] stringByAppendingString:@"."]stringByAppendingString:[inputString substringWithRange:[match rangeAtIndex:2]]];
        
    }else{
        inputString = nil;
        [self showAlertView:@"Error" withMessage:@"Not a valid input. Input example: 'MMW 13'"];
        
    }
    return inputString;
    
}
-(void)showAlertView:(NSString *)title withMessage:(NSString *)message
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message: message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
}
-(void)settingsButtonPressed{
    [ViewController goToSecondPageController];
}
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end