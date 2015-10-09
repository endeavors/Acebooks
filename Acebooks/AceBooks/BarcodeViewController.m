//
//  BarcodeViewController.m
//  AceBooks
//
//  Created by Gurkirat Singh on 3/6/15.
//  Copyright (c) 2015 AceBooks. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "BarcodeViewController.h"
#import "ZBarSDK.h"
#import "ViewController.h"
#import "ScanCollectionViewCell.h"
#import "CardTableViewCell.h"
#import "MainPagerController.h"
#import "SellBooksController.h"

#define THUMBNAIL_HEIGHT (IMG_HEIGHT/1.4)
#define kAnimationCompletionBlock @"animationCompletionBlock"


@interface BarcodeViewController ()
@property (strong, nonatomic) IBOutlet UICollectionView *scanCollectionView;
@property (strong, nonatomic) IBOutlet ZBarReaderView *readerView;
    
@end

@implementation BarcodeViewController{
    UIView *movingLine;
    UIButton *doneButton;
    float collectionCellHeight;
    NSMutableArray * isbnArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterForeground:) name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [ZBarReaderView class];
    self.readerView.readerDelegate = (id)self;
    self.readerView.trackingColor = [UIColor clearColor];
    self.readerView.allowsPinchZoom = NO;
    self.readerView.tracksSymbols= FALSE;
    self.readerView.torchMode = 0;
    [self.readerView setBackgroundColor:[UIColor clearColor]];
    
    
   
    if (SCREEN_HEIGHT < 568){
        //iphone 4s
        self.readerView.frame = CGRectMake((SCREEN_WIDTH-(SCREEN_WIDTH *0.70))/2, (-SCREEN_HEIGHT * 0.035)+(SCREEN_HEIGHT *0.135), SCREEN_WIDTH *0.70, SCREEN_WIDTH *0.70);
        [self.readerView.layer setCornerRadius:(SCREEN_WIDTH*0.7)/2];
    }else{
        self.readerView.frame = CGRectMake(0, (-SCREEN_HEIGHT * 0.035)+(SCREEN_HEIGHT *0.135), SCREEN_WIDTH, SCREEN_WIDTH);
        [self.readerView.layer setCornerRadius:SCREEN_WIDTH/2];
    }
    
    movingLine = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                          0,
                                                          self.readerView.frame.size.width, 5)];
    movingLine.alpha = 0.6;
    movingLine.backgroundColor = [UIColor greenColor];
    [self.readerView addSubview:movingLine];
    [movingLine setHidden: YES];
    
    UILabel * titleInstruction = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, -SCREEN_HEIGHT * 0.035 +SCREEN_HEIGHT * 0.11)];
    titleInstruction.text = @"SCAN BARCODE TO SELL";
    [titleInstruction setFont:[UIFont fontWithName:@"Avenir-Black" size:17.0]];
    titleInstruction.textColor = [UIColor whiteColor];
    titleInstruction.lineBreakMode = NSLineBreakByWordWrapping;
    titleInstruction.numberOfLines = 0;
    titleInstruction.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview: titleInstruction];

    doneButton =[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/4, self.readerView.frame.size.height + self.readerView.frame.origin.y + 15, SCREEN_WIDTH/2, SCREEN_HEIGHT * 0.06)];
    [doneButton setTitle:@"DONE" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    doneButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:17];
    doneButton.titleLabel.textColor = [UIColor whiteColor];
    doneButton.backgroundColor = [UIColor colorWithRed:0.275 green:0.51 blue:0.706 alpha:1];
    [self.view addSubview:doneButton];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:doneButton.bounds
                                                   byRoundingCorners:UIRectCornerAllCorners
                                                         cornerRadii:CGSizeMake(20, 30)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = doneButton.bounds;
    maskLayer.path  = maskPath.CGPath;
    doneButton.layer.mask = maskLayer;
    
    self.readerView.scanCrop = self.readerView.bounds;
    
    isbnArray = [[NSMutableArray alloc]init];
    [self configCollectionView];
}

