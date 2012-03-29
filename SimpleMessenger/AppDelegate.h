//
//  AppDelegate.h
//  SimpleMessenger
//
//  Created by 고 준일 on 12. 1. 17..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;
- (void)sendDeviceToken:(NSData *)tokenData;
@end
