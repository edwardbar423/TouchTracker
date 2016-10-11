//
//  Line.m
//  TouchTracker
//
//  Created by Andrew Barber on 10/10/16.
//  Copyright © 2016 Invictus. All rights reserved.
//

#import "Line.h"

@implementation Line

-(instancetype)initWithBegin:(CGPoint)begin end:(CGPoint)end {
    self = [super init];
    if (self) {
        _begin = begin;
        _end = end;
    }
    return self;
}

@end