-(void)viewDidDisappear:(BOOL)animated
{
   
    [self killAnimation];
    
}
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self startAnimationAndCamera];
    
}
-(void)doneButtonPressed
{
    
    if ([isbnArray count] == 0){
        [self showAlertView:@"Notice" withMessage:@"You must scan one or more items before proceeding."];
        
    }else{
        SellBooksController *sellBooksController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SellBooksController"];
        sellBooksController.isbnArray = isbnArray;
        
       /* sellBooksController.isbnArray =   @[@{@"9780061241895": @{
            @"author": @"Cialdini",
            @"large": @"http://books.google.com/books/content?id=E5p5qVbkl1IC&printsec=frontcover&img=1&zoom=0&source=gbs_api",
            @"small": @"http://books.google.com/books/content?id=E5p5qVbkl1IC&printsec=frontcover&img=1&zoom=1&source=gbs_api",
            @"title": @"Influence: The Psychology Of Persuasion"
        }},@{
                                            @"9780061336461": @{
                                                @"author": @"Pinker",
                                                @"large": @"http://books.google.com/books/content?id=xORilwEACAAJ&printsec=frontcover&img=1&zoom=0&source=gbs_api",
                                                @"small": @"http://books.google.com/books/content?id=xORilwEACAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api",
                                                @"title": @"The Language Instinct"
                                            }},@{
                                            @"9780061350276": {
                                                @"author": @"Friedlander",
                                                @"large": @"http://books.google.com/books/content?id=lR_PnQEACAAJ&printsec=frontcover&img=1&zoom=0&source=gbs_api",
                                                @"small": @"http://books.google.com/books/content?id=lR_PnQEACAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api",
                                                @"title": @"Nazi Germany & The Jews 1933-1945 (abridged)"
                                            }}
                                                ];*/
        
        [self presentViewController:sellBooksController animated:YES completion:NULL];
    }
   
}
-(void) killAnimation
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self.readerView stop];
    });
    
    
    [UIView animateWithDuration:0.12
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut |
     UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         movingLine.transform =  CGAffineTransformMakeTranslation(0, 0);
                     }
                     completion:^(BOOL finished){
                         [movingLine setHidden:YES];
                        
                     }];

}
-(void)startAnimationAndCamera
{
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self.readerView start];
    });
    [self startReaderViewAnimation];
}


- (void)appDidBecomeActive:(NSNotification *)notification {

    [self startAnimationAndCamera];
}

- (void)appDidEnterForeground:(NSNotification *)notification {
    [self killAnimation];

}
- (void)startReaderViewAnimation
{
    
    animationCompletionBlock theBlock;
    
    //Create a shape layer that we will use as a mask for the image view
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    CGFloat maskHeight = self.readerView.layer.bounds.size.height;
    CGFloat maskWidth = self.readerView.layer.bounds.size.width;
    
    CGPoint centerPoint= CGPointMake( maskWidth/2, maskHeight/2);
    
    //Make the radius of our arc large enough to reach into the corners of the image view.
    CGFloat radius = sqrtf(maskWidth * maskWidth + maskHeight * maskHeight)/2;

    //Don't fill the path, but stroke it in black.
    maskLayer.fillColor = [[UIColor clearColor] CGColor];
    maskLayer.strokeColor = [[UIColor blackColor] CGColor];
    
    maskLayer.lineWidth = radius; //Make the line thick enough to completely fill the circle we're drawing
    
    CGMutablePathRef arcPath = CGPathCreateMutable();
    
    //Move to the starting point of the arc so there is no initial line connecting to the arc
    CGPathMoveToPoint(arcPath, nil, centerPoint.x, centerPoint.y-radius/2);
    
    //Create an arc at 1/2 our circle radius, with a line thickess of the full circle radius
    CGPathAddArc(arcPath,nil,centerPoint.x,centerPoint.y,radius/2,3*M_PI/2,-M_PI/2,YES);
    
    maskLayer.path = arcPath;
    
    //Start with an empty mask path (draw 0% of the arc)
    maskLayer.strokeEnd = 0.0;
    
    CFRelease(arcPath);
    
    //Install the mask layer into out image view's layer.
    self.readerView.layer.mask = maskLayer;
    
    //Set our mask layer's frame to the parent layer's bounds.
    self.readerView.layer.mask.frame = self.readerView.layer.bounds;
    
    //Create an animation that increases the stroke length to 1, then reverses it back to zero.
    CABasicAnimation *swipe = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    swipe.duration = 0.7;
    swipe.delegate = self;
    [swipe setValue: theBlock forKey: kAnimationCompletionBlock];
    
    swipe.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    swipe.fillMode = kCAFillModeForwards;
    swipe.removedOnCompletion = NO;
    swipe.autoreverses = NO;
    
    swipe.toValue = [NSNumber numberWithFloat: 1.0];
    
    //Set up a completion block that will be called once the animation is completed.
    theBlock = ^void(void)
    {
        
        [movingLine setHidden:NO];
        [self moveLine];

    };
    
    [swipe setValue: theBlock forKey: kAnimationCompletionBlock];
    [maskLayer addAnimation: swipe forKey: @"strokeEnd"];
    
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    animationCompletionBlock theBlock = [theAnimation valueForKey: kAnimationCompletionBlock];
    if (theBlock)
        theBlock();
}
- (void) readerView: (ZBarReaderView*) readerView didReadSymbols: (ZBarSymbolSet*) symbols fromImage: (UIImage*) image
{
    NSLog(@"here");
    
    //self.readerView.backgroundColor = [UIColor greenColor];
    int dataType = 0;
    NSString * isbnString;
    for (ZBarSymbol *symbol in symbols)
    {
        isbnString = symbol.data;
        dataType = symbol.type;
        NSLog(@"symbol.type = %d", symbol.type);
        NSLog(@"symbol.data = %@", symbol.data);
        
        break;
    }
    
    if ([isbnString length] != 13){
        [self showAlertView:@"Error" withMessage:@"ISBN is not valid."];

    }else{
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]init];
        id returnedObject = [[MainPagerController getISBNData]objectForKey:isbnString];
        if (returnedObject){
            [tempDict setObject:returnedObject forKey:isbnString];
            [isbnArray addObject:tempDict];
            [self.scanCollectionView reloadData ];
            
            
            NSInteger item = [self collectionView:self.scanCollectionView numberOfItemsInSection:0] - 1;
            NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:0];
            [self.scanCollectionView scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
        }else{
            //[self showAlertView:@"Alert" withMessage:@"Book scanned is not required this quarter. You can only sell books for courses offered in current quarter."];
            [self showAlertView:@"Alert" withMessage:@"Book doesn't exist in the database."];
        }
        
    }
}

