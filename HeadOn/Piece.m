//
//  Piece.m
//  Head On
//
//  Created by Kevin Huang on 1/29/13.
//  Copyright (c) 2013 The Company. All rights reserved.
//

#import "Piece.h"

@implementation Piece

- (CCNode *) createSprite: (int) number {
    _group = [[CCNode alloc] init];
    CGSize size = CGSizeMake(160, 160);
    _group.contentSize = size;
    
    [self setSelectedSprite:number];
    
    _legR.flipX = YES;
    
    [_group addChild:_back z:1];
    [_group addChild:_side z:1];
    [_group addChild:_body z:1];
    [_group addChild:_loss z:1];
    [_group addChild:_armL z:2];
    [_group addChild:_armR z:2];
    [_group addChild:_legL z:0];
    [_group addChild:_legR z:2];
    
    [self faceIdle];
    
    return _group;
}

- (void) setSelectedSprite: (int) number {
//1 - pooky
//2 - panda
//3 - cow
//4 - rabbit
//5 - bear
    CGSize size = _group.contentSize;
    armCoordL = ccp(size.width/2 - 49, size.height/2);
    armCoordR = ccp(size.width/2 + 49, size.height/2);
    legCoordL = ccp(size.width/2 - 20, size.height/2 - 34);
    legCoordR = ccp(size.width/2 + 20, size.height/2 - 34);
    sideFootCoord = ccp(size.width/2 - 3, size.height/2 - 30);
    sideArmCoord = ccp(size.width/2 + 5, size.height/2);
    bodyCoord = ccp(size.width/2, size.height/2 + 25);
    
    switch (number) {
        case 1: {
            _armL = [[CCSprite alloc] initWithFile:@"pookyhand.png"];
            _armR = [[CCSprite alloc] initWithFile:@"pookyhand.png"];
            _legL = [[CCSprite alloc] initWithFile:@"pookyfoot.png"];
            _legR = [[CCSprite alloc] initWithFile:@"pookyfoot.png"];
            _body = [[CCSprite alloc] initWithFile:@"redhead.png"];
            _side = [[CCSprite alloc] initWithFile:@"sidehead.png"];
            _back = [[CCSprite alloc] initWithFile:@"backredhead.png"];
            _loss = [[CCSprite alloc] initWithFile:@"losshead.png"];
            handTexture = [[CCTextureCache sharedTextureCache] addImage:@"pookyhand.png"];
            footTexture = [[CCTextureCache sharedTextureCache] addImage:@"pookyfoot.png"];
            break;
        } case 2: {
            _armL = [[CCSprite alloc] initWithFile:@"pandahand.png"];
            _armR = [[CCSprite alloc] initWithFile:@"pandahand.png"];
            _legL = [[CCSprite alloc] initWithFile:@"pandafoot.png"];
            _legR = [[CCSprite alloc] initWithFile:@"pandafoot.png"];
            _body = [[CCSprite alloc] initWithFile:@"pandahead.png"];
            _side = [[CCSprite alloc] initWithFile:@"pandaheadside.png"];
            _back = [[CCSprite alloc] initWithFile:@"pandaheadback.png"];
            _loss = [[CCSprite alloc] initWithFile:@"losshead.png"];
            handTexture = [[CCTextureCache sharedTextureCache] addImage:@"pandahand.png"];
            footTexture = [[CCTextureCache sharedTextureCache] addImage:@"pandafoot.png"];
            break;
        } case 3: {
            _armL = [[CCSprite alloc] initWithFile:@"cawhand.png"];
            _armR = [[CCSprite alloc] initWithFile:@"cawhand.png"];
            _legL = [[CCSprite alloc] initWithFile:@"cawfoot.png"];
            _legR = [[CCSprite alloc] initWithFile:@"cawfoot.png"];
            _body = [[CCSprite alloc] initWithFile:@"cawhead.png"];
            _side = [[CCSprite alloc] initWithFile:@"cawheadside.png"];
            _back = [[CCSprite alloc] initWithFile:@"cawheadback.png"];
            _loss = [[CCSprite alloc] initWithFile:@"losshead.png"];
            handTexture = [[CCTextureCache sharedTextureCache] addImage:@"cawhand.png"];
            footTexture = [[CCTextureCache sharedTextureCache] addImage:@"cawfoot.png"];
            break;
        } case 4: {
            _armL = [[CCSprite alloc] initWithFile:@"rabbithand.png"];
            _armR = [[CCSprite alloc] initWithFile:@"rabbithand.png"];
            _legL = [[CCSprite alloc] initWithFile:@"rabbitfoot.png"];
            _legR = [[CCSprite alloc] initWithFile:@"rabbitfoot.png"];
            _body = [[CCSprite alloc] initWithFile:@"rabbithead.png"];
            _side = [[CCSprite alloc] initWithFile:@"rabbitheadside.png"];
            _back = [[CCSprite alloc] initWithFile:@"rabbitheadback.png"];
            _loss = [[CCSprite alloc] initWithFile:@"losshead.png"];
            handTexture = [[CCTextureCache sharedTextureCache] addImage:@"rabbithand.png"];
            footTexture = [[CCTextureCache sharedTextureCache] addImage:@"rabbitfoot.png"];
            break;
        } case 5: {
            _armL = [[CCSprite alloc] initWithFile:@"bearhand.png"];
            _armR = [[CCSprite alloc] initWithFile:@"bearhand.png"];
            _legL = [[CCSprite alloc] initWithFile:@"bearfoot.png"];
            _legR = [[CCSprite alloc] initWithFile:@"bearfoot.png"];
            _body = [[CCSprite alloc] initWithFile:@"bearhead.png"];
            _side = [[CCSprite alloc] initWithFile:@"bearheadside.png"];
            _back = [[CCSprite alloc] initWithFile:@"bearheadback.png"];
            _loss = [[CCSprite alloc] initWithFile:@"losshead.png"];
            handTexture = [[CCTextureCache sharedTextureCache] addImage:@"bearhand.png"];
            footTexture = [[CCTextureCache sharedTextureCache] addImage:@"bearfoot.png"];
            break;
        } case 6: {
            _armL = [[CCSprite alloc] initWithFile:@"froghand.png"];
            _armR = [[CCSprite alloc] initWithFile:@"froghand.png"];
            _legL = [[CCSprite alloc] initWithFile:@"frogfoot.png"];
            _legR = [[CCSprite alloc] initWithFile:@"frogfoot.png"];
            _body = [[CCSprite alloc] initWithFile:@"froghead.png"];
            _side = [[CCSprite alloc] initWithFile:@"frogheadside.png"];
            _back = [[CCSprite alloc] initWithFile:@"frogheadback.png"];
            _loss = [[CCSprite alloc] initWithFile:@"losshead.png"];
            handTexture = [[CCTextureCache sharedTextureCache] addImage:@"froghand.png"];
            footTexture = [[CCTextureCache sharedTextureCache] addImage:@"frogfoot.png"];
            break;
        } case 7: {
            _armL = [[CCSprite alloc] initWithFile:@"monkeyhand.png"];
            _armR = [[CCSprite alloc] initWithFile:@"monkeyhand.png"];
            _legL = [[CCSprite alloc] initWithFile:@"monkeyfoot.png"];
            _legR = [[CCSprite alloc] initWithFile:@"monkeyfoot.png"];
            _body = [[CCSprite alloc] initWithFile:@"monkeyhead.png"];
            _side = [[CCSprite alloc] initWithFile:@"monkeyside.png"];
            _back = [[CCSprite alloc] initWithFile:@"monkeyback.png"];
            _loss = [[CCSprite alloc] initWithFile:@"losshead.png"];
            handTexture = [[CCTextureCache sharedTextureCache] addImage:@"monkeyhand.png"];
            footTexture = [[CCTextureCache sharedTextureCache] addImage:@"monkeyfoot.png"];
            sideArmCoord = ccp(size.width/2 + 5, size.height/2 - 5);
            break;
        } case 8: {
            _armL = [[CCSprite alloc] initWithFile:@"roosterhand.png"];
            _armR = [[CCSprite alloc] initWithFile:@"roosterhand.png"];
            _legL = [[CCSprite alloc] initWithFile:@"roosterfoot.png"];
            _legR = [[CCSprite alloc] initWithFile:@"roosterfoot.png"];
            _body = [[CCSprite alloc] initWithFile:@"roosterhead.png"];
            _side = [[CCSprite alloc] initWithFile:@"roosterheadside.png"];
            _back = [[CCSprite alloc] initWithFile:@"roosterheadback.png"];
            _loss = [[CCSprite alloc] initWithFile:@"losshead.png"];
            handTexture = [[CCTextureCache sharedTextureCache] addImage:@"roosterhand.png"];
            footTexture = [[CCTextureCache sharedTextureCache] addImage:@"roosterfoot.png"];
            break;
        } case 9: {
            _armL = [[CCSprite alloc] initWithFile:@"cathand.png"];
            _armR = [[CCSprite alloc] initWithFile:@"cathand.png"];
            _legL = [[CCSprite alloc] initWithFile:@"catfoot.png"];
            _legR = [[CCSprite alloc] initWithFile:@"catfoot.png"];
            _body = [[CCSprite alloc] initWithFile:@"cathead.png"];
            _side = [[CCSprite alloc] initWithFile:@"catheadside.png"];
            _back = [[CCSprite alloc] initWithFile:@"catheadback.png"];
            _loss = [[CCSprite alloc] initWithFile:@"losshead.png"];
            handTexture = [[CCTextureCache sharedTextureCache] addImage:@"cathand.png"];
            footTexture = [[CCTextureCache sharedTextureCache] addImage:@"catfoot.png"];
            sideArmCoord = ccp(size.width/2 + 5, size.height/2 - 8);
            break;
        } case 10: {
            _armL = [[CCSprite alloc] initWithFile:@"doghand.png"];
            _armR = [[CCSprite alloc] initWithFile:@"doghand.png"];
            _legL = [[CCSprite alloc] initWithFile:@"dogfoot.png"];
            _legR = [[CCSprite alloc] initWithFile:@"dogfoot.png"];
            _body = [[CCSprite alloc] initWithFile:@"doghead.png"];
            _side = [[CCSprite alloc] initWithFile:@"dogheadside.png"];
            _back = [[CCSprite alloc] initWithFile:@"dogheadback.png"];
            _loss = [[CCSprite alloc] initWithFile:@"losshead.png"];
            handTexture = [[CCTextureCache sharedTextureCache] addImage:@"doghand.png"];
            footTexture = [[CCTextureCache sharedTextureCache] addImage:@"dogfoot.png"];
            sideArmCoord = ccp(size.width/2 + 5, size.height/2 - 8);
            break;
        }
        default:
            break;
    }
}

