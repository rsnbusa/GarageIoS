//
//  feederViewController.h
//  FeedIoT
//
//  Created by Robert on 3/13/16.
//  Copyright © 2016 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ThirViewController.h"
#import "httpVC.h"

@interface feederViewController : UIViewController
{

    BOOL changef,keyboardIsShown ;
    CGFloat animatedDistance;
    httpVC *comm;
}
@property (strong) IBOutlet UITextField *openTime,*waitTime;
@property (strong) IBOutlet UISlider *openSlider,*waitSlider;
@property (strong) IBOutlet UIButton *b1,*b2,*b3,*b4,*b5;
@property int openT,waitT;
@property (strong) ThirViewController *fc;
@end

