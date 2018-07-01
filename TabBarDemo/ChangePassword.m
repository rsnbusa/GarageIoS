//
//  ChangePassword.m
//  GarageIoT
//
//  Created by Robert on 6/22/16.
//  Copyright © 2016 Colin Eberhardt. All rights reserved.
//

#import "ChangePassword.h"
#import "KeychainWrapper.h"
#import <Security/Security.h>

@interface ChangePassword ()

@end

@implementation ChangePassword
@synthesize user,pass,passc;

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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self saveit:NULL];
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    user.delegate=(id)self;
    pass.delegate=(id)self;
    passc.delegate=(id)self;
    [user becomeFirstResponder];
//    [self performSegueWithIdentifier:@"getPassword" sender:self];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)saveit:(id)sender
{
    if([pass.text isEqualToString:passc.text])
       {
           KeychainWrapper* keychain = [[KeychainWrapper alloc]init];
           [keychain mySetObject:kSecAttrAccessibleWhenUnlocked forKey:kSecAttrAccessible];
           [keychain mySetObject:user.text forKey:kSecAttrAccount];
           [keychain mySetObject:pass.text forKey:kSecValueData];
       //    [self performSegueWithIdentifier:@"returnFirst" sender:self];
           [self dismissViewControllerAnimated:YES completion:nil];
       }
    else
        [self showMessage:@"Password Change" withMessage:@"Password do not match"];
}

-(IBAction)cancelit:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
  //  [self performSegueWithIdentifier:@"returnFirst" sender:self];

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