- (void) raiseLeftArm: (int) number  {
    int radius = _armL.boundingBox.size.width/2;
    CGPoint originalPos = _armL.position;
    NSMutableArray *moves = [[NSMutableArray alloc] init];
    for (int i = 5; i <= 60; i += 5) {
        int deltaX = radius - radius*cos(CC_DEGREES_TO_RADIANS(i));
        int deltaY = radius*sin(CC_DEGREES_TO_RADIANS(i));
        CGPoint newPos = ccp(originalPos.x + deltaX, originalPos.y + deltaY);
        [moves addObject:[CCMoveTo actionWithDuration:0.03 position:newPos]];
        [moves addObject:[CCRotateBy actionWithDuration:0.0 angle:5]];
    }
    
    for (int i = 55; i >= 0; i -= 5) {
        int deltaX = radius - radius*cos(CC_DEGREES_TO_RADIANS(i));
        int deltaY = radius*sin(CC_DEGREES_TO_RADIANS(i));
        CGPoint newPos = ccp(originalPos.x + deltaX, originalPos.y + deltaY);
        [moves addObject:[CCMoveTo actionWithDuration:0.03 position:newPos]];
        [moves addObject:[CCRotateBy actionWithDuration:0.0 angle:-5]];
    }
    
    CCSequence *seq = [CCSequence actionWithArray:moves];
    
    [_armL runAction:[CCRepeat actionWithAction:seq times:number]];
}

