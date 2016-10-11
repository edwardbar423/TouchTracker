//
//  DrawView.m
//  TouchTracker
//
//  Created by Andrew Barber on 10/10/16.
//  Copyright © 2016 Invictus. All rights reserved.
//

#import "DrawView.h"

@implementation DrawView

-(void)strokeLine:(Line *)line {
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    path.lineWidth = 10;
    path.lineCapStyle = kCGLineCapRound;
    
    [path moveToPoint:line.begin];
    [path addLineToPoint:line.end];
    
    [path stroke];
    
}

-(void)drawRect:(CGRect)rect {
    
    [[UIColor blackColor] setStroke];
    for (Line *line in self.finishedLines) {
        [self strokeLine:line];
    }
   
    [[UIColor redColor] setStroke];
    for (Line *line in self.currentLines.allValues) {
        
        [self strokeLine:line];
        
    }
   
    if (self.selectedLine) {
        
        [[UIColor greenColor] setStroke];
        [self strokeLine:self.selectedLine];
        
    }
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    for (UITouch *touch in touches) {
        
        CGPoint location = [touch locationInView:self];
        Line *newLine = [[Line alloc] initWithBegin:location end:location];
        NSValue *key = [NSValue valueWithNonretainedObject:touch];
        self.currentLines[key] = newLine;
        
    }
        [self setNeedsDisplay];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    for (UITouch *touch in touches) {
        
        CGPoint location = [touch locationInView:self];
        NSValue *key = [NSValue valueWithNonretainedObject:touch];
        
        Line *line = self.currentLines[key];
        line.end = location;
        
    }
    
    [self setNeedsDisplay];
    
}
    
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    for (UITouch *touch in touches) {
        
        CGPoint location = [touch locationInView:self];
        
        NSValue *key = [NSValue valueWithNonretainedObject:touch];
        
        Line *line = self.currentLines[key];
        line.end = location;
        
        [self.finishedLines addObject:line];
        [self.currentLines removeObjectForKey:key];
        
    }
    
    [self setNeedsDisplay];
    
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self.currentLines removeAllObjects];
    [self setNeedsDisplay];
    
}

-(Line *)lineAtPoint:(CGPoint)point {
    
    for (Line *line in self.finishedLines) {
        
        CGPoint begin = line.begin;
        CGPoint end = line.end;
        
        for (CGFloat t = 0; t < 1.0; t += 0.05) {
            
            CGFloat x = begin.x + ((end.x - begin.x) * t);
            CGFloat y = begin.y + ((end.y - begin.y) * t);
            
            if (hypot(x - point.x, y - point.y) < 20.0) {
                return line;
            }
        }
    }
    return nil;
}

-(void)moveLine:(UIPanGestureRecognizer *)gestureRecognizer {
    Line *line = self.selectedLine;
    if (line) {
        if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
            CGPoint translation = [gestureRecognizer translationInView:self];
            
            CGPoint begin = line.begin;
            begin.x += translation.x;
            begin.y += translation.y;
            line.begin = begin;
            
            CGPoint end = line.end;
            end.x += translation.x;
            end.y += translation.y;
            line.end = end;
            
            [gestureRecognizer setTranslation:CGPointZero inView:self];
            
            [self setNeedsDisplay];
        } else {
            return;
        }
    }
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        _finishedLines = [[NSMutableArray alloc] init];
        _currentLines = [[NSMutableDictionary alloc] init];
        
        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(doubleTap:)];
        doubleTapRecognizer.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTapRecognizer];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(tap:)];
        tapRecognizer.delaysTouchesBegan = YES;
        [tapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
        [self addGestureRecognizer:tapRecognizer];
        
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                                 action:@selector(longPress:)];
        [self addGestureRecognizer:longPressGestureRecognizer];
        
        _moveRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                  action:@selector(moveLine:)];
        _moveRecognizer.delegate = self;
        _moveRecognizer.cancelsTouchesInView = NO;
        [self addGestureRecognizer:_moveRecognizer];
    }
    
    return self;
}

-(void)tap:(UIGestureRecognizer *)gestureRecognizer {
    
    NSLog(@"Recognized a tap");
    
    CGPoint point = [gestureRecognizer locationInView:self];
    self.selectedLine = [self lineAtPoint:point];
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    
    if (self.selectedLine) {
        
        [self becomeFirstResponder];
        
        UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:@"Delete"
                                                            action:@selector(deleteLine:)];
        menu.menuItems = @[deleteItem];
        
        [menu setTargetRect:CGRectMake(point.x, point.y, 2, 2) inView:self];
        [menu setMenuVisible:YES animated:YES];
        
    } else {
        
        [menu setMenuVisible:NO animated:YES];
        
    }
    
    [self setNeedsDisplay];
    
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGR {
    if (gestureRecognizer == self.moveRecognizer) {
        return YES;
    }
    return NO;
}

-(void)doubleTap:(UIGestureRecognizer *)gestureRecognizer {
    
    NSLog(@"Recognized a double tap");
    
    [self.currentLines removeAllObjects];
    [self.finishedLines removeAllObjects];
    
    [self setNeedsDisplay];
    
}

-(void)longPress:(UIGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gestureRecognizer locationInView:self];
        
        self.selectedLine = [self lineAtPoint:point];
        
        if (self.selectedLine) {
            [self.currentLines removeAllObjects];
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        self.selectedLine = nil;
    }
    
    [self setNeedsDisplay];
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)deleteLine:(id)sender {
    
    if (self.selectedLine) {
        [self.finishedLines removeObject:self.selectedLine];
        
        [self setNeedsDisplay];
        
    }
    
}

@end



























