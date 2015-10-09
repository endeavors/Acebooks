//
//  SellBooksController.m
//  AceBooks
//
//  Created by Gurkirat Singh on 3/7/15.
//  Copyright (c) 2015 AceBooks. All rights reserved.
//

#import "SellBooksController.h"
#import "SellBooksCollectionViewCell.h"
#import "CardTableViewCell.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "ViewController.h"
#import "M13ProgressHUD.h"
#import "MainPagerController.h"
#import "M13ProgressViewRing.h"

@interface SellBooksController ()
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) UIView * topView;

@end

@implementation SellBooksController{
    NSArray *pickerData;
    float lastOffset;
    NSMutableDictionary * bookOptions;
    NSIndexPath *selectedItemIndexPath;
    M13ProgressHUD * HUD;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    
    NSMutableArray * priceData = [[NSMutableArray alloc]init];
    for (int i = 0; i <= 500; i++){
        if (i == 0){
            [priceData addObject:@"Free"];
        }else{
            [priceData addObject:[NSString stringWithFormat:@"$%d",i]];
        }
    }
    NSLog(@"price %lu", (unsigned long)[priceData count]);
    pickerData = @[priceData,
                    @[@"New", @"Used", @"Minor Wear", @"Poor"]];
    NSLog(@"count: %lu", (unsigned long)[pickerData count]);
    self.bottomView.frame = CGRectMake(0,SCREEN_HEIGHT,SCREEN_WIDTH,self.bottomView.frame.size.height);
    bookOptions = [[NSMutableDictionary alloc]init];
    [self configCollectionView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self initHUD];
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
    HUD.status = @"Processing Request";
    [HUD show:YES];
}
-(void)hideHUD:(M13ProgressViewAction)action
{
    [HUD hide:YES];
    [HUD performAction:action animated:YES];
}

/*--------------------------------------Collection View-------------------------------------------*/

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.isbnArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SellBooksCollectionViewCell *cell = (SellBooksCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"SellBooksCell" forIndexPath:indexPath];
    
    NSDictionary *keyWeNeed = [self.isbnArray objectAtIndex:indexPath.item];
    NSDictionary *infoDict = [keyWeNeed objectForKey:[keyWeNeed allKeys][0]];
    
   

    if (ICLICKER_ISBN == ([[keyWeNeed allKeys][0] integerValue])){
        [cell setBookImageAndTitle:nil withPlaceholderImage:[UIImage imageNamed:@"iclicker2.png"] titleString:[infoDict objectForKey:@"title"]];
    }else{
        [cell setBookImageAndTitle: [infoDict objectForKey:@"large"]?[NSURL URLWithString:[infoDict objectForKey:@"large"]]:([infoDict objectForKey:@"small"])?[NSURL URLWithString:[infoDict objectForKey:@"small"]]:nil withPlaceholderImage:[UIImage imageNamed:@"noimagepl.png"] titleString:[infoDict objectForKey:@"title"]];
    }

    NSDictionary *setOptionsDict = [bookOptions objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.item]];
    NSLog(@"DICT: %@", bookOptions);
    if (setOptionsDict){
        
        if ([setOptionsDict objectForKey:@"price"]){
            cell.priceLabel.text = [NSString stringWithFormat:@"$%@",[[setOptionsDict objectForKey:@"price"]stringValue]];
        }else{
            cell.priceLabel.text = @"";
        }
        if ([setOptionsDict objectForKey:@"condition"]){
            cell.conditionLabel.text = [setOptionsDict objectForKey:@"condition"];
        }else{
            cell.conditionLabel.text = @"";
        }
        
    }else{
        cell.priceLabel.text = @"";
        cell.conditionLabel.text = @"";
    }
    
    if (selectedItemIndexPath != nil && [indexPath compare:selectedItemIndexPath] == NSOrderedSame){
        [cell showIndicator];
    }else{
        [cell hideIndicator];
    }

    return cell;
}
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self animatePickerBottomToTop];
    
    NSMutableArray *indexPaths = [NSMutableArray arrayWithObject:indexPath];
    
    if (selectedItemIndexPath)
    {
        if ([indexPath compare:selectedItemIndexPath] == NSOrderedSame)
        {
            selectedItemIndexPath = nil;
            [self animatePickerTopToBottom];
        }
        else
        {
            [indexPaths addObject:selectedItemIndexPath];
            selectedItemIndexPath = indexPath;
        }
    }
    else
    {
  
        selectedItemIndexPath = indexPath;
    }
    
    //animate to desired row
    NSDictionary * infoDict = [bookOptions objectForKey:[NSString stringWithFormat:@"%ld",(long)selectedItemIndexPath.item]];
    if (infoDict){
        NSString *price = [NSString stringWithFormat:@"$%@",[[infoDict objectForKey:@"price"]stringValue]];
        if (price){
            NSUInteger index = [pickerData[0] indexOfObject:price];
            [self.pickerView selectRow:index inComponent:0 animated:YES];
            
        }
        NSString *condition = [infoDict objectForKey:@"condition"];
        if (condition){
            NSUInteger index = [pickerData[1] indexOfObject:condition];
            [self.pickerView selectRow:index inComponent:1 animated:YES];
            
        }
        
    }
    [collectionView reloadItemsAtIndexPaths:indexPaths];
    
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self animatePickerTopToBottom];
    
}
-(void) collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
}

