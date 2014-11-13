//
//  InviteCell.h
//  Head On
//
//  Created by Kevin Huang on 2/12/13.
//  Copyright (c) 2013 The Company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AutoScrollLabel.h"

@interface InviteCell : UITableViewCell

@property (strong, nonatomic) IBOutlet AutoScrollLabel *NameLabel;
@property (strong, nonatomic) IBOutlet UILabel *LevelLabel;
- (IBAction)StartGame:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *GoButton;
- (IBAction)RejectButton:(id)sender;
@property (nonatomic, retain) PFObject *game;
@property (nonatomic, retain) NSMutableArray *parentDataSet;
@property (nonatomic, retain) UITableView *parentTableView;
@end
