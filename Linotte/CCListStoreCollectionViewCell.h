//
//  CCListStoreTableViewCell.h
//  Linotte
//
//  Created by stant on 09/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCListStoreCollectionViewCell : UICollectionViewCell

- (void)loadImageFromUrl:(NSString *)urlString;
- (void)setImage:(UIImage *)image;
- (void)setTitle:(NSString *)title;

@end
