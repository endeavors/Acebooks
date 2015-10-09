//
//  BuyBooksCollectionView.m
//  AceBooks
//
//  Created by Gurkirat Singh on 3/21/15.
//  Copyright (c) 2015 AceBooks. All rights reserved.
//

#import "BuyBooksCollectionView.h"
#import "UIImageView+WebCache.h"
#import "CardTableViewCell.h"

@implementation BuyBooksCollectionView

-(void)awakeFromNib
{
    self.backgroundColor = [UIColor colorWithRed:0.231 green:0.216 blue:0.216 alpha:1];
    
    self.imgView = [[UIImageView alloc]initWithFrame:CGRectMake((IMG_WIDTH-(IMG_WIDTH*0.85))/2,TOP_MARGIN,IMG_WIDTH * 0.85, IMG_HEIGHT *0.85)];
    [self.contentView addSubview:self.imgView];
    
    self.bookTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, (IMG_HEIGHT *0.85) + TOP_MARGIN, IMG_WIDTH, SCREEN_HEIGHT * 0.12)];
    self.bookTitle.textAlignment = NSTextAlignmentCenter;
    self.bookTitle.textColor = [UIColor whiteColor];
    [self.bookTitle setFont:[UIFont fontWithName:@"Avenir-Roman" size:10]];
    self.bookTitle.numberOfLines = 0;
    self.bookTitle.lineBreakMode = NSLineBreakByTruncatingTail |NSLineBreakByWordWrapping;
    [self.contentView addSubview:self.bookTitle];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
