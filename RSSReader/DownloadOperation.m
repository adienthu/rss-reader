//
//  DownloadOperation.m
//  RSSReader
//
//  Created by Aditya Dasgupta on 7/31/13.
//  Copyright (c) 2013 aditya-d. All rights reserved.
//

#import "DownloadOperation.h"

@implementation DownloadOperation

- (id)init {
    self = [super init];
    if (self) {
        executing = NO;
        finished = NO;
        isDone = NO;
        rssData = [[NSMutableData alloc] init];
    }
    return self;
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return executing;
}

- (BOOL)isFinished {
    return finished;
}

- (void)start {
    // Always check for cancellation before launching the task.
    if ([self isCancelled])
    {
        // Must move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    // If the operation is not canceled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)main {
    @try {
        
        // Do the main work of the operation here.
        [self startDownload];
        while (!isDone) {
            if ([self isCancelled])
            {
                rssData.data = nil;
                [connection unscheduleFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                connection = nil;
                break;
            }
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
        }
        
        [self completeOperation];
    }
    @catch(...) {
        // Do not rethrow exceptions.
    }
}

-(void)startDownload
{
    NSURL* rssURL = [NSURL URLWithString:@"http://in.sports.yahoo.com/top/rss.xml"];
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:rssURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30.0f];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection scheduleInRunLoop:[NSRunLoop currentRunLoop]
                          forMode:NSDefaultRunLoopMode];
    [connection start];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [rssData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)inConnection
{
    isDone = YES;
    NSLog(@"Total bytes downloaded - %d",[rssData length]);
    [inConnection unscheduleFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

-(NSData*)urlContents
{
    return [NSData dataWithData:rssData];
}

/*
-(void)startDownload
{
//    NSURL* rssURL = [NSURL URLWithString:@"http://in.sports.yahoo.com/top/rss.xml"];
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"in.sports.yahoo.com", 80, &readStream, &writeStream);
//    CFURLRef urlRef = CFURLCreateWithString(NULL, (CFStringRef)@"http://in.sports.yahoo.com/top/rss.xml", NULL);
//    readStream = CFReadStreamCreateW WithFile(NULL, urlRef);
    rssStream = (__bridge_transfer NSInputStream *)readStream;
    upStream = (__bridge_transfer NSOutputStream *)writeStream;
//    NSInputStream* rssStream = [[NSInputStream alloc] initWithURL:rssURL];
    [rssStream setDelegate:self];
    [upStream setDelegate:self];
    [rssStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                         forMode:NSDefaultRunLoopMode];
    [upStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                         forMode:NSDefaultRunLoopMode];
    [rssStream open];
    [upStream open];
    //    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:60.0f]];
    //    parser = [[NSXMLParser alloc] initWithStream:rssStream];
    //    parser.delegate = self;
    //    [parser parse];
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
    
    switch(eventCode) {
        case NSStreamEventHasBytesAvailable:
        {
            if (stream == rssStream) {
                if(!rssData) {
                    rssData = [NSMutableData data];
                }
                uint8_t buf[1024];
                unsigned int len = 0;
                len = [(NSInputStream *)stream read:buf maxLength:1024];
                if(len) {
                    [rssData appendBytes:(const void *)buf length:len];
                    // bytesRead is an instance variable of type NSNumber.
                    bytesRead += len;
                    NSLog(@"Bytes downloaded - %d",bytesRead);
                    NSLog(@"String: %@",[NSString stringWithUTF8String:[rssData bytes]]);
                } else {
                    NSLog(@"no buffer!");
                }
            }
            
            break;
        }
        case NSStreamEventEndEncountered:
        {
            if (stream == rssStream) {
                [stream close];
                [stream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                  forMode:NSDefaultRunLoopMode];
                stream = nil; // stream is ivar, so reinit it
                //            NSLog(@"Bytes downloaded - %d",bytesRead);
                isDone = YES;
            }
            
            break;
        }
        case NSStreamEventHasSpaceAvailable:
        {
            if (stream == upStream) {
                NSString * str = [NSString stringWithFormat:
                                  @"GET /top/rss.xml HTTP/1.0\r\n\r\n"];
                const uint8_t * rawstring = (const uint8_t *)[str UTF8String];
                int numbytesWritten = [upStream write:rawstring maxLength:strlen((const char*)rawstring)];
                NSLog(@"Num bytes written - %d",numbytesWritten);
                [upStream close];
                [stream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                  forMode:NSDefaultRunLoopMode];
            }
            break;
        }
        default:
        {
            NSLog(@"Not handling event code %d",eventCode);
            break;
        }
    }
}
*/
- (void)completeOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    executing = NO;
    finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

@end