- (void) raiseRightArm: (int) number  {
    int radius = _armR.boundingBox.size.width/2;
    CGPoint originalPos = _armR.position;
    NSMutableArray *moves = [[NSMutableArray alloc] init];
    for (int i = 5; i <= 60; i += 5) {
        int deltaX = radius - radius*cos(CC_DEGREES_TO_RADIANS(i));
        int deltaY = radius*sin(CC_DEGREES_TO_RADIANS(i));
        CGPoint newPos = ccp(originalPos.x - deltaX, originalPos.y + deltaY);
        [moves addObject:[CCMoveTo actionWithDuration:0.03 position:newPos]];
        [moves addObject:[CCRotateBy actionWithDuration:0.0 angle:-5]];
    }
    
    for (int i = 55; i >=  0; i -= 5) {
        int deltaX = radius - radius*cos(CC_DEGREES_TO_RADIANS(i));
        int deltaY = radius*sin(CC_DEGREES_TO_RADIANS(i));
        CGPoint newPos = ccp(originalPos.x - deltaX, originalPos.y + deltaY);
        [moves addObject:[CCMoveTo actionWithDuration:0.03 position:newPos]];
        [moves addObject:[CCRotateBy actionWithDuration:0.0 angle:5]];
    }
    
    CCSequence *seq = [CCSequence actionWithArray:moves];
    
    [_armR runAction:[CCRepeat actionWithAction:seq times:number]];
}

