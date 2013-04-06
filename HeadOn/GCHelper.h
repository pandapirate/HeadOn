//
//  GCHelper.h
//  Head On
//
//  Created by Kevin Huang on 2/18/13.
//  Copyright (c) 2013 The Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@protocol GCHelperProtocol <NSObject>

- (void) onScoresSubmitted:(BOOL) success;
@end

@interface GCHelper : NSObject <GKGameCenterControllerDelegate>
{
    BOOL gcAvailable;
    BOOL userAuthenticated;
    NSMutableDictionary *achievementCache;
    int completedAchievements;
}

@property (assign, readonly) BOOL gameCenterAvailable;
@property (nonatomic, assign) id<GCHelperProtocol> delegate;
@property (nonatomic, readonly) NSError *lastError;

+ (GCHelper *) sharedInstance;
- (void) authenticateLocalUser;
- (void) submitHighScore: (int64_t) score forCategory: (NSString *) category;
- (void) addGameOnBoard: (int) boardSize againstComputer: (int) difficulty isOnlineGame: (BOOL) online p1Won: (BOOL) won;
- (void) checkAchievements;
- (void) initializeStatistics;
- (int) totalWins;
- (void) submitAchievement: (NSString *) identifier percentComplete: (double) percent;
@end
