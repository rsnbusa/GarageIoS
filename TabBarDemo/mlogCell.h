//
//  LogCell.h
//  GarageIoT
//
//  Created by Robert on 6/16/17.
//  Copyright © 2017 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface mlogCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *hora,*dia,*mensaje,*code1;
@property (nonatomic, weak) IBOutlet UIImageView *codeImage;
@end
