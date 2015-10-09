//
//  CollectionViewCell.m
//  AceBooks
//
//  Created by Gurkirat Singh on 3/5/15.
//  Copyright (c) 2015 AceBooks. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell{
    UILabel *profLabel;
}

-(void)awakeFromNib
{

    profLabel = [[UILabel alloc]initWithFrame:self.bounds];
    profLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
    [profLabel setFont:[UIFont fontWithName:@"Copperplate" size:19]];
    profLabel.textAlignment = NSTextAlignmentCenter;
    profLabel.textColor = [UIColor whiteColor] ;
    [profLabel setNumberOfLines:0];
    [profLabel setLineBreakMode:NSLineBreakByWordWrapping];
    profLabel.adjustsFontSizeToFitWidth = YES;
    
    [self addSubview:profLabel];
    
    self.layer.cornerRadius = 10;
    
}
-(void)setLabelText:(NSString *)string
{
    [profLabel setText:string];
}
@end
