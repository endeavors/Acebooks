//
//  OfferCollectionViewCell.m
//  AceBooks
//
//  Created by Gurkirat Singh on 3/26/15.
//  Copyright (c) 2015 AceBooks. All rights reserved.
//

#import "OfferCollectionViewCell.h"
#import "ViewController.h"

@implementation OfferCollectionViewCell

-(void)awakeFromNib
{
    self.backgroundColorLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH * 0.25, SCREEN_WIDTH * 0.25)];
    self.backgroundColorLabel.backgroundColor = [self getRandomColor];
    self.backgroundColorLabel.layer.cornerRadius = (SCREEN_WIDTH * 0.25)/2;
    self.backgroundColorLabel.layer.masksToBounds = YES;
    [self addSubview:self.backgroundColorLabel];
    
    self.offerPriceLabel = [[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH * 0.05)/2, (SCREEN_WIDTH * 0.05)/2, SCREEN_WIDTH * 0.20, SCREEN_WIDTH * 0.20)];
    self.offerPriceLabel.backgroundColor = [UIColor whiteColor];
    self.offerPriceLabel.layer.cornerRadius = (SCREEN_WIDTH *0.20)/2;
    self.offerPriceLabel.layer.masksToBounds = YES;
    self.offerPriceLabel.font = [UIFont fontWithName:@"Avenir-Black" size:23];
    self.offerPriceLabel.numberOfLines = 1;
    self.offerPriceLabel.textAlignment = NSTextAlignmentCenter;
    [self.backgroundColorLabel addSubview:self.offerPriceLabel];
    
}
-(UIColor *)getRandomColor
{
    UIColor *randomRGBColor = [[UIColor alloc] initWithRed:arc4random()%256/256.0 green:arc4random()%256/256.0 blue:arc4random()%256/256.0 alpha:1.0];
    return randomRGBColor;
}
    
@end
