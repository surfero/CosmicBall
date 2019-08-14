//
//  GameScene.m
//  ArrayBallTest
//
//  Created by Garrett Crawford on 10/7/14.
//  Copyright (c) 2014 Noox. All rights reserved.
//
//
//  Make 'Tap to begin label' white with a black border

#import "GameScene.h"
#import "MainMenuScene.h"
#import "Paddle.h"
#import "Ball.h"
#import "Barriers.h"
#import "PointsLabel.h"
#import "PowerUp.h"


// this gets us access to the AVAudioPlayer class
// which we use to play the game music
#import <AVFoundation/AVFoundation.h>

// set up property to hold the speed of the ball here

@interface GameScene ()

@property int shadowStyleTimer;

// this checks to see if the user is not on the title screen
@property BOOL passedTitleScreen;

// this checks to see if the game has started
@property BOOL isStarted;
// checks to see if the game is over
@property BOOL isGameOver;

@property SKAction *gameMusic;

// checks to see how many balls are present
@property int ballCounter;

// this checks if the user is touching
@property BOOL isTouching;
// this checks if the paddle is moving left
@property BOOL movingLeft;
// this checks if the paddle is moving right
@property BOOL movingRight;

// power up stuff

// checks to see if the user has a power up
@property BOOL powerUp;

// checks to see if the power up is on screen
@property BOOL powerUpIsVisible;

// checks to see if the user has received a power up
@property BOOL powerUpReceived;

@property BOOL paddleExploded;

// timer used to keep track of how long the user has had a power up
@property NSTimer *powerUpTimer;

// this keeps track of the number of seconds that the user is alive
@property NSTimer *gameTimer;

@property NSTimer *missileTimer;

// keeps track of the number of seconds the game has been running
@property int gameSeconds;

// keeps track of the number of seconds between each missile
@property float missileSeconds;

// this holds onto the random power up that is generated
@property int randomPowerUp;

// this property checks to see if the nuke power up is available
@property BOOL nukeTime;

// checks to see if the nuke label has been added on screen
@property BOOL nukeLabelAdded;

@property BOOL nukeMusic;

// number of seconds for the timer of each power up
@property int seconds;

// this is a score variable
@property int paddleHitCount;

// number of lives for the player
@property int lives;

@end

@implementation GameScene

{
    // set our paddle to be global
    Paddle *paddle;
    
    SKSpriteNode *spaceBackground;
    
    // vortex object
    SKSpriteNode *vortex;
    
    // force field object
    SKSpriteNode *forceField;
    
    // nuke sprites
    SKSpriteNode *explosion;
    SKSpriteNode *nuke; //*nukeBomb;
    
    // power up label nodes
    SKLabelNode *missileLabel, *bigPaddleLabel, *vortexLabel, *extraLifeLabel, *forceFieldLabel, *freezeLabel;
    
    // set up a node tree to hold our all of our nodes
    SKNode *scene;
    
    // first ball needs to be global
    Ball *ball;
    
    // this array holds our ball
    // helps to keep track of the number of balls on screen
    // and can be used for power ups that affect all balls
    NSMutableArray *ballArray;
    
    // this array holds all of the game sounds
    NSMutableArray *soundsArray;
    
    // this array holds temporary nodes
    NSMutableArray *temporaryNodes;
    
    // game barriers
    Barriers *rightBarrier, *topBarrier, *leftBarrier, *gameOverBarrier;
    
    //SKSpriteNode *powerUpBarrier;
    
    // this will play the game music
    AVAudioPlayer *gameMusic, *gameOverMusic, *paddleSound, *nukeSound, *lifeUp, *forceFieldSound;
    
    // score labels
    PointsLabel *scoreLabel, *highScoreLabel;
    
    // lives label
    SKLabelNode *lifeLabel;
    
    SKLabelNode *powerUpTimerNode;
    
    SKSpriteNode *leftButton, *rightButton;
    
    // the countdown timer that appears when the user receives the nuke power up
    SKLabelNode *nukeCountDownLabel;
    
    // power up object that the user can collect
    PowerUp *powerUp;
    
    SKSpriteNode *oneUp;
}

// set up all of the categories here
static const uint32_t ballCategory = 0x1 << 0;
static const uint32_t paddleCategory = 0x1 << 1;
static const uint32_t barrierCategory = 0x1 << 2;
static const uint32_t gameOverBarrierCategory = 0x1 << 3;
static const uint32_t powerUpCategory = 0x1 << 4;
static const uint32_t powerUpNetCategory = 0x1 << 5;
static const uint32_t forceFieldCategory = 0x1 << 7;
static const uint32_t powerUpBarrierCategory = 0x1 << 8;
static const uint32_t missileCategory = 0x1 << 9;

@synthesize paddleHitCount;

//static const uint32_t barrierCategory = 0x1 << 1;

+(instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    GameScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}

#pragma mark Game Setup

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    
    [self removeAllChildren];
    [self removeAllActions];
    [scene removeAllActions];
    [scene removeAllChildren];
    
    [self loadObjectsToScreen];
    [self loadGameSounds];
    
    self.view.ignoresSiblingOrder = NO;
    
    /*
    SKSpriteNode *hud = [SKSpriteNode spriteNodeWithImageNamed:@"hud"];
    hud.size = CGSizeMake(420, 820);
    hud.position = CGPointMake(0, 320);
    hud.zPosition = 1;
    [self addChild:hud];
     */
    
    // set anchor point to be in the middle toward the bottom of the screen
    self.anchorPoint = CGPointMake(0.5, 0.1);
    
    // contactDelegate is a protocol
    self.physicsWorld.contactDelegate = self;
    self.physicsWorld.gravity = CGVectorMake(0, -1);
    
    [self loadScoreLabels];
    
    [self setUpCategories];
    
    // paddle hit count starts at 0
    paddleHitCount = 0;
    
    // game seconds starts at 0
    self.gameSeconds = 0;
    
    self.shadowStyleTimer = 0;
}