- (void) swingLeftLeg: (int) number  {
    int radius = _legL.boundingBox.size.width/2;
    CGPoint originalPos = _legL.position;
    NSMutableArray *moves = [[NSMutableArray alloc] init];
    for (int i = 5; i <= 60; i += 5) {
        int deltaX = radius - radius*cos(CC_DEGREES_TO_RADIANS(i));
        int deltaY = radius*sin(CC_DEGREES_TO_RADIANS(i));
        CGPoint newPos = ccp(originalPos.x + deltaX, originalPos.y - deltaY);
        [moves addObject:[CCMoveTo actionWithDuration:0.03 position:newPos]];
        [moves addObject:[CCRotateBy actionWithDuration:0.0 angle:-5]];
    }
    
    for (int i = 55; i >= 0; i -= 5) {
        int deltaX = radius - radius*cos(CC_DEGREES_TO_RADIANS(i));
        int deltaY = radius*sin(CC_DEGREES_TO_RADIANS(i));
        CGPoint newPos = ccp(originalPos.x + deltaX, originalPos.y - deltaY);
        [moves addObject:[CCMoveTo actionWithDuration:0.03 position:newPos]];
        [moves addObject:[CCRotateBy actionWithDuration:0.0 angle:5]];
    }
    
    CCSequence *seq = [CCSequence actionWithArray:moves];
    
    [_legL runAction:[CCRepeat actionWithAction:seq times:number]];
}

- (void) swingRightLeg: (int) number  {
    int radius = _legR.boundingBox.size.width/2;
    CGPoint originalPos = _legR.position;
    NSMutableArray *moves = [[NSMutableArray alloc] init];
    for (int i = 5; i <= 60; i += 5) {
        int deltaX = radius - radius*cos(CC_DEGREES_TO_RADIANS(i));
        int deltaY = radius*sin(CC_DEGREES_TO_RADIANS(i));
        CGPoint newPos = ccp(originalPos.x - deltaX, originalPos.y - deltaY);
        [moves addObject:[CCMoveTo actionWithDuration:0.03 position:newPos]];
        [moves addObject:[CCRotateBy actionWithDuration:0.0 angle:5]];
    }
    
    for (int i = 55; i >= 0; i -= 5) {
        int deltaX = radius - radius*cos(CC_DEGREES_TO_RADIANS(i));
        int deltaY = radius*sin(CC_DEGREES_TO_RADIANS(i));
        CGPoint newPos = ccp(originalPos.x - deltaX, originalPos.y - deltaY);
        [moves addObject:[CCMoveTo actionWithDuration:0.03 position:newPos]];
        [moves addObject:[CCRotateBy actionWithDuration:0.0 angle:-5]];
    }
    
    CCSequence *seq = [CCSequence actionWithArray:moves];
    
    [_legR runAction:[CCRepeat actionWithAction:seq times:number]];
}

- (void) jump: (int) number {    
    [self faceDown];
    [self raiseLeftArm: number];
    [self raiseRightArm: number];
    [self swingLeftLeg: number];
    [self swingRightLeg: number];
    
    CGPoint originalPos = _group.position;
    int deltaY = 0;
    NSMutableArray *moves = [[NSMutableArray alloc] init];
    for (int i = 0; i < 24; i++) {
        if (i < 12) {
            deltaY += 3;
        } else {
            deltaY -= 3;
        }
        CGPoint newPos = ccp(originalPos.x, originalPos.y + deltaY);
        [moves addObject:[CCMoveTo actionWithDuration:0.03 position:newPos]];
    }
    
    CCSequence *seq = [CCSequence actionWithArray:moves];
    
    [_group runAction:[CCSequence actions:[CCRepeat actionWithAction:seq times:number],
                       [CCCallBlockN actionWithBlock:^(CCNode *node) {[self faceIdle];}],
                       nil]];
}

