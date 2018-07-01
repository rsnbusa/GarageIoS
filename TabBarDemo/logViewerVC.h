//
//  logViewerVC.h
//  FeedIoT
//
//  Created by Robert on 5/6/16.
//  Copyright © 2016 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "httpVC.h"
#import "AppDelegate.h"

@interface logViewerVC : UIViewController
{
    NSMutableArray *logs;
     httpVC *comm;
    NSString *mis;
    NSMutableString *answer;
    NSArray *lines;
    AppDelegate *appDelegate;
}
@property (strong,nonatomic) IBOutlet UITableView *table;
@property (strong,nonatomic) IBOutlet UIImageView *bffIcon;
@end