-(void)moveLine
{
 
    [UIView animateWithDuration:1.6 delay:0.0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat |UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseInOut
                     animations:^{
                         movingLine.transform =  CGAffineTransformMakeTranslation(0, self.readerView.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         
                     }];
}
/*------------------------------------------------------------------------------------------------------------------*/

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [isbnArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ScanCollectionViewCell *cell = (ScanCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ScanCell" forIndexPath:indexPath];
    
    NSDictionary *keyWeNeed = [isbnArray objectAtIndex:indexPath.item];
    NSDictionary *imageDict = [keyWeNeed objectForKey:[keyWeNeed allKeys][0]];
    
   /* if ([imageDict count] == 0){
        [cell setRegularImage]; //has no image
    }else{
        [cell setAsyncImage:[imageDict objectForKey:@"small"]];
    }*/
    NSURL *nsurl = nil;
    if (ICLICKER_ISBN == ([[keyWeNeed allKeys][0] integerValue])){
        [cell setAsyncImage:nil withPlaceholderImage:[UIImage imageNamed:@"iclicker2.png"]];
    }else{
        if ([imageDict objectForKey:@"small"]){
            nsurl = [NSURL URLWithString:[imageDict objectForKey:@"small"]];
            [cell setAsyncImage:nsurl withPlaceholderImage:[UIImage imageNamed:@"noimagepl.png"]];
        }else{
            [cell setAsyncImage:nil withPlaceholderImage:[UIImage imageNamed:@"noimagepl.png"]];
        }
    }
    
    
    
    [cell setFrameofViews: collectionCellHeight];
    cell.crossButton.tag = indexPath.item;
    [cell.crossButton addTarget:self action:@selector(crossButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
    
}

#pragma mark – UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return CGSizeMake(collectionCellHeight, collectionCellHeight);
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
    
}
-(void)crossButtonPressed:(id)sender
{
    UIButton *crossButton = (UIButton *)sender;
    [isbnArray removeObjectAtIndex:crossButton.tag];
    [self.scanCollectionView reloadData];
    
}
-(void)showAlertView:(NSString*)title withMessage:(NSString*)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
-(void)configCollectionView
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    float collectionViewYCoord = doneButton.frame.origin.y+(SCREEN_HEIGHT * 0.06) + 10;
    [self.scanCollectionView setFrame:CGRectMake(0,collectionViewYCoord,SCREEN_WIDTH,(SCREEN_HEIGHT-50) - collectionViewYCoord)];
    [self.scanCollectionView setCollectionViewLayout:flowLayout];
    self.scanCollectionView.dataSource = self;
    self.scanCollectionView.delegate = self;

    
    //minus 10 accounting for edge insets of collectionview
    collectionCellHeight = self.scanCollectionView.frame.size.height - 10;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
