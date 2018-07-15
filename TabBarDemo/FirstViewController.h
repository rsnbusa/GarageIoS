//
//  FirstViewController.h
//  FoodAuto
//
//  Created by Robert on 3/2/16.
//  Copyright © 2016 Robert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "httpVC.h"
#import "MQTTKit.h"
#import "AMTumblrHud.h"

@interface FirstViewController : UIViewController <UIScrollViewDelegate, NSNetServiceDelegate, NSNetServiceBrowserDelegate,UICollectionViewDataSource, UICollectionViewDelegate,NSStreamDelegate >
{
    UIImage *imagel,*grid,*pano;
    AppDelegate *appDelegate;
   
    BOOL viewmodef,batchf,loadFlag;
    int fotoHV;
    int indexOfPage;
    httpVC *comm;
    uint8_t buffer[40000];
    UIView *backGroundBlurr;
    int oldcomo;
    UIImage *passOn,*passOff;
    AMTumblrHud *tumblrHUD ;
    UIImageView *lscrollView;
        NSTimer *mitimer;
    

}
@property (strong) NSMutableString *host,*answer,*mqttServer;
@property (strong) IBOutlet UILabel *petName,*opens,*aborted,*guards,*doorState;
@property  (strong) NSNumber *effects;
@property BOOL collect;
@property (strong, nonatomic) IBOutlet UIScrollView         *picScroll;
@property (strong, nonatomic) IBOutlet UIImageView          *hhud;
@property (strong, nonatomic) IBOutlet UICollectionView     *album;
@property (strong, nonatomic) IBOutlet UISlider             *fotoSize;
@property (strong, nonatomic) IBOutlet UIButton             *onOff,*passSW,*addBut;
@property (strong, nonatomic) NSNetServiceBrowser           *netServiceBrowser;
@property (nonatomic, strong, readwrite) NSOutputStream     *networkStream;
@property (nonatomic, strong, readwrite) NSInputStream      *fileStream;
@property (nonatomic, assign, readonly ) uint8_t            *buffer;
@property (nonatomic, assign, readwrite) size_t             bufferOffset;
@property (nonatomic, assign, readwrite) size_t             bufferLimit;
@end

