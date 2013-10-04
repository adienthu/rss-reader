//
//  DownloadOperation.h
//  RSSReader
//
//  Created by Aditya Dasgupta on 7/31/13.
//  Copyright (c) 2013 aditya-d. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadOperation : NSOperation <NSStreamDelegate, NSURLConnectionDelegate>
{
    BOOL executing;
    BOOL finished;
    NSMutableData* rssData;
    int bytesRead;
    BOOL isDone;
    NSInputStream *rssStream;
    NSOutputStream *upStream;
    NSURLConnection* connection;
}

-(NSData*)urlContents;

@end
