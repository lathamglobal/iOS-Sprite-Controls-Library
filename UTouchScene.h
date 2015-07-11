//
//  UTouchScene.h
//  SpriteControls
//
//  Created by Mark Latham on 4/9/15.
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
#import "UControl.h"

/// A gesture type.
typedef enum
{
    GestureTypeNone,
    GestureTypeTap,
    GestureTypeSlowDrag,
    GestureTypeSwipeHorizontal,
    GestureTypeSwipeVertical,
    
} GestureType;

/// A touch event data class.
@interface UTouchSceneEvent : NSObject

/// The event timestamp.
@property CFTimeInterval timestamp;

/// The current touch location.
@property CGPoint touchLocation;

/// The current touch location delta from the previous location.
@property CGVector touchLocationDelta;

/// The touched nodes.
@property NSArray *touchedNodes;

/// The swipe velocity.
@property CGFloat swipeVelocity;

/// The touch phase.
@property UITouchPhase touchPhase;

/// The gesture type that the touch events embody.
@property GestureType gestureType;

@end


/// The touch scene data class.  Designed to be inherited by custom scenes.
@interface UTouchScene : SKScene

/// Init with size.
- (instancetype)initWithSize:(CGSize)size;

/// Touch handler, to be implemented in subclass.
-(uint)touchUpdateHandler:(UTouchSceneEvent*)update;

/// Set all controls' touch level property.
-(void)setAllControlsTouchLevel:(TouchLevel)level;

@end
