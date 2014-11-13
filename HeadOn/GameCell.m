//
//  GameCell.m
//  Head On
//
//  Created by Kevin Huang on 2/10/13.
//  Copyright (c) 2013 The Company. All rights reserved.
//

#import "GameCell.h"
#import "GameLogic.h"
#import "GameLayer.h"
#import "Game.h"

@implementation GameCell

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

- (IBAction)ResumeButton:(UIButton *)sender {
    if (_gameNumber) {
        NSLog(@"Game from Memory: %i", _gameNumber);
        [[GameLogic sharedGameLogic] popViews];
        [[CCDirector sharedDirector] replaceScene:[GameLayer sceneFromMemory:_gameNumber]];
        
    } else if (_GameObject) {
        NSLog(@"Game From Online");
        [[GameLogic sharedGameLogic] popViews];
        BOOL isPlayer1 = NO;
        if ([[[_GameObject objectForKey:@"Player1"] objectId] isEqualToString:[GameLogic sharedGameLogic].playerData.objectId]){
            isPlayer1 = YES;
            NSLog(@"Player 1");
        } else {
            NSLog(@"Player 2");
        }

        [[CCDirector sharedDirector] replaceScene:[GameLayer sceneFromGame:_GameObject isPlayer1:isPlayer1]];
    }
}

- (void) alertView:(UIAlertView *) alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
//        NSLog(@"Number: %i", _parentTableView.numberOfSections);
        if (_gameNumber) {
            NSString *gameName = [NSString stringWithFormat:@"Game%i", _gameNumber];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:gameName];
            [_parentDataSet removeObjectAtIndex:_selectedRow];
            [_parentTableView reloadData];
        } else {
            PFObject *GameObject = [_parentDataSet objectAtIndex:_selectedRow];
            
            PFObject *p1 = [GameObject objectForKey:@"Player1"];
            PFObject *p2 = [GameObject objectForKey:@"Player2"];
            
            int p1Total = [[p1 objectForKey:@"OnlineTotal"] intValue];
            int p2Total = [[p2 objectForKey:@"OnlineTotal"] intValue];
            
            int p1Win = [[p1 objectForKey:@"OnlineWins"] intValue];
            int p2Win = [[p2 objectForKey:@"OnlineWins"] intValue];
            
            int p1Exp = [[p1 objectForKey:@"Experience"] intValue];
            int p2Exp = [[p2 objectForKey:@"Experience"] intValue];
            
            BOOL isPlayer1 = NO;
            if ([p1.objectId isEqualToString:[GameLogic sharedGameLogic].playerData.objectId]) {
                isPlayer1 = YES;
            }
            
            int winexp = [self calculateWinnerExpForP1:p1Exp andP2:p2Exp p1Loss:isPlayer1];
            
            if (isPlayer1) {
                [p2 setObject:[NSNumber numberWithInt:p2Exp + winexp] forKey:@"Experience"];
                p2Win++;
            } else {
                [p1 setObject:[NSNumber numberWithInt:p1Exp + winexp] forKey:@"Experience"];
                p1Win++;
            }
            
            p1Total++;
            p2Total++;
            
            [p1 setObject:[NSNumber numberWithInt:p1Total] forKey:@"OnlineTotal"];
            [p2 setObject:[NSNumber numberWithInt:p2Total] forKey:@"OnlineTotal"];
            
            [p1 setObject:[NSNumber numberWithInt:p1Win] forKey:@"OnlineWins"];
            [p2 setObject:[NSNumber numberWithInt:p2Win] forKey:@"OnlineWins"];
            
            [GameObject setObject:[NSNumber numberWithBool:YES] forKey:@"Ended"];
            [GameObject saveInBackground];
            
            [p1 saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error)
                    NSLog(@"Error p1");
            }];
            
            [p2 saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error)
                    NSLog(@"Error p2");
            }];
            
            [_parentDataSet removeObjectAtIndex:_selectedRow];
            [_parentTableView reloadData];
        }
    }
}

- (IBAction)ForfeitButton:(UIButton *)sender {
    
    UIAlertView *forfeit;
    if (_gameNumber) 
        forfeit = [[UIAlertView alloc] initWithTitle:@"Delete Game?" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
    else
        forfeit = [[UIAlertView alloc] initWithTitle:@"Forfeit?" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
    [forfeit show];
}

- (int) calculateWinnerExpForP1: (int) p1Exp andP2: (int) p2Exp p1Loss: (BOOL) p1loss {
    int exp = 0;
        
    int p1Level = [[GameLogic sharedGameLogic] calculateLevel:p1Exp];
    int p2Level = [[GameLogic sharedGameLogic] calculateLevel:p2Exp];
    
    int coef = 10;
    
    if (p1loss) {
        if (p1Level > p2Level) {
            coef += (p1Level - p2Level) * 2;
        } else {
            coef -= (p2Level - p1Level) * 1;
        }
    } else {
        if (p1Level > p2Level) {
            coef -= (p1Level - p2Level) * 1;
        } else {
            coef += (p2Level - p1Level) * 2;
        }
    }
    
    if (coef < 1)
        coef = 1;
    
    if (coef > 20)
        coef = 20;
    
    exp += 500;
    exp += coef * 200;

    return exp;
}
@end
