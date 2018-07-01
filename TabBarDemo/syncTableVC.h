//
//  syncTableVC.h
//  FeedIoT
//
//  Created by Robert on 3/21/16.
//  Copyright © 2016 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface syncTableVC : UIViewController
{
    UIColor *redC,*greenC,*blueC,*settingC,*orangeC;
}
@property (strong) IBOutlet UITableView *tablesync;
@property (strong) NSArray *servingsArray;
@end
