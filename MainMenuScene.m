//
//  MainMenuScene.m
//  ArrayBallTest
//
//  Created by Garrett Crawford on 11/23/14.
//  Copyright (c) 2014 Noox. All rights reserved.
//

#import "MainMenuScene.h"
#import "GameScene.h"
#import <AVFoundation/AVFoundation.h>

@interface MainMenuScene ()
@property BOOL musicDisabled;
@end

@implementation MainMenuScene

{
    AVAudioPlayer *menuMusic;
    
    NSMutableArray *mainSKNodes, *mainLabelNodes, *tempLabelNodes, *tempSKNodes;
    
    SKSpriteNode *howToPlay1, *howToPlay2, *howToPlay3, *howToPlay4;
    
    SKLabelNode *arrayBallTitle, *playButton, *musicDisabledOption;
}

-(void)didMoveToView:(SKView *)view
{
    
    mainSKNodes = [[NSMutableArray alloc] init];
    mainLabelNodes = [[NSMutableArray alloc] init];
    tempLabelNodes = [[NSMutableArray alloc] init];
    
    NSLog(@"Screen width: %f", [UIScreen mainScreen].bounds.size.width);
    NSLog(@"Screen height: %f", [UIScreen mainScreen].bounds.size.height);
    
    // DO NOT USE MAINSPACE.PNG
    SKSpriteNode *menuBackground = [SKSpriteNode spriteNodeWithImageNamed:@"TitleSpace"];
    menuBackground.size = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    menuBackground.position = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    menuBackground.name = @"menuBackground";
    [self addChild:menuBackground];
    [mainSKNodes addObject:menuBackground];
    
    [self mainMenu];
    
    NSURL *urlMusic = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"MenuMusic" ofType:@"mp3"]];
    menuMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:urlMusic error:nil];
    [menuMusic play];
}

-(void)mainMenu
{
    arrayBallTitle = [SKLabelNode labelNodeWithText:@"Cosmic Ball"];
    arrayBallTitle.fontColor = [UIColor purpleColor];
    arrayBallTitle.fontName = @"Copperplate-Bold";
    arrayBallTitle.fontSize = 48;
    arrayBallTitle.position = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height*.8);
    [mainLabelNodes addObject:arrayBallTitle];
    [self addChild:arrayBallTitle];
    
    playButton = [SKLabelNode labelNodeWithText:@"Begin Mission"];
    playButton.name = @"playButton";
    playButton.fontSize = 35;
    playButton.fontName = @"Copperplate";
    playButton.position = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height * .2);
    playButton.fontColor = [UIColor greenColor];
    [self addChild:playButton];
    [mainLabelNodes addObject:playButton];
    
    SKLabelNode *optionsButton = [SKLabelNode labelNodeWithText:@"Options"];
    optionsButton.name = @"optionsButton";
    optionsButton.fontSize = 35;
    optionsButton.fontName = @"Copperplate";
    optionsButton.position = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height * .35);
    optionsButton.fontColor = [UIColor greenColor];
    [self addChild:optionsButton];
    [mainLabelNodes addObject:optionsButton];
    
    SKLabelNode *howToPlayButton = [SKLabelNode labelNodeWithText:@"How to play"];
    howToPlayButton.name = @"howToPlayButton";
    howToPlayButton.fontSize = 35;
    howToPlayButton.fontName = @"Copperplate";
    howToPlayButton.position = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height*.5);
    howToPlayButton.fontColor = [UIColor greenColor];
    [self addChild:howToPlayButton];
    [mainLabelNodes addObject:howToPlayButton];
    
    SKLabelNode *creditsButton = [SKLabelNode labelNodeWithText:@"Credits"];
    creditsButton.name = @"creditsButton";
    creditsButton.fontSize = 35;
    creditsButton.fontName = @"Copperplate";
    creditsButton.position = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height*.65);
    creditsButton.fontColor = [UIColor greenColor];
    [self addChild:creditsButton];
    [mainLabelNodes addObject:creditsButton];
}

