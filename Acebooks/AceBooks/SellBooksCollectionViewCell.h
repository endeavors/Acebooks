//
//  SellBooksCollectionViewCell.h
//  AceBooks
//
//  Created by Gurkirat Singh on 3/13/15.
//  Copyright (c) 2015 AceBooks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SellBooksCollectionViewCell : UICollectionViewCell
@property(nonatomic,strong)UILabel * priceLabel;
@property(nonatomic,strong) UILabel * conditionLabel;

-(void)setBookImageAndTitle:(NSURL *)nsurl withPlaceholderImage:(UIImage *)image titleString: (NSString *)titleString;
-(void)setPrice:(NSString *)priceInput;
-(void)setInfoConditionLabel:(NSString *)input;
-(void)showIndicator;
-(void)hideIndicator;

@end