- (void) swingRightArm: (int) number {
    int angle = _armR.rotation;
    _armR.rotation = 0;
    int radius = _armR.boundingBox.size.width/2;
    CGPoint originalPos = _armR.position;
    originalPos = ccp(originalPos.x-6, originalPos.y-6);
    _armR.rotation = angle;
    
    NSMutableArray *moves = [[NSMutableArray alloc] init];
    
    angle = 30;
    for (int i = 0; i < 12; i++) {
        if (i < 6) {
            [moves addObject:[CCRotateBy actionWithDuration:0.0 angle:-10]];
            angle += 10;
        } else {
            [moves addObject:[CCRotateBy actionWithDuration:0.0 angle:10]];
            angle -= 10;
        }
        
        int deltaY = radius - radius*cos(CC_DEGREES_TO_RADIANS(angle));
        int deltaX = radius*sin(CC_DEGREES_TO_RADIANS(angle));
        
        CGPoint newPos = ccp(originalPos.x + deltaX, originalPos.y + deltaY);
        [moves addObject:[CCMoveTo actionWithDuration:0.1 position:newPos]];
    }
    
    
    CCSequence *seq = [CCSequence actionWithArray:moves];
    
    [_armR runAction:[CCRepeat actionWithAction:seq times:number/2]];
}

- (void) swingLeftArm: (int) number {
    int angle = _armL.rotation;
    _armL.rotation = 0;
    int radius = _armL.boundingBox.size.width/2;
    CGPoint originalPos = _armL.position;
    originalPos = ccp(originalPos.x+6, originalPos.y-6);
    _armL.rotation = angle;
    
    NSMutableArray *moves = [[NSMutableArray alloc] init];
    
    angle = -30;
    for (int i = 0; i < 12; i++) {
        if (i < 6) {
            [moves addObject:[CCRotateBy actionWithDuration:0.0 angle:10]];
            angle -= 10;
        } else {
            [moves addObject:[CCRotateBy actionWithDuration:0.0 angle:-10]];
            angle += 10;
        }
        
        int deltaY = radius - radius*cos(CC_DEGREES_TO_RADIANS(angle));
        int deltaX = radius*sin(CC_DEGREES_TO_RADIANS(angle));
        
        CGPoint newPos = ccp(originalPos.x + deltaX, originalPos.y + deltaY);
        [moves addObject:[CCMoveTo actionWithDuration:0.1 position:newPos]];
    }
    
    
    CCSequence *seq = [CCSequence actionWithArray:moves];
    
    [_armL runAction:[CCRepeat actionWithAction:seq times:number/2]];
}

- (void) sideWalk: (int) number faceRight: (BOOL) isRight {
    int radius = _body.boundingBox.size.width/2;

    if (isRight)
        [self faceRight];
    else
        [self faceLeft];
    
    CGPoint originalPosForward = isRight ? _legR.position : _legL.position;
    
    NSMutableArray *ForwardMove = [[NSMutableArray alloc] init];
    int angle = 0;
    for (int i = 0; i < 12; i++) {
        if (i < 3) {
            [ForwardMove addObject:[CCRotateBy actionWithDuration:0.0 angle:-10]];
            angle += 10;
        } else if (i < 9){
            [ForwardMove addObject:[CCRotateBy actionWithDuration:0.0 angle:10]];
            angle -= 10;
        } else{
            [ForwardMove addObject:[CCRotateBy actionWithDuration:0.0 angle:-10]];
            angle += 10;
        }
        int deltaY = radius - radius*cos(CC_DEGREES_TO_RADIANS(angle));
        int deltaX = radius*sin(CC_DEGREES_TO_RADIANS(angle));
        
        CGPoint newPos = ccp(originalPosForward.x + deltaX, originalPosForward.y + deltaY);
//        NSLog(@"%f, %f", newPos.x, newPos.y);
        [ForwardMove addObject:[CCMoveTo actionWithDuration:0.05 position:newPos]];
    }
    //NSLog(@"Total moves: %i", legRMove.count);
    
    CGPoint originalPosBack = isRight ? _legL.position : _legR.position;
    NSMutableArray *BackwardMove = [[NSMutableArray alloc] init];
    
    angle = 0;
    for (int i = 0; i < 12; i++) {
        if (i < 3) {
            [BackwardMove addObject:[CCRotateBy actionWithDuration:0.0 angle:10]];
            angle -= 10;
        } else if (i < 9){
            [BackwardMove addObject:[CCRotateBy actionWithDuration:0.0 angle:-10]];
            angle += 10;
        } else{
            [BackwardMove addObject:[CCRotateBy actionWithDuration:0.0 angle:10]];
            angle -= 10;
        }
        int deltaY = radius - radius*cos(CC_DEGREES_TO_RADIANS(angle));
        int deltaX = radius*sin(CC_DEGREES_TO_RADIANS(angle));
        
        CGPoint newPos = ccp(originalPosBack.x + deltaX, originalPosBack.y + deltaY);
        [BackwardMove addObject:[CCMoveTo actionWithDuration:0.05 position:newPos]];
    }
    
    CCSequence *forward = [CCSequence actionWithArray:ForwardMove];
    CCSequence *back = [CCSequence actionWithArray:BackwardMove];
    
    if (isRight) {
        [_legL runAction:[CCRepeat actionWithAction:back times:number]];
        [_legR runAction:[CCRepeat actionWithAction:forward times:number]];
    } else {
        [_legR runAction:[CCRepeat actionWithAction:back times:number]];
        [_legL runAction:[CCRepeat actionWithAction:forward times:number]];
    }
}

