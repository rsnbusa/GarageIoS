//
//  AppDelegate.h
//  FoodAuto
//
//  Created by Robert on 3/2/16.
//  Copyright © 2016 Robert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MQTTKit.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIViewController *firstViewController,*secondViewController;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) NSMutableArray *servingsArray,*bffs,*emailsArray,*appColors,*imageArray,*logText;
@property (strong, nonatomic) NSMutableDictionary *feed_addr,*queues;
@property int lastbutton;
@property (strong, nonatomic) NSManagedObject *workingBFF,*oldbff;
@property (strong, nonatomic) NSMutableArray* feeders;
@property (strong, nonatomic) NSMutableString *direccion,*deviceMqtt;
@property (strong, nonatomic) NSString *saveMqttServer,*saveMqttPort;
@property (strong, nonatomic) NSArray *mqservers;

@property BOOL addf,passwordf,clonef,rxIn,backg;
@property int lastpos,messageType,voyserver;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong,nonatomic) MQTTClient *client;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
//- (void)createQueue:(NSString*)nombre;
- (void)startTelegramService:(NSString*)whichServer withPort:(NSString*)thisPort complete:(MQTTMessageHandler) aca;
- (void)subscribeMQTT:(NSString*)rx;
-(void)unsubscribeMQTT:(NSString*)rx;
-(void)connectManager:(NSString*)cualMqtt;
@end

