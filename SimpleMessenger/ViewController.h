//
//  ViewController.h
//  SimpleMessenger
//
//  Created by 고 준일 on 12. 1. 17..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITableView *msgTableView;
@property (strong, nonatomic) IBOutlet UIView *msgView;
@property (strong, nonatomic) IBOutlet UITextField *msgTextField;

@property (strong, nonatomic) NSDate *lastUpdate;
@property (strong, nonatomic) NSMutableData *recvData;
@property (strong, nonatomic) NSMutableArray *msgArr;
@property (strong, nonatomic) NSTimer *msgTimer;

- (IBAction)msgSend:(id)sender;

- (IBAction)sendNewMessage:(NSString *)newMsg
                  withName:(NSString *)name;
@end
