//
//  Position.h
//  DoubleStrike
//
//  Created by Kevin Huang on 1/22/13.
//  Copyright (c) 2013 The Company. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Position : NSObject
@property (nonatomic) int x;
@property (nonatomic) int y;
@property (nonatomic) int boardX;
@property (nonatomic) int boardY;
@property (nonatomic) int piece;

@end
