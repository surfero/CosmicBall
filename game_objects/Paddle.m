//
//  Paddle.m
//  ArrayBallTest
//
//  Created by Garrett Crawford on 10/7/14.
//  Copyright (c) 2014 Noox. All rights reserved.
//
//  COSMIC BALL!!!!!!!

#import "Paddle.h"

@implementation Paddle
static const uint32_t paddleCategory = 0x1 << 1;

// factory method to return our paddle
+(id)paddle
{
    // create a black rectangle to represent our paddle
    // dimensions: 108x48
    Paddle *paddle = [Paddle spriteNodeWithImageNamed:@"paddle"];
    
    paddle.position = CGPointMake(0, 0);
    paddle.zPosition = 1;
    
    // set paddle name property
    paddle.name = @"paddle";
    
    // give our paddle a physics body
    paddle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:paddle.size];
    
    // sets the mass of the paddle to a high value so that the ball
    // does not push it down
    paddle.physicsBody.mass = 5000000;
    
    // allows our paddle to not be affected by rotational forces from barriers
    paddle.physicsBody.allowsRotation = NO;
    
    // 'disable' gravity on the paddle so that it does not fall straight down off the screen
    // read more about 'dynamic' in API
    paddle.physicsBody.dynamic = YES;
    paddle.physicsBody.affectedByGravity = NO;
    
    return paddle;
}

// this method will move our paddle to the left
-(void)movePaddleLeft:(int)speed
{
    self.paddleLeftMovementSpeed = speed;
    
    SKAction *moveLeft = [SKAction moveByX:self.paddleLeftMovementSpeed y:0 duration:0.1];
    
    [self runAction:moveLeft];
    
}

// this method moves the paddle to the right
-(void)movePaddleRight:(int)speed
{
    self.paddleRightMovementSpeed = speed;
    
    SKAction *moveRight = [SKAction moveByX:self.paddleRightMovementSpeed y:0 duration:0.1];
    
    [self runAction:moveRight];
}

-(void)normalPaddle
{
    self.size = CGSizeMake(108, 48);
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    self.physicsBody.mass = 5000000;
    self.physicsBody.allowsRotation = NO;
    self.physicsBody.dynamic = YES;
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.categoryBitMask = paddleCategory;
}

// power ups
-(void)grow
{
    self.size = CGSizeMake(200, 48);
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    
    // sets the mass of the paddle to a high value so that the ball
    // does not push it down
    self.physicsBody.mass = 5000000;
    
    // allows our paddle to not be affected by rotational forces from barriers
    self.physicsBody.allowsRotation = NO;
    
    // 'disable' gravity on the paddle so that it does not fall straight down off the screen
    // read more about 'dynamic' in API
    self.physicsBody.dynamic = YES;
    self.physicsBody.affectedByGravity = NO;
    
    self.physicsBody.categoryBitMask = paddleCategory;
}

@end
