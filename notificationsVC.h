//
//  notificationsVC.h
//  FeedIoT
//
//  Created by Robert on 4/1/16.
//  Copyright © 2016 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FirstViewController.h"
#import "AppDelegate.h"
#import "MultiSelectSegmentedControl.h"
#import "TextFieldValidator.h"
#import "httpVc.h"

@interface notificationsVC : UIViewController <UIAlertViewDelegate>
{
    FirstViewController *fc;
    BOOL changef,keyboardIsShown,dirtyf,editf ;
    CGFloat animatedDistance;
    AppDelegate *appDelegate;
    NSString *mis;
    NSMutableString *answer,*copyemail;
    NSIndexSet *selectedIndices;
    NSMutableArray *selectedItemsArray,*copyArray;
    httpVC *comm;
    UIView *backGroundBlurr;
    int oldtrans;

}

@property (strong) IBOutlet TextFieldValidator *mqtt,*IFTTT,*domain;
@property (strong) IBOutlet UISegmentedControl *notis;
@property (strong) IBOutlet UITableView *emailTable;
@property (strong) IBOutlet UIImageView *bffIcon;
@property (strong) IBOutlet UISwitch *exception;
@property (strong) IBOutlet UIBarButtonItem *editab;
@end