-(void)loadObjectsToScreen
{
    // create game background
    spaceBackground = [SKSpriteNode spriteNodeWithImageNamed:@"spaceBackground"];
    spaceBackground.size = CGSizeMake(515, 790);
    spaceBackground.zPosition = 0;
    spaceBackground.position = CGPointMake(0, 300);
    [self addChild:spaceBackground];
    NSLog(@"spaceBackground added");
    
    temporaryNodes = [[NSMutableArray alloc] init];
    
    scene = [SKNode node];
    [self addChild:scene];
    
    [self leftButton];
    [self rightButton];
    
    // create our paddle and add it to the scene (node tree)
    paddle = [Paddle paddle];
    [scene addChild:paddle];
    
    // create ball array to hold all balls
    ballArray = [[NSMutableArray alloc] init];
    
    // create our ball and add it to the scene
    ball = [Ball ball];
    ball.physicsBody.affectedByGravity = NO;
    [scene addChild:ball];
    [ballArray addObject:ball];
    self.ballCounter = 1;
    
    // create our barriers
    topBarrier = [Barriers topBarrier];
    leftBarrier = [Barriers leftBarrier];
    rightBarrier = [Barriers rightBarrier];
    gameOverBarrier = [Barriers gameOverBarrier];
    
    // add the power up barrier
    SKSpriteNode *powerUpBarrier = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(1000, 20)];
    powerUpBarrier.position = CGPointMake(0, 0);
    powerUpBarrier.alpha = 0;
    powerUpBarrier.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:powerUpBarrier.size];
    powerUpBarrier.physicsBody.affectedByGravity = NO;
    powerUpBarrier.physicsBody.dynamic = NO;
    powerUpBarrier.physicsBody.categoryBitMask = powerUpBarrierCategory;
    powerUpBarrier.physicsBody.contactTestBitMask = powerUpCategory;
    [scene addChild:powerUpBarrier];
    
    // add the tapToBegin label
    SKLabelNode *tapToBeginLabel = [SKLabelNode labelNodeWithFontNamed:@"AmericanTypewriter-Bold"];
    tapToBeginLabel.zPosition = 1;
    tapToBeginLabel.name = @"tapToBeginLabel";
    tapToBeginLabel.text = @"Tap to begin!";
    tapToBeginLabel.color = [UIColor blackColor];
    tapToBeginLabel.colorBlendFactor = 1.0;
    tapToBeginLabel.fontSize = 50.0;
    tapToBeginLabel.position = CGPointMake(0, 300);
    [scene addChild:tapToBeginLabel];
    [self animateWithPulse:tapToBeginLabel];
    
    // add them to the scene
    [scene addChild:topBarrier];
    [scene addChild:leftBarrier];
    [scene addChild:rightBarrier];
    [scene addChild:gameOverBarrier];
    
    // add the buttons to the scene
    [scene addChild:leftButton];
    [scene addChild:rightButton];
    //[scene addChild:[self resetButton]];
    
    /*
    NSLog(@"nuke label added");
    nukeCountDownLabel = [SKLabelNode labelNodeWithFontNamed:@"CoolveticaRg-Regular"];
    nukeCountDownLabel.position = CGPointMake(150, 545);
    nukeCountDownLabel.text = @"10";
    nukeCountDownLabel.zPosition = 1;
    nukeCountDownLabel.fontSize = 40;
     */
    
    NSLog(@"nuke logo added");
    nuke = [SKSpriteNode spriteNodeWithImageNamed:@"nuclear_icon"];
    nuke.position = CGPointMake(150, 560);
    nuke.size = CGSizeMake(55, 55);
    nuke.zPosition = 1;
    nuke.alpha = 1.0;
}


// this creates the button that moves our paddle left
-(void)leftButton
{
    leftButton = [SKSpriteNode spriteNodeWithImageNamed:@"arrowLeft"];
    leftButton.name = @"leftButton";
    leftButton.size = CGSizeMake(100, 105);
    leftButton.position = CGPointMake(-160, -25);
    leftButton.zPosition = 1;
    // Making it invisible
    //leftButton.alpha = 0.0;
}

// this creates the button to move the paddle right
-(void)rightButton
{
    rightButton = [SKSpriteNode spriteNodeWithImageNamed:@"arrowRight"];
    rightButton.name = @"rightButton";
    rightButton.size = CGSizeMake(100, 105);
    rightButton.position = CGPointMake(160, -25);
    rightButton.zPosition = 1;
    // Making it invisible
    //rightButton.alpha = 0.0
}

// creates the resetButton
// for testing purposes only
-(SKSpriteNode *)resetButton
{
    SKSpriteNode *resetButton = [SKSpriteNode spriteNodeWithImageNamed:@"Reset"];
    resetButton.size = CGSizeMake(40, 40);
    resetButton.name = @"resetButton";
    resetButton.position = CGPointMake(0, 620);
    resetButton.zPosition = 1;
    resetButton.alpha = 1.0;
    
    return resetButton;
}

-(void)addScoreLabel
{
    [scene addChild:scoreLabel];
}

// loads the game's score labels
-(void)loadScoreLabels
{
    // properites of a score label
    scoreLabel = [PointsLabel pointsLabelWithFontNamed:@"Copperplate-Bold"];
    scoreLabel.fontSize = 30;
    scoreLabel.name = @"scoreLabel";
    scoreLabel.position = CGPointMake(200, 600);
    scoreLabel.zPosition = 3;
    scoreLabel.fontColor = [SKColor greenColor];
    scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    [scene addChild:scoreLabel];
    NSLog(@"score label added");
    
    NSUserDefaults *defaults3 = [NSUserDefaults standardUserDefaults];
    
    NSInteger *highScorePoints  = [defaults3 integerForKey:@"highScoreLabel"];
    
    highScoreLabel = [PointsLabel pointsLabelWithFontNamed:@"Copperplate-Bold"];
    highScoreLabel.fontSize = 30;
    highScoreLabel.name = @"highScoreLabel";
    highScoreLabel.position = CGPointMake(120, 225);
    highScoreLabel.zPosition = 1;
    [highScoreLabel setPoints:highScorePoints];
    highScoreLabel.fontColor = [SKColor greenColor];
    highScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    [self addChild:highScoreLabel];
    highScoreLabel.alpha = 0;
    
    // set up number of lives
    self.lives = 3;
    
    lifeLabel = [SKLabelNode labelNodeWithFontNamed:@"Copperplate-Bold"];
    lifeLabel.fontSize = 30;
    lifeLabel.name = @"lifeLabel";
    lifeLabel.position = CGPointMake(-150, 600);
    lifeLabel.zPosition = 1;
    lifeLabel.text = [NSString stringWithFormat:@"Lives: %i", self.lives];
    [scene addChild:lifeLabel];
}

#pragma mark Game Sounds

