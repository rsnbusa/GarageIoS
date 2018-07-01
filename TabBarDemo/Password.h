//
//  Password.h
//  GarageIoT
//
//  Created by Robert on 6/21/16.
//  Copyright © 2016 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@interface Password : UIViewController
{
        AppDelegate *appDelegate;
        bool hasTouch;
}
@property (nonatomic,strong) IBOutlet UITextField *user,*pass;
@end