- (void) walkVertical: (int) number {
//    CCTexture2D *handTexture = [[CCTextureCache sharedTextureCache] addImage:@"pooky-hand.png"];
//    CCTexture2D *footTexture = [[CCTextureCache sharedTextureCache] addImage:@"pooky-foot.png"];
    
    [self raiseLeftArm:number];
    [self raiseRightArm:number];
    
    [_legL setTexture:handTexture];
    [_legR setTexture:handTexture];
    
    _legL.scaleX = 0.7;
    _legR.scaleX = 0.7;
    
    _legL.position = ccp(_legL.position.x + 5, _legL.position.y);
    _legR.position = ccp(_legR.position.x - 5, _legR.position.y);
    
    CGPoint origPoint = _legL.position;
    
    NSMutableArray *LeftMove = [[NSMutableArray alloc] init];
    
    [LeftMove addObject:[CCCallBlock actionWithBlock:^{
        [_group reorderChild:_legL z:2];
    }]];
    [LeftMove addObject:[CCScaleTo actionWithDuration:0.0 scaleX:0.7 scaleY:1.1]];
    [LeftMove addObject:[CCMoveTo actionWithDuration:0.1 position:ccp(origPoint.x, origPoint.y + 5)]];
    [LeftMove addObject:[CCScaleTo actionWithDuration:0.0 scaleX:0.7 scaleY:1.2]];
    [LeftMove addObject:[CCMoveTo actionWithDuration:0.1 position:ccp(origPoint.x, origPoint.y + 10)]];
    [LeftMove addObject:[CCScaleTo actionWithDuration:0.0 scaleX:0.7 scaleY:1.3]];
    [LeftMove addObject:[CCMoveTo actionWithDuration:0.1 position:ccp(origPoint.x, origPoint.y + 15)]];
    [LeftMove addObject:[CCScaleTo actionWithDuration:0.0 scaleX:0.7 scaleY:1.2]];
    [LeftMove addObject:[CCMoveTo actionWithDuration:0.1 position:ccp(origPoint.x, origPoint.y + 10)]];
    [LeftMove addObject:[CCScaleTo actionWithDuration:0.0 scaleX:0.7 scaleY:1.1]];
    [LeftMove addObject:[CCMoveTo actionWithDuration:0.1 position:ccp(origPoint.x, origPoint.y + 5)]];
    [LeftMove addObject:[CCCallBlock actionWithBlock:^{
        [_group reorderChild:_legL z:0];
    }]];
    [LeftMove addObject:[CCScaleTo actionWithDuration:0.0 scaleX:0.7 scaleY:1.1]];
    [LeftMove addObject:[CCMoveTo actionWithDuration:0.1 position:ccp(origPoint.x, origPoint.y + 5)]];
    [LeftMove addObject:[CCScaleTo actionWithDuration:0.0 scaleX:0.7 scaleY:1.2]];
    [LeftMove addObject:[CCMoveTo actionWithDuration:0.1 position:ccp(origPoint.x, origPoint.y + 10)]];
    [LeftMove addObject:[CCScaleTo actionWithDuration:0.0 scaleX:0.7 scaleY:1.3]];
    [LeftMove addObject:[CCMoveTo actionWithDuration:0.1 position:ccp(origPoint.x, origPoint.y + 15)]];
    [LeftMove addObject:[CCScaleTo actionWithDuration:0.0 scaleX:0.7 scaleY:1.2]];
    [LeftMove addObject:[CCMoveTo actionWithDuration:0.1 position:ccp(origPoint.x, origPoint.y + 10)]];
    [LeftMove addObject:[CCScaleTo actionWithDuration:0.0 scaleX:0.7 scaleY:1.1]];
    [LeftMove addObject:[CCMoveTo actionWithDuration:0.1 position:ccp(origPoint.x, origPoint.y + 5)]];
    
    
    origPoint = _legR.position;
    NSMutableArray *RightMove = [[NSMutableArray alloc] init];
    [RightMove addObject:[CCCallBlock actionWithBlock:^{
        [_group reorderChild:_legR z:0];
    }]];
    [RightMove addObject:[CCScaleTo actionWithDuration:0.0 scaleX:0.7 scaleY:1.1]];
    [RightMove addObject:[CCMoveTo actionWithDuration:0.1 position:ccp(origPoint.x, origPoint.y + 5)]];
    [RightMove addObject:[CCScaleTo actionWithDuration:0.0 scaleX:0.7 scaleY:1.2]];
    [RightMove addObject:[CCMoveTo actionWithDuration:0.1 position:ccp(origPoint.x, origPoint.y + 10)]];
    [RightMove addObject:[CCScaleTo actionWithDuration:0.0 scaleX:0.7 scaleY:1.3]];
    [RightMove addObject:[CCMoveTo actionWithDuration:0.1 position:ccp(origPoint.x, origPoint.y + 15)]];
    [RightMove addObject:[CCScaleTo actionWithDuration:0.0 scaleX:0.7 scaleY:1.2]];
    [RightMove addObject:[CCMoveTo actionWithDuration:0.1 position:ccp(origPoint.x, origPoint.y + 10)]];
    [RightMove addObject:[CCScaleTo actionWithDuration:0.0 scaleX:0.7 scaleY:1.1]];
    [RightMove addObject:[CCMoveTo actionWithDuration:0.1 position:ccp(origPoint.x, origPoint.y + 5)]];
    [RightMove addObject:[CCCallBlock actionWithBlock:^{
        [_group reorderChild:_legR z:2];
    }]];
    [RightMove addObject:[CCScaleTo actionWithDuration:0.0 scaleX:0.7 scaleY:1.1]];
    [RightMove addObject:[CCMoveTo actionWithDuration:0.1 position:ccp(origPoint.x, origPoint.y + 5)]];
    [RightMove addObject:[CCScaleTo actionWithDuration:0.0 scaleX:0.7 scaleY:1.2]];
    [RightMove addObject:[CCMoveTo actionWithDuration:0.1 position:ccp(origPoint.x, origPoint.y + 10)]];
    [RightMove addObject:[CCScaleTo actionWithDuration:0.0 scaleX:0.7 scaleY:1.3]];
    [RightMove addObject:[CCMoveTo actionWithDuration:0.1 position:ccp(origPoint.x, origPoint.y + 15)]];
    [RightMove addObject:[CCScaleTo actionWithDuration:0.0 scaleX:0.7 scaleY:1.2]];
    [RightMove addObject:[CCMoveTo actionWithDuration:0.1 position:ccp(origPoint.x, origPoint.y + 10)]];
    [RightMove addObject:[CCScaleTo actionWithDuration:0.0 scaleX:0.7 scaleY:1.1]];
    [RightMove addObject:[CCMoveTo actionWithDuration:0.1 position:ccp(origPoint.x, origPoint.y + 5)]];
    
    CCSequence *left = [CCSequence actionWithArray:LeftMove];
    CCSequence *right = [CCSequence actionWithArray:RightMove];
    
    [_legL runAction:[CCSequence actions:[CCRepeat actionWithAction:left times:number], [CCCallBlock actionWithBlock:^{
        [_legL setTexture:footTexture];
        _legL.scaleX = 1.0;
        
        [self faceIdle];
        
    }], nil]];
    [_legR runAction:[CCSequence actions:[CCRepeat actionWithAction:right times:number], [CCCallBlock actionWithBlock:^{
        [_legR setTexture:footTexture];
        _legR.scaleX = 1.0;
        _legR.flipX = YES;
        
        [self faceIdle];
    }], nil]];
}

