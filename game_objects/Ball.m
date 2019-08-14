//
//  Ball.m
//  ArrayBallTest
//
//  Created by Garrett Crawford on 10/10/14.
//  Copyright (c) 2014 Noox. All rights reserved.
//

#import "Ball.h"
#import "Barriers.h"

@interface Ball ()

@property SKNode *world;

@end

@implementation Ball

// return our ball
+(id)ball
{
    // the ball is a random image from google
    Ball *ball = [Ball spriteNodeWithImageNamed:@"rock2"];
    
    // set the position of the ball
    ball.position = CGPointMake(0, 110);
    
    // set ball name property
    ball.name = @"ball";
    
    // give the ball a physics body
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball.frame.size.width/2];

    // this literally makes the ball unaffected by gravity
    ball.physicsBody.affectedByGravity = YES;

    // this checks to see how bouncy the ball is (0 being not bouncy, 1 being very bouncy)
    ball.physicsBody.restitution = 0.55;
    
    return ball;
}

// this will animate the movement of the ball
-(void)move:(int)deltaX withDeltaY:(int)deltaY
{
    SKAction *testMoveRight = [SKAction moveByX:deltaX y:deltaY duration:0.03];
    
    // this will repeat the action over and over
    SKAction *move = [SKAction repeatActionForever:testMoveRight];
    [self runAction:move];
    
}

-(void)stopMoving
{
    [self removeAllActions];
}

@end
