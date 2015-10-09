//
//  SecondPageController.m
//  AceBooks
//
//  Created by Gurkirat Singh on 3/3/15.
//  Copyright (c) 2015 AceBooks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecondPageController.h"
#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "UIImageView+WebCache.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "SellingCollectionViewCell.h"
#import "CardTableViewCell.h"
#import "M13ProgressHUD.h"
#import "M13ProgressViewRing.h"
#import "OfferCollectionViewCell.h"
#import "BuyingBooksTableViewCell.h"

@interface SecondPageController ()
@property (weak, nonatomic) IBOutlet UICollectionView *offerCollectionView;
@property (weak, nonatomic) IBOutlet UIView *blackBackgroundPopupView;
@property (weak, nonatomic) IBOutlet UITableView *buyingBooksTableView;
@property (weak, nonatomic) IBOutlet UICollectionView *sellingCollectionView;
@end


@implementation SecondPageController{
    UIButton *buyingButton;
    UIButton *sellingButton;
    UIImageView *dollarImg;
    UIImageView *cartImg;
    BOOL buyingSelected;
    
    NSString *fbid;
    NSArray *sellingBooksArray;
    M13ProgressHUD * HUD;
    UIRefreshControl *refreshControl;
    UIRefreshControl * offerViewRefreshControl;
    BOOL refreshedOnceOnLoad;
    NSMutableArray *offersArray;
    
    UILabel *popupTitleLabel;
    UILabel *popupAuthorLabel;
    UILabel *popupConditionLabel;
    UILabel *popupPriceLabel;
    UILabel *staticOfferLabel;
    
    NSArray *pickerData;
    PFObject *selectedBookPFObject;
    PFObject *selectedOfferPFObject;
    UIView *pickerBaseView;
    UIColor *previousHighlightColor;
    NSInteger selectedOfferItemIndex;
    
    UIView *acceptedOfferView;
    UILabel *acceptedOfferPriceLabel;
    UIButton *editButton;
    NSMutableArray *buyingBooksArray;
    UIRefreshControl *buyingRefreshControl;
    UILabel *noBuyingBooksLabel;
    UILabel *noSellingBooksLabel;
    NSMutableDictionary *defaultsDict;
    UIView *makeOfferBackground;
    UILabel *setPriceLabel;
    NSArray *pickerOfferViewData;
    PFObject *makeOfferPFObject;
    NSInteger makeOfferPFObjectItemNum;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupTopBarView];
    [self configBuyingBooksTableView];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray * priceData = [[NSMutableArray alloc]init];
        for (int i = 0; i <= 500; i++){
            if (i == 0){
                [priceData addObject:@"Free"];
            }else{
                [priceData addObject:[NSString stringWithFormat:@"$%d",i]];
            }
        }
        pickerData = @[priceData,
                       @[@"New", @"Used", @"Minor Wear", @"Poor"]];
        [priceData removeObjectAtIndex:0];
        pickerOfferViewData = priceData;
    });
    
    [self configSellingCollectionView];
    [self configOfferCollectionView];
    [self createMakeOfferPopupView];
    [self createCollectionViewCellPopupView];
    [self requestSellersBooks];
    [self requestBuyingBooksArrayFromParse:YES]; //show HUD
    [self configPickerView];
    
    [self initHUD];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!refreshedOnceOnLoad){
        [self showHUD];
    }
}

/*----------------------------Refresh Controls---------------------------------------*/
-(void)refreshControlStatus
{
    [self requestSellersBooks];
}

-(void)buyingRefreshControlStatus
{
    [self requestBuyingBooksArrayFromParse:NO];
}

-(void)offerViewRefreshControlStatus:(id)sender
{
    if (offersArray != nil){
        [self loadAllOffersofSelectedBook:YES];
    }else{
        [offerViewRefreshControl endRefreshing];
    }
    
}

-(void)requestSellersBooks
{
    if ([ViewController getFBID] != nil){
        fbid = [ViewController getFBID];
        [self getSellersBooks];
    }else{
        FBRequest *request = [FBRequest requestForMe];
        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            
            if (!error) {
                NSDictionary *userData = (NSDictionary *)result;
                fbid = userData[@"id"];
                [self getSellersBooks];
            }else{
                [self showAlertView:@"Error" withMessage:[NSString stringWithFormat:@"Could not retrieve data due to the following reason: %@",[error localizedDescription]]];
            }
            [refreshControl endRefreshing];
        }];
        
    }
    
}

-(void)getSellersBooks
{
    PFQuery *query = [PFQuery queryWithClassName:@"Selling"];
    NSLog(@"FBID is: %@", fbid);
    [query whereKey:@"fbid" hasPrefix:fbid];
    [query orderByDescending:@"offerLastUpdated"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu PFobjects.", (unsigned long)objects.count);
            // Do something with the found objects
            for (PFObject *object in objects) {
                NSLog(@"%@", object);
            }
            
            sellingBooksArray = objects;
            defaultsDict = [[[NSUserDefaults standardUserDefaults]objectForKey:@"sellingBooksDict"] mutableCopy];
            
            if ([sellingBooksArray count] == 0){
                if (noSellingBooksLabel == nil){
                    [self showNoSellingBooksLabel];
                }
            }else{
                [self removeNoSellingBooksLabel];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.sellingCollectionView reloadData];
                if (!refreshedOnceOnLoad){
                    refreshedOnceOnLoad = YES;
                    [self hideHUD];
                }
                NSLog(@"reloading" );
            });
            
            
        } else {
            
             [self showAlertView:@"Query Error" withMessage:[error localizedDescription]];
        }
        [refreshControl endRefreshing];
        
    }];
}
/*------------------------ Offer Collection View --------------------------------*/
-(void)configOfferCollectionView
{
    self.offerCollectionView.delegate = self;
    self.offerCollectionView.dataSource = self;
    self.offerCollectionView.tag = 2;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [self.offerCollectionView setCollectionViewLayout:flowLayout];
    
    offerViewRefreshControl = [[UIRefreshControl alloc] init];
    offerViewRefreshControl.tintColor = [UIColor whiteColor];
    [offerViewRefreshControl addTarget:self action:@selector(offerViewRefreshControlStatus:)
             forControlEvents:UIControlEventValueChanged];
    [self.offerCollectionView addSubview:offerViewRefreshControl];
}

-(void)closeOfferView
{
    [self removeAnimateOfferview];
    
    if(![pickerBaseView isHidden]){
        [self animateDownEditView:NO]; //the view is refreshed w/ new values each time so we don't need to reset the values before closing
    }
    
}

/*---------------------------Picker View------------------------------------------*/
-(void)configPickerView
{
    
    UIPickerView *myPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0,0, pickerBaseView.frame.size.width, pickerBaseView.frame.size.height-27)];
    myPickerView.backgroundColor = [UIColor clearColor];
    myPickerView.delegate = self;
    myPickerView.dataSource = self;
    myPickerView.showsSelectionIndicator = YES;
    myPickerView.tag = 2;
    [pickerBaseView addSubview:myPickerView];
    
    UIButton * cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(0, myPickerView.frame.origin.y + myPickerView.frame.size.height - 15, myPickerView.frame.size.width/2, pickerBaseView.frame.size.height - (myPickerView.frame.origin.y + myPickerView.frame.size.height))];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont fontWithName:@"Avenir-Medium" size:18]];
    cancelButton.backgroundColor = [UIColor colorWithRed:0.075 green:0.22 blue:0.439 alpha:1];/*#133870*/
    [cancelButton addTarget:self action:@selector(cancelButtonPressedForEditView:) forControlEvents:UIControlEventTouchUpInside];
    [pickerBaseView addSubview:cancelButton];
    
    UIButton * saveButton = [[UIButton alloc]initWithFrame:CGRectMake(pickerBaseView.frame.size.width/2, myPickerView.frame.origin.y + myPickerView.frame.size.height - 15, myPickerView.frame.size.width/2, pickerBaseView.frame.size.height - (myPickerView.frame.origin.y + myPickerView.frame.size.height))];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveButton setTitle:@"Save Changes" forState:UIControlStateNormal];
    [saveButton.titleLabel setFont:[UIFont fontWithName:@"Avenir-Medium" size:18]];
    saveButton.backgroundColor = [UIColor colorWithRed:0.31 green:0.58 blue:0.804 alpha:1]; /*#4f94cd*/
    [saveButton addTarget:self action:@selector(saveButtonPressedForEditView:) forControlEvents:UIControlEventTouchUpInside];
    [pickerBaseView addSubview:saveButton];
}