-(void)loadGameSounds
{
    // initialize game music player
    NSURL *urlMusic = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"spacegamemusic" ofType:@"mp3"]];
    gameMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:urlMusic error:nil];
    
    // initialize game over music
    NSURL *urlOver = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"GameOverMusic" ofType:@"mp3"]];
    gameOverMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:urlOver error:nil];
    
    // initialize paddle sound
    NSURL *urlPaddle = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"paddleSound" ofType:@"wav"]];
    paddleSound = [[AVAudioPlayer alloc] initWithContentsOfURL:urlPaddle error:nil];
    
    NSURL *urlNuke = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"nuke" ofType:@"mp3"]];
    nukeSound = [[AVAudioPlayer alloc] initWithContentsOfURL:urlNuke error:nil];
    
    NSURL *url1Up = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"1UP" ofType:@"mp3"]];
    lifeUp = [[AVAudioPlayer alloc] initWithContentsOfURL:url1Up error:nil];
    
    NSURL *urlForceField = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"forceField" ofType:@"wav"]];
    forceFieldSound = [[AVAudioPlayer alloc] initWithContentsOfURL:urlForceField error:nil];
    
    soundsArray = [[NSMutableArray alloc] initWithObjects:gameMusic, gameOverMusic, paddleSound, nukeSound, lifeUp, forceFieldSound, nil];
}

#pragma mark Object Categories

-(void)setUpCategories
{
    // setting up ball categories
    ball.physicsBody.categoryBitMask = ballCategory;
    ball.physicsBody.contactTestBitMask = paddleCategory;
    ball.physicsBody.collisionBitMask = barrierCategory;
    
    paddle.physicsBody.categoryBitMask = paddleCategory;
    
    rightBarrier.physicsBody.categoryBitMask = barrierCategory;
    rightBarrier.physicsBody.contactTestBitMask = ballCategory;
    rightBarrier.physicsBody.collisionBitMask = ballCategory;
    
    topBarrier.physicsBody.categoryBitMask = barrierCategory;
    
    leftBarrier.physicsBody.categoryBitMask = barrierCategory;
    
    gameOverBarrier.physicsBody.categoryBitMask = gameOverBarrierCategory;
    gameOverBarrier.physicsBody.contactTestBitMask = ballCategory | powerUpCategory;
}

#pragma mark Start/Restart/Gameover

-(void)start
{
    self.isStarted = YES;
    ball.physicsBody.affectedByGravity = YES;
    
    // this removes the tap to start label when the game starts
    [[scene childNodeWithName:@"tapToBeginLabel"] removeFromParent];
    
    
    gameMusic.numberOfLoops = -1;
    
    // play game music
    if ([[self.userData valueForKey:@"music"] isEqualToString:@"yes"])
    {
        NSLog(@"no music!");
    }
    else
    {
        [gameMusic play];
    }

    // start game timer
    [self gameTimerDelegate];
}

// called when a ball reaches the bottom of the screen
-(void)gameOver
{
    self.isGameOver = YES;
    
    [gameMusic stop];
    [nukeSound stop];
    
    [gameOverMusic play];
    
    // game over label creation
    SKLabelNode *gameOverLabel = [SKLabelNode labelNodeWithFontNamed:@"AmericanTypewriter-Bold"];
    gameOverLabel.name = @"gameOverLabel";
    gameOverLabel.text = @"Game Over!";
    gameOverLabel.color = [UIColor purpleColor];
    gameOverLabel.colorBlendFactor = 1.0;
    gameOverLabel.fontSize = 50.0;
    gameOverLabel.position = CGPointMake(0, 300);
    gameOverLabel.zPosition = 1;
    [scene addChild:gameOverLabel];
    
    highScoreLabel.alpha = 1;
    
    // tap to reset label creation
    SKLabelNode *tapToResetLabel = [SKLabelNode labelNodeWithFontNamed:@"AmericanTypewriter-Bold"];
    tapToResetLabel.name = @"tapToResetLabel";
    tapToResetLabel.text = @"Tap here to restart!";
    tapToResetLabel.color = [UIColor greenColor];
    tapToResetLabel.colorBlendFactor = 1.0;
    tapToResetLabel.fontSize = 40.0;
    tapToResetLabel.position = CGPointMake(0, 150);
    tapToResetLabel.zPosition = 1;
    [scene addChild:tapToResetLabel];
    [self animateWithPulse:tapToResetLabel];
    
    SKLabelNode *mainMenuLabel = [SKLabelNode labelNodeWithFontNamed:@"AmericanTypewriter-Bold"];
    mainMenuLabel.name = @"mainMenuLabel";
    mainMenuLabel.text = @"Main menu";
    mainMenuLabel.color = [UIColor greenColor];
    mainMenuLabel.colorBlendFactor = 1.0;
    mainMenuLabel.fontSize = 40.0;
    mainMenuLabel.zPosition = 1;
    mainMenuLabel.position = CGPointMake(0, 80);
    [scene addChild:mainMenuLabel];
    [self animateWithPulse:mainMenuLabel];
    
    [self updateHighScore];
}

- (void)doGameOverVolumeFade
{
    if (gameOverMusic.volume > 0.1) {
        gameOverMusic.volume -= 0.1;
        [self performSelector:@selector(doGameOverVolumeFade) withObject:nil afterDelay:0.08];
    }
}

// this is called when everything is to be restarted
// this will only be called when game is over
-(void)restartGame
{
    for (SKNode* node in scene.children) {
        [node removeFromParent];
        [node removeAllActions];
    }
    
    [gameOverMusic stop];
    [self.gameTimer invalidate];
    
    [self cleanUpChildrenAndRemove:self];
    // create a new gamescene
    GameScene *newScene = [[GameScene alloc] initWithSize:self.frame.size];
    
    // this fixes the strange problem of the game shrinking in size
    newScene.scaleMode = SKSceneScaleModeAspectFill;
    
    // present the new game
    [self.view presentScene:newScene];
    
    if (self.nukeLabelAdded)
    {
        [self.powerUpTimer invalidate];
        [nuke removeFromParent];
        [nukeCountDownLabel removeFromParent];
        [explosion removeFromParent];
    }
    
    [nukeSound stop];
}

