//
//  mqttUser.h
//  MeterIoT
//
//  Created by Robert on 2/9/17.
//  Copyright © 2017 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "httpVC.h"
#import "AppDelegate.h"

@interface mqttUser : UIViewController
{
    httpVC *comm;
    NSString *mis;
    AppDelegate* appDelegate;
}
@property (strong) IBOutlet UIImageView *bffIcon;
@property (strong) IBOutlet UITextField *meterid,*startkwh,*server,*port;

@end