-(void)cancelButtonPressedForEditView:(id)sender
{
    [self animateDownEditView:YES];
    
}

-(void)saveButtonPressedForEditView:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Save the current price and condition?"
                                                    message: @"Confirm to save info."
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Confirm", nil];
    alert.tag = 1;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 1){ //Save button alert view
        
        if (buttonIndex != [alertView cancelButtonIndex]){
            [self animateDownEditView:NO];
            [self showHUD];
            PFQuery *query = [PFQuery queryWithClassName:@"Selling"];
            
            [query getObjectInBackgroundWithId:selectedBookPFObject.objectId block:^(PFObject *selectedBook, NSError *error) {
                
                if (!error){
                    selectedBook[@"condition"] = popupConditionLabel.text;
                    
                    if ([popupPriceLabel.text isEqualToString:@"Free"]){
                        selectedBook[@"price"] = @0;
                    }else{
                        NSString *priceString = [popupPriceLabel.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
                        selectedBook[@"price"] = @([priceString intValue]);
                    }
                    
                    [selectedBook saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded){
                            [selectedBookPFObject fetch];
                            [HUD performAction:M13ProgressViewActionSuccess animated:YES];
                            NSLog(@"in second page");
                            [self performSelector:@selector(hideHUDAfterSavingEdit:) withObject:nil afterDelay:0.4];
                            [self reloadValuesAfterSave];
                        }else{
                            [HUD performAction:M13ProgressViewActionFailure animated:YES];
                            [self performSelector:@selector(hideHUDAfterSavingEdit:) withObject:[error localizedDescription] afterDelay:0.4];
                        }
                    }];
                }else{[self removeAnimateOfferview];
                    [HUD performAction:M13ProgressViewActionFailure animated:YES];
                    [self performSelector:@selector(hideHUDAfterSavingEdit:) withObject:[error localizedDescription] afterDelay:0.4];
                }
                
            }];
        }else{
            [alertView dismissWithClickedButtonIndex:[alertView cancelButtonIndex] animated:YES];
        }
        
    }else if (alertView.tag == 2){ //Accept, deny, or cancel offer
        
        if (buttonIndex == [alertView cancelButtonIndex]){
            [alertView dismissWithClickedButtonIndex:[alertView cancelButtonIndex] animated:YES];
            
        }else if (buttonIndex == 1){ //Deny
            
            [self showHUD];
            PFQuery *query = [PFQuery queryWithClassName:@"BookOffers"];
            [query getObjectInBackgroundWithId:selectedOfferPFObject.objectId block:^(PFObject *returnedObject, NSError *error) {
            
                returnedObject[@"offerStatus"] = @"NO";
                [returnedObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded){
                        [offersArray removeObjectAtIndex:selectedOfferItemIndex];
                        [HUD performAction:M13ProgressViewActionSuccess animated:YES];
                        [self performSelector:@selector(hideHUDAfterSavingEdit:) withObject:nil afterDelay:0.4];
                        [self.offerCollectionView reloadData];
                        [self sendPushNotificationToLoser];
                    }else{
                        [HUD performAction:M13ProgressViewActionFailure animated:YES];
                        [HUD hide:YES];
                        [self showAlertView:@"Error" withMessage:@"Error in sending request"];
                    }
                    
                }];
                
            }];
        }else{ //Accept
            
            [self showHUD];
        
            PFQuery *query = [PFQuery queryWithClassName:@"BookOffers"];
            [query getObjectInBackgroundWithId:selectedOfferPFObject.objectId block:^(PFObject *returnedObject, NSError *error) {
                
                
                NSMutableArray *tempOfferArray = offersArray;
                NSMutableArray *notAcceptedfbidArray = [[NSMutableArray alloc]init];
                
                for (int i = 0; i < [tempOfferArray count]; i++){
                    PFObject *object = tempOfferArray[i];
                    if (i == selectedOfferItemIndex){
                        object[@"offerStatus"] = @"YES";
                    }else{
                        object[@"offerStatus"] = @"LOST";
                        [notAcceptedfbidArray addObject:object[@"fbid"]];
                    }
                    tempOfferArray[i] = object;
                    
                    
                }
                
                [PFObject saveAllInBackground:tempOfferArray block:^(BOOL succeeded, NSError *error) {
                    if(!error){
                        PFQuery *soldquery = [PFQuery queryWithClassName:@"Selling"];
                        
                        [soldquery getObjectInBackgroundWithId:selectedBookPFObject.objectId block:^(PFObject *bookobject, NSError *error) {
                            bookobject[@"sold"] = @YES;
                            
                            [bookobject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if(succeeded){
                                    
                                    offersArray = nil;
                                    [self setOfferTitle];
                                    editButton.hidden = YES;
                                    acceptedOfferPriceLabel.text = [NSString stringWithFormat:@"$%@",[selectedOfferPFObject[@"current_offer"]stringValue]];
                                    [self animateUpAcceptedOfferView];
                                    
                                    /* send the push notification */
                                    [self sendPushNotificationToWinner];
                                    [self sendPushNotificationToLosers:notAcceptedfbidArray];
                                    
                                    [HUD performAction:M13ProgressViewActionSuccess animated:YES];
                                    [self performSelector:@selector(hideHUDAfterSavingEdit:) withObject:nil afterDelay:0.4];
                                    
                                }else{
                                    [HUD performAction:M13ProgressViewActionFailure animated:YES];
                                    [HUD hide:YES];
                                    [self showAlertView:@"Error in accepting offer" withMessage:[error localizedDescription]];
                                }
                            }];
                        }];
                        
                        
                    }else{
                        [HUD performAction:M13ProgressViewActionFailure animated:YES];
                        [HUD hide:YES];
                        [self showAlertView:@"Error in accepting offer" withMessage:[error localizedDescription]];
                    }
                }];
                
            }];
        }
    }else if (alertView.tag == 3){
        
        if (buttonIndex == 1){ //pressed OK button
            [self removeAnimateMakeOfferview];
            [self showHUD];
            
            PFObject *parent_item = [makeOfferPFObject objectForKey:@"parent_offer"];
            if(parent_item){
                [parent_item setObject:[NSDate date] forKey:@"offerLastUpdated"];
                [parent_item saveInBackground];
            }
            
          
            /*key already is in the local datastore. So only update the values in the remote database. We don't care about updating in local datastore. It is only used as a way to see if a offer to the same book was previously made or not. */
            
            PFQuery *remoteQuery = [PFQuery queryWithClassName:@"BookOffers"];
            [remoteQuery getObjectInBackgroundWithId:makeOfferPFObject.objectId block:^(PFObject *returnedOfferObject, NSError *error) {
                
                NSString *offerString = [setPriceLabel.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
                
                //update it
                returnedOfferObject[@"current_offer"] = @([offerString intValue]);
                
                //show the offer status to be pending
                [returnedOfferObject removeObjectForKey:@"offerStatus"];
                
                [returnedOfferObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded){
                        NSLog(@"succeeding in updating offer");
                        [returnedOfferObject fetch];
                        NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:0 inSection:makeOfferPFObjectItemNum];
                        
                        
                        NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
                        
                        [HUD performAction:M13ProgressViewActionSuccess animated:YES];
                        [self performSelector:@selector(hideHUDAfterMakingOffer:) withObject:nil afterDelay:0.4];
                        
                        [self.buyingBooksTableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationRight];
                        
                        PFQuery *pushQuery = [PFInstallation query];
                        [pushQuery whereKey:@"fbid" hasPrefix:parent_item[@"fbid"]];
                        
                        NSDictionary *data = @{
                                               @"alert" : [NSString stringWithFormat:@"You have a new offer of %@ on a book!",setPriceLabel.text],
                                               @"badge" : @"Increment"
                                               };
                        PFPush *push = [[PFPush alloc] init];
                        [push setQuery:pushQuery];
                        [push setData:data];
                        [push sendPushInBackground];
                        
                    }else{
                        NSLog(@"failed in updating offer");
                        [HUD performAction:M13ProgressViewActionFailure animated:YES];
                        [self performSelector:@selector(hideHUDAfterMakingOffer:) withObject:[error localizedDescription] afterDelay:0.4];
                    }
                }];
                
            }];
            
        }

    }else if (alertView.tag == 4){
        if (buttonIndex == [alertView cancelButtonIndex]){
             [alertView dismissWithClickedButtonIndex:[alertView cancelButtonIndex] animated:YES];
        }else{
            [self showHUD];
            PFQuery *query = [PFQuery queryWithClassName:@"BookOffers"];
            [query whereKey:@"parent_offer" equalTo:selectedBookPFObject];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    // The find succeeded.
                    // Do something with the found objects
                    for (PFObject *object in objects) {
                        NSLog(@"To delete: %@", object.objectId);
                        [object deleteInBackground];
                    }
                    
                    PFObject *object = [PFObject objectWithoutDataWithClassName:@"Selling"
                                                                       objectId:selectedBookPFObject.objectId];
                    [object deleteInBackgroundWithBlock:^(BOOL success,NSError *error ){
                        if (success){
                            [HUD performAction:M13ProgressViewActionSuccess animated:YES];
                            [self performSelector:@selector(hideHUDAfterMakingOffer:) withObject:nil afterDelay:0.4];
                            
                            [self closeOfferView ];
                            [self requestSellersBooks];
                        }else{
                            [HUD performAction:M13ProgressViewActionFailure animated:YES];
                            [self performSelector:@selector(hideHUDAfterMakingOffer:) withObject:[error localizedDescription]  afterDelay:0.4];
                        }
                    }];
                    
                } else {
                    // Log details of the failure
                    [HUD performAction:M13ProgressViewActionFailure animated:YES];
                    [self performSelector:@selector(hideHUDAfterMakingOffer:) withObject:[error localizedDescription]  afterDelay:0.4];
                }
            }];
            
            
        }
    }
}

