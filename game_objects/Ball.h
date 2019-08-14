//
//  Ball.h
//  ArrayBallTest
//
//  Created by Garrett Crawford on 10/10/14.
//  Copyright (c) 2014 Noox. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Ball : SKSpriteNode
@property BOOL didHitRightBarrier;

+(id)ball;
-(void)move:(int)deltaX withDeltaY:(int)deltaY;
-(void)stopMoving;
@end