- (void) walkRight: (int) number {
    [self sideWalk:number faceRight:YES];
    [self swingRightArm:number];
    [_group runAction:[CCSequence actions:[CCDelayTime actionWithDuration:(0.6 * number+0.1)],[CCCallBlock actionWithBlock:^{
        [self faceIdle];
    }], nil]];
}

- (void) walkLeft: (int) number {
    [self sideWalk:number faceRight:NO];
    [self swingLeftArm:number];
    [_group runAction:[CCSequence actions:[CCDelayTime actionWithDuration:(0.6 * number+0.1)],[CCCallBlock actionWithBlock:^{
        [self faceIdle];
    }], nil]];
}

- (void) walkDown: (int) number {
    [self faceDown];
    [self walkVertical:number];
}

- (void) walkUp: (int) number {
    [self faceUp];
    [self walkVertical:number];
}

- (void) getCaptured {
    BOOL action1 = (arc4random() %2 == 1);
    
    if (action1) {
        [_group runAction:[CCScaleTo actionWithDuration:0.8 scaleX:0.5 scaleY:0.05]];
    } else {
        _group.position = ccp(_group.position.x + 40, _group.position.y+40);
        [_group runAction:[CCRotateTo actionWithDuration:0.8 angle:3600]];
        [_group runAction:[CCScaleTo actionWithDuration:0.8 scale:0.05]];
    }
}

