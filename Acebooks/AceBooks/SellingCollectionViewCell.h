//
//  SellingCollectionViewCell.h
//  AceBooks
//
//  Created by Gurkirat Singh on 3/26/15.
//  Copyright (c) 2015 AceBooks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SellingCollectionViewCell : UICollectionViewCell
@property(nonatomic, strong)UILabel *title;
@property(nonatomic, strong)UILabel *author;
@property(nonatomic, strong)UIImageView *imgView;
@property(nonatomic, strong)UILabel *sellingOfferIndicator;
@end