-(void)sendPushNotificationToWinner
{
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"fbid" hasPrefix:selectedOfferPFObject[@"fbid"]];
    
    NSDictionary *data = @{
                           @"alert" : [NSString stringWithFormat:@"Your offer of $%@ is accepted. Contact the seller now!",
                                       [[selectedOfferPFObject objectForKey:@"current_offer"]stringValue]],
                           @"badge" : @"Increment"
                           };
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    [push setData:data];
    [push sendPushInBackground];
}

-(void)sendPushNotificationToLoser
{
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"fbid" hasPrefix:selectedOfferPFObject[@"fbid"]];
    
    NSDictionary *data = @{
                           @"alert" : [NSString stringWithFormat:@"Sorry, your offer of $%@ was not accepted by the seller. Make another offer!",
                                       [[selectedOfferPFObject objectForKey:@"current_offer"]stringValue]],
                           @"badge" : @"Increment"
                           };
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    [push setData:data];
    [push sendPushInBackground];
}

-(void)sendPushNotificationToLosers:(NSArray *)fbidArray
{
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"fbid" containedIn:fbidArray];
    
    NSDictionary *data = @{
                           @"alert" : @"Sorry, your offer did not win. The book was sold to another student.",
                           @"badge" : @"Increment"
                           };
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    [push setData:data];
    [push sendPushInBackground];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView.tag == 1){
        return 1;
    }
    return 2;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == 1){
        return [pickerOfferViewData count];
    }
    return [pickerData[component]count];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString * itemTitle;
    if (pickerView.tag == 1){
        itemTitle = pickerOfferViewData[row];
    }else{
        itemTitle = pickerData[component][row];
    }
    
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:itemTitle attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"Avenir-Medium" size:21]}];
    
    return attString;
    
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:  (NSInteger)component
{
    if (pickerView.tag == 1){
        setPriceLabel.text = pickerOfferViewData[row];
        [self animateLabel:setPriceLabel];
    }else{
        NSString * selectedOption = pickerData[component][row];
        if (component == 0){
            popupPriceLabel.text = selectedOption;
            [self animateLabel:popupPriceLabel];
        }else{
            popupConditionLabel.text = selectedOption;
            [self animateLabel:popupConditionLabel];
        }
    }
    
}

-(void)hideHUDAfterSavingEdit:(NSString *)errorDescription
{
    [HUD hide:YES];
    if (errorDescription != nil){
        [self showAlertView:@"Error in Saving Data" withMessage:errorDescription];
    }
}



/*-------------------------Buying Table View---------------------------------------*/
#pragma mark - Table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return IMG_HEIGHT+BOTTOM_MARGIN + SCREEN_WIDTH * 0.28;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (buyingBooksArray == nil){
        return 0;
    }
    return [buyingBooksArray count];
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
    
    if (buyingBooksArray == nil) return nil;
    
    BuyingBooksTableViewCell *cell = [self.buyingBooksTableView dequeueReusableCellWithIdentifier:@"buyingBooksCell"];
    
    
    PFObject * currentOffer = [buyingBooksArray objectAtIndex:indexPath.section];

    PFObject *parentOfferPFObject = [currentOffer objectForKey:@"parent_offer"];
    
    cell.PFObjectID = parentOfferPFObject.objectId;
    
    NSLog(@"Parentofferobject: %@",parentOfferPFObject);
    NSLog(@"object id: %@" ,parentOfferPFObject.objectId);
    
    [parentOfferPFObject fetchIfNeededInBackgroundWithBlock:^(PFObject *parentOfferPFObject, NSError *error) {
        NSLog(@"buying books parent_offer: %@", parentOfferPFObject);
        
        if (!error){
            
            if ([parentOfferPFObject.objectId isEqualToString:cell.PFObjectID]){
                
                if (ICLICKER_ISBN == [[parentOfferPFObject objectForKey:@"isbn"]integerValue]){
                    [cell.imgView sd_setImageWithURL:nil
                                    placeholderImage:[UIImage imageNamed:@"iclicker2.png"]];
                }else{
                    NSString *imgurl = [parentOfferPFObject objectForKey:@"image_url"];
                    if (![imgurl isEqualToString: @"null"]){
                        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:imgurl]
                                        placeholderImage:[UIImage imageNamed:@"noimagepl.png"]];
                    }else{
                        [cell.imgView sd_setImageWithURL:nil
                                        placeholderImage:[UIImage imageNamed:@"noimagepl.png"]];
                    }
                    
                }
                
                cell.title.text = [parentOfferPFObject objectForKey:@"title"];
                cell.author.text = [parentOfferPFObject objectForKey:@"author"];
                cell.conditionLabel.text = [parentOfferPFObject objectForKey:@"condition"];
                cell.price.text = [NSString stringWithFormat:@"$%@",[[parentOfferPFObject objectForKey:@"price"]stringValue]];
                cell.offerPriceLabel.text = [NSString stringWithFormat:@"$%@",[[currentOffer objectForKey:@"current_offer"]stringValue]];

                
                if ([currentOffer objectForKey:@"offerStatus"]){
                    if ([[currentOffer objectForKey:@"offerStatus"] isEqualToString:@"YES"]){
                        cell.offerStatus.text = @"ACCEPTED";
                        cell.offerStatus.textColor = [UIColor greenColor];
                        cell.contactSeller.hidden = NO;
                        cell.makeAnotherOffer.hidden = YES;
                        
                        cell.contactSeller.tag = indexPath.section;
                        [cell.contactSeller addTarget:self action:@selector(contactSellerPressed:) forControlEvents:UIControlEventTouchUpInside];
                        
                    }else if ([[currentOffer objectForKey:@"offerStatus"] isEqualToString:@"NO"]){
                        
                        cell.offerStatus.text = @"DENIED";
                        cell.offerStatus.textColor = [UIColor redColor];
                        cell.contactSeller.hidden = YES;
                        cell.makeAnotherOffer.hidden = NO;
                        cell.makeAnotherOffer.backgroundColor = [UIColor colorWithRed:0.804 green:0.149 blue:0.149 alpha:1]; /*#cd2626*/
                        
                        cell.makeAnotherOffer.tag = indexPath.section;
                        [cell.makeAnotherOffer addTarget:self action:@selector(makeAnotherOfferPressed:) forControlEvents:UIControlEventTouchUpInside];
                    }else{
                        //lost the offer
                        cell.offerStatus.text = @"Your offer didn't win.";
                        cell.offerStatus.textColor = [UIColor redColor];;
                        cell.contactSeller.hidden = YES;
                        cell.makeAnotherOffer.hidden = YES;

                    }
                  
                }else{
                    //there is no value in that field
                    cell.offerStatus.text = @"PENDING";
                    cell.offerStatus.textColor = [UIColor colorWithRed:0 green:0.749 blue:1 alpha:1]; /*#00bfff*/
                    cell.makeAnotherOffer.hidden = NO;
                    cell.contactSeller.hidden = YES;
                    cell.makeAnotherOffer.backgroundColor = [UIColor colorWithRed:0.275 green:0.51 blue:0.706 alpha:0.6];
                    
                    cell.makeAnotherOffer.tag = indexPath.section;
                    [cell.makeAnotherOffer addTarget:self action:@selector(makeAnotherOfferPressed:) forControlEvents:UIControlEventTouchUpInside];
                }
            }
            
            
        }else{
            NSLog(@"Error occured in getting your offers: %@", [error localizedDescription]);
            //[self showAlertView:@"Error occured in getting your offers" withMessage:[error localizedDescription]];
            
        }
    }];
    
    
    return cell;
}


