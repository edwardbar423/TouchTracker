//
//  DrawView.h
//  TouchTracker
//
//  Created by Andrew Barber on 10/10/16.
//  Copyright © 2016 Invictus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Line.h"

@interface DrawView : UIView

@property (nonatomic) NSMutableDictionary *currentLines;
@property (nonatomic) NSMutableArray *finishedLines;
@property (nonatomic, weak) Line *selectedLine;
@property (nonatomic) UIPanGestureRecognizer *moveRecognizer;

@end
