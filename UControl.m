//
//  UControl.m
//  SpriteControls
//
//  Created by Mark Latham on 4/13/15.
//  Copyright (c) 2015 Utrepic. All rights reserved.
//  Version 1.0
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import "UControl.h"
#import "UTouchScene.h"
#import "SpriteControls.h"


NSString *const UControlBackgroundKey = @"UControlBackground";
NSString *const UControlTestBackgroundKey = @"test_background";

@implementation UControl
{
    SKNode *_background;
    BOOL _isTestBackground;
}

/// Init with size.
-(instancetype)initWithSize:(CGSize)size
{
    self = [super init];
    if (self)
    {
        //  frame and defaults
        _size = size;
        [self setDefaults];
    }
    return self;
}

/// Init with size and background object.
-(instancetype)initWithSize:(CGSize)size
            backgroundObject:(id)backgroundObject
{
    self = [super init];
    if (self)
    {
        //  frame and defaults
        _size = size;
        [self setDefaults];

        //  background
        if ([backgroundObject isKindOfClass:[UIColor class]])
        {
            self.background = [SKSpriteNode spriteNodeWithColor:backgroundObject size:size];
            _background.name = UControlBackgroundKey;
        }
        else if ([backgroundObject isKindOfClass:[SKTexture class]])
        {
            self.background = [SKSpriteNode spriteNodeWithTexture:backgroundObject];
            _background.name = UControlBackgroundKey;
        }
        else if ([backgroundObject isKindOfClass:[NSString class]])
        {
            self.background = [SKSpriteNode spriteNodeWithImageNamed:backgroundObject];
            _background.name = UControlBackgroundKey;
        }
        else if ([backgroundObject isKindOfClass:[SKNode class]])
        {
            self.background = backgroundObject;
            _background.name = UControlBackgroundKey;
        }
    }
    return self;
}

//  set defaults
-(void)setDefaults
{
    self.zPosition = 5;
    _touchLevel = TouchLevel1;
    _activeAlpha = 1.0;
    _inactiveAlpha = 1.0;
    _transitionDuration = 0.0;
    _isTestBackground = NO;
}

/// The control background.  This is optional, and can be left nil.
-(SKNode*)background
{
    return _background;
}
-(void)setBackground:(SKNode *)background
{
    if (_background && _background.parent)
        [_background removeFromParent];
    
    _background = background;
    if (_background)
        [self addChild:_background];
}

/// Turns on a purple test background.
-(BOOL)isTestBackground
{
    return _isTestBackground;
}
-(void)setIsTestBackground:(BOOL)isTestBackground
{
    _isTestBackground = isTestBackground;

    //  remove any exiting test background
    SKNode *node = [self childNodeWithName:UControlTestBackgroundKey];
    if (node)
        [node removeFromParent];

    if (isTestBackground)
    {
        SKSpriteNode *testBackground = [SKSpriteNode spriteNodeWithColor:[UIColor purpleColor] size:_size];
        testBackground.name = UControlTestBackgroundKey;
        [self addChild:testBackground];
    }
}

/// Factory method for control with size.
+(instancetype)controlWithSize:(CGSize)size
{
    return [[UControl alloc] initWithSize:size];
}

/// Factory method for control with size and background object.
+(instancetype)controlWithSize:(CGSize)size
               backgroundObject:(id)backgroundObject
{
    return [[UControl alloc] initWithSize:size backgroundObject:backgroundObject];
}

//  fade alpha helper method
-(void)fadeAlpha
{
    if (_transitionDuration < 0.01)
    {
        if (_touchLevel)
            self.alpha = _activeAlpha;
        else
            self.alpha = _inactiveAlpha;
    }
    else
    {
        [self removeActionForKey:@"ctrl_tf"];
        if (_touchLevel)
            [self runAction:[SKAction fadeAlphaTo:_activeAlpha duration:_transitionDuration] withKey:@"ctrl_tf"];
        else
            [self runAction:[SKAction fadeAlphaTo:_inactiveAlpha duration:_transitionDuration] withKey:@"ctrl_tf"];
    }
}

/// The control for touch level (analagous to z-order).
/// When this value is zero, the control is inactive.
-(TouchLevel)touchLevel
{
    return _touchLevel;
}
-(void)setTouchLevel:(TouchLevel)touchLevel
{
    //  save active adn fade alpha
    _touchLevel = touchLevel;
    [self fadeAlpha];
    //SCLog(@"%@ %@ touch level = %d", NSStringFromClass([self class]), self.name, _touchLevel);
}

/// The overall alpha when the control is active.
-(CGFloat)activeAlpha
{
    return _activeAlpha;
}
-(void)setActiveAlpha:(CGFloat)activeAlpha
{
    _activeAlpha = activeAlpha;
    [self fadeAlpha];
}

/// The overall alpha when the control is inactive.
-(CGFloat)inactiveAlpha
{
    return _inactiveAlpha;
}
-(void)setInactiveAlpha:(CGFloat)inactiveAlpha
{
    _inactiveAlpha = inactiveAlpha;
    [self fadeAlpha];
}

/// Method to determine if this control is being touched.
-(BOOL)isTouched:(UTouchSceneEvent*)event
{
    //  convert location to control coordinates
    CGPoint location = [self convertPoint:event.touchLocation fromNode:self.scene];
    CGFloat hw = self.size.width * 0.5;
    CGFloat hh = self.size.height * 0.5;
    return ((location.x >= -hw) && (location.x < hw) && (location.y >= -hh) && (location.y < hh));
}

/// Touch event method to support UTouchScene.
-(BOOL)touchEvent:(UTouchSceneEvent *)event
{
    if ((event.gestureType == GestureTypeTap) && [self isTouched:event])
    {
        if (_altTapHandler)
            _altTapHandler(self);
        else if (_tapHandler)
            _tapHandler(self);
        return YES;
    }
    return NO;
}

@end
