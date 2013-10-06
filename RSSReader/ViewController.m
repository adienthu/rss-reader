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
#import "UIImageView+AFNetworking.h"

@interface ViewController ()<NSXMLParserDelegate, UITableViewDataSource, UITableViewDelegate, NSStreamDelegate>

@property (nonatomic, strong) UITableView* tblView;
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

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
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
    UINavigationBar* navBar = [[self navigationController] navigationBar];
    UIView* contentView = [self view];
    UITableView* feedListTable = [[UITableView alloc] init];
    self.tblView = feedListTable;
    [contentView addSubview:self.tblView];
    [feedListTable setTranslatesAutoresizingMaskIntoConstraints:NO];
    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:feedListTable
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:contentView
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.0f
                                                               constant:navBar.frame.origin.y+navBar.frame.size.height]];
    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:feedListTable
                                                            attribute:NSLayoutAttributeLeft
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:contentView
                                                            attribute:NSLayoutAttributeLeft
                                                           multiplier:1.0f
                                                             constant:0]];
//    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:feedListTable
//                                                              attribute:NSLayoutAttributeWidth
//                                                              relatedBy:NSLayoutRelationEqual
//                                                                 toItem:contentView
//                                                              attribute:NSLayoutAttributeWidth
//                                                             multiplier:1.0f
//                                                               constant:0]];
    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:feedListTable
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:contentView
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0f
                                                               constant:0]];
    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:feedListTable
                                                            attribute:NSLayoutAttributeRight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:contentView
                                                            attribute:NSLayoutAttributeRight
                                                           multiplier:1.0f
                                                             constant:0]];
    feedListTable.hidden = YES;
    feedListTable.delegate = self;
    feedListTable.dataSource = self;
    [feedListTable registerNib:[UINib nibWithNibName:@"FeedsTableViewCell" bundle:nil] forCellReuseIdentifier:@"feedCell"];
    feedListTable.separatorStyle = UITableViewCellSelectionStyleNone;
//    FeedsTableViewCell* cell = (FeedsTableViewCell*)[feedListTable dequeueReusableCellWithIdentifier:@"feedCell"];
    feedListTable.rowHeight = 120;//cell.frame.size.height;
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
        [self.stopButton setTitle:@"Reload" forState:UIControlStateNormal];
        if ([theOp isExecuting]) {
            [theOp cancel];
        }
    }else if([button.titleLabel.text isEqualToString:@"Reload"]){
        [self startDownload];
    }
}

-(void)startDownload
{
    [self.loadingIndicator startAnimating];
    [self.stopButton setTitle:@"Stop" forState:UIControlStateNormal];
    self.statusLabel.text = @"Downloading...";
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
    self.loadingIndicator.hidden = YES;
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
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if (currentFeed && [elementName isEqualToString:@"item"]) {
        [feeds addObject:currentFeed];
        currentString = nil;
        currentMetadata = nil;
        return;
    }
    
    if (currentFeed && [currentMetadata isEqualToString:@"title"]) {
        currentFeed.title = currentString;
//        NSLog(@"'%@'---->'%@'",currentFeed.title,currentFeed.imgURL);
        currentString = nil;
        currentMetadata = nil;
        return;
    }
    
    if (currentFeed && [currentMetadata isEqualToString:@"description"]) {
        TFHpple* htmlParser = [[TFHpple alloc] initWithHTMLData:[currentString dataUsingEncoding:NSUTF8StringEncoding]];
        NSArray* elems = [htmlParser searchWithXPathQuery:@"//p"];
        TFHppleElement* elem = [elems lastObject];
        currentFeed.body = elem.text;
        htmlParser = nil;
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
    if (feeds.count == 0) {
        return nil;
    }
    UITableViewCell* cachedCell = [tableView cellForRowAtIndexPath:indexPath];
    if (cachedCell) {
        NSLog(@"USING CACHED CELL");
        return cachedCell;
    }
    static NSString* resuseIdentifier = @"feedCell";
    FeedsTableViewCell* cell = (FeedsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:resuseIdentifier];
    RSSFeed* feed = [feeds objectAtIndex:indexPath.row];
    cell.title.text = feed.title;
    if (feed.imgURL) {
        NSLog(@"'%@'---->'%@'",cell.title.text,feed.imgURL);
        // load image lazily
        NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:feed.imgURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0f];
        __weak FeedsTableViewCell* weakCell = cell;
        AFImageRequestOperation* op = [AFImageRequestOperation imageRequestOperationWithRequest:request
                                                                                        success:^(UIImage *image) {
                                                                                            FeedsTableViewCell* strongCell = weakCell;
                                                                                            if (strongCell && [[tableView indexPathForCell:strongCell] isEqual:indexPath]) {
                                                                                                [[strongCell feedImgView] setImage:image];
                                                                                                [[strongCell contentView] setNeedsLayout];
//                                                                                                [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                                                                            }
                                                                                        }];
        [op start];
    }
    
    /*
    __weak UIImageView* weakImgView = cell.imageView;
    [cell.imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        UIImageView* strongImgView = weakImgView;
        NSLog(@"Downloaded image for feed with title '%@'",feed.title);
        if (strongImgView) {
            [strongImgView setImage:image];
//            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [strongImgView layoutIfNeeded];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//        NSLog(@"Failed to download image for feed with title '%@'",feed.title);
    }];
     */
//    [cell.imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
//    cell.imageView.contentMode = UIViewContentModeScaleToFill;
//    [cell.imageView setImageWithURL:[NSURL URLWithString:feed.imgURL]];
//    cell.detailTextLabel.text = feed.body;
    return cell;
}

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString* resuseIdentifier = @"feedCell";
//    FeedsTableViewCell* cell = (FeedsTableViewCell*)[self.tblView dequeueReusableCellWithIdentifier:resuseIdentifier];
//    return cell.frame.size.height;
//}
@end
