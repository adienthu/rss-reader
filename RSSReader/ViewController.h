//
//  ViewController.h
//  RSSReader
//
//  Created by aditya-d on 7/17/13.
//  Copyright (c) 2013 aditya-d. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSSFeed.h"

@class DownloadOperation;
@class AFHTTPRequestOperation;
@interface ViewController : UIViewController
{
@private
    NSXMLParser* parser;
    NSMutableArray* feeds;
    RSSFeed* currentFeed;
    NSString* currentMetadata;
    NSMutableString* currentString;
    DownloadOperation* theOp;
    AFHTTPRequestOperation* afOp;
//    NSMutableData* rssData;
//    int bytesRead;
}
@end
