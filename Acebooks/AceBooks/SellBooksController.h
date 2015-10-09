//
//  SellBooksController.h
//  AceBooks
//
//  Created by Gurkirat Singh on 3/7/15.
//  Copyright (c) 2015 AceBooks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SellBooksController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (strong, nonatomic)NSArray * isbnArray;
@end