/*-------------------------------Table view functions------------------------------*/

-(void)makeAnotherOfferPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    makeOfferPFObject = [buyingBooksArray objectAtIndex:button.tag];
    makeOfferPFObjectItemNum = button.tag;
    [self animateMakeOfferPopupView];
}

-(void)contactSellerPressed:(id)sender
{
    [self showHUD];
    UIButton *button = (UIButton *)sender;
    PFObject * currentRowItem = [buyingBooksArray objectAtIndex:button.tag];
    PFObject *sellerBook = currentRowItem[@"parent_offer"];
    [sellerBook fetchIfNeededInBackgroundWithBlock:^(PFObject *book, NSError *error) {
        
        if(!error){
            NSString *sellerFbid = book[@"fbid"];
            [self openFacebookMessenger:sellerFbid];
        }else{
            [self showAlertView:@"Error" withMessage:@"Due to an internal error the seller cannot be contacted at this time."];
        }
        [self hideHUD];
        
    }];
    
}

-(void)requestBuyingBooksArrayFromParse:(BOOL)showHUD
{
    if (showHUD){
        [self showHUD];
    }
    PFQuery *fbidQuery = [PFQuery queryWithClassName:@"BookOffers"];
    [fbidQuery whereKey:@"fbid" hasPrefix:fbid];
    [fbidQuery orderByDescending:@"updatedAt"];
    
    [fbidQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu buying books offers.", (unsigned long)objects.count);
            for (PFObject *object in objects) {
                NSLog(@"Buying Books: %@", object);
            }
            
            buyingBooksArray = [NSMutableArray arrayWithArray:objects];
            [self.buyingBooksTableView reloadData];
            
            if ([buyingBooksArray count] == 0){
                if (noBuyingBooksLabel == nil){
                    [self showNoBuyingBooksLabel];
                }
            }else{
                [self removeNoBuyingBooksLabel];
            }
            
            if (showHUD){
                [HUD performAction:M13ProgressViewActionSuccess animated:YES];
            }
            
            [self performSelector:@selector(hideHUDForBuyingBooks:) withObject:[NSArray arrayWithObjects:@(showHUD),@"None", nil] afterDelay:0.4];
            
        } else {
            if (showHUD){
                [HUD performAction:M13ProgressViewActionFailure animated:YES];
            }
            
            [self performSelector:@selector(hideHUDForBuyingBooks:) withObject:[NSArray arrayWithObjects:@(showHUD),[error localizedDescription], nil] afterDelay:0.4];
        }
        
        if (!showHUD){
            [buyingRefreshControl endRefreshing];
        }
    }];
}

-(void)hideHUDForBuyingBooks:(NSArray *)objectArray
{
    if ([objectArray[0] isEqual:@YES]){
        [HUD hide:YES];
    }
    
    if (![objectArray[1] isEqualToString:@"None"]){
        [self showAlertView:@"Error in retrieving offers you have previously made" withMessage:objectArray[1]];
    }
}

-(void)configBuyingBooksTableView
{
    self.buyingBooksTableView.delegate = self;
    self.buyingBooksTableView.dataSource = self;
    self.buyingBooksTableView.frame = CGRectMake(0, sellingButton.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT-(sellingButton.frame.size.height));
    
    UIImageView *backgroundLogo = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-(SCREEN_WIDTH-100))/2, -(SCREEN_WIDTH-100), SCREEN_WIDTH-100, SCREEN_WIDTH-100)];
    backgroundLogo.image = [UIImage imageNamed:@"backgroundLogo.png"];
    [self.buyingBooksTableView addSubview:backgroundLogo];
    
    
    buyingRefreshControl = [[UIRefreshControl alloc] init];
    buyingRefreshControl.tintColor = [UIColor whiteColor];
    [buyingRefreshControl addTarget:self action:@selector(buyingRefreshControlStatus)
             forControlEvents:UIControlEventValueChanged];
    [self.buyingBooksTableView addSubview:buyingRefreshControl];
}

/*---------------------------Make Another Offer View---------------------------------*/

