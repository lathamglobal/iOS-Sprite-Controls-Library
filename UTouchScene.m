//
//  UTouchScene.m
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

#import "UTouchScene.h"
#import "UControl.h"


const float touchDistance = 20.0;
const float touchVelocity = 200.0;

@implementation UTouchSceneEvent
@end

/// The touch scene data class.  Designed to be inherited by custom scenes.
@implementation UTouchScene
{
    //  current array of UControls
    NSArray *controls;
    
    //  touch metrics
    CFTimeInterval _touchStartTime;
    CGPoint _touchStartLocation;
}

/// Init with size.
- (instancetype)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if (self)
    {
        _touchStartTime = 0;
        _touchStartLocation = CGPointZero;
        controls = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

//  update control list
- (void)updateControlList
{
    //  get all controls in scene's tree
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:50];
    [self enumerateChildNodesWithName:@"//*" usingBlock:^(SKNode *node, BOOL *stop) {
        if ([node isKindOfClass:[UControl class]] && !node.hidden && ((UControl*)node).touchLevel)
            [array addObject:node];
    }];
    
    __block UControl *c1;
    __block UControl *c2;
    controls = [array sortedArrayUsingComparator: ^(id obj1, id obj2) {
        c1 = obj1;
        c2 = obj2;
        
        if (c1.touchLevel < c2.touchLevel) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if (c1.touchLevel > c2.touchLevel) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
}

// touches began event handler
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //  start location and time
    UITouch *touch = [touches anyObject];
    _touchStartLocation = [touch locationInNode:self];
    _touchStartTime = event.timestamp;
    
    //  new event
    UTouchSceneEvent *e = [UTouchSceneEvent new];
    e.timestamp = event.timestamp;
    e.touchLocation = _touchStartLocation;
    e.touchLocationDelta = CGVectorMake(0, 0);
    e.swipeVelocity = 0.0;
    e.touchedNodes = [self.scene nodesAtPoint:_touchStartLocation];
    e.touchPhase = UITouchPhaseBegan;
    e.gestureType = GestureTypeNone;
    
    
    //  update controls list
    [self updateControlList];
    
    //  update controls and self
    for (UControl *control in controls)
        if ([control touchEvent:e])
            break;
    [self touchUpdateHandler:e];
}
// touches moved event handler
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //  positions
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    CGPoint prevTouchLocation = [touch previousLocationInNode:self];
    CGVector touchLocationDelta = CGVectorMake(touchLocation.x - prevTouchLocation.x,
                                               touchLocation.y - prevTouchLocation.y);

    //  new event
    UTouchSceneEvent *e = [UTouchSceneEvent new];
    e.timestamp = event.timestamp;
    e.touchLocation = touchLocation;
    e.touchLocationDelta = touchLocationDelta;
    e.swipeVelocity = 0.0;
    e.touchedNodes = [self.scene nodesAtPoint:touchLocation];
    e.touchPhase = UITouchPhaseMoved;
    e.gestureType = GestureTypeNone;
    
    //  update controls and self
    for (UControl *control in controls)
        if ([control touchEvent:e])
            break;
    [self touchUpdateHandler:e];
}
// touches ended event handler
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //  end location and time
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    CFTimeInterval touchTime = event.timestamp;
    
    //  update self and delegates
    GestureType gestureType = GestureTypeTap;
    CGFloat horizontalDistance = (touchLocation.x - _touchStartLocation.x);
    float velocity = horizontalDistance / (touchTime - _touchStartTime);
    if (horizontalDistance >= touchDistance)
        gestureType = GestureTypeSlowDrag;
    if (ABS(velocity) > touchVelocity)
        gestureType = GestureTypeSwipeHorizontal;

    //  new event
    UTouchSceneEvent *e = [UTouchSceneEvent new];
    e.timestamp = event.timestamp;
    e.touchLocation = touchLocation;
    e.touchLocationDelta = CGVectorMake(0, 0);
    e.swipeVelocity = velocity;
    e.touchedNodes = [self.scene nodesAtPoint:touchLocation];
    e.touchPhase = UITouchPhaseEnded;
    e.gestureType = gestureType;
    
    //  update controls and self
    for (UControl *control in controls)
        if ([control touchEvent:e])
            break;
    [self touchUpdateHandler:e];
}
// touches cancelled event handler
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

/// Touch update handler, designed to be implemented in scene subclass.
-(uint)touchUpdateHandler:(UTouchSceneEvent*)update
{
    return 0;
}

/// Set all controls' touch level property.
-(void)setAllControlsTouchLevel:(TouchLevel)level
{
    __block UControl *control = nil;
    
    [self enumerateChildNodesWithName:@"//*" usingBlock:^(SKNode *node, BOOL *stop) {
        if ([node isKindOfClass:[UControl class]])
        {
            control = (UControl*)node;
                control.touchLevel = level;
        }
    }];
}

@end