- (void) faceRight {
    _side.position = bodyCoord;
    _armR.position = ccp(sideArmCoord.x - 10, sideArmCoord.y);
    _legL.position = sideFootCoord;
    _legR.position = ccp(sideFootCoord.x + 6, sideFootCoord.y);
    
    _legR.flipX = YES;
    _legL.flipX = YES;
    _armL.visible = NO;
    _armR.visible = YES;
    
    _legR.rotation = 0;
    _legL.rotation = 0;
    _armR.rotation = 60;
    
    _legR.scale = 1;
    _legL.scale = 1;
    _armR.scale = 1;
    
    _body.visible = NO;
    _back.visible = NO;
    _loss.visible = NO;
    _side.visible = YES;
    _side.flipX = NO;
}

- (void) faceLeft {
    _side.position = bodyCoord;
    _armL.position = sideArmCoord;
    _legL.position = sideFootCoord;
    _legR.position = ccp(sideFootCoord.x + 6, sideFootCoord.y);
    
    _legR.flipX = NO;
    _legL.flipX = NO;
    _armL.visible = YES;
    _armR.visible = NO;
    
    _legR.rotation = 0;
    _legL.rotation = 0;
    _armL.rotation = -60;
    
    _legR.scale = 1;
    _legL.scale = 1;
    _armR.scale = 1;
    
    _body.visible = NO;
    _back.visible = NO;
    _loss.visible = NO;
    _side.visible = YES;
    _side.flipX = YES;
}

- (void) faceDown {
    _body.position = bodyCoord;
    _armL.position = armCoordL;
    _armR.position = armCoordR;
    _legL.position = legCoordL;
    _legR.position = legCoordR;
    
    _legR.flipX = YES;
    _legL.flipX = NO;
    _armL.visible = YES;
    _armR.visible = YES;
    
    _legR.rotation = 0;
    _legL.rotation = 0;
    _armL.rotation = 0;
    _armR.rotation = 0;
    
    _legR.scale = 1;
    _legL.scale = 1;
    _armL.scale = 1;
    _armR.scale = 1;
    
    _body.visible = YES;
    _back.visible = NO;
    _side.visible = NO;
    _loss.visible = NO;
}

- (void) faceUp {
    _back.position = bodyCoord;
    _armL.position = armCoordL;
    _armR.position = armCoordR;
    _legL.position = legCoordL;
    _legR.position = legCoordR;
    
    _legR.flipX = YES;
    _legL.flipX = NO;
    _armL.visible = YES;
    _armR.visible = YES;
    
    _legR.rotation = 0;
    _legL.rotation = 0;
    _armL.rotation = 0;
    _armR.rotation = 0;
    
    _legR.scale = 1;
    _legL.scale = 1;
    _armL.scale = 1;
    _armR.scale = 1;
    
    _body.visible = NO;
    _back.visible = YES;
    _side.visible = NO;
    _loss.visible = NO;
}

- (void) faceIdle {
    [self faceDown];
    
    _loss.position = bodyCoord;
    _armL.position = ccp(armCoordL.x+6, armCoordL.y - 13);
    _armR.position = ccp(armCoordR.x-6, armCoordR.y - 13);
    
    _armL.rotation = -60;
    _armR.rotation = 60;
    
    _body.visible = YES;
    _back.visible = NO;
    _side.visible = NO;
    _loss.visible = NO;
}

- (void) showLoss {
    [self faceDown];
    
    _loss.position = bodyCoord;
    _armL.position = ccp(armCoordL.x, armCoordL.y - 10);
    _armR.position = ccp(armCoordR.x, armCoordR.y - 10);
    
    _armL.rotation = -45;
    _armR.rotation = 45;
    
    _body.visible = NO;
    _loss.visible = YES;
}

- (void) reset:(CGPoint)point {
    [_group stopAllActions];
    [_armL stopAllActions];
    [_armR stopAllActions];
    [_legL stopAllActions];
    [_legR stopAllActions];
    
    [self faceIdle];
    _group.position = point;
}

@end
