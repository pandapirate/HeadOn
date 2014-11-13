//
//  PlayerCell.m
//  Head On
//
//  Created by Kevin Huang on 2/12/13.
//  Copyright (c) 2013 The Company. All rights reserved.
//

#import "PlayerCell.h"
#import "OnlineGameSelection.h"

@implementation PlayerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)StartGame:(UIButton *)sender {
    [[GameLogic sharedGameLogic] popViews];
    [[CCDirector sharedDirector] replaceScene:[OnlineGameSelection sceneWithPlayer:_user]];
}

@end
