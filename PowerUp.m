//
//  PowerUp.m
//  ArrayBallTest
//
//  Created by Garrett Crawford on 10/31/14.
//  Copyright (c) 2014 Noox. All rights reserved.
//

#import "PowerUp.h"

@implementation PowerUp

+(id)powerUp
{
    PowerUp *powerUp = [PowerUp spriteNodeWithImageNamed:@"batteryPower"];
    
    powerUp.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:powerUp.size];
    
    return powerUp;
}

+(id)oneUp
{
    PowerUp *oneUp = [PowerUp spriteNodeWithImageNamed:@"1UP"];
    
    oneUp.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:oneUp.size];
    
    return oneUp;
}

@end
