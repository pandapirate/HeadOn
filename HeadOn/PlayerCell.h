//
//  PlayerCell.h
//  Head On
//
//  Created by Kevin Huang on 2/12/13.
//  Copyright (c) 2013 The Company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AutoScrollLabel.h"

@interface PlayerCell : UITableViewCell

@property (nonatomic, retain) PFObject *user;

@property (strong, nonatomic) IBOutlet UILabel *PlayerLevel;
@property (strong, nonatomic) IBOutlet AutoScrollLabel *PlayerName;
- (IBAction)StartGame:(UIButton *)sender;

@end
