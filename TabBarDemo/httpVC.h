//
//  httpVC.h
//  FeedIoT
//
//  Created by Robert on 4/14/16.
//  Copyright © 2016 Colin Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQTTKit.h"

@interface httpVC : NSObject
{
    NSMutableArray *servers, *ports;
    BOOL flag;
   
}

-(uint)lsender: (NSString*) que andAnswer:(NSString **) quedijo andTimeOut:(float) cuantoEspero vcController:(id)quien;
-(uint)lsender: (NSString*) que andAnswer:(NSString **) quedijo andTimeOut:(float) cuantoEspero;
@end