-(void)createMakeOfferPopupView
{
    makeOfferBackground = [[UIView alloc]initWithFrame:CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGHT-50)];
    makeOfferBackground.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.7];
    [self.view addSubview:makeOfferBackground];
    
    UIView *makeOfferPopupView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-100, SCREEN_HEIGHT *0.6)];
    makeOfferPopupView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    makeOfferPopupView.backgroundColor = [UIColor colorWithRed:0.098 green:0.318 blue:0.639 alpha:0.8]; /*#1951a3*/
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
    myPickerView.tag = 1;
    myPickerView.showsSelectionIndicator = YES;
    [makeOfferPopupView addSubview:myPickerView];
    
    UIButton *submitButton = [[UIButton alloc]initWithFrame:CGRectMake(0, myPickerView.frame.origin.y + myPickerView.frame.size.height, makeOfferPopupView.frame.size.width, 20)];
    [submitButton setTitle:@"SUBMIT" forState:UIControlStateNormal];
    [submitButton.titleLabel setFont:[UIFont fontWithName:@"Avenir-Black" size:20]];
    [submitButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(makeOfferSubmitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [submitButton setShowsTouchWhenHighlighted:YES];
    [makeOfferPopupView addSubview:submitButton];
    
    [makeOfferBackground setHidden: YES];
}

-(void)makeOfferSubmitButtonPressed:(id)sender
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm"
                                                    message: [NSString stringWithFormat:@"By submitting this offer of %@, I am abiding by Acebook's community rule to only make legitimate offers.", setPriceLabel.text]
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Confirm", nil];
    alert.tag = 3;
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

/*-------------- Selling Collection View Delegate Methods ONLY------------------------*/

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (collectionView.tag == 2){
        if (offersArray == nil) return 0;
        return [offersArray count];
    }
    if (sellingBooksArray == nil) return 0;
    return [sellingBooksArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView.tag == 2){
        OfferCollectionViewCell *cell = (OfferCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"offerCollectionViewCell" forIndexPath:indexPath];
        cell.offerPriceLabel.text = [NSString stringWithFormat:@"$%@",[([offersArray objectAtIndex:indexPath.item][@"current_offer"])stringValue]];
        return cell;
    }
    
    SellingCollectionViewCell *cell = (SellingCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"sellingBooksCell" forIndexPath:indexPath];
    PFObject *eachIndex = [sellingBooksArray objectAtIndex:indexPath.item];
    
    if (ICLICKER_ISBN == [[eachIndex objectForKey:@"isbn"]integerValue]){
        [cell.imgView sd_setImageWithURL:nil
                        placeholderImage:[UIImage imageNamed:@"iclicker2.png"]];
    }else{
        if ([[eachIndex objectForKey:@"image_url"] isEqualToString:@"null"]){
            [cell.imgView sd_setImageWithURL:nil
                            placeholderImage:[UIImage imageNamed:@"noimagepl.png"]];
        }else{
            [cell.imgView sd_setImageWithURL:[NSURL URLWithString:[eachIndex objectForKey:@"image_url"]]
                            placeholderImage:[UIImage imageNamed:@"noimagepl.png"]];
        }
    }
    
    
    cell.title.text = [eachIndex objectForKey:@"title"];
    cell.author.text = [NSString stringWithFormat:@"By %@", [eachIndex objectForKey:@"author"]];
    
    
    if ([defaultsDict objectForKey:eachIndex.objectId]){
        cell.sellingOfferIndicator.hidden = NO;
    }else{
        cell.sellingOfferIndicator.hidden = YES;
    }
    
    return cell;
}
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView.tag == 1){ //seller's collection view
        [self showHUD];
        selectedBookPFObject = [sellingBooksArray objectAtIndex:indexPath.item];
        
        if ([defaultsDict objectForKey:selectedBookPFObject.objectId]){
            [defaultsDict removeObjectForKey:selectedBookPFObject.objectId];
            
            [[NSUserDefaults standardUserDefaults]setObject:defaultsDict forKey:@"sellingBooksDict"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            SellingCollectionViewCell *cell = (SellingCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
            cell.sellingOfferIndicator.hidden = YES;
        }
        
        [self loadAllValuesForOfferView];
    
    }else{ //offer collection view
        
        selectedOfferPFObject = [offersArray objectAtIndex:indexPath.item];
        selectedOfferItemIndex = indexPath.item;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Accept offer of %@",[NSString stringWithFormat:@"$%@",[([offersArray objectAtIndex:indexPath.item][@"current_offer"])stringValue]]]
                                                        message: @"You cannot undo this action."
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Deny", @"Accept", nil];
        alert.tag = 2;
        [alert show];
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {

    
}

-(void) collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{

    if (collectionView.tag == 2){
        OfferCollectionViewCell *cell = (OfferCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
        previousHighlightColor = cell.backgroundColorLabel.backgroundColor;
        cell.backgroundColorLabel.backgroundColor = [UIColor colorWithRed:0.69 green:0.09 blue:0.122 alpha:1]; /*#b0171f*/
    }
    
}

-(void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (collectionView.tag == 2){
        OfferCollectionViewCell *cell = (OfferCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
        cell.backgroundColorLabel.backgroundColor = previousHighlightColor;
    }
}

#pragma mark – UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView.tag == 2){
        return CGSizeMake(SCREEN_WIDTH * 0.25, SCREEN_WIDTH * 0.25);
    }
    return CGSizeMake(IMG_WIDTH *1.5, (IMG_HEIGHT *1.2) + (SCREEN_HEIGHT * 0.15));
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (collectionView.tag == 2){
        return UIEdgeInsetsMake(5, 5, 5, 5);
    }
    return UIEdgeInsetsMake(15, 5, 25, 5);
    
}

/*-----------------------Config Selling Collection View------------------------------*/

-(void)configSellingCollectionView
{
    self.sellingCollectionView.delegate = self;
    self.sellingCollectionView.dataSource = self;
    self.sellingCollectionView.tag = 1;
    self.sellingCollectionView.frame = CGRectMake(0, sellingButton.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT-(sellingButton.frame.size.height));
    self.sellingCollectionView.hidden = YES;
    
    UIImageView *backgroundLogo = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-(SCREEN_WIDTH-100))/2, -(SCREEN_WIDTH-100), SCREEN_WIDTH-100, SCREEN_WIDTH-100)];
    backgroundLogo.image = [UIImage imageNamed:@"backgroundLogo.png"];
    [self.sellingCollectionView addSubview:backgroundLogo];
    
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refreshControlStatus)
             forControlEvents:UIControlEventValueChanged];
    [self.sellingCollectionView addSubview:refreshControl];
}
/*-----------------------------------------------------------------------------------*/
-(void)hideHUDAfterMakingOffer:(NSString *)errorDescription
{
    [HUD hide:YES];
    if (errorDescription != nil){
        [self showAlertView:@"Error in retrieving offers" withMessage:errorDescription];
    }
}

/*-----------------------Offer View in Selling Collection View-----------------------*/