#pragma mark Touch Events

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in [event allTouches]) {
        CGPoint location = [touch locationInNode:scene];
        
        SKNode *node = [self nodeAtPoint:location];
    
        // this starts the movement of the ball
        if (!self.isStarted) {
            [self start];
        }
    
        else if (self.isGameOver) {
            if ([node.name isEqualToString:@"tapToResetLabel"])
            {
                [self restartGame];
            }
        
            else if ([node.name isEqualToString:@"mainMenuLabel"])
            {
                NSLog(@"mainMenuLabel touched");
                [self removeAllActions];
                [self doGameOverVolumeFade];
            
                [self cleanUpChildrenAndRemove:self];
                SKTransition *gameTransition = [SKTransition crossFadeWithDuration:3];
                MainMenuScene *menuScene = [MainMenuScene sceneWithSize:self.view.bounds.size];
                menuScene.scaleMode = SKSceneScaleModeAspectFill;
                [self.view presentScene:menuScene transition:gameTransition];
            }
        }
    
        // this block is executed if the game has already started
        else {
            self.isTouching = YES;
        
        // if the user touches the left button, move the paddle left
            if ([node.name isEqualToString:@"leftButton"]) {
                [paddle removeAllActions];
                self.movingLeft = YES;
                
                // changes the image of the paddle to animate the movement of the paddle
                [paddle setTexture:[SKTexture textureWithImageNamed:@"paddleMoveLeft"]];
                
                [leftButton setTexture:[SKTexture textureWithImageNamed:@"buttonleft_pressed"]];
                
                SKAction *movePaddleLeft = [SKAction moveBy:CGVectorMake(-50, 0) duration:0.1];
                SKAction *repeatMoveLeft = [SKAction repeatActionForever:movePaddleLeft];
                [paddle runAction:repeatMoveLeft];
            
            }
        
            // if the user touches the right button, move the paddle right
            else if ([node.name isEqualToString:@"rightButton"]) {
                [paddle removeAllActions];
                self.movingRight = YES;
                
                [paddle setTexture:[SKTexture textureWithImageNamed:@"paddleMoveRight"]];
                [rightButton setTexture:[SKTexture textureWithImageNamed:@"buttonright_pressed"]];
                
                SKAction *movePaddleRight = [SKAction moveBy:CGVectorMake(50, 0) duration:0.1];
                SKAction *repeatMoveRight = [SKAction repeatActionForever:movePaddleRight];
                [paddle runAction:repeatMoveRight];
            }
        
            if ([node.name isEqualToString:@"resetButton"]) {
            
                if (self.nukeLabelAdded)
                {
                    [self.powerUpTimer invalidate];
                    [nuke removeFromParent];
                    [nukeCountDownLabel removeFromParent];
                    [explosion removeFromParent];
                }
            
                [nukeSound stop];
            
                [gameMusic stop];
                [self.gameTimer invalidate];
                [self.powerUpTimer invalidate];
                [self cleanUpChildrenAndRemove:self];
                GameScene *newScene = [[GameScene alloc] initWithSize:self.frame.size];
            
                newScene.scaleMode = SKSceneScaleModeAspectFill;
            
                [self.view presentScene:newScene];
            }
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    self.isTouching = NO;
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:scene];
    SKNode *node = [self nodeAtPoint:location];
    
    // if the user lets go of the left button, stop paddle movement
    if ([node.name isEqualToString:@"leftButton"]) {
        self.movingLeft = NO;
        [paddle removeAllActions];
        
        [paddle setTexture:[SKTexture textureWithImageNamed:@"paddle"]];
        [leftButton setTexture:[SKTexture textureWithImageNamed:@"arrowLeft"]];
    }
    
    // if the user lets go of the right button, stop paddle movement
    else if ([node.name isEqualToString:@"rightButton"]) {
        self.movingRight = NO;
        [paddle removeAllActions];
        
        [paddle setTexture:[SKTexture textureWithImageNamed:@"paddle"]];
        [rightButton setTexture:[SKTexture textureWithImageNamed:@"arrowRight"]];
    }
}

#pragma mark Adding Balls

// this method adds a new ball to the game when needed
-(void)addBall
{
    if (!self.isGameOver)
    {
        Ball *newBall = [Ball ball];
        newBall.position = CGPointMake(paddle.position.x, paddle.position.y + 3);
    
        newBall.physicsBody.categoryBitMask = ballCategory;
        newBall.physicsBody.contactTestBitMask = paddleCategory;
        newBall.physicsBody.collisionBitMask = barrierCategory;
    
        [scene addChild:newBall];
        [ballArray addObject:newBall];
        self.ballCounter++;
    }
}

#pragma mark Game Timer

// this calls the timer that keeps track of the number of the seconds the user is surviving
// aka the user's "score"
-(void)gameTimerDelegate
{
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(incrementGameTimer) userInfo:nil repeats:YES];
}

// this increments the user's game score every second
-(void)incrementGameTimer
{
    // if the game is over
    // stop the timer
    if (self.isGameOver) {
        [self.gameTimer invalidate];
    }
    
    // if the game is not over
    // keep incrementing score every second
    else {
        self.gameSeconds++;
        //NSLog(@"%i", self.gameSeconds);
        [scoreLabel increment];
        
        if (explosion.alpha == 1.0) {
            explosion.alpha = 0.0;
            [explosion removeFromParent];
        }
    }
}


#pragma mark Powerup Generation and Timers

// this method generates a random number between 1 and 10
// this is used to determine whether or not a power up will appear on screen
-(int)getRandomNumber
{
    int randomNumber;
    randomNumber = arc4random() % 5 + 1;
    
    return randomNumber;
}

// this method adds a power up to the game
-(void)addPowerUp
{
    int xPosition = 0;
    
    switch (arc4random() % 2 + 1)
    {
        case 1:
            xPosition = arc4random() % 160 + 1;
            break;
        case 2:
            xPosition = -arc4random() % 150 + 1;
            break;
    }

    powerUp = [PowerUp powerUp];
    powerUp.position = CGPointMake(xPosition, 500);
    powerUp.zPosition = 1;
    
    powerUp.physicsBody.categoryBitMask = powerUpCategory;
    powerUp.physicsBody.contactTestBitMask = paddleCategory;
    powerUp.physicsBody.collisionBitMask = barrierCategory;
    
    [scene addChild:powerUp];
    [self animatePowerUp:powerUp];
}

// if the user collects a power up during gameplay
// this method will be called to generate a random number based on the number of power ups
// the user will be rewarded with a random power up
-(int)powerUpNumber
{
    int randomPowerUp;
    
    // if the user has more than 4 balls on screen
    // the user has a chance to obtain the nuke power up
    if (self.nukeTime) {
        randomPowerUp = arc4random() % 7 + 1;
    }
    
    else {
        // allow the user to receive the laser power up if there are 3 or more balls present
        if (self.ballCounter >= 2) {
            randomPowerUp = arc4random() % 6 + 1;
        }
        // if only 1 ball, user can only receive other power ups
        else {
            do
            {
                randomPowerUp = arc4random() % 5 + 1;
            } while (randomPowerUp == 5);
        }
    }
    return randomPowerUp;
}

