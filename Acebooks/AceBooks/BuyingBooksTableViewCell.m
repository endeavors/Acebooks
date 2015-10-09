//
//  BuyingBooksTableViewCell.m
//  AceBooks
//
//  Created by Gurkirat Singh on 3/30/15.
//  Copyright (c) 2015 AceBooks. All rights reserved.
//

#import "BuyingBooksTableViewCell.h"
#import "CardTableViewCell.h"
#import "ViewController.h"

#define TOP_PADDING 5
#define BOTTOM_PADDING 5
#define RIGHT_PADDING 5
#define LEFT_PADDING 5

@implementation BuyingBooksTableViewCell{
    UILabel *staticAuthorLabel;
    UILabel *staticConditionLabel;
    UILabel *backgroundColorLabel;
    UILabel *staticOfferLabel;
    UILabel *staticPriceLabel;
}

- (void)awakeFromNib {
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor colorWithRed:0.231 green:0.216 blue:0.216 alpha:0.5];
    
    float totalAvailWidth = SCREEN_WIDTH - RIGHT_MARGIN;
    
    self.imgView = [[UIImageView alloc]initWithFrame:CGRectMake(totalAvailWidth-IMG_WIDTH +RIGHT_PADDING, TOP_PADDING, IMG_WIDTH, IMG_HEIGHT)];
    self.imgView.contentMode = UIViewContentModeScaleAspectFill;
    self.imgView.clipsToBounds = YES;
    [self addSubview:self.imgView];
    
    self.title = [[UILabel alloc]initWithFrame:CGRectMake(LEFT_PADDING, 0, SCREEN_WIDTH-IMG_WIDTH-RIGHT_MARGIN, 50)];
    self.title.textColor = [UIColor colorWithRed:0.741 green:0.741 blue:0.741 alpha:1];
    [self.title setNumberOfLines:0];
    [self.title setFont:[UIFont fontWithName:@"Avenir-Black" size:15]];
    self.title.adjustsFontSizeToFitWidth = YES;
    self.title.textAlignment = NSTextAlignmentLeft;
    self.title.lineBreakMode = NSLineBreakByCharWrapping | NSLineBreakByTruncatingTail;
    [self addSubview:self.title];

    staticAuthorLabel =[[UILabel alloc]initWithFrame:CGRectMake(LEFT_PADDING, self.title.frame.size.height, (SCREEN_WIDTH-IMG_WIDTH)*0.3, 30)];
    [staticAuthorLabel setFont:[UIFont fontWithName:@"Avenir-Book" size:16]];
    staticAuthorLabel.textAlignment = NSTextAlignmentLeft;
    staticAuthorLabel.textColor = [UIColor colorWithRed:0.741 green:0.741 blue:0.741 alpha:1] ;
    [staticAuthorLabel setText:@"Author:"];
    [staticAuthorLabel setNumberOfLines:1];
    [staticAuthorLabel setLineBreakMode:NSLineBreakByWordWrapping];
    staticAuthorLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:staticAuthorLabel];
    
    self.author =[[UILabel alloc]initWithFrame:CGRectMake(staticAuthorLabel.frame.size.width,self.title.frame.size.height, (totalAvailWidth)-staticAuthorLabel.frame.size.width, staticAuthorLabel.frame.size.height)];
    [self.author setFont:[UIFont fontWithName:@"Avenir-Roman" size:16]];
    self.author.textAlignment = NSTextAlignmentLeft;
    self.author.textColor = [UIColor colorWithRed:0.741 green:0.741 blue:0.741 alpha:1];
    [self.author setNumberOfLines:2];
    [self.author setLineBreakMode:NSLineBreakByWordWrapping];
    self.author.adjustsFontSizeToFitWidth = YES;
    [self addSubview:self.author];
    
    staticConditionLabel =[[UILabel alloc]initWithFrame:CGRectMake(LEFT_PADDING,staticAuthorLabel.frame.origin.y + staticAuthorLabel.frame.size.height, self.author.frame.origin.x, staticAuthorLabel.frame.size.height)];
    staticConditionLabel.textAlignment = NSTextAlignmentLeft;
    [staticConditionLabel setFont:[UIFont fontWithName:@"Avenir-Book" size:16]];
    staticConditionLabel.textColor = [UIColor colorWithRed:0.741 green:0.741 blue:0.741 alpha:1] ;
    [staticConditionLabel setNumberOfLines:1];
    [staticConditionLabel setText:@"Condition:"];
    staticConditionLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:staticConditionLabel];
    
    self.conditionLabel =[[UILabel alloc]initWithFrame:CGRectMake(staticConditionLabel.frame.size.width, self.author.frame.origin.y + self.author.frame.size.height, (totalAvailWidth)-staticConditionLabel.frame.size.width, staticConditionLabel.frame.size.height)];
    self.conditionLabel.textAlignment = NSTextAlignmentLeft;
    [self.conditionLabel setFont:[UIFont fontWithName:@"Avenir-Roman" size:16]];
    self.conditionLabel.textColor = [UIColor colorWithRed:0.741 green:0.741 blue:0.741 alpha:1];
    [self.conditionLabel setNumberOfLines:1];
    self.conditionLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:self.conditionLabel];
    
    staticPriceLabel  = [[UILabel alloc]initWithFrame:CGRectMake(LEFT_PADDING, staticConditionLabel.frame.origin.y + staticConditionLabel.frame.size.height, (SCREEN_WIDTH-IMG_WIDTH)*0.3, staticConditionLabel.frame.size.height)];
    staticPriceLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:16];
    staticPriceLabel.textColor = [UIColor colorWithRed:0.741 green:0.741 blue:0.741 alpha:1];
    staticPriceLabel.numberOfLines = 1;
    staticPriceLabel.text = @"Price:";
    staticPriceLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:staticPriceLabel];
    
    self.price =[[UILabel alloc]initWithFrame:CGRectMake(staticPriceLabel.frame.size.width,staticConditionLabel.frame.origin.y +  staticConditionLabel.frame.size.height, (totalAvailWidth-staticPriceLabel.frame.size.width), staticConditionLabel.frame.size.height)];
    [self.price setFont:[UIFont fontWithName:@"Avenir-Black" size:20]];
    self.price.textAlignment = NSTextAlignmentLeft;
    self.price.textColor = [UIColor colorWithRed:0.741 green:0.741 blue:0.741 alpha:1];
    [self.price setNumberOfLines:1];
    self.price.adjustsFontSizeToFitWidth = YES;
    [self addSubview:self.price];
    
    backgroundColorLabel = [[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-IMG_WIDTH)+((IMG_WIDTH-(SCREEN_WIDTH*0.23))/2), (SCREEN_WIDTH *0.05)/2 + TOP_PADDING + IMG_HEIGHT , SCREEN_WIDTH * 0.23, SCREEN_WIDTH * 0.23)];
    backgroundColorLabel.backgroundColor = [self getRandomColor];
    backgroundColorLabel.layer.cornerRadius = (SCREEN_WIDTH * 0.23)/2;
    backgroundColorLabel.layer.masksToBounds = YES;
    [self addSubview:backgroundColorLabel];
    
    self.offerPriceLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH * 0.18, SCREEN_WIDTH * 0.18)];
    self.offerPriceLabel.center = CGPointMake(backgroundColorLabel.frame.size.width/2, backgroundColorLabel.frame.size.width/2);
    self.offerPriceLabel.backgroundColor = [UIColor whiteColor];
    self.offerPriceLabel.layer.cornerRadius = (SCREEN_WIDTH *0.18)/2;
    self.offerPriceLabel.layer.masksToBounds = YES;
    self.offerPriceLabel.font = [UIFont fontWithName:@"Avenir-Black" size:23];
    self.offerPriceLabel.numberOfLines = 1;
    self.offerPriceLabel.textAlignment = NSTextAlignmentCenter;
    [backgroundColorLabel addSubview:self.offerPriceLabel];

    staticOfferLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, backgroundColorLabel.frame.origin.y - TOP_PADDING/*+ (SCREEN_WIDTH * 0.05)/2*/, SCREEN_WIDTH-IMG_WIDTH, self.offerPriceLabel.frame.size.height/2)];
    staticOfferLabel.font = [UIFont fontWithName:@"Avenir-Black" size:16];
    staticOfferLabel.adjustsFontSizeToFitWidth = YES;
    staticOfferLabel.numberOfLines = 0;
    staticOfferLabel.textColor = [UIColor whiteColor];
    staticOfferLabel.textAlignment = NSTextAlignmentCenter;
    staticOfferLabel.text = @"Offer you made:";
    [self addSubview:staticOfferLabel];
    
    self.offerStatus = [[UILabel alloc]initWithFrame:CGRectMake(0,staticOfferLabel.frame.origin.y + staticOfferLabel.frame.size.height - TOP_PADDING, staticOfferLabel.frame.size.width, self.offerPriceLabel.frame.size.height/2)];
    self.offerStatus.textAlignment = NSTextAlignmentCenter;
    [self.offerStatus setFont:[UIFont fontWithName:@"Avenir-Black" size:18]];
    [self.offerStatus setTextColor:[UIColor greenColor]];
    [self addSubview:self.offerStatus];
    
    self.makeAnotherOffer = [[UIButton alloc]initWithFrame:CGRectMake((self.offerStatus.frame.size.width - (totalAvailWidth * 0.6))/2, self.offerStatus.frame.origin.y + self.offerStatus.frame.size.height, totalAvailWidth *0.6, self.offerPriceLabel.frame.size.height/2)];
    [self.makeAnotherOffer setTitle:@"Make Another Offer" forState:UIControlStateNormal];
    self.makeAnotherOffer.titleLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:17];
    self.makeAnotherOffer.showsTouchWhenHighlighted = YES;
    self.makeAnotherOffer.titleLabel.textColor = [UIColor whiteColor];
    self.makeAnotherOffer.backgroundColor = [UIColor colorWithRed:0.275 green:0.51 blue:0.706 alpha:0.6];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.makeAnotherOffer.bounds
                                                   byRoundingCorners:UIRectCornerAllCorners
                                                         cornerRadii:CGSizeMake(20, 30)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.makeAnotherOffer.bounds;
    maskLayer.path  = maskPath.CGPath;
    self.makeAnotherOffer.layer.mask = maskLayer;
    [self addSubview:self.makeAnotherOffer];
    self.makeAnotherOffer.hidden = YES;
    
    self.contactSeller = [[UIButton alloc]initWithFrame:CGRectMake((self.offerStatus.frame.size.width - (totalAvailWidth * 0.6))/2, self.offerStatus.frame.origin.y + self.offerStatus.frame.size.height, totalAvailWidth *0.6, self.offerPriceLabel.frame.size.height/2)];
    [self.contactSeller setTitle:@"Contact Seller" forState:UIControlStateNormal];
    self.contactSeller.titleLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:17];
    self.contactSeller.titleLabel.textColor = [UIColor whiteColor];
    self.contactSeller.showsTouchWhenHighlighted = YES;
    self.contactSeller.backgroundColor = [UIColor colorWithRed:0.431 green:0.545 blue:0.239 alpha:1]; /*#6e8b3d*/
    UIBezierPath *maskCSPath = [UIBezierPath bezierPathWithRoundedRect:self.contactSeller.bounds
                                                   byRoundingCorners:UIRectCornerAllCorners
                                                         cornerRadii:CGSizeMake(20, 30)];
    CAShapeLayer *maskCSLayer = [CAShapeLayer layer];
    maskCSLayer.frame = self.contactSeller.bounds;
    maskCSLayer.path  = maskCSPath.CGPath;
    self.contactSeller.layer.mask = maskCSLayer;
    [self addSubview:self.contactSeller];
    self.contactSeller.hidden = YES;
    

}

-(UIColor *)getRandomColor
{
    UIColor *randomRGBColor = [[UIColor alloc] initWithRed:arc4random()%256/256.0 green:arc4random()%256/256.0 blue:arc4random()%256/256.0 alpha:1.0];
    return randomRGBColor;
}


@end
