//
//  ScanCollectionViewCell.h
//  AceBooks
//
//  Created by Gurkirat Singh on 3/12/15.
//  Copyright (c) 2015 AceBooks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScanCollectionViewCell : UICollectionViewCell
-(void)setFrameofViews:(float)cellHeight;
-(void)setAsyncImage:(NSURL *)nsurl withPlaceholderImage:(UIImage *)image;
@property(nonatomic,strong)UIButton *crossButton;
@end
