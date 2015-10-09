//
//  SecondPageController.h
//  AceBooks
//
//  Created by Gurkirat Singh on 3/3/15.
//  Copyright (c) 2015 AceBooks. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface SecondPageController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property NSUInteger pageIndex;
@end