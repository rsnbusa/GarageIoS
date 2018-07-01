//
//  wifiViewController.h
//  FeedIoT
//
//

#import <UIKit/UIKit.h>
#import "FirstViewController.h"
#import "AppDelegate.h"
@interface wifiViewController : UIViewController
{
    FirstViewController *fc;
    NSArray *wifis;
    NSMutableString *ap;
    AppDelegate *appDelegate;
    NSString *mis,*arranca;
    NSMutableString *answer,*ipaddress;
    BOOL apsetup;
}
@property (strong) IBOutlet UITableView *myTable;
@property (strong) IBOutlet UIImageView *bffIcon;
@property (strong) IBOutlet UITextField *webPort,*fixip,*webTemp;
@property (strong) IBOutlet UIButton *b1,*b2;
@property (strong) IBOutlet UILabel *l1,*l2;
@property (strong) IBOutlet UISwitch *clone;
@property (strong) NSString *initer;
@end
