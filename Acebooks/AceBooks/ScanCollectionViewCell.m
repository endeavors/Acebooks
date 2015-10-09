//
//  ScanCollectionViewCell.m
//  AceBooks
//
//  Created by Gurkirat Singh on 3/12/15.
//  Copyright (c) 2015 AceBooks. All rights reserved.
//

#import "ScanCollectionViewCell.h"
#import "ViewController.h"
#import "CardTableViewCell.h"
#import "UIImageView+WebCache.h"

static float imgViewWidth;
@implementation ScanCollectionViewCell{
    UIImageView *imgView;
    
}

-(void)awakeFromNib
{
   // [self setBackgroundColor:[UIColor grayColor]];
    imgView = [[UIImageView alloc]init];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.clipsToBounds = YES;
    imgView.backgroundColor = [UIColor colorWithRed:0.275 green:0.51 blue:0.706 alpha:0.6];
    [self addSubview:imgView];
    
    self.crossButton = [[UIButton alloc]init];
    self.crossButton.clipsToBounds = YES;
    [self.crossButton setImage:[UIImage imageNamed:@"closebutton.png"] forState:UIControlStateNormal];
    self.crossButton.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.crossButton];
    
}

-(void)setFrameofViews:(float)cellHeight
{
    imgViewWidth = cellHeight * 0.8;
    imgView.frame = CGRectMake(0, 0, imgViewWidth, self.frame.size.height);
    self.crossButton.frame = CGRectMake(imgViewWidth - (SCREEN_WIDTH * 0.08)/2,-9,SCREEN_WIDTH * 0.08, SCREEN_WIDTH * 0.08);
}
-(void)setAsyncImage:(NSURL *)nsurl withPlaceholderImage:(UIImage *)image
{
    [imgView sd_setImageWithURL:nsurl
                 placeholderImage:image];
}


@end
