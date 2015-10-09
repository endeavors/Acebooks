//
//  BuyingBooksTableViewCell.h
//  AceBooks
//
//  Created by Gurkirat Singh on 3/30/15.
//  Copyright (c) 2015 AceBooks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BuyingBooksTableViewCell : UITableViewCell
@property (strong,nonatomic) UIImageView *imgView;
@property (strong, nonatomic) UILabel * title;
@property (strong, nonatomic) UILabel *author;
@property (strong, nonatomic) UILabel *conditionLabel;
@property (strong,nonatomic)UILabel *price;
@property(strong, nonatomic)UILabel *offerPriceLabel;
@property (strong, nonatomic) NSString* PFObjectID;
@property (strong, nonatomic)UILabel *offerStatus;
@property(strong, nonatomic)UIButton *contactSeller;
@property(strong, nonatomic)UIButton *makeAnotherOffer;
@end
