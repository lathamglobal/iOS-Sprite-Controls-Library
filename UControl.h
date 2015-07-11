//
//  UControl.h
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

#import <SpriteKit/SpriteKit.h>
@class UTouchSceneEvent;


/// UControl touch level, where 10 is highest priority.
typedef enum
{
    TouchLevelNone,
    TouchLevel1,
    TouchLevel2,
    TouchLevel3,
    TouchLevel4,
    TouchLevel5,
    TouchLevel6,
    TouchLevel7,
    TouchLevel8,
    TouchLevel9,
    TouchLevel10
    
} TouchLevel;


@interface UControl : SKNode
{
    TouchLevel _touchLevel;
    CGFloat _activeAlpha;
    CGFloat _inactiveAlpha;
}

/// The control size, used for  touch area.
/// The base class SKNode does not have a size property.
@property (readonly) CGSize size;

/// The control for touch level (analagous to z-order).
/// When this value is zero, the control is inactive.
@property TouchLevel touchLevel;

/// The control background.  This is optional, and can be left nil.
@property SKNode *background;

/// Turns on a purple test background.
@property BOOL isTestBackground;

/// The main tap handler code block.
@property (copy) void (^tapHandler)(UControl *control);

/// The alternate tap handler code block.
@property (copy) void (^altTapHandler)(UControl *control);

/// The overall alpha when the control is active.
@property CGFloat activeAlpha;

/// The overall alpha when the control is inactive.
@property CGFloat inactiveAlpha;

/// The transistion duration from active to inactive alpha (and reverse).
@property CGFloat transitionDuration;


/// Init with size.
-(instancetype)initWithSize:(CGSize)size;

/// Init with size and background object.
-(instancetype)initWithSize:(CGSize)size
            backgroundObject:(id)backgroundObject;

/// Factory method for control with size.
+(instancetype)controlWithSize:(CGSize)size;

/// Factory method for control with size and background object.
+(instancetype)controlWithSize:(CGSize)size
               backgroundObject:(id)backgroundObject;

/// Method to determine if this control is being touched.
-(BOOL)isTouched:(UTouchSceneEvent*)event;

/// Touch event method to support UTouchScene.
-(BOOL)touchEvent:(UTouchSceneEvent *)event;

@end