- (void)doVolumeFade
{
    if (menuMusic.volume > 0.1) {
       menuMusic.volume -= 0.1;
       [self performSelector:@selector(doVolumeFade) withObject:nil afterDelay:0.08];
    }
}

-(void)playSelectionSound
{
    SKAction *buttonTappedSound = [SKAction playSoundFileNamed:@"selection.wav" waitForCompletion:NO];
    [self runAction:buttonTappedSound];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"playButton"])
    {
        NSLog(@"play button pressed");
        [self removeAllActions];
        [self removeTempNodes];
        [self removeMainNodes];
        
        [self playSelectionSound];
        [self animateFast:playButton];
        
        SKTransition *gameTransition = [SKTransition crossFadeWithDuration:3];
        GameScene *scene = [GameScene unarchiveFromFile:@"GameScene"];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        scene.userData = [NSMutableDictionary dictionary];
        if (self.musicDisabled)
        {
            [scene.userData setObject:@"yes" forKey:@"music"];
        }
        [self.view presentScene:scene transition:gameTransition];
         
        [self doVolumeFade];
    }
    
    else if ([node.name isEqualToString:@"no"])
    {
        [self playSelectionSound];
        if ([musicDisabledOption.text isEqualToString:@"no"])
        {
            musicDisabledOption.text = @"yes";
            self.musicDisabled = YES;
            [menuMusic stop];
        }
        else
        {
            musicDisabledOption.text = @"no";
            self.musicDisabled = NO;
            [menuMusic play];
        }
    }
    
    else if ([node.name isEqualToString:@"howToPlayButton"])
    {
        NSLog(@"How to play button pressed");
        [self removeMainNodes];
        
        howToPlay1 = [SKSpriteNode spriteNodeWithImageNamed:@"gameGuide1"];
        howToPlay1.name = @"howToPlay1";
        howToPlay1.size = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        howToPlay1.position = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
        [tempSKNodes addObject:howToPlay1];
        [self addChild:howToPlay1];
        [self playSelectionSound];
        
        arrayBallTitle.alpha = 0.0;
        playButton.alpha = 0.0;
        
    }
    
    else if ([node.name isEqualToString:@"optionsButton"])
    {
        NSLog(@"Options button pressed");
        [self playSelectionSound];
        [self removeMainNodes];
        
        SKLabelNode *optionsLabel = [SKLabelNode labelNodeWithText:@"Options"];
        optionsLabel.position = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height*.8);
        optionsLabel.fontColor = [UIColor greenColor];
        optionsLabel.fontSize = 35;
        optionsLabel.fontName = @"Copperplate";
        [self performSelector:@selector(addLabelNode:) withObject:optionsLabel];
        [tempLabelNodes addObject:optionsLabel];
        
        SKLabelNode *musicDisabled = [SKLabelNode labelNodeWithText:@"Disable Music:"];
        musicDisabled.fontColor = [UIColor greenColor];
        musicDisabled.fontSize = 18;
        musicDisabled.fontName = @"Copperplate";
        musicDisabled.position = CGPointMake([UIScreen mainScreen].bounds.size.width*.4, [UIScreen mainScreen].bounds.size.height *.5);
        [self performSelector:@selector(addLabelNode:) withObject:musicDisabled];
        [tempLabelNodes addObject:musicDisabled];
        
        musicDisabledOption = [SKLabelNode labelNodeWithText:@"no"];
        musicDisabledOption.name = @"no";
        musicDisabledOption.position = CGPointMake([UIScreen mainScreen].bounds.size.width*.7, [UIScreen mainScreen].bounds.size.height *.5);
        musicDisabledOption.fontColor = [UIColor greenColor];
        musicDisabledOption.fontSize = 18;
        musicDisabledOption.fontName = @"Copperplate";
        [self performSelector:@selector(addLabelNode:) withObject:musicDisabledOption];
        [tempLabelNodes addObject:musicDisabledOption];
        
        SKLabelNode *backToMainMenu = [SKLabelNode labelNodeWithText:@"Main Menu"];
        backToMainMenu.name = @"backToMainMenu";
        backToMainMenu.fontColor = [UIColor greenColor];
        backToMainMenu.fontSize = 18;
        backToMainMenu.fontName = @"Copperplate";
        backToMainMenu.position = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height*.1);
        [self performSelector:@selector(addLabelNode:) withObject:backToMainMenu];
        [tempLabelNodes addObject:backToMainMenu];
    }
    
    else if ([node.name isEqualToString:@"creditsButton"])
    {
        NSLog(@"Credits button pressed");
        [self playSelectionSound];
        [self removeMainNodes];
        
        SKLabelNode *credits = [SKLabelNode labelNodeWithText:@"Credits"];
        credits.fontColor = [UIColor greenColor];
        credits.fontSize = 35;
        credits.fontName = @"Copperplate";
        credits.position = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height*.8);
        [self performSelector:@selector(addLabelNode:) withObject:credits];
        [tempLabelNodes addObject:credits];
        
        SKLabelNode *programmer = [SKLabelNode labelNodeWithText:@"Programmed by: Garrett Crawford"];
        programmer.fontColor = [UIColor greenColor];
        programmer.fontSize = 18;
        programmer.fontName = @"Copperplate";
        programmer.position = CGPointMake([UIScreen mainScreen].bounds.size.width *.5, [UIScreen mainScreen].bounds.size.height*.6);
        [self performSelector:@selector(addLabelNode:) withObject:programmer];
        [tempLabelNodes addObject:programmer];
        
        SKLabelNode *music = [SKLabelNode labelNodeWithText:@"Music: Viraj Pande"];
        music.fontColor = [UIColor greenColor];
        music.fontSize = 18;
        music.fontName = @"Copperplate";
        music.position = CGPointMake([UIScreen mainScreen].bounds.size.width *.5, [UIScreen mainScreen].bounds.size.height*.45);
        [self performSelector:@selector(addLabelNode:) withObject:music];
        [tempLabelNodes addObject:music];
        
        SKLabelNode *art = [SKLabelNode labelNodeWithText:@"Game Art Work: Adam Dao"];
        art.fontColor = [UIColor greenColor];
        art.fontSize = 18;
        art.fontName = @"Copperplate";
        art.position = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height*.3);
        [self performSelector:@selector(addLabelNode:) withObject:art];
        [tempLabelNodes addObject:art];
        
        SKLabelNode *guild = [SKLabelNode labelNodeWithText:@"Major thanks to the Developers Guild"];
        guild.fontColor = [UIColor greenColor];
        guild.fontSize = 15;
        guild.fontName = @"Copperplate";
        guild.position = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height*.2);
        [self performSelector:@selector(addLabelNode:) withObject:guild];
        [tempLabelNodes addObject:guild];
        
        SKLabelNode *backToMainMenu = [SKLabelNode labelNodeWithText:@"Main Menu"];
        backToMainMenu.name = @"backToMainMenu";
        backToMainMenu.fontColor = [UIColor greenColor];
        backToMainMenu.fontSize = 18;
        backToMainMenu.fontName = @"Copperplate";
        backToMainMenu.position = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height*.1);
        [self performSelector:@selector(addLabelNode:) withObject:backToMainMenu];
        [tempLabelNodes addObject:backToMainMenu];
    }
    
    else if ([node.name isEqualToString:@"backToMainMenu"])
    {
        [self playSelectionSound];
        [self removeTempNodes];
        [self runAction:[SKAction performSelector:@selector(mainMenu) onTarget:self]];
        NSLog(@"back to main menu");
    }

    else if ([node.name isEqualToString:@"howToPlay1"])
    {
        NSLog(@"fun");
        
        [self playSelectionSound];
        [node removeFromParent];
        
        howToPlay2 = [SKSpriteNode spriteNodeWithImageNamed:@"fun"];
        howToPlay2.name = @"howToPlay2";
        howToPlay2.size = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        howToPlay2.position = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
        [tempSKNodes addObject:howToPlay2];
        [self addChild:howToPlay2];
    }

    else if ([node.name isEqualToString:@"howToPlay2"])
    {
        NSLog(@"fun2");
        [self playSelectionSound];
        [node removeFromParent];
        
        howToPlay3 = [SKSpriteNode spriteNodeWithImageNamed:@"gameGuide3"];
        howToPlay3.name = @"howToPlay3";
        howToPlay3.size = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        howToPlay3.position = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
        [tempSKNodes addObject:howToPlay3];
        [self addChild:howToPlay3];
    }
    
    else if ([node.name isEqualToString:@"howToPlay3"])
    {
        NSLog(@"fun3");
        [self playSelectionSound];
        [node removeFromParent];
        
        howToPlay4 = [SKSpriteNode spriteNodeWithImageNamed:@"gameGuide4"];
        howToPlay4.name = @"howToPlay4";
        howToPlay4.size = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        howToPlay4.position = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
        [tempSKNodes addObject:howToPlay4];
        [self addChild:howToPlay4];
    }
    
    else if ([node.name isEqualToString:@"howToPlay4"])
    {
        NSLog(@"fun4");
        [self playSelectionSound];
        [node removeFromParent];
        
        SKSpriteNode *howToPlay5 = [SKSpriteNode spriteNodeWithImageNamed:@"gameGuide5"];
        howToPlay5.name = @"howToPlay5";
        howToPlay5.size = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);;
        howToPlay5.position = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
        [tempSKNodes addObject:howToPlay5];
        [self addChild:howToPlay5];
    }
    
    else if ([node.name isEqualToString:@"howToPlay5"])
    {
        [self playSelectionSound];
        [node removeFromParent];
        
        [self removeTempNodes];
        arrayBallTitle.alpha = 1.0;
        [self runAction:[SKAction performSelector:@selector(mainMenu) onTarget:self]];
    }
}

