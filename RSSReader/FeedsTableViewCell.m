//
//  FeedsTableViewCell.m
//  RSSReader
//
//  Created by Aditya Dasgupta on 8/11/13.
//  Copyright (c) 2013 aditya-d. All rights reserved.
//

#import "FeedsTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation FeedsTableViewCell

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
