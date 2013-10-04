//
//  RSSFeed.h
//  RSSReader
//
//  Created by aditya-d on 7/17/13.
//  Copyright (c) 2013 aditya-d. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSSFeed : NSObject

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* imgURL;
@property (nonatomic, strong) NSString* body;

@end
