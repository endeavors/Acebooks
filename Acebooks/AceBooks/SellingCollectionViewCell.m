//
//  SellingCollectionViewCell.m
//  AceBooks
//
//  Created by Gurkirat Singh on 3/26/15.
//  Copyright (c) 2015 AceBooks. All rights reserved.
//

#import "SellingCollectionViewCell.h"
#import "ViewController.h"
#import "CardTableViewCell.h"

@implementation SellingCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:0.231 green:0.216 blue:0.216 alpha:1];
    
    self.title = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, IMG_WIDTH * 1.5, SCREEN_HEIGHT *0.10)];
    self.title.textColor = [UIColor whiteColor];//[UIColor colorWithRed:0.741 green:0.741 blue:0.741 alpha:1];
    [self.title setNumberOfLines:0];
    [self.title setFont:[UIFont fontWithName:@"Avenir-Black" size:16]];
    self.title.adjustsFontSizeToFitWidth = YES;
    self.title.minimumScaleFactor = 
    self.title.textAlignment = NSTextAlignmentCenter;
    self.title.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
    [self addSubview:self.title];
    
    self.imgView = [[UIImageView alloc]initWithFrame:CGRectMake(((IMG_WIDTH * 1.5) - (IMG_WIDTH * 1.2))/2,self.title.frame.size.height,IMG_WIDTH * 1.2, IMG_HEIGHT *1.2)];
    self.imgView.contentMode = UIViewContentModeScaleAspectFill;
    self.imgView.clipsToBounds = YES;
    [self addSubview:self.imgView];
    
    
    
    self.sellingOfferIndicator = [[UILabel alloc]initWithFrame:CGRectMake(self.imgView.frame.origin.x +  self.imgView.frame.size.width-(15/2),self.imgView.frame.origin.y - (15/2), 15,15)];
    self.sellingOfferIndicator.layer.cornerRadius = 15/2;
    self.sellingOfferIndicator.layer.masksToBounds = YES;
    self.sellingOfferIndicator.backgroundColor =[UIColor colorWithRed:0 green:0.749 blue:1 alpha:1];
    self.sellingOfferIndicator.hidden = YES;
    [self addSubview:self.sellingOfferIndicator];
    
    self.author =[[UILabel alloc]initWithFrame:CGRectMake(0,self.title.frame.size.height + self.imgView.frame.size.height, IMG_WIDTH * 1.5, SCREEN_HEIGHT * 0.05)];
    [self.author setFont:[UIFont fontWithName:@"Avenir-Roman" size:14]];
    self.author.textAlignment = NSTextAlignmentCenter;
    self.author.textColor = [UIColor whiteColor];
    [self.author setNumberOfLines:0];
    [self.author setLineBreakMode:NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail];
    self.author.adjustsFontSizeToFitWidth = YES;
    [self addSubview:self.author];
    
}

@end
