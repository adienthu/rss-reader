//
//  ViewController.m
//  RSSReader
//
//  Created by aditya-d on 7/17/13.
//  Copyright (c) 2013 aditya-d. All rights reserved.
//

#import "ViewController.h"
#import "TFHpple.h"
#import "DownloadOperation.h"
#import "FeedsTableViewCell.h"
#import "AFHTTPRequestOperation.h"

@interface ViewController ()<NSXMLParserDelegate, UITableViewDataSource, UITableViewDelegate, NSStreamDelegate>

@property (nonatomic, weak) IBOutlet UITableView* tblView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView* loadingIndicator;
@property (nonatomic, weak) IBOutlet UIButton* stopButton;
@property (nonatomic, weak) IBOutlet UILabel* statusLabel;
@end

@implementation ViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        feeds = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self.stopButton.titleLabel setNeedsDisplay];
//    [self.loadingIndicator startAnimating];
//    NSInvocationOperation* theOp = [[NSInvocationOperation alloc] initWithTarget:self
//                                                                        selector:@selector(startDownload) object:nil];
//    theOp.completionBlock = ^(void){
//        [self performSelectorOnMainThread:@selector(finishedDownload) withObject:nil waitUntilDone:NO];
//    };
////    [theOp start];
//    [self.opQueue addOperation:theOp];
//    [theOp start];
    [self startDownload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Download
- (IBAction)stopButtonTapped:(UIButton*)button {
    if ([button.titleLabel.text isEqualToString:@"Stop"]) {
//        @synchronized(parser){
//            [parser abortParsing];
//        }
//        @synchronized(feeds){
//            [feeds removeAllObjects];
//        }
//        [self.opQueue cancelAllOperations];
//        button.titleLabel.text = @"Reload";
        [self.stopButton setTitle:@"Reload" forState:UIControlStateNormal];        
        if ([theOp isExecuting]) {
            [theOp cancel];
        }
//        [self.loadingIndicator stopAnimating];
    }else if([button.titleLabel.text isEqualToString:@"Reload"]){
        [self startDownload];
//        [button layoutIfNeeded];
    }
}

-(void)startDownload
{
    [self.loadingIndicator startAnimating];
    [self.stopButton setTitle:@"Stop" forState:UIControlStateNormal];
    self.statusLabel.text = @"Downloading...";
//    theOp = [[DownloadOperation alloc] init];
//    __weak ViewController* weakSelf = self;
//    theOp.completionBlock = ^(void){
//        ViewController* strongSelf = weakSelf;
//        if (strongSelf) {
//            [strongSelf performSelectorOnMainThread:@selector(finishedDownload) withObject:nil waitUntilDone:NO];
//        }
//    };
//    [theOp start];
    NSURL* rssURL = [NSURL URLWithString:@"http://in.sports.yahoo.com/top/rss.xml"];
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:rssURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30.0f];
    afOp = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    __weak ViewController* weakSelf = self;
    [afOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        ViewController* strongSelf = weakSelf;
        [strongSelf finishedDownload];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error getting feeds!");
        NSLog(@"Error: %@",[error description]);
    }];
    
    [afOp setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        ViewController* strongSelf = weakSelf;
        strongSelf.statusLabel.text = [NSString stringWithFormat:@"%d bytes downloaded",bytesRead];
    }];
    [afOp start];
}

-(void)finishedDownload
{
    [self.loadingIndicator stopAnimating];
    if (theOp.isCancelled == NO) {
        self.stopButton.hidden = YES;
    }
    self.statusLabel.text = @"Parsing...";
    //[self startParsing:[theOp urlContents]];
    [self startParsing:[afOp responseData]];
    self.statusLabel.text = @"";
    theOp = nil;
    if (feeds.count > 0) {
        self.tblView.hidden = NO;
        [self.tblView reloadData];
    }
}

