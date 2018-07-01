//
//  tabc.m
//  HeatIoT
//
//  Created by Robert on 9/9/16.
//  Copyright © 2016 Colin Eberhardt. All rights reserved.
//

#import "tabc.h"

@implementation tabc

    
    -(CGSize)sizeThatFits:(CGSize)size
    {
        CGSize sizeThatFits = [super sizeThatFits:size];
        sizeThatFits.height = 100;
        
        return sizeThatFits;
    }
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
