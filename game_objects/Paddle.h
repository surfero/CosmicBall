//
//  Paddle.h
//  ArrayBallTest
//
//  Created by Garrett Crawford on 10/7/14.
//  Copyright (c) 2014 Noox. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Paddle : SKSpriteNode
@property int paddleLeftMovementSpeed;
@property int paddleRightMovementSpeed;

+(id)paddle;
-(void)movePaddleLeft:(int)speed;
-(void)movePaddleRight:(int)speed;

-(void)normalPaddle;

// power ups
-(void)grow;

@end