//-(void)startDownload
//{
//    NSURL* rssURL = [NSURL URLWithString:@"http://in.sports.yahoo.com/top/rss.xml"];
//    NSInputStream* rssStream = [[NSInputStream alloc] initWithURL:rssURL];
//    [rssStream setDelegate:self];
//    [rssStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
//                       forMode:NSDefaultRunLoopMode];
//    [rssStream open];
//    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:60.0f]];
////    parser = [[NSXMLParser alloc] initWithStream:rssStream];
////    parser.delegate = self;
////    [parser parse];
//}
//
//- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
//    
//    switch(eventCode) {
//        case NSStreamEventHasBytesAvailable:
//        {
//            if(!rssData) {
//                rssData = [[NSMutableData data] retain];
//            }
//            uint8_t buf[1024];
//            unsigned int len = 0;
//            len = [(NSInputStream *)stream read:buf maxLength:1024];
//            if(len) {
//                [rssData appendBytes:(const void *)buf length:len];
//                // bytesRead is an instance variable of type NSNumber.
//                bytesRead += len;
//            } else {
//                NSLog(@"no buffer!");
//            }
//            break;
//        }
//        case NSStreamEventEndEncountered:
//        {
//            [stream close];
//            [stream removeFromRunLoop:[NSRunLoop currentRunLoop]
//                              forMode:NSDefaultRunLoopMode];
//            [stream release];
//            stream = nil; // stream is ivar, so reinit it
//            NSLog(@"Bytes downloaded - %d",bytesRead);
//            break;
//        }
//        default:
//            NSLog(@"Not handling event code %d",eventCode);
//    }
//}

#pragma mark XML Parsing

-(void)startParsing:(NSData*)rssData
{
    parser = [[NSXMLParser alloc] initWithData:rssData];
    parser.delegate = self;
    [parser parse];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"item"]) {
        currentFeed = [[RSSFeed alloc] init];
        return;
    }
    
    if (currentFeed && [elementName isEqualToString:@"media:content"]) {
        currentFeed.imgURL = [attributeDict objectForKey:@"url"];
        return;
    }
    
    if (currentFeed && ([elementName isEqualToString:@"title"] || [elementName isEqualToString:@"description"])) {
        currentMetadata = elementName;
        return;
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (currentMetadata) {
        if (!currentString) {
            currentString  = [[NSMutableString alloc] initWithCapacity:50];
        }
        [currentString appendString:string];
    }
//    @autoreleasepool {
//        if (currentFeed && [currentMetadata isEqualToString:@"title"]) {
//            currentFeed.title = [currentFeed.title stringByAppendingString:string];
//        }else if(currentFeed && [currentMetadata isEqualToString:@"description"]) {
//            currentFeed.body = [currentFeed.body stringByAppendingString:string];
//        }
//    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if (currentFeed && [elementName isEqualToString:@"item"]) {
//        NSLog(@"Title: %@\nImage URL: %@\n Body: %@\n\n",currentFeed.title,currentFeed.imgURL,currentFeed.body);
        [feeds addObject:currentFeed];
        currentString = nil;
        currentMetadata = nil;
        //NSLog(@"Downloaded feed %d",feeds.count);
        return;
    }
    
    if (currentFeed && [currentMetadata isEqualToString:@"title"]) {
        currentFeed.title = currentString;
        currentString = nil;
        currentMetadata = nil;
        return;
    }
    
    if (currentFeed && [currentMetadata isEqualToString:@"description"]) {
        //NSString* htmlString = [[NSString alloc] initWithFormat:@"<html>%@</html>",currentString];
        TFHpple* htmlParser = [[TFHpple alloc] initWithHTMLData:[currentString dataUsingEncoding:NSUTF8StringEncoding]];
        NSArray* elems = [htmlParser searchWithXPathQuery:@"//p"];
        TFHppleElement* elem = [elems lastObject];
        currentFeed.body = elem.text;
        htmlParser = nil;
//        NSError* error = nil;
//        HTMLParser* htmlParser = [[HTMLParser alloc] initWithString:currentString error:&error];
//        if (error)
//            NSLog(@"HTML Parser error: %@",error.description);
//        else
//            currentFeed.body = [[htmlParser para] contents];
        currentString = nil;
        currentMetadata = nil;        
        return;
    }
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    currentFeed = nil;
    currentString = nil;
    NSLog(@"%@",parseError);
}

#pragma mark Table View data source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return feeds.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FeedsTableViewCell* cell = nil;
    cell = (FeedsTableViewCell*)[self.tblView dequeueReusableCellWithIdentifier:@"feedCell"];
    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"feedCell"];
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"FeedsTableViewCell" owner:self options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (FeedsTableViewCell *)currentObject;
                break;
            }
        }
    }
    RSSFeed* feed = [feeds objectAtIndex:indexPath.row];
    cell.textLabel.text = feed.title;
    cell.detailTextLabel.text = feed.body;
//    cell.title.text = feed.title;
//    cell.subTitle.text = feed.body;
    return cell;
}
@end