-(void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
}

#pragma mark – UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(IMG_WIDTH *1.5, (IMG_HEIGHT *1.2) + (SCREEN_HEIGHT * 0.12)+15);
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(15, 5, 25, 5);
    
}
-(void)animatePickerBottomToTop
{
    NSLog(@"animating b to t");
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.collectionView.frame = CGRectMake(0,self.collectionView.frame.origin.y,SCREEN_WIDTH,SCREEN_HEIGHT-self.bottomView.frame.size.height);
                         self.bottomView.frame = CGRectMake(0, SCREEN_HEIGHT-self.bottomView.frame.size.height, self.bottomView.frame.size.width, self.bottomView.frame.size.height);
                     }
                     completion:^(BOOL finished){
                     }];
}
-(void)animatePickerTopToBottom
{
    NSLog(@"t to b");
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.collectionView.frame = CGRectMake(0,self.collectionView.frame.origin.y,SCREEN_WIDTH,SCREEN_HEIGHT);
                         self.bottomView.frame = CGRectMake(0, SCREEN_HEIGHT, self.bottomView.frame.size.width, self.bottomView.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         
                     }];
}


-(void)viewDidLayoutSubviews
{
    NSLog(@"content size %f", self.collectionView.contentSize.height);
    if (self.collectionView.contentSize.height != 0){
    UIButton *postBooks = [[UIButton alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - (SCREEN_WIDTH-40))/2, self.collectionView.contentSize.height , SCREEN_WIDTH-40, SCREEN_WIDTH * 0.11)];
    [postBooks setTitle:@"Post Books to Sell" forState:UIControlStateNormal];
    [postBooks.layer setCornerRadius:15];
    [postBooks.layer setBorderColor:[UIColor colorWithRed:0.118 green:0.404 blue:0.706 alpha:1].CGColor];
    [postBooks.layer setBorderWidth:2];
    [postBooks addTarget:self action:@selector(postBooksPressed:) forControlEvents:UIControlEventTouchUpInside];
    [postBooks addTarget:self action:@selector(postBooksHighlight:) forControlEvents:UIControlEventTouchDown];
    [self.collectionView addSubview:postBooks];
    }
}
-(void)postBooksHighlight:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [button setBackgroundColor:[UIColor colorWithRed:0.118 green:0.404 blue:0.706 alpha:0.5]];
}
-(void)postBooksPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [button setBackgroundColor:[UIColor clearColor]];
    [self showHUD];
    
    if([self checkIfAllOptionsFilled]){
        NSLog(@"yes");
        NSArray *allValues = [bookOptions allValues];
        NSMutableArray *objectArray = [[NSMutableArray alloc]init];
        
        FBRequest *request = [FBRequest requestForMe];
        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            
            if (!error) {
                /*
                {
                 isbn:
                 condition:
                 price:
                 fbid:
                 
                 author:
                 title:
                 image_large:
                }
                */
                
                /*isbnArray is an array of dictionary of isbns*/
                NSDictionary *userData = (NSDictionary *)result;
                NSString *facebookID = userData[@"id"];
                
                for(int i = 0; i < [allValues count]; i++){
                    NSMutableDictionary * tempDict = allValues[i];
                    [tempDict setObject:facebookID forKey:@"fbid"];
                    
                    NSLog(@"isbnarray: %@",self.isbnArray);
                    
                    NSDictionary *dict = [[self.isbnArray objectAtIndex:i] objectForKey:tempDict[@"isbn"]];
                    [tempDict setObject:dict[@"author"] forKey:@"author"];
                    [tempDict setObject:dict[@"title"] forKey:@"title"];
                    
                    id imageurl =dict[@"large"]?dict[@"large"]:dict[@"small"]?dict[@"small"]:@"null";
                    NSLog(@"imgurl: %@", imageurl);
                    
                    if (imageurl != nil){
                        [tempDict setObject:imageurl forKey:@"image_url"];
                    }
                    
                    [tempDict setObject:[NSDate date] forKey:@"offerLastUpdated"];
                   
                    PFObject *parseObject = [PFObject objectWithClassName:@"Selling"];
                    [tempDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
                        [parseObject setObject:obj forKey:key];
                    }];
                    [objectArray addObject:parseObject];
                    
                }
                
                //save in remote datastore
                [PFObject saveAllInBackground:objectArray block:^(BOOL succeeded, NSError *error) {
                    if(!error){
                        NSLog(@"save complete");
                        [self hideHUD:M13ProgressViewActionSuccess];
                        [self dismissViewControllerAnimated:YES completion:nil];
                        [ViewController goToMainPageController];
                        [self showAlertView:@"Success!" withMessage:@"All books are posted successfully!"];
                    }else{
                        [self hideHUD:M13ProgressViewActionFailure];
                        [self showAlertView:@"Error" withMessage:[error localizedDescription]];
                    }  
                }];
            }else{
                [self hideHUD:M13ProgressViewActionFailure];
                [self showAlertView:@"Error" withMessage:@"Unable to process request. Perhaps try again."];
            }
        }];

    }else{
        NSLog(@"no");
        [self hideHUD:M13ProgressViewActionFailure];
        [self showAlertView:@"Alert" withMessage:@"Some books still have price or condition that need to be set."];
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
-(BOOL)checkIfAllOptionsFilled
{
    NSLog(@"count of isbn array %ld", [self.isbnArray count]);
    NSLog(@"count of options %ld", [bookOptions count]);
    
    if ([bookOptions count] != [self.isbnArray count]){
        return NO;
    }
    NSArray * allValues = [bookOptions allValues];
    for (NSDictionary *eachDict in allValues){
        if ([eachDict count] != 3){
            return NO;
        }
    }
    return YES;
}
-(void)configCollectionView
{
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [self.collectionView setCollectionViewLayout:flowLayout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.contentInset = UIEdgeInsetsMake(50, 0, 50, 0);
    
    self.topView = [[UIView alloc]initWithFrame:CGRectMake(0, -SCREEN_HEIGHT *0.065, SCREEN_WIDTH, SCREEN_HEIGHT *0.09)];
    self.topView.backgroundColor = [UIColor clearColor];
    [self.collectionView addSubview:self.topView];
    
    UIButton *closeButton = [[UIButton alloc]initWithFrame:CGRectMake(3, 3, SCREEN_WIDTH *0.10, SCREEN_WIDTH * 0.10)];
    [closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setShowsTouchWhenHighlighted:YES];
    [closeButton setImage:[UIImage imageNamed:@"closebutton.png"] forState:UIControlStateNormal];
    [self.topView addSubview:closeButton];
    
    UILabel *instructLabel = [[UILabel alloc]initWithFrame:CGRectMake(3+(SCREEN_WIDTH * 0.11) + 5, 3, SCREEN_WIDTH -(3+(SCREEN_WIDTH * 0.11) + 15) , SCREEN_WIDTH * 0.15)];
    instructLabel.text = @"Select each book to set its price and condition";
    [instructLabel setFont:[UIFont fontWithName:@"Avenir-Roman" size:17]];
    [instructLabel setTextColor:[UIColor whiteColor]];
    [instructLabel setTextAlignment:NSTextAlignmentRight];
    [instructLabel setNumberOfLines:2];
    [self.topView addSubview: instructLabel];
    
}

/*--------------------------------------Picker View-----------------------------------------------*/
// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [pickerData[component]count];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString * itemTitle = pickerData[component][row];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:itemTitle attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"Avenir-Medium" size:21]}];
    
    return attString;
    
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:  (NSInteger)component
{
    NSString * selectedOption = pickerData[component][row];
    
    /*
     {
        indicator : indexPath.item,
        indexPath.item: {
            "isbn": 92842080980...,
            "price": $55,
            "condition" : New
        },
        indexPath.item:{
            ...
        }
        ....
     }
     */
    
    //get the item number that was selected
    NSString * itemNum =[NSString stringWithFormat:@"%ld", (long)selectedItemIndexPath.item];//[bookOptions objectForKey:@"indicator"];
    NSMutableDictionary * itemOptions;
    
    if ([bookOptions objectForKey:itemNum]){
        itemOptions =[bookOptions objectForKey:itemNum];
        
    }else{
        itemOptions = [[NSMutableDictionary alloc]init];
        NSDictionary *keyWeNeed = [self.isbnArray objectAtIndex:[itemNum intValue]];
        NSLog(@"keyweneed: %@", keyWeNeed);
        [itemOptions setObject:[keyWeNeed allKeys][0] forKey:@"isbn"];
    }
    
    SellBooksCollectionViewCell *cell = (SellBooksCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:selectedItemIndexPath];
    if (component == 0){
        [cell setPrice:selectedOption];
        
        if ([selectedOption isEqualToString:@"Free"]){
             [itemOptions setObject:@0 forKey:@"price"];
        }else{
            selectedOption = [selectedOption stringByReplacingOccurrencesOfString:@"$" withString:@""];
            [itemOptions setObject:@([selectedOption intValue]) forKey:@"price"];
        }
        
    }else{
        [cell setInfoConditionLabel:selectedOption];
        [itemOptions setObject:selectedOption forKey:@"condition"];
    }
    [bookOptions setObject:itemOptions  forKey:itemNum];
  
}


- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (BOOL)prefersStatusBarHidden{
    return YES;
}
- (IBAction)dismissPressed:(id)sender {
    [self animatePickerTopToBottom];
    [self collectionView:self.collectionView didSelectItemAtIndexPath:selectedItemIndexPath];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
