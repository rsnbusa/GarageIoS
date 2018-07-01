//
//  Timers.h
//  MeterIoT
//
//  Created by Robert on 6/14/17.
//  Copyright © 2017 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "httpVC.h"
#import "AppDelegate.h"

@interface Timers : UIViewController
{
    httpVC *comm;
    NSString *mis;
    AppDelegate* appDelegate;
    bool save;
    MQTTMessageHandler viejo;
}
@property (strong, nonatomic) IBOutlet UILabel         *wait,*timeout,*sleep,*motor;
@property (strong, nonatomic) IBOutlet UISlider         *waitsl,*timeoutsl,*sleepsl,*motorsl;
@property (strong, nonatomic) IBOutlet UISwitch         *guard,*autosend;
@property (strong) IBOutlet UIImageView *bffIcon;
@end
