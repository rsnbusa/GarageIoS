//
//  feederViewController.m
//  FeedIoT
//
//  Created by Robert on 3/13/16.
//  Copyright © 2016 Colin Eberhardt. All rights reserved.
//

#import "feederViewController.h"
#import "AppDelegate.h"
#import "ThirViewController.h"
#import "FirstViewController.h"
#import "HMSegmentedControl.h"
#import "httpVC.h"

@implementation feederViewController

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;


@synthesize openTime,waitTime,openSlider,waitSlider,b1,b2,b3,b4,b5,openT,waitT,fc;


-(IBAction)editingEnded:(id)sender{
    [sender resignFirstResponder];
}

-(IBAction)editingChange:(UITextField*)sender{
    if (sender==openTime)
        openSlider.value=sender.text.integerValue;
    if (sender==waitTime)
        waitSlider.value=sender.text.integerValue;
    changef=true;
}
-(IBAction)sliderTime:(UISlider*)sender{
    float localf=sender.value;
    if (sender==openSlider)
        openTime.text=[NSString stringWithFormat:@"%d",(int)localf];
    if(sender==waitSlider)
        waitTime.text=[NSString stringWithFormat:@"%d",(int)localf];
    changef=true;
}

-(IBAction)testIt:(id)sender{
    NSString *mis;
    NSMutableString *answer;
    answer=[NSMutableString string];
    mis=[NSString stringWithFormat:@"test?open=%ld&wait=%ld",openTime.text.integerValue,waitTime.text.integerValue];
    [comm lsender:mis andAnswer:answer andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue] vcController:self];
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect textFieldRect =
    [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect =
    [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
    midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
    (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

-(IBAction)prepareForUnwindSetFeeder:(UIStoryboardSegue *)segue {
    
}

-(IBAction)doneBut:(id)sender
{
 [self performSegueWithIdentifier:@"finCustom" sender:self];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    comm=[httpVC new];
    openTime.keyboardType=UIKeyboardTypeNumbersAndPunctuation;
    waitTime.keyboardType=UIKeyboardTypeNumbersAndPunctuation;
    changef=false;
    openSlider.value= [[[NSUserDefaults standardUserDefaults]objectForKey:@"serv3Open"] integerValue];
    waitSlider.value= [[[NSUserDefaults standardUserDefaults]objectForKey:@"serv3Wait"] integerValue];
    openTime.text=[NSString stringWithFormat:@"%d",(int)openSlider.value];
    waitTime.text=[NSString stringWithFormat:@"%d",(int)waitSlider.value];
}



- (void)viewWillDisappear:(BOOL)animated { //Is used as a Save Options if anything was changed Instead of Buttons
    
    [super viewWillDisappear:animated];
    if (changef)
    {
        fc.openT=(int)openSlider.value;
        fc.waitT=(int)waitSlider.value;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger: (int)openSlider.value]  forKey:@"serv4Open"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger: (int)waitSlider.value]  forKey:@"serv4Wait"];
    }
    
}
@end
