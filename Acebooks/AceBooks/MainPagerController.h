//
//  MainPagerController.h
//  AceBooks
//
//  Created by Gurkirat Singh on 3/3/15.
//  Copyright (c) 2015 AceBooks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainPagerController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate, UIAlertViewDelegate,UIPickerViewDataSource, UIPickerViewDelegate>

+(NSDictionary *)getISBNData;
+(NSDictionary *)getTextbookJson;
@property NSUInteger pageIndex;
@end