//
//  BarcodeViewController.h
//  AceBooks
//
//  Created by Gurkirat Singh on 3/6/15.
//  Copyright (c) 2015 AceBooks. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^animationCompletionBlock)(void);
@interface BarcodeViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@end
