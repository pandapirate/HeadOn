//
//  GameCell.h
//  Head On
//
//  Created by Kevin Huang on 2/10/13.
//  Copyright (c) 2013 The Company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AutoScrollLabel.h"

@interface GameCell : UITableViewCell

@property (nonatomic, retain) UITableView *parentTableView;
@property (nonatomic, retain) NSMutableArray *parentDataSet;
@property (nonatomic) int selectedRow;
@property (nonatomic) int gameNumber;
@property (nonatomic, retain) PFObject *GameObject;

@property (strong, nonatomic) IBOutlet AutoScrollLabel *NameLabel;
@property (strong, nonatomic) IBOutlet UILabel *BoardSize;
- (IBAction)ResumeButton:(UIButton *)sender;

@end