// this method gives the user the power up that is randomly generated
-(void)getPowerUp
{
    NSLog(@"power up");
    
    self.randomPowerUp = [self powerUpNumber];
    
    switch (self.randomPowerUp) {
        case 1:
            [paddle grow];
            [self powerUpTimerDelegate];
            
            bigPaddleLabel = [[SKLabelNode alloc] init];
            bigPaddleLabel.text = @"Big Paddle!";
            bigPaddleLabel.zPosition = 1;
            [self performSelector:@selector(addPowerUpLabel:) withObject:bigPaddleLabel];
            break;
        case 2:
            [scene runAction:[SKAction performSelector:@selector(vortex) onTarget:self]];
            [self powerUpTimerDelegate];
            
            vortexLabel = [[SKLabelNode alloc] init];
            vortexLabel.text = @"Vortex!";
            vortexLabel.zPosition = 1;
            [self performSelector:@selector(addPowerUpLabel:) withObject:vortexLabel];
            break;
        case 3:
            [self extraLife];
            [self powerUpTimerDelegate];
            
            extraLifeLabel = [[SKLabelNode alloc] init];
            extraLifeLabel.text = @"Extra Life!";
            extraLifeLabel.zPosition = 1;
            [self performSelector:@selector(addPowerUpLabel:) withObject:extraLifeLabel];
            break;
        case 4:
            [scene runAction:[SKAction performSelector:@selector(addForceField) onTarget:self]];
            [self powerUpTimerDelegate];
            
            forceFieldLabel = [[SKLabelNode alloc] init];
            forceFieldLabel.text = @"Force Field!";
            forceFieldLabel.zPosition = 1;
            [self performSelector:@selector(addPowerUpLabel:) withObject:forceFieldLabel];
            break;
        case 5:
            [self runAction:[SKAction performSelector:@selector(alterGravity) onTarget:self]];
            [self powerUpTimerDelegate];
            
            freezeLabel = [[SKLabelNode alloc] init];
            freezeLabel.text = @"Freeze!";
            freezeLabel.zPosition = 1;
            
            [scene runAction:[SKAction performSelector:@selector(snowEffect) onTarget:self]];
            
            [self performSelector:@selector(addPowerUpLabel:) withObject:freezeLabel];
            break;
        case 6:
        {
            [self missileTimerDelegate];
            [self powerUpTimerDelegate];
            
            missileLabel = [[SKLabelNode alloc] init];
            missileLabel.text = @"Laser!";
            missileLabel.zPosition = 1;
            [self performSelector:@selector(addPowerUpLabel:) withObject:missileLabel];
            break;
        }
        case 7:
            NSLog(@"nuke");
            [self powerUpTimerDelegate];
            break;
        default:
            break;
    }
}

-(void)addPowerUpLabel:(SKLabelNode *)node
{
    node.fontColor = [UIColor blueColor];
    node.fontName = @"Futura-CondensedExtraBold";
    node.fontSize = 80;
    node.position = CGPointMake(0, 400);
    NSLog(@"added label power");
    [self addChild:node];
    [self animateWithPulse:node];
}

// calls the 8 second timer for the duration of each power up
-(void)powerUpTimerDelegate
{
    if (self.randomPowerUp == 7) {
        self.seconds = 14;
        self.powerUpTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(testMethod) userInfo:nil repeats:YES];
    }
    else {
        self.seconds = 8;
        [scene runAction:[SKAction performSelector:@selector(powerUpTimerNode) onTarget:self]];
        self.powerUpTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(testMethod) userInfo:nil repeats:YES];
    }
}

-(void)powerUpTimerNode
{
    powerUpTimerNode = [[SKLabelNode alloc] init];
    powerUpTimerNode.fontName = @"Copperplate-Bold";
    powerUpTimerNode.fontSize = 30;
    powerUpTimerNode.fontColor = [UIColor redColor];
    powerUpTimerNode.position = CGPointMake(-120, 550);
    powerUpTimerNode.zPosition = 1;
    powerUpTimerNode.text = [NSString stringWithFormat:@"Time left: %i", self.seconds];
    [scene addChild:powerUpTimerNode];
}

// begins the timer for the power up
-(void)testMethod
{
    NSLog(@"added powerup timer");
    powerUpTimerNode.text = [NSString stringWithFormat:@"Time left: %i", self.seconds];
    
    // bogus code but whatever
    if (self.seconds < 8)
    {
        [bigPaddleLabel removeFromParent];
        [vortexLabel removeFromParent];
        [extraLifeLabel removeFromParent];
        [forceFieldLabel removeFromParent];
        [freezeLabel removeFromParent];
        [missileLabel removeFromParent];
    }
    
    if (self.seconds == 0)
    {
        [powerUpTimerNode removeFromParent];
        if (self.powerUpIsVisible && !self.powerUpReceived) {
            NSLog(@"power up regenerated");
            self.powerUpIsVisible = NO;
        }
        
        if (self.randomPowerUp == 1 && self.powerUpReceived) {
            NSLog(@"no more luxury life");
            [self.powerUpTimer invalidate];
            [paddle normalPaddle];
            
            // the user now does not have a power up
            self.powerUp = NO;
            
            // now the power up is no longer visible
            // the program can begin to re add them to the scene
            self.powerUpIsVisible = NO;
        }
        
        else if (self.randomPowerUp == 2 && self.powerUpReceived) {
            NSLog(@"no more luxury life");
            [self.powerUpTimer invalidate];
            
            [vortex removeFromParent];
            
            self.powerUp = NO;
            self.powerUpIsVisible = NO;
        }
        
        else if (self.randomPowerUp == 3 && self.powerUpReceived) {
            NSLog(@"no more luxury life");
            [self.powerUpTimer invalidate];
            
            self.powerUp = NO;
            self.powerUpIsVisible = NO;
        }
        
        else if (self.randomPowerUp == 4 && self.powerUpReceived) {
            NSLog(@"no more luxury life");
            [self.powerUpTimer invalidate];
            [forceField removeFromParent];
            
            self.powerUp = NO;
            self.powerUpIsVisible = NO;
        }
        
        else if (self.randomPowerUp == 5 && self.powerUpReceived) {
            NSLog(@"no more luxury life");
            [self.powerUpTimer invalidate];
            
            for (Ball *balls in ballArray) {
                balls.physicsBody.affectedByGravity = YES;
                [balls setTexture:[SKTexture textureWithImageNamed:@"rock2"]];
            }
            
            for (SKEmitterNode *skem in temporaryNodes)
            {
                [skem removeFromParent];
            }
            
            self.powerUp = NO;
            self.powerUpIsVisible = NO;
        }
        
        else if (self.randomPowerUp == 6 && self.powerUpReceived) {
            NSLog(@"no more luxury life");
            [self.powerUpTimer invalidate];
            
            self.powerUp = NO;
            self.powerUpIsVisible = NO;
            
        }
        
        else if (self.randomPowerUp == 7 && self.powerUpReceived) {
            NSLog(@"no more luxury life");
            
            [nukeCountDownLabel removeFromParent];
            [self.powerUpTimer invalidate];
            [self destroyBalls];
            
            self.powerUp = NO;
            self.powerUpIsVisible = NO;
            self.nukeLabelAdded = NO;
            self.nukeMusic = NO;
        }
    }
    
    else {
        
        if (self.nukeTime && self.randomPowerUp == 7) {
            if (!self.nukeMusic)
            {
                [nukeSound play];
                self.nukeMusic = YES;
            }
            
            self.seconds--;
            NSLog(@"Seconds left: %i", self.seconds);
            
            if (self.seconds <= 10) {
                if (!self.nukeLabelAdded) {

                    //[scene runAction:[SKAction performSelector:@selector(addNuke) onTarget:self]];
                    [self addNuke];
                    //[scene runAction:[SKAction performSelector:@selector(addNukeLabel) onTarget:self]];
                    NSLog(@"NUKE IS BEING ADDED");
                    self.nukeLabelAdded = YES;
                }
                nukeCountDownLabel.text = [NSString stringWithFormat:@"%i", self.seconds];
            }
        }
        
        else {
            self.seconds--;
            NSLog(@"Seconds left: %i", self.seconds);
        }
    }
}

