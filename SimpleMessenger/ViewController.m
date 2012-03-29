//
//  ViewController.m
//  SimpleMessenger
//
//  Created by 고 준일 on 12. 1. 17..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@implementation ViewController
@synthesize msgTableView;
@synthesize msgView;
@synthesize msgTextField;

@synthesize lastUpdate;
@synthesize recvData;
@synthesize msgArr;
@synthesize msgTimer;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.msgArr = [[NSMutableArray alloc] init];
    self.recvData = [[NSMutableData alloc] init];
    self.msgTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                     target:self
                                                   selector:@selector(getNewMessage:)
                                                   userInfo:nil
                                                    repeats:YES];
}

- (void)viewDidUnload
{
    [self setMsgTableView:nil];
    [self setMsgView:nil];
    [self setMsgTextField:nil];

    [self setLastUpdate:nil];
    [self setRecvData:nil];
    [self setMsgArr:nil];
    [self setMsgTimer:nil];

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)msgSend:(id)sender {
    [msgTextField resignFirstResponder];
    if (msgTextField.text.length > 0) {
        [self sendNewMessage:msgTextField.text
                    withName:USER_NAME];
        
        NSDictionary *myMsgDict = [NSDictionary dictionaryWithObjectsAndKeys: 
                                   msgTextField.text, @"message",
                                   USER_NAME, @"user", nil];
        [msgArr addObject: myMsgDict];
        [self.msgTableView reloadData];
    }
    [msgTextField setText:@""];
    
}

- (void)sendNewMessage:(NSString *)newMsg
              withName:(NSString *)name {
    
    NSString *msgSendURL = [NSString stringWithFormat:@"http://%@/add.php", SERVER_IP];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:msgSendURL]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy 
                                                       timeoutInterval:30];
    
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: [[NSString stringWithFormat: @"user=%@&message=%@", name, newMsg] dataUsingEncoding: NSUTF8StringEncoding]];
    
    [NSURLConnection sendSynchronousRequest:request
                          returningResponse:nil 
                                      error:nil];
}

- (void)getNewMessage:(NSTimer *)timer {
    NSString *dateStr;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat: @"yyyyMMddHHmmss"];
    
    if (!lastUpdate) {
        NSDate *nowDate = [NSDate date];
        dateStr = [df stringFromDate: nowDate];
        [self setLastUpdate: nowDate];
    } else {
        dateStr = [df stringFromDate: lastUpdate];
    }
    
    NSString *urlStr = [NSString stringWithFormat: @"http://%@/message.php?lastupdate=%@&user=%@", SERVER_IP, dateStr, USER_NAME];
    NSString *escapeStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString: escapeStr]];
    [request setHTTPMethod: @"GET"];
    
    NSURLConnection *recvConnection = [[NSURLConnection alloc] initWithRequest:request
                                                                      delegate:self];

    if (recvConnection) {
        NSMutableData *newRecvData = [[NSMutableData alloc] init];
        [self setRecvData: newRecvData];
    }
}

#pragma mark - NSURLConnection Delegate method
- (void)connection:(NSURLConnection *)connection 
didReceiveResponse:(NSURLResponse *)response {
    [recvData setLength: 0];
}

- (void)connection:(NSURLConnection *)connection 
    didReceiveData:(NSData *)data {
    [recvData appendData: data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

    if (recvData) {
        NSError *error;
        NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:recvData
                                                           options:kNilOptions
                                                             error:&error];
        if ([jsonArr count] > 0) {
            [msgArr addObjectsFromArray:jsonArr];
            [self.msgTableView reloadData];
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
            [self setLastUpdate: [df dateFromString: [[jsonArr lastObject] objectForKey:@"added"]]];
        }
    }
    [self setRecvData:nil];
    
}

- (void)connection:(NSURLConnection *)connection 
  didFailWithError:(NSError *)error {
    [self setRecvData:nil];
}

#pragma mark - TableView delegate method
- (NSInteger)numberOfSectionInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.msgArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellId = @"cell";
    
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:CellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellId];
    }

    NSDictionary *messageDict = [msgArr objectAtIndex:indexPath.row];
    cell.textLabel.text = [messageDict objectForKey: @"message"];
    cell.detailTextLabel.text = [messageDict objectForKey: @"user"];
    
    return cell;
}

#define KBD_HEIGHT 215
#pragma mark - TextField delegate method
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.msgView.center = CGPointMake(self.msgView.center.x, self.msgView.center.y - KBD_HEIGHT);
                     }];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.msgView.center = CGPointMake(self.msgView.center.x, self.msgView.center.y + KBD_HEIGHT);
                     }];
    return YES;
}
@end
