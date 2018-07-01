//
//  Password.m
//  GarageIoT
//
//  Created by Robert on 6/21/16.
//  Copyright © 2016 Colin Eberhardt. All rights reserved.
//

#import "Password.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "KeychainWrapper.h"
#import <Security/Security.h>

#if 1 // set to 1 to enable logs
#define LogDebug(frmt, ...) NSLog([frmt stringByAppendingString:@"[%s]{%d}"], ##__VA_ARGS__,__PRETTY_FUNCTION__,__LINE__);
#else
#define LogDebug(frmt, ...) {}
#endif

@interface Password ()

@end

@implementation Password
@synthesize user,pass;

-(void)showMessage:(NSString*) title withMessage:(NSString *)message
{
UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                               message:message
                                                        preferredStyle:UIAlertControllerStyleAlert];
UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                                                                                }];


[alert addAction:defaultAction];
[self presentViewController:alert animated:YES completion:nil];
}

-(IBAction)cancel:(id)sender
{
    exit(0);
}

-(IBAction)prepareForUnwindPassword:(UIStoryboardSegue *)segue {
    
}

-(IBAction)login:(id)sender
{
    KeychainWrapper* keychain = [[KeychainWrapper alloc]init];
    [keychain mySetObject:(id)kSecAttrAccessibleWhenUnlocked forKey:(id)kSecAttrAccessible];
    LogDebug(@"%@, %@", [keychain myObjectForKey:kSecAttrAccount], [keychain myObjectForKey:kSecValueData]);
    NSString *useri=[keychain myObjectForKey:(id)kSecAttrAccount];
    NSString *passwi=[keychain myObjectForKey:(id)kSecValueData];
    LogDebug(@"User %@ Pass %@",useri,passwi);
    if([useri isEqualToString:user.text] && [passwi isEqualToString:pass.text])
    {
    appDelegate.passwordf=YES;
        [self dismissViewControllerAnimated:YES completion:nil];
  //  [self performSegueWithIdentifier:@"returnFirst" sender:self];
    }
    else
    {
        [self showMessage:@"Login Error" withMessage:@"Invalid User or Password"];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self login:NULL];
    return NO;
}

-(IBAction)changeUserPassword:(id)sender
{
    KeychainWrapper* keychain = [[KeychainWrapper alloc]init];
    [keychain mySetObject:(id)kSecAttrAccessibleWhenUnlocked forKey:(id)kSecAttrAccessible];
    //  LogDebug(@"%@, %@", [keychain myObjectForKey:kSecAttrAccount], [keychain myObjectForKey:kSecValueData]);
    NSString *useri=[keychain myObjectForKey:(id)kSecAttrAccount];
    NSString *passwi=[keychain myObjectForKey:(id)kSecValueData];
    if([useri isEqualToString:user.text] && [passwi isEqualToString:pass.text])
    {
        appDelegate.passwordf=YES;
        [self performSegueWithIdentifier:@"changePassword" sender:self];
    }
    else
    {
        [self showMessage:@"Login Error" withMessage:@"Invalid User or Password"];
    }

    
}
-(void)checkPassword
{
    
    LAContext *context = [[LAContext alloc] init];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:@"Are you the device owner?"
                          reply:^(BOOL success, NSError *error) {
                              if (error) {/*
                                           dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
                                           dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                           [self showMensaje:@"Touch Id" withMessage:@"General Error" doExit:YES];
                                           });*/
                                  hasTouch=NO;
                              }
                              
                              if (!success) {/*
                                              dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
                                              dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                              [self showMensaje:@"Touch Id" withMessage:@"No fingers registered" doExit:YES];
                                              });*/
                                  hasTouch=NO;
                              }
                              else
                                  
                              {
                                   hasTouch=YES;
                                  appDelegate.passwordf=YES;
                                  [self performSegueWithIdentifier:@"returnFirst" sender:self];
                              }
                              
                          }];
        
    } else {
        /*
         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
         [self showMensaje:@"Touch Id" withMessage:@"Device does not support TouchId" doExit:NO];
         });*/
    }
    hasTouch=NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    user.delegate=(id)self;
    pass.delegate=(id)self;
    [user becomeFirstResponder];
    // Do any additional setup after loading the view.
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
     appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   
    [self checkPassword];


    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
