//
//  CardTableViewCell.m
//  AceBooks
//
//  Created by Gurkirat Singh on 3/3/15.
//  Copyright (c) 2015 AceBooks. All rights reserved.
//

#import "CardTableViewCell.h"
#import "ViewController.h"

@interface CardTableViewCell()
@property (strong, nonatomic) UILabel *staticConditionLabel;
@property(strong, nonatomic)UILabel * staticAuthorLabel;
@end
@implementation CardTableViewCell

-(void)awakeFromNib
{

    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor colorWithRed:0.231 green:0.216 blue:0.216 alpha:1];
    self.imgView = [[UIImageView alloc]init];
    self.imgView.contentMode = UIViewContentModeScaleAspectFill;
    self.imgView.clipsToBounds = YES;
    [self addSubview:self.imgView];
    
    self.title = [[UILabel alloc]init];
    self.title.textColor = [UIColor colorWithRed:0.741 green:0.741 blue:0.741 alpha:1];
    [self.title setNumberOfLines:0];
    [self.title setFont:[UIFont fontWithName:@"Avenir-Black" size:15]];
    self.title.adjustsFontSizeToFitWidth = YES;
    self.title.textAlignment = NSTextAlignmentLeft;
    self.title.lineBreakMode = NSLineBreakByWordWrapping;
    [self addSubview:self.title];

    self.staticAuthorLabel =[[UILabel alloc]init];
    [self.staticAuthorLabel setFont:[UIFont fontWithName:@"Avenir-Book" size:15]];
    self.staticAuthorLabel.textAlignment = NSTextAlignmentLeft;
    self.staticAuthorLabel.textColor = [UIColor colorWithRed:0.741 green:0.741 blue:0.741 alpha:1] ;
    [self.staticAuthorLabel setText:@"Author:"];
    [self.staticAuthorLabel setNumberOfLines:0];
    [self.staticAuthorLabel setLineBreakMode:NSLineBreakByWordWrapping];
    self.staticAuthorLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:self.staticAuthorLabel];
    
    self.author =[[UILabel alloc]init];
    [self.author setFont:[UIFont fontWithName:@"Avenir-Black" size:14]];
    self.author.textAlignment = NSTextAlignmentLeft;
    self.author.textColor = [UIColor colorWithRed:0.741 green:0.741 blue:0.741 alpha:1];
    [self.author setNumberOfLines:0];
    [self.author setLineBreakMode:NSLineBreakByWordWrapping];
    self.author.adjustsFontSizeToFitWidth = YES;
    [self addSubview:self.author];
  
    self.staticConditionLabel =[[UILabel alloc]init];
    self.staticConditionLabel.textAlignment = NSTextAlignmentLeft;
    [self.staticConditionLabel setFont:[UIFont fontWithName:@"Avenir-Book" size:15]];
    self.staticConditionLabel.textColor = [UIColor colorWithRed:0.741 green:0.741 blue:0.741 alpha:1] ;
    [self.staticConditionLabel setNumberOfLines:1];
    [self.staticConditionLabel setText:@"Condition:"];
    self.staticConditionLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:self.staticConditionLabel];
    
    self.conditionLabel =[[UILabel alloc]init];
    self.conditionLabel.textAlignment = NSTextAlignmentLeft;
    [self.conditionLabel setFont:[UIFont fontWithName:@"Avenir-Black" size:14]];
    self.conditionLabel.textColor = [UIColor colorWithRed:0.741 green:0.741 blue:0.741 alpha:1];
    [self.conditionLabel setNumberOfLines:1];
    self.conditionLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:self.conditionLabel];
  
    self.price =[[UILabel alloc]init];
    [self.price setFont:[UIFont fontWithName:@"Avenir-Black" size:22]];
    self.price.textAlignment = NSTextAlignmentLeft;
    self.price.textColor = [UIColor whiteColor] ;
    [self.price setNumberOfLines:1];
    self.price.adjustsFontSizeToFitWidth = YES;
    [self addSubview:self.price];
  
    self.buynow = [[UIButton alloc]init];
    [self.buynow setTitle:@"BUY NOW" forState:UIControlStateNormal];
    self.buynow.titleLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:17];
    self.buynow.titleLabel.textColor = [UIColor whiteColor];
    [self.buynow setShowsTouchWhenHighlighted:YES];
    self.buynow.backgroundColor = [UIColor colorWithRed:0.4 green:0.804 blue:0 alpha:1];
    [self addSubview:self.buynow];
    
    self.makeoffer =[[UIButton alloc]init];
    [self.makeoffer setTitle:@"Make Offer" forState:UIControlStateNormal];
    self.makeoffer.titleLabel.textColor = [UIColor whiteColor];
    self.makeoffer.titleLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:17];
    self.makeoffer.backgroundColor = [UIColor colorWithRed:0.275 green:0.51 blue:0.706 alpha:1];
    [self.makeoffer setShowsTouchWhenHighlighted:YES];
    [self addSubview:self.makeoffer];


    
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGSize boundingSize = CGSizeMake(LABEL_WIDTH, CGFLOAT_MAX);
    CGSize expectedSize = [self.title sizeThatFits:boundingSize];
    self.title.frame = CGRectMake(LEFT_MARGIN, TOP_MARGIN, LABEL_WIDTH, expectedSize.height);
    
   
    NSLog(@"layout subviews");
    
    expectedSize = [self.staticAuthorLabel sizeThatFits:boundingSize];
    self.staticAuthorLabel.frame = CGRectMake(LEFT_MARGIN, TOP_MARGIN + self.title.frame.size.height+BOTTOM_MARGIN, expectedSize.width, expectedSize.height);
    
    CGSize boundingSizeForAuthor = CGSizeMake(LABEL_WIDTH-self.staticAuthorLabel.frame.size.width, CGFLOAT_MAX);
    CGSize expectedSizeForAuthor = [self.author sizeThatFits:boundingSizeForAuthor];
    
    expectedSize = [self.staticConditionLabel sizeThatFits:boundingSize];
    self.staticConditionLabel.frame = CGRectMake(LEFT_MARGIN, self.staticAuthorLabel.frame.origin.y + self.staticAuthorLabel.frame.size.height, expectedSize.width, expectedSize.height);

    
    CGSize boundingSizeForCondition = CGSizeMake(LABEL_WIDTH-self.staticConditionLabel.frame.size.width, CGFLOAT_MAX);
    CGSize expectedSizeForCondition = [self.conditionLabel sizeThatFits:boundingSizeForCondition];
    self.conditionLabel.frame = CGRectMake(self.staticConditionLabel.frame.size.width+(2*RIGHT_MARGIN), self.staticConditionLabel.frame.origin.y+1, expectedSizeForCondition.width, expectedSizeForCondition.height);
    
    
    self.author.frame = CGRectMake(self.staticConditionLabel.frame.size.width+(2*RIGHT_MARGIN), self.staticAuthorLabel.frame.origin.y+ 1, expectedSizeForAuthor.width, expectedSizeForAuthor.height);

    
    expectedSize = [self.price sizeThatFits:boundingSize];
    self.price.frame = CGRectMake(LEFT_MARGIN, TOP_MARGIN + self.staticConditionLabel.frame.origin.y + self.staticConditionLabel.frame.size.height , LABEL_WIDTH, expectedSize.height);
    
    float maxYCoordinate = fmaxf(self.price.frame.origin.y + self.price.frame.size.height, IMG_HEIGHT);
    float imgViewHeight = maxYCoordinate/2 - (IMG_HEIGHT/2);
    if ((int)imgViewHeight == 0){
        imgViewHeight= 5.0f;
    }
    
    self.imgView.frame = CGRectMake(SCREEN_WIDTH-(IMG_WIDTH + RIGHT_MARGIN),imgViewHeight, IMG_WIDTH, IMG_HEIGHT);
    
    self.buynow.frame = CGRectMake(0,maxYCoordinate + LEFT_MARGIN_MULTIPLIER_TWO, SCREEN_WIDTH/2, SCREEN_HEIGHT * 0.05);
    
    self.makeoffer.frame = CGRectMake(SCREEN_WIDTH/2,maxYCoordinate + LEFT_MARGIN_MULTIPLIER_TWO, SCREEN_WIDTH/2, SCREEN_HEIGHT * 0.05);
    self.cellHeight =  self.makeoffer.frame.origin.y + self.makeoffer.frame.size.height;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
   // [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
