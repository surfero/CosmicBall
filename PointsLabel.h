//
//  PointsLabel.h
//  ArrayBallTest
//
//  Created by Garrett Crawford on 10/31/14.
//  Copyright (c) 2014 Noox. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface PointsLabel : SKLabelNode
@property int number;

+(id)pointsLabelWithFontNamed:(NSString *)fontName;
-(void)increment;
-(void)setPoints:(int)points;
@end