#pragma mark Powerups

// this power up places a vortex on the screen
// if a ball touches the vortex, the ball will stop moving completely in its tracks
// and fall straight down
-(void)vortex
{
    vortex = [SKSpriteNode spriteNodeWithImageNamed:@"darkhole"];
    vortex.size = CGSizeMake(300, 300);
    vortex.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:60];
    vortex.physicsBody.dynamic= YES;
    vortex.physicsBody.mass = 9000000;
    vortex.physicsBody.affectedByGravity = NO;
    vortex.position = CGPointMake(0, 550);
    vortex.zPosition = 1;
    
    vortex.physicsBody.categoryBitMask = powerUpNetCategory;
    vortex.physicsBody.contactTestBitMask = ballCategory;
    
    [scene addChild:vortex];
    [self rotate:vortex];
}

// create a shooting action for the missiles
-(void)missile
{
    SKSpriteNode *missile = [SKSpriteNode spriteNodeWithImageNamed:@"missile"];
    missile.size = CGSizeMake(8, 40);
    missile.zPosition = 1;
    missile.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:missile.size];
    missile.physicsBody.dynamic = NO;
    missile.physicsBody.affectedByGravity = NO;
    missile.position = CGPointMake(paddle.position.x, paddle.position.y + 55);
    
    missile.physicsBody.categoryBitMask = missileCategory;
    missile.physicsBody.contactTestBitMask = ballCategory | paddleCategory;
    
    [scene addChild:missile];
    
    [self fireMissile:missile];
}

-(void)missileTimerDelegate
{
    self.missileTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(loadMissiles) userInfo:nil repeats:YES];
}

-(void)loadMissiles
{
    self.missileSeconds += 1.5;
    NSLog(@"loaded %f", self.missileSeconds);
    
    if (!self.isGameOver)
    {
        [scene runAction:[SKAction performSelector:@selector(missile) onTarget:self]];
    }
    
    if (self.missileSeconds >= 9.0) {
        self.missileSeconds = 0.0;
        [self.missileTimer invalidate];
    }
}

// this power up awards the user with an extra life
-(void)extraLife
{
    NSLog(@"1UP");
    self.lives++;
    [lifeUp play];
    lifeLabel.text = [NSString stringWithFormat:@"Lives: %i", self.lives];
}

// adds a force field to the game which bounces balls up and down the screen
// this also gets the user more points
-(void)addForceField
{
    forceField = [SKSpriteNode spriteNodeWithImageNamed:@"forceField"];
    forceField.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:forceField.size];
    
    forceField.position = CGPointMake(0, 200);
    forceField.zPosition = 1;
    forceField.physicsBody.allowsRotation = NO;
    forceField.physicsBody.dynamic = NO;
    
    forceField.physicsBody.affectedByGravity = NO;
    
    forceField.physicsBody.categoryBitMask = forceFieldCategory;
    forceField.physicsBody.contactTestBitMask = ballCategory | paddleCategory;
    forceField.physicsBody.collisionBitMask = ballCategory;
    
    
    [scene addChild:forceField];
}

// this power up freezes all of the balls in place on screen except for one ball
// that is allowed to move freely around
-(void)alterGravity
{
    for (Ball *balls in ballArray) {
        balls.physicsBody.affectedByGravity = NO;
        balls.physicsBody.velocity = CGVectorMake(0, 0);
        [balls setTexture:[SKTexture textureWithImageNamed:@"frozenBall"]];
    }
    
    if ([ballArray lastObject]) {
        Ball *luckyBall = [ballArray lastObject];
        luckyBall.physicsBody.affectedByGravity = YES;
        [luckyBall setTexture:[SKTexture textureWithImageNamed:@"rock2"]];
    }
}

// this power up is a nuke, and is called at the end of a 10 second timer
// this power up blows up every single ball on screen and removes them
-(void)destroyBalls
{
    NSLog(@"Nuked");
    [nuke removeFromParent];
    for (Ball *b in ballArray) {
        [b removeFromParent];
    }
    
    //[nukeBomb removeFromParent];
    
    self.ballCounter = 0;
    
    explosion = [SKSpriteNode spriteNodeWithImageNamed:@"explosion"];
    explosion.position = CGPointMake(0, 350);
    explosion.size = CGSizeMake(1500, 1500);
    explosion.zPosition = 1;
    explosion.alpha = 0.0;
    [scene addChild:explosion];
    
    [self explode:explosion];
    
    [scene runAction:[SKAction performSelector:@selector(addBall) onTarget:self]];
    
    self.nukeTime = NO;
}

// this adds the 10 second countdown label onto the screen
-(void)addNukeLabel
{
    
}

// this adds the nuke symbol when the timer is seconds on the nuke
-(void)addNuke
{
    [self addChild:nuke];
    //[self addChild:nukeCountDownLabel];
    [self rotateNuke:nuke];
}

#pragma mark Highscore Update

-(void)updateHighScore
{
    if (scoreLabel.number > highScoreLabel.number) {
        [highScoreLabel setPoints:scoreLabel.number];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:highScoreLabel.number forKey:@"highScoreLabel"];
    }
}

-(void)addSpark
{
    SKEmitterNode *spark = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"Spark" ofType:@"sks"]];
    spark.name = @"spark";
    spark.targetNode = self.scene;
    spark.zPosition = 2.0;
    spark.position = CGPointMake(paddle.position.x, paddle.position.y + 20);
    [scene addChild:spark];
}

-(void)ballExplosion:(SKSpriteNode *)node
{
    SKEmitterNode *paddleSpark = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"TestSpark" ofType:@"sks"]];
    paddleSpark.name = @"ballExplosion";
    paddleSpark.targetNode = self.scene;
    paddleSpark.position = CGPointMake(node.position.x, node.position.y);
    paddleSpark.zPosition = 1.0;
    [scene addChild:paddleSpark];
}