-(void)createCollectionViewCellPopupView
{
    int commonHeightofLabel = 27;
    self.blackBackgroundPopupView.frame = CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGHT-50);
    self.blackBackgroundPopupView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.7];
    self.blackBackgroundPopupView.hidden = YES;
    [self.view addSubview:self.blackBackgroundPopupView];
    
    UIView *offerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-50, SCREEN_HEIGHT *0.80)];
    offerView.center = CGPointMake(SCREEN_WIDTH/2, (SCREEN_HEIGHT/2)-commonHeightofLabel);
    offerView.backgroundColor = [UIColor colorWithRed:0.18 green:0.18 blue:0.18 alpha:0.8];
    offerView.layer.cornerRadius = 10;
    offerView.clipsToBounds = YES;
    [self.blackBackgroundPopupView addSubview: offerView];
    
    editButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0, offerView.frame.size.width, 30)];
    [editButton setTitle:@"EDIT" forState:UIControlStateNormal];
    [editButton.titleLabel setFont:[UIFont fontWithName:@"Avenir-Black" size:20]];
    [editButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(editButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [editButton setShowsTouchWhenHighlighted:YES];
    [offerView addSubview:editButton];
    
    UIButton * removeButton = [[UIButton alloc]initWithFrame:CGRectMake(offerView.frame.size.width - (offerView.frame.size.width/4), 3, offerView.frame.size.width/4, 20)];
    [removeButton setTitle:@"Remove" forState:UIControlStateNormal];
    [removeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [removeButton.titleLabel setFont:[UIFont fontWithName:@"Avenir-Roman" size:16]];
    removeButton.showsTouchWhenHighlighted = YES;
    [removeButton addTarget:self action:@selector(removeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [offerView addSubview: removeButton];
    
    UIButton *closeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [closeButton setImage:[UIImage imageNamed:@"closebutton.png"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeOfferView) forControlEvents:UIControlEventTouchUpInside];
    [offerView addSubview:closeButton];
    
    
    popupTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(LEFT_MARGIN/2, closeButton.frame.origin.y + closeButton.frame.size.height, offerView.frame.size.width - RIGHT_MARGIN, 50)];
    popupTitleLabel.textAlignment = NSTextAlignmentCenter;
    popupTitleLabel.numberOfLines = 0;
    popupTitleLabel.textColor = [UIColor whiteColor];
    popupTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail |NSLineBreakByWordWrapping;
    popupTitleLabel.adjustsFontSizeToFitWidth= YES;
    popupTitleLabel.font = [UIFont fontWithName:@"Avenir-Black" size:16];
    popupTitleLabel.minimumScaleFactor = 0.6;
    [offerView addSubview:popupTitleLabel];
    
    popupAuthorLabel= [[UILabel alloc]initWithFrame:CGRectMake(0,popupTitleLabel.frame.origin.y + popupTitleLabel.frame.size.height, offerView.frame.size.width, commonHeightofLabel)];
    popupAuthorLabel.textAlignment = NSTextAlignmentCenter;
    popupAuthorLabel.textColor = [UIColor whiteColor];
    popupAuthorLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:16];
    [offerView addSubview:popupAuthorLabel];
    
    UILabel *staticConditionLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, popupAuthorLabel.frame.origin.y + popupAuthorLabel.frame.size.height, (offerView.frame.size.width/2)-RIGHT_MARGIN, commonHeightofLabel)];
    staticConditionLabel.textColor = [UIColor whiteColor];
    staticConditionLabel.textAlignment = NSTextAlignmentRight;
    staticConditionLabel.text = @"Condition:";
    staticConditionLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:16];
    [offerView addSubview:staticConditionLabel];
    
    popupConditionLabel = [[UILabel alloc]initWithFrame:CGRectMake(offerView.frame.size.width/2, popupAuthorLabel.frame.origin.y + popupAuthorLabel.frame.size.height, offerView.frame.size.width/2, commonHeightofLabel)];
    popupConditionLabel.textColor = [UIColor whiteColor];
    popupConditionLabel.textAlignment = NSTextAlignmentLeft;
    popupConditionLabel.font = [UIFont fontWithName:@"Avenir-Black" size:17];
    [offerView addSubview:popupConditionLabel];
    
    UILabel *staticPriceLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, staticConditionLabel.frame.origin.y + staticConditionLabel.frame.size.height, (offerView.frame.size.width/2)-RIGHT_MARGIN, commonHeightofLabel)];
    staticPriceLabel.textColor = [UIColor whiteColor];
    staticPriceLabel.textAlignment = NSTextAlignmentRight;
    staticPriceLabel.text = @"Price:";
    staticPriceLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:16];
    [offerView addSubview:staticPriceLabel];

    
    popupPriceLabel = [[UILabel alloc]initWithFrame:CGRectMake(offerView.frame.size.width/2, popupConditionLabel.frame.origin.y + popupConditionLabel.frame.size.height, offerView.frame.size.width/2, commonHeightofLabel)];
    popupPriceLabel.textColor = [UIColor whiteColor];
    popupPriceLabel.textAlignment = NSTextAlignmentLeft;
    popupPriceLabel.font = [UIFont fontWithName:@"Avenir-Black" size:17];
    [offerView addSubview:popupPriceLabel];
    
    staticOfferLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, staticPriceLabel.frame.origin.y + staticPriceLabel.frame.size.height , offerView.frame.size.width, commonHeightofLabel + 10)];
    staticOfferLabel.textColor = [UIColor colorWithRed:0 green:0.749 blue:1 alpha:1]; /*#00bfff*/
    staticOfferLabel.textAlignment = NSTextAlignmentCenter;
    staticOfferLabel.numberOfLines = 0;
    staticOfferLabel.font = [UIFont fontWithName:@"Avenir-Black" size:16];
    staticOfferLabel.adjustsFontSizeToFitWidth = YES;
    [offerView addSubview:staticOfferLabel];
    
    [self.offerCollectionView removeFromSuperview];
    
    float bottomOfferViewY = BOTTOM_MARGIN/2 + staticOfferLabel.frame.origin.y + staticOfferLabel.frame.size.height;
    float bottomOfferViewHeight = offerView.frame.size.height - (staticOfferLabel.frame.origin.y + staticOfferLabel.frame.size.height);
    float bottomOfferViewWidth = offerView.frame.size.width;
    
    [self.offerCollectionView setFrame:CGRectMake(0, bottomOfferViewY,bottomOfferViewWidth, bottomOfferViewHeight)];
    [offerView addSubview: self.offerCollectionView];
    
    pickerBaseView = [[UIView alloc]initWithFrame:CGRectMake(0,bottomOfferViewY,bottomOfferViewWidth, bottomOfferViewHeight)];
    pickerBaseView.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:0.231 green:0.216 blue:0.216 alpha:1.0];
    pickerBaseView.hidden = YES;
    [offerView addSubview:pickerBaseView];
    
    
    acceptedOfferView =[[UIView alloc]initWithFrame:CGRectMake(0, bottomOfferViewY, bottomOfferViewWidth, bottomOfferViewHeight)];
    acceptedOfferView.hidden = YES;
    [offerView addSubview:acceptedOfferView];
    
    
    UILabel *backgroundColorLabel = [[UILabel alloc]initWithFrame:CGRectMake((bottomOfferViewWidth -(SCREEN_WIDTH * 0.45))/2, ((bottomOfferViewHeight-commonHeightofLabel) -(SCREEN_WIDTH * 0.45))/2, SCREEN_WIDTH * 0.45, SCREEN_WIDTH * 0.45)];
    backgroundColorLabel.backgroundColor = [self getRandomColor];
    backgroundColorLabel.layer.cornerRadius = (SCREEN_WIDTH * 0.45)/2;
    backgroundColorLabel.layer.masksToBounds = YES;
    [acceptedOfferView addSubview: backgroundColorLabel];
    
    acceptedOfferPriceLabel = [[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH * 0.05)/2, (SCREEN_WIDTH * 0.05)/2, SCREEN_WIDTH * 0.40, SCREEN_WIDTH * 0.40)];
    acceptedOfferPriceLabel.backgroundColor = [UIColor whiteColor];
    acceptedOfferPriceLabel.layer.cornerRadius = (SCREEN_WIDTH *0.40)/2;
    acceptedOfferPriceLabel.layer.masksToBounds = YES;
    acceptedOfferPriceLabel.font = [UIFont fontWithName:@"Avenir-Black" size:32];
    acceptedOfferPriceLabel.numberOfLines = 1;
    acceptedOfferPriceLabel.textAlignment = NSTextAlignmentCenter;
    [backgroundColorLabel addSubview:acceptedOfferPriceLabel];
    
    UIImageView *acceptedCheckmarkImg = [[UIImageView alloc]initWithFrame:CGRectMake(RIGHT_MARGIN + backgroundColorLabel.frame.origin.x+ backgroundColorLabel.frame.size.width, ((backgroundColorLabel.frame.size.height + backgroundColorLabel.frame.origin.y)-50)/2, 50, 50)];
    acceptedCheckmarkImg.image = [UIImage imageNamed:@"checkmark.png"];
    [acceptedOfferView addSubview:acceptedCheckmarkImg];
    
    UIButton * contactBuyerButton = [[UIButton alloc]initWithFrame:CGRectMake(0, bottomOfferViewHeight- 2*commonHeightofLabel, bottomOfferViewWidth, 2*commonHeightofLabel)];
    [contactBuyerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [contactBuyerButton setTitle:@"Contact Buyer" forState:UIControlStateNormal];
    [contactBuyerButton.titleLabel setFont:[UIFont fontWithName:@"Avenir-Medium" size:18]];
    [contactBuyerButton setShowsTouchWhenHighlighted:YES];
    contactBuyerButton.backgroundColor = [UIColor colorWithRed:0.075 green:0.22 blue:0.439 alpha:1];/*#133870*/
    [contactBuyerButton addTarget:self action:@selector(contactBuyerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [acceptedOfferView addSubview:contactBuyerButton];
}

-(void)removeButtonPressed:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to remove this item?"
                                                    message: @"You cannot undo this action."
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Remove", nil];
    alert.tag = 4;
    [alert show];
}

-(void)setupOfferArray:(NSArray *)objects refreshStatus:(BOOL)fromRefreshing
{
    NSLog(@"0 index is not YES in offersArray");
    offersArray = [NSMutableArray arrayWithArray:objects];
    [HUD performAction:M13ProgressViewActionSuccess animated:YES];
    [self performSelector:@selector(hideHUDAfterMakingOffer:) withObject:nil afterDelay:0.4];
    
    [self setOfferTitle];
    if (fromRefreshing)
        [offerViewRefreshControl endRefreshing];
    if ([editButton isHidden]){
        editButton.hidden = NO;
    }
    if (![acceptedOfferView isHidden]){
        [self animateDownAcceptedOfferView];
    }
    
    [self.offerCollectionView reloadData];
}
-(void)setOfferTitle
{
    NSLog(@"offersarray: %@",offersArray);
    if (offersArray == nil){ //will be nil when an offer is already accepted
        NSLog(@"inside title");
        staticOfferLabel.text = @"Accepted Offer of:";
    }else if ([offersArray count] == 0){
        staticOfferLabel.text = @"No offers have been made so far.";
    } else{
        staticOfferLabel.text = @"Offers Made So Far: \n (Select to accept/deny)";
    }
}


-(void)reloadValuesAfterSave
{
    popupConditionLabel.text = [selectedBookPFObject objectForKey:@"condition"];
    
    NSNumber *price = [selectedBookPFObject objectForKey:@"price"];
    if ([price isEqual:[NSNumber numberWithInt:0]]){
        popupPriceLabel.text = @"Free";
    }else{
        popupPriceLabel.text = [NSString stringWithFormat:@"$%@",[price stringValue]];
    }
    
}
-(void)loadAllValuesForOfferView
{
    popupTitleLabel.text = [selectedBookPFObject objectForKey:@"title"];
    popupAuthorLabel.text = [NSString stringWithFormat:@"By %@",[selectedBookPFObject objectForKey:@"author"]];
    popupConditionLabel.text = [selectedBookPFObject objectForKey:@"condition"];
    
    NSNumber *price = [selectedBookPFObject objectForKey:@"price"];
    if ([price isEqual:[NSNumber numberWithInt:0]]){
        popupPriceLabel.text = @"Free";
    }else{
        popupPriceLabel.text = [NSString stringWithFormat:@"$%@",[price stringValue]];
    }
    
    [self loadAllOffersofSelectedBook:NO];
    [self animateOfferPopupView];
    
}
-(void)loadAllOffersofSelectedBook:(BOOL)fromRefreshing
{
    PFQuery *query = [PFQuery queryWithClassName:@"BookOffers"];
    [query whereKey:@"parent_offer" equalTo:selectedBookPFObject];
    [query whereKey:@"offerStatus" notEqualTo:@"NO"]; //only get YES or undefined (blank) slots
    [query orderByDescending:@"offerStatus"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            //Success
            NSLog(@"Successfully retrieved %lu offers.", (unsigned long)objects.count);
            // Do something with the found objects
            for (PFObject *object in objects) {
                NSLog(@"%@", object);
            }
            
            BOOL acceptedOffer;
            //0 index will always be true by descending order if there are any True booleans that match the query
            if ([objects count] != 0){
                if ([[objects objectAtIndex:0] objectForKey:@"offerStatus"]){
                    if ([[objects objectAtIndex:0][@"offerStatus"] isEqual: @"YES"]){
                        //only display the accepted offer view, not the collection view
                        
                        acceptedOffer = YES;
                        offersArray = nil;
                        selectedOfferPFObject = [objects objectAtIndex:0];
                        [HUD performAction:M13ProgressViewActionSuccess animated:YES];
                        [self performSelector:@selector(hideHUDAfterMakingOffer:) withObject:nil afterDelay:0.4];
                        [self setOfferTitle];
                        editButton.hidden = YES;
                        acceptedOfferPriceLabel.text = [NSString stringWithFormat:@"$%@",[selectedOfferPFObject[@"current_offer"]stringValue]];
                        [self animateUpAcceptedOfferView];
                    }
                }
            }
            
            if(!acceptedOffer){
                [HUD performAction:M13ProgressViewActionSuccess animated:YES];
                [self performSelector:@selector(hideHUDAfterMakingOffer:) withObject:nil afterDelay:0.4];
                [self setupOfferArray:objects refreshStatus:fromRefreshing];
                
            }
            
        } else {
            [HUD performAction:M13ProgressViewActionFailure animated:YES];
            [self performSelector:@selector(hideHUDAfterMakingOffer:) withObject:[error localizedDescription] afterDelay:0.4];
        }
    }];
}


