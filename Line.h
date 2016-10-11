//
//  Line.h
//  TouchTracker
//
//  Created by Andrew Barber on 10/10/16.
//  Copyright © 2016 Invictus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Line : NSObject

@property (nonatomic) CGPoint begin;
@property (nonatomic) CGPoint end;

-(instancetype)initWithBegin:(CGPoint)begin end:(CGPoint)end;

@end