-(void)forceFieldEffect:(SKSpriteNode *)node
{
    SKEmitterNode *forceFieldSpark = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"ForceFieldSpark" ofType:@"sks"]];
    forceFieldSpark.name = @"forceFieldSpark";
    forceFieldSpark.targetNode = self.scene;
    forceFieldSpark.position = CGPointMake(node.position.x, node.position.y);
    forceFieldSpark.zPosition = 1.0;
    [scene addChild:forceFieldSpark];
}

-(void)paddleExplosion:(SKSpriteNode *)node
{
    SKEmitterNode *spark = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"PaddleExplosion" ofType:@"sks"]];
    spark.name = @"paddleExplosion";
    spark.targetNode = self.scene;
    spark.position = CGPointMake(node.position.x, node.position.y / 1.4);
    spark.zPosition = 1.0;
    [scene addChild:spark];
}

-(void)addDummyNode:(SKSpriteNode *)node
{
    [self addChild:node];
}

-(void)powerUpEffect:(SKSpriteNode *)node
{
    SKEmitterNode *powerEffect = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"PowerUpEffect" ofType:@"sks"]];
    powerEffect.name = @"powerUpEffect";
    powerEffect.targetNode = self.scene;
    powerEffect.position = CGPointMake(node.position.x, node.position.y / 1.4);
    powerEffect.zPosition = 1;
    [scene addChild:powerEffect];
}

-(void)snowEffect
{
    SKEmitterNode *freezeEffectSnow = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"FreezeEffect" ofType:@"sks"]];
    freezeEffectSnow.name = @"freezeEffectSnow";
    freezeEffectSnow.targetNode = self.scene;
    freezeEffectSnow.position = CGPointMake(-300, 700);
    freezeEffectSnow.zPosition = 1;
    [temporaryNodes addObject:freezeEffectSnow];
    [self addChild:freezeEffectSnow];
}

// clean up sparks
-(void)cleanUpChildrenAndRemove:(SKNode*)node {
    for (SKNode *child in node.children) {
        [self cleanUpChildrenAndRemove:child];
    }
    [node removeFromParent];
}

#pragma mark Collision Detection

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    // if a body in the scene makes contact with the paddle
    // shoot the ball back up
    if ((firstBody.categoryBitMask & ballCategory) != 0 && (secondBody.categoryBitMask & paddleCategory) != 0) {
        
        // increment paddle hit counter
        paddleHitCount++;

        // move ball up
        [firstBody applyImpulse:CGVectorMake(arc4random() % 20 + 50, arc4random() % 20 + 70)];
        
        // if the score is divisible by 5
        // add another ball using an action perform selector
        if (paddleHitCount % 5 == 0 && paddleHitCount != 0) {
            [scene runAction:[SKAction performSelector:@selector(addBall) onTarget:self]];
        }
        
        // if the power is not visible and the random number is true, add the power up to the scene
        if ([self getRandomNumber] == 2 && !self.powerUpIsVisible) {
            [scene runAction:[SKAction performSelector:@selector(addPowerUp) onTarget:self]];
            NSLog(@"Power up added to scene");
            
            // the power up is now visible
            self.powerUpIsVisible = YES;
        }
         
        // if there are 4 or more balls on the screen
        // the nuke power up becomes possible to obtain
        if (self.ballCounter >= 4) {
            self.nukeTime = YES;
        }
        
        // play paddle sound
        SKAction *paddleNoise = [SKAction playSoundFileNamed:@"paddleSound.wav" waitForCompletion:NO];
        [self runAction:paddleNoise];
        
    }
    
    // if a ball comes in contact with the vortex, set the balls velocity to 0 in all directions
    else if ((firstBody.categoryBitMask & ballCategory) != 0 && (secondBody.categoryBitMask & powerUpNetCategory) != 0) {
        firstBody.velocity = CGVectorMake(0, 0);
    }
    
    else if ((firstBody.categoryBitMask & ballCategory) != 0 && (secondBody.categoryBitMask & missileCategory) != 0) {
        NSLog(@"missile hit");
        
        // we cast two sprite nodes to hold the physics bodies of the missile and ball here
        SKSpriteNode *firstNode = (SKSpriteNode *) firstBody.node;
        SKSpriteNode *secondNode = (SKSpriteNode *) secondBody.node;
        
        // ball explosion effect
        [self performSelector:@selector(ballExplosion:) withObject:firstNode];
        SKAction *ballExplosion = [SKAction playSoundFileNamed:@"laserExplosion.wav" waitForCompletion:NO];
        [self runAction:ballExplosion];
        
        //[scene runAction:[SKAction performSelector:@selector(ballExplosion) onTarget:self]];
        
        // then remove the missile and ball from the scene
        [firstNode removeFromParent];
        [secondNode removeFromParent];
        
        // ball counter decremented due to ball being removed
        self.ballCounter--;
        
        // if the ball count is 0, add a new ball to the game
        if (self.ballCounter == 0) {
            [scene runAction:[SKAction performSelector:@selector(addBall) onTarget:self]];
        }
    }
    
    // if a ball comes in contact with the force field
    // shoot the balls back up and increment the score
    else if ((firstBody.categoryBitMask & ballCategory) != 0 && (secondBody.categoryBitMask & forceFieldCategory) != 0) {
        SKSpriteNode *firstNode = (SKSpriteNode *) firstBody.node;
        [self performSelector:@selector(forceFieldEffect:) withObject:firstNode];
        
        NSLog(@"FORCE FIELD!!");
        SKAction *forceFieldNoise = [SKAction playSoundFileNamed:@"forceField.wav" waitForCompletion:NO];
        [self runAction:forceFieldNoise];
        [firstBody applyImpulse:CGVectorMake(arc4random() % 20 + 50, 70)];
    }
    
    // checks for collision of power up and paddle
    if ((firstBody.categoryBitMask & paddleCategory) != 0 && (secondBody.categoryBitMask & powerUpCategory) != 1) {
        self.powerUpReceived = YES;
        [powerUp removeFromParent];
        
        [self performSelector:@selector(powerUpEffect:) withObject:paddle];
        
        SKAction *powerUpSound = [SKAction playSoundFileNamed:@"powerUpSound.wav" waitForCompletion:NO];
        [self runAction:powerUpSound];
        
        // if the user does not have a power up
        if (!self.powerUp) {
            [self getPowerUp];
            
            // now the user has a power up
            self.powerUp = YES;
        }
    }
    
    // if the user is to miss a power up and the power up reaches the bottom of the screen
    // regenerate a power up
    if ((firstBody.categoryBitMask & powerUpCategory) != 0 && (secondBody.categoryBitMask & powerUpBarrierCategory) != 0) {
        NSLog(@"power up regenerated");
        self.powerUpIsVisible = NO;
    }
    
    // if a ball hits the game over barrier below the paddle
    // the game is over
    else if ((firstBody.categoryBitMask & ballCategory) != 0 && (secondBody.categoryBitMask & gameOverBarrierCategory) != 0) {
        
        NSLog(@"Lost a ball");
        
        // checks to see if the game is over
        if (!self.isGameOver) {
            
            SKSpriteNode *redFlash = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(1000, 9000)];
            redFlash.alpha = 0.5;
            [self addChild:redFlash];
            [self flashRed:redFlash];
            
            // decrement lives
            self.lives--;
            
            // decrement ball counter
            self.ballCounter--;
            
            // if the user sucks and loses a life when only one ball is present
            // add in another ball
            if (self.ballCounter == 0) {
                [scene runAction:[SKAction performSelector:@selector(addBall) onTarget:self]];
            }
            
            // update lives label
            lifeLabel.text = [NSString stringWithFormat:@"Lives: %i", self.lives];
            
            NSLog(@"%i", self.ballCounter);
            
            SKAction *loseLifeSound = [SKAction playSoundFileNamed:@"loseLife.mp3" waitForCompletion:NO];
            [self runAction:loseLifeSound];
        }
        
        // if the user has 0 lives
        // the game is over
        if (self.lives == 0) {
            // call game over method
            [self gameOver];
            
            // create dummy node to hold position of paddle before explosion effect
            SKSpriteNode *explosionPoint = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(10, 10)];
            explosionPoint.position = paddle.position;
            explosionPoint.zPosition = 1;
            explosionPoint.alpha = 0;
            [self performSelector:@selector(addDummyNode:) withObject:explosionPoint];
            
            if (!self.paddleExploded)
            {
                [self performSelector:@selector(paddleExplosion:) withObject:explosionPoint];
                SKAction *paddleExplosionSound = [SKAction playSoundFileNamed:@"paddleExplosion.wav" waitForCompletion:NO];
                [self runAction:paddleExplosionSound];
                [paddle removeFromParent];
                self.paddleExploded = YES;
            }
            
            // set this so that when the remaining balls fall down, they don't touch the paddle
            paddle.physicsBody.categoryBitMask = 0;
            
            if (self.nukeLabelAdded)
            {
                [self.powerUpTimer invalidate];
                [nuke removeFromParent];
                [nukeCountDownLabel removeFromParent];
                [explosion removeFromParent];
            }
        }
    }
}