/*-------------------------------Offer view button methods--------------------------*/
-(void)openFacebookMessenger:(NSString*)buyerfbid
{
    if(buyerfbid){
        
        NSString *mfbid = [NSString stringWithFormat:@"fb-messenger://user-thread/%@",buyerfbid];
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:mfbid]])
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mfbid]];
        }else{
            
            NSString *fbString = [NSString stringWithFormat:@"fb://profile/%@", buyerfbid];
            NSURL *nsurl =[NSURL URLWithString:fbString];
            if ([[UIApplication sharedApplication] canOpenURL:nsurl]){
                [[UIApplication sharedApplication] openURL:nsurl];
            
            }else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.facebook.com/%@", buyerfbid]]]){
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.facebook.com/%@", buyerfbid]]];
            }else{
                [self showAlertView:@"Error" withMessage:@"Having trouble directing you to seller's profile. Please try again."];
            }
        }
    }else{
        [self showAlertView:@"Error" withMessage:@"Unable to retrieve seller info. Please try again."];
    }
    
}

-(void)editButtonPressed:(id)sender
{
    if ([pickerBaseView isHidden]){
        [self animateUpEditView];
        staticOfferLabel.text = @"Edit and save your changes below";
        [self animateLabel:staticOfferLabel];
    }else{
        [self animateDownEditView:YES];

    }
}
-(void)contactBuyerButtonPressed:(id)sender
{
    [self openFacebookMessenger:[selectedOfferPFObject objectForKey:@"fbid"]];
}

/*-----------------------------TOP VIEW BAR-----------------------------------------*/

-(void)setupTopBarView
{
    UIView *topBuyingView =[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/2, -SCREEN_HEIGHT * 0.035 + SCREEN_HEIGHT * 0.11)];
    topBuyingView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *singleTapBuyingView =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(singleTapBuyingView:)];
    [topBuyingView addGestureRecognizer:singleTapBuyingView];
    [self.view addSubview:topBuyingView];
    
    UIView *topSellingView =[[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2, 0, SCREEN_WIDTH/2, -SCREEN_HEIGHT * 0.035 + SCREEN_HEIGHT * 0.11)];
    UITapGestureRecognizer *singleTapSellingView =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(singleTapSellingView:)];
    [topSellingView addGestureRecognizer:singleTapSellingView];
    topSellingView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:topSellingView];
    

    buyingButton = [[UIButton alloc]initWithFrame:CGRectMake((topBuyingView.frame.size.width - topBuyingView.frame.size.height)/2, 0, topBuyingView.frame.size.height, topBuyingView.frame.size.height)];
    [buyingButton setShowsTouchWhenHighlighted:YES];
    [buyingButton setContentVerticalAlignment:UIControlContentVerticalAlignmentBottom];
    [buyingButton setTitle:@"Buying" forState:UIControlStateNormal];
    [buyingButton.titleLabel setFont:[UIFont fontWithName:@"Avenir-Roman" size:11]];
    [buyingButton addTarget:self action:@selector(buyingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [topBuyingView addSubview:buyingButton];

    cartImg = [[UIImageView alloc]initWithFrame:CGRectMake((buyingButton.frame.size.width - 35)/2, 0, 35, 35)];
    cartImg.image = [UIImage imageNamed:@"cart.png"];
    [buyingButton addSubview:cartImg];
    
    
    sellingButton = [[UIButton alloc]initWithFrame:CGRectMake((topSellingView.frame.size.width -topSellingView.frame.size.height)/2 , 0, topSellingView.frame.size.height, topSellingView.frame.size.height)];
    [sellingButton setShowsTouchWhenHighlighted:YES];
    [sellingButton setContentVerticalAlignment:UIControlContentVerticalAlignmentBottom];
    [sellingButton setTitle:@"Selling" forState:UIControlStateNormal];
    [sellingButton.titleLabel setFont:[UIFont fontWithName:@"Avenir-Roman" size:11]];
    [sellingButton addTarget:self action:@selector(sellingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [topSellingView addSubview:sellingButton];
    
    dollarImg = [[UIImageView alloc]initWithFrame:CGRectMake((sellingButton.frame.size.width - 35)/2, 0, 35, 35)];
    dollarImg.image = [UIImage imageNamed:@"dollarcirclegrayscale.png"];
    [sellingButton addSubview:dollarImg];
    
    buyingSelected = YES;
    [self addHighlightView:topBuyingView];
}

- (void)singleTapBuyingView:(UITapGestureRecognizer *)recognizer {
    [self setBuyingButtonSelected];
}

- (void)singleTapSellingView:(UITapGestureRecognizer *)recognizer {
    [self setSellingButtonSelected];
}
-(void)buyingButtonPressed:(id)sender
{
    [self setBuyingButtonSelected];
}
-(void)sellingButtonPressed:(id)sender
{
    [self setSellingButtonSelected];
}

-(void)setBuyingButtonSelected
{
    if(!buyingSelected){
        dollarImg.image = [UIImage imageNamed:@"dollarcirclegrayscale.png"];
        cartImg.image = [UIImage imageNamed:@"cart.png"];
        buyingSelected = YES;
        [self removeHighlightView:[sellingButton superview]];
        [self addHighlightView:[buyingButton superview]];
        [self animateDownSellingCollectionView];
    }

}
-(void)setSellingButtonSelected
{
    if(buyingSelected){
        cartImg.image = [UIImage imageNamed:@"cartgrayscale.png"];
        dollarImg.image = [UIImage imageNamed:@"dollarcircle.png"];
        buyingSelected = NO;
        [self removeHighlightView:[buyingButton superview]];
        [self addHighlightView:[sellingButton superview]];
        [self animateUpSellingCollectionView];
    }

}
-(void)addHighlightView:(UIView *)view
{
    [view setBackgroundColor:[UIColor colorWithRed:0.22 green:0.22 blue:0.22 alpha:1] /*#383838*/];
}

-(void)removeHighlightView:(UIView *)view
{
    [view setBackgroundColor:[UIColor clearColor]];
}


/*-----------------------------------Zero Output Label--------------------------------*/
-(void)showNoBuyingBooksLabel
{
    noBuyingBooksLabel = [[UILabel alloc]initWithFrame:CGRectMake(20,0, SCREEN_WIDTH-40, self.buyingBooksTableView.frame.size.height)];
    noBuyingBooksLabel.font = [UIFont fontWithName:@"Avenir-Book" size:20];
    noBuyingBooksLabel.text = @"You currently have not made any offers to a seller.";
    noBuyingBooksLabel.numberOfLines = 0;
    noBuyingBooksLabel.textAlignment = NSTextAlignmentCenter;
    noBuyingBooksLabel.textColor = [UIColor whiteColor];
    noBuyingBooksLabel.backgroundColor = [UIColor clearColor];
    [self.buyingBooksTableView addSubview:noBuyingBooksLabel];
}
-(void)removeNoBuyingBooksLabel
{
    [noBuyingBooksLabel removeFromSuperview];
    noBuyingBooksLabel = nil;
}

-(void)showNoSellingBooksLabel
{
    noSellingBooksLabel = [[UILabel alloc]initWithFrame:CGRectMake(20,0, SCREEN_WIDTH-40, self.sellingCollectionView.frame.size.height)];
    noSellingBooksLabel.font = [UIFont fontWithName:@"Avenir-Book" size:20];
    noSellingBooksLabel.text = @"You are not currently selling any books. Swipe left to the very end to list a book.";
    noSellingBooksLabel.numberOfLines = 0;
    noSellingBooksLabel.textAlignment = NSTextAlignmentCenter;
    noSellingBooksLabel.textColor = [UIColor whiteColor];
    noSellingBooksLabel.backgroundColor = [UIColor clearColor];
    [self.sellingCollectionView addSubview:noSellingBooksLabel];
}
-(void)removeNoSellingBooksLabel
{
    [noSellingBooksLabel removeFromSuperview];
    noSellingBooksLabel = nil;
}



/*------------------------------Controller Animations---------------------------------*/
-(void)animateUpAcceptedOfferView
{
    NSLog(@"animating acceptedOfferView");
    acceptedOfferView.transform = CGAffineTransformMakeScale(0.2, 0.2);
    acceptedOfferView.hidden = NO;
    [UIView animateWithDuration:0.20 delay:0.0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         acceptedOfferView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         self.offerCollectionView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.01, 0.01);
                         
                     }
                     completion:^(BOOL finished){
                         if(finished){
                             self.offerCollectionView.hidden = YES;
                         }
                     }];
}

-(void)animateDownAcceptedOfferView
{
    [UIView animateWithDuration:0.20 delay:0.0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         acceptedOfferView.transform =CGAffineTransformScale(CGAffineTransformIdentity, 0.01, 0.01);
                         self.offerCollectionView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                         
                         
                     }
                     completion:^(BOOL finished){
                         if(finished){
                             self.offerCollectionView.hidden = NO;
                             acceptedOfferView.hidden = YES;
                         }
                     }];

}

