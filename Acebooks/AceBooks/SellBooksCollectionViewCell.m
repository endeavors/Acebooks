//
//  SellBooksCollectionViewCell.m
//  AceBooks
//
//  Created by Gurkirat Singh on 3/13/15.
//  Copyright (c) 2015 AceBooks. All rights reserved.
//

#import "SellBooksCollectionViewCell.h"
#import "CardTableViewCell.h"
#import "UIImageView+WebCache.h"

@implementation SellBooksCollectionViewCell{
    UIImageView *imageView;
    UILabel * bookTitle;
    UIView * indicator;
}

-(void)awakeFromNib
{
    
    indicator = [[UIView alloc]initWithFrame:CGRectMake((IMG_WIDTH *1.5 -IMG_WIDTH*1.2)/2,0,IMG_WIDTH*1.2, 5)];
    [indicator setBackgroundColor: [UIColor colorWithRed:0 green:0.749 blue:1 alpha:1]];
    indicator.hidden = YES;
    [self.contentView addSubview:indicator];
    
    imageView = [[UIImageView alloc]initWithFrame:CGRectMake((IMG_WIDTH *1.5 -IMG_WIDTH*1.2)/2,5,IMG_WIDTH*1.2, IMG_HEIGHT *1.2)];
    
    [imageView setBackgroundColor: [UIColor colorWithRed:0.275 green:0.51 blue:0.706 alpha:0.6]];
    [self.contentView addSubview:imageView];
    
    
    bookTitle = [[UILabel alloc]initWithFrame:CGRectMake(0,(IMG_HEIGHT *1.2)+15,IMG_WIDTH * 1.5, SCREEN_HEIGHT * 0.12)];
    bookTitle.textColor = [UIColor whiteColor];
    bookTitle.numberOfLines = 0;
    [self addSubview:bookTitle];
    
   
    self.priceLabel = [[UILabel alloc]initWithFrame:CGRectMake((IMG_WIDTH *1.5 -IMG_WIDTH*1.2)/2, 5, IMG_WIDTH *1.2, SCREEN_HEIGHT*0.04)];
    self.priceLabel.backgroundColor = [UIColor colorWithRed:0.329 green:0.329 blue:0.329 alpha:0.8];
    self.priceLabel.numberOfLines = 1;
    self.priceLabel.font = [UIFont fontWithName:@"Avenir-Black" size:22];
    self.priceLabel.textColor =[UIColor whiteColor];
    self.priceLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.priceLabel];
    
    self.conditionLabel = [[UILabel alloc]initWithFrame:CGRectMake((IMG_WIDTH *1.5 -IMG_WIDTH*1.2)/2, (IMG_HEIGHT*1.2)+5 -(SCREEN_HEIGHT*0.04), IMG_WIDTH *1.2, SCREEN_HEIGHT*0.04)];
    self.conditionLabel.backgroundColor = [UIColor colorWithRed:0.329 green:0.329 blue:0.329 alpha:0.8];
    self.conditionLabel.numberOfLines = 1;
    self.conditionLabel.font = [UIFont fontWithName:@"Avenir-Black" size:20];
    self.conditionLabel.textColor =[UIColor whiteColor];
    self.conditionLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.conditionLabel];
                                                             
}

-(void)showIndicator
{
    indicator.hidden = NO;
}
-(void)hideIndicator
{
    indicator.hidden = YES;
}
-(void)setBookImageAndTitle:(NSURL *)nsurl withPlaceholderImage:(UIImage *)image titleString: (NSString *)titleString
{
    [imageView sd_setImageWithURL:nsurl
           placeholderImage:image];

    if (titleString != nil){
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:titleString];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail | NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [paragraphStyle setLineSpacing:0.0];
    [attributedString addAttributes:@{NSParagraphStyleAttributeName:paragraphStyle, NSFontAttributeName:[UIFont fontWithName:@"Avenir-Medium" size:12]} range:NSMakeRange(0, [titleString length])];
    bookTitle.attributedText = attributedString ;
    
    CGSize maxSize = CGSizeMake(IMG_WIDTH * 1.5, CGFLOAT_MAX);
    CGSize requiredSize = [bookTitle sizeThatFits:maxSize];
    [bookTitle setFrame:CGRectMake(((IMG_WIDTH *1.5)-bookTitle.frame.size.width)/2,bookTitle.frame.origin.y,bookTitle.frame.size.width,requiredSize.height)];
    }
}

-(void)setPrice:(NSString *)priceInput
{
    self.priceLabel.text = priceInput;
    [self animateLabelScale:self.priceLabel];
}
-(void)setInfoConditionLabel:(NSString *)input
{
    self.conditionLabel.text = input;
    [self animateLabelScale:self.conditionLabel];
}
-(void)animateLabelScale:(UILabel*)label
{
    NSLog(@"animating label");
    [UIView animateWithDuration:0.2
                     animations:^{
                         label.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.7, 1.7);
                     } completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:0.2
                                          animations:^{
                                              label.transform = CGAffineTransformIdentity;
                                          } completion:^(BOOL finished) {
                                              
                                          }];

                     }];
}
@end