-(void)restartMenu
{
    SKScene *newMenu = [MainMenuScene sceneWithSize:self.view.bounds.size];
    newMenu.scaleMode = SKSceneScaleModeAspectFill;
    [self.view presentScene:newMenu];
}

-(void)addLabelNode:(SKLabelNode *)ln
{
    [self addChild:ln];
}

-(void)animateFast:(SKLabelNode *)node
{
    // this is the animation to make our tapToBegin/tapToReset disappear
    SKAction *disappear = [SKAction fadeAlphaTo:0.0 duration:0.5];
    // this is the action to make our tapToBegin/tapToReset labels appear
    SKAction *appear = [SKAction fadeAlphaTo:1.0 duration:0.5];
    
    // this is our pulse action that will run the two animations
    SKAction *pulse = [SKAction sequence:@[disappear, appear]];
    [node runAction:[SKAction repeatActionForever:pulse]];
}

-(void)removeBackground
{
    for (SKSpriteNode *sk in mainSKNodes)
    {
        sk.alpha = 0.0;
    }
    
    for (SKLabelNode *ln in mainLabelNodes)
    {
        ln.alpha = 0;
    }
}

-(void)addMainMenu
{
    for (SKSpriteNode *sk in mainSKNodes)
    {
        [self addChild:sk];
    }
}

-(void)removeMainNodes
{
    for (SKSpriteNode *sk in mainSKNodes)
    {
        if ([sk.name isEqualToString:@"menuBackground"])
        {
            continue;
        }
        else
        {
            [sk removeFromParent];
        }
    }
    
    for (SKLabelNode *ln in mainLabelNodes)
    {
        [ln removeFromParent];
    }
}

-(void)removeTempNodes
{
    for (SKSpriteNode *sk in tempSKNodes)
    {
        [sk removeFromParent];
    }
    
    for (SKLabelNode *ln in tempLabelNodes)
    {
        [ln removeFromParent];
    }
}

-(void)dealloc
{
    NSLog(@"deallocated properly");
}


@end