-(void)animateUpEditView
{
    pickerBaseView.transform = CGAffineTransformMakeScale(0.2, 0.2);
    pickerBaseView.hidden = NO;
    [UIView animateWithDuration:0.20 delay:0.0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         pickerBaseView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         self.offerCollectionView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.01, 0.01);
                         
                     }
                     completion:^(BOOL finished){
                         if(finished){
                             self.offerCollectionView.hidden = YES;
                         }
                     }];
}

-(void)animateDownEditView:(BOOL)needToResetValues
{
    [UIView animateWithDuration:0.20 delay:0.0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         pickerBaseView.transform =CGAffineTransformScale(CGAffineTransformIdentity, 0.01, 0.01);
                         self.offerCollectionView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
        
                         
                     }
                     completion:^(BOOL finished){
                         if(finished){
                             self.offerCollectionView.hidden = NO;
                             pickerBaseView.hidden = YES;
                             [self reloadValuesAfterSave];
                             [self setOfferTitle];
                             
                         }
                     }];
}

-(void)animateUpSellingCollectionView
{
   
    [self animateDownBuyingBooksTableView];
    
}
-(void)animateDownSellingCollectionView
{
    [UIView animateWithDuration:0.20 delay:0.0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.sellingCollectionView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.01, 0.01);
                         
                     }
                     completion:^(BOOL finished){
                         if(finished){
                             self.sellingCollectionView.hidden = YES;
                             [self animateUpBuyingBooksTableView];
                         }
                     }];
}
-(void)animateUpBuyingBooksTableView
{
    
    self.buyingBooksTableView.transform = CGAffineTransformMakeScale(0.2, 0.2);
    self.buyingBooksTableView.hidden = NO;
    [UIView animateWithDuration:0.20 delay:0.0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.buyingBooksTableView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         
                     }
                     completion:^(BOOL finished){
                         
                         NSLog(@"buying collectionview: %@", self.buyingBooksTableView);
                         NSLog(@"is hidden or not: %@", [self.buyingBooksTableView isHidden]?@"YES":@"NO");
                     }];
}
-(void)animateDownBuyingBooksTableView
{
    [UIView animateWithDuration:0.20 delay:0.0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.buyingBooksTableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.01, 0.01);
                         
                     }
                     completion:^(BOOL finished){
                         
                             NSLog(@"called");
                             self.buyingBooksTableView.hidden = YES;
                             self.sellingCollectionView.transform = CGAffineTransformMakeScale(0.2, 0.2);
                             self.sellingCollectionView.hidden = NO;
                             [UIView animateWithDuration:0.20 delay:0.0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                                              animations:^{
                                                  self.sellingCollectionView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                  
                                              }
                                              completion:^(BOOL finished){
                                                  NSLog(@"selling collectionview: %@", self.sellingCollectionView);
                                                  NSLog(@"is hidden or not: %@", [self.sellingCollectionView isHidden]?@"YES":@"NO");
                                                  
                                                  NSLog(@"buying collectionview: %@", self.buyingBooksTableView);
                                                  NSLog(@"is hidden or not: %@", [self.buyingBooksTableView isHidden]?@"YES":@"NO");
                                              }];
                         
                     }];
}

-(void)animateLabel:(UILabel *)labelToAnimate
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         labelToAnimate.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.7, 1.7);
                     } completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:0.2
                                          animations:^{
                                              labelToAnimate.transform = CGAffineTransformIdentity;
                                          } completion:^(BOOL finished) {
                                              
                                          }];
                         
                     }];
}

- (void)animateOfferPopupView
{
    self.blackBackgroundPopupView.hidden = NO;
    self.blackBackgroundPopupView.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.blackBackgroundPopupView.alpha = 0;
    [UIView animateWithDuration:.25 animations:^{
        self.blackBackgroundPopupView.alpha = 1;
        self.blackBackgroundPopupView.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)removeAnimateOfferview
{
    [UIView animateWithDuration:.25 animations:^{
        self.blackBackgroundPopupView.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.blackBackgroundPopupView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.blackBackgroundPopupView setHidden:YES];
        }
    }];
}

/*---------------------------------HUD-----------------------------------------------*/
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
-(void)hideHUD
{
    [HUD hide:YES];
    [HUD performAction:M13ProgressViewActionNone animated:NO];
}

/*-----------------------------------------------------------------------------------*/

-(UIColor *)getRandomColor
{
    UIColor *randomRGBColor = [[UIColor alloc] initWithRed:arc4random()%256/256.0 green:arc4random()%256/256.0 blue:arc4random()%256/256.0 alpha:1.0];
    return randomRGBColor;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end