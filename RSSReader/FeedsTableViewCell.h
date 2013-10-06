//
//  FeedsTableViewCell.h
//  RSSReader
//
//  Created by Aditya Dasgupta on 8/11/13.
//  Copyright (c) 2013 aditya-d. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedsTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel* title;
@property (nonatomic, strong) IBOutlet UIImageView* feedImgView;

@end