#pragma mark Game Animations

// this animates the pulsing effect of the tapToBegin/Reset labels
-(void)animateWithPulse:(SKNode *)node
{
    // this is the animation to make our tapToBegin/tapToReset disappear
    SKAction *disappear = [SKAction fadeAlphaTo:0.0 duration:0.6];
    // this is the action to make our tapToBegin/tapToReset labels appear
    SKAction *appear = [SKAction fadeAlphaTo:1.0 duration:0.6];
    
    // this is our pulse action that will run the two animations
    SKAction *pulse = [SKAction sequence:@[disappear, appear]];
    [node runAction:[SKAction repeatActionForever:pulse]];
}

-(void)flashRed:(SKNode *)node
{
    SKAction *disappear = [SKAction fadeAlphaTo:0.0 duration:0.1];
    [node runAction:disappear];
}

-(void)animatePowerUp:(SKNode *)node
{
    // this is the animation to make our tapToBegin/tapToReset disappear
    SKAction *disappear = [SKAction fadeAlphaTo:0.2 duration:0.8];
    // this is the action to make our tapToBegin/tapToReset labels appear
    SKAction *appear = [SKAction fadeAlphaTo:1.0 duration:0.8];
    
    // this is our pulse action that will run the two animations
    SKAction *pulse = [SKAction sequence:@[disappear, appear]];
    [node runAction:[SKAction repeatActionForever:pulse]];
}

// animates a shadow style effect for the paddle
-(void)shadowEffect:(SKNode *)node
{
    SKAction *disappear = [SKAction fadeAlphaTo:0.0 duration:0.6];
    
    SKSpriteNode *paddleShadow = [SKSpriteNode spriteNodeWithImageNamed:@"paddle"];
    paddleShadow.position = node.position;
    [self addChild:paddleShadow];
    [paddleShadow runAction:disappear];
    
}

// this animation rotates the black hole
-(void)rotate:(SKNode *)node
{
    SKAction *rotate = [SKAction rotateByAngle:-5 duration:2];
    [node runAction:[SKAction repeatActionForever:rotate]];
}

// this animation rotates the nuke emblem that appears when receiving the nuke power up
-(void)rotateNuke:(SKNode *)node
{
    SKAction *rotate = [SKAction rotateByAngle:-1 duration:1];
    [node runAction:[SKAction repeatActionForever:rotate]];
}

// this animation moves the bomb down toward the center of the screen
-(void)moveDown:(SKNode *)node
{
    SKAction *moveDown = [SKAction moveBy:CGVectorMake(0, -30) duration:1];
    [node runAction:[SKAction repeatActionForever:moveDown]];
}

// this animation shows the explosion of the nuke
-(void)explode:(SKNode *)node
{
    SKAction *explode = [SKAction fadeAlphaTo:1.0 duration:0.5];
    [node runAction:[SKAction repeatAction:explode count:1]];
    if (node.alpha == 1.0) {
        NSLog(@"explosion finished");
    }
}

// this animation fires the missile from the paddle
-(void)fireMissile:(SKNode *)node
{
    SKAction *shoot = [SKAction moveBy:CGVectorMake(0, 425) duration:1];
    [node runAction:[SKAction repeatActionForever:shoot]];
    SKAction *spaceLaserSound = [SKAction playSoundFileNamed:@"spaceLaser.wav" waitForCompletion:NO];
    [self runAction:spaceLaserSound];
}

// see comment below
// called roughly 60 times per second
-(void)update:(CFTimeInterval)currentTime
{
    if (self.isStarted)
    {
        self.shadowStyleTimer++;
        if (self.shadowStyleTimer % 10 == 0 && !self.isGameOver)
        {
            [self performSelector:@selector(shadowEffect:) withObject:paddle];
        }
    }
}

-(void)dealloc
{
    NSLog(@"gamescene deallocated");
}

@end

@implementation SKEmitterNode (fromFile)
+(instancetype)orb_emitterNamed:(NSString *)name
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle alloc] pathForResource:name ofType:@"sks"]];
}

@end
