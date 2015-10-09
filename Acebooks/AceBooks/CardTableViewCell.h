//
//  CardTableViewCell.h
//  AceBooks
//
//  Created by Gurkirat Singh on 3/3/15.
//  Copyright (c) 2015 AceBooks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

#define IMG_RATIO 0.722
#define LEFT_MARGIN 10
#define TOP_MARGIN 10
#define RIGHT_MARGIN 10
#define BOTTOM_MARGIN 10
#define IMG_WIDTH (SCREEN_WIDTH * 0.30)
#define IMG_HEIGHT (IMG_WIDTH/IMG_RATIO)
#define LEFT_MARGIN_MULTIPLIER_TWO (2*LEFT_MARGIN)
#define LABEL_WIDTH (SCREEN_WIDTH - (LEFT_MARGIN_MULTIPLIER_TWO+(LEFT_MARGIN/2) +IMG_WIDTH))

#define ICLICKER_ISBN 9781429280471

@interface CardTableViewCell : UITableViewCell

@property (strong,nonatomic) UIImageView *imgView;
@property (strong, nonatomic) UILabel * title;
@property (strong, nonatomic) UILabel *author;
@property (strong, nonatomic) UILabel *conditionLabel;
@property (strong,nonatomic)UILabel *price;
@property (strong,nonatomic) UIButton *buynow;
@property (strong, nonatomic) UIButton *makeoffer;
@property NSInteger cellHeight;


@end
