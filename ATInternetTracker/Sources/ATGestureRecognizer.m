/*
 This SDK is licensed under the MIT license (MIT)
 Copyright (c) 2015- Applied Technologies Internet SAS (registration number B 403 261 258 - Trade and Companies Register of Bordeaux – France)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */


#import "ATGestureRecognizer.h"
#include <objc/runtime.h>

@implementation ATGestureRecognizer

/**
 *  Get the reconizers associated with an uiview
 *
 *  @param touchedView the view
 *  @param eventType   the recognizer expacted
 *
 *  @return an dictionary with target/action
 */
+ (NSDictionary *)getRecognizerInfoFromView:(UIView *)touchedView withExpected:(NSString *)eventType;
{
    NSMutableDictionary* infos = [[NSMutableDictionary alloc] init];
    NSMutableArray* gestureRecognizers = [[NSMutableArray alloc] init];
    
    if(touchedView) {
        if([touchedView respondsToSelector:@selector(gestureRecognizers)]) {
            [gestureRecognizers addObjectsFromArray:touchedView.gestureRecognizers];
        }
    }
    
    for (NSInteger i = gestureRecognizers.count-1; i >= 0; i--) {
        if ([eventType isEqualToString:@"tap"]) {
            if (![gestureRecognizers[i] isKindOfClass:[UITapGestureRecognizer class]]) {
                [gestureRecognizers removeObjectAtIndex:i];
            }
        }
        else if ([eventType isEqualToString:@"swipe"]) {
            if (![gestureRecognizers[i] isKindOfClass:[UISwipeGestureRecognizer class]] && ![gestureRecognizers[i] isKindOfClass:[UIPanGestureRecognizer class]]) {
                [gestureRecognizers removeObjectAtIndex:i];
            }
        }
        else if ([eventType isEqualToString:@"pinch"]) {
            if (![gestureRecognizers[i] isKindOfClass:[UIPinchGestureRecognizer class]]) {
                [gestureRecognizers removeObjectAtIndex:i];
            }
        }
        else if ([eventType isEqualToString:@"rotate"]) {
            if (![gestureRecognizers[i] isKindOfClass:[UIRotationGestureRecognizer class]]) {
                [gestureRecognizers removeObjectAtIndex:i];
            }
        }
    }
    
    for(UIGestureRecognizer* recogniser in gestureRecognizers) {
        if (((UITapGestureRecognizer*)recogniser).numberOfTapsRequired == 1) {
        
            Ivar targetsIvar = class_getInstanceVariable([UIGestureRecognizer class], "_targets");
            id targetActionPairs = object_getIvar(recogniser, targetsIvar);
            
            Class targetActionPairClass = NSClassFromString(@"UIGestureRecognizerTarget");
            Ivar actionIvar = class_getInstanceVariable(targetActionPairClass, "_action");

            for (id targetActionPair in targetActionPairs)
            {
                SEL action = (__bridge void *)object_getIvar(targetActionPair, actionIvar);
                infos[@"action"] = NSStringFromSelector(action);
                
                if([recogniser isKindOfClass:[UITapGestureRecognizer class]]) {
                    infos[@"eventType"] = @"tap";
                } else if([recogniser isKindOfClass:[UISwipeGestureRecognizer class]]) {
                    infos[@"eventType"] = @"swipe";
                } else if([recogniser isKindOfClass:[UIPinchGestureRecognizer class]]) {
                    infos[@"eventType"] = @"pinch";
                } else if([recogniser isMemberOfClass:[UIPanGestureRecognizer class]]) {
                    infos[@"eventType"] = @"pan";
                } else if([recogniser isKindOfClass:[UIRotationGestureRecognizer class]]) {
                    infos[@"eventType"] = @"rotate";
                }
                return infos;
            }
        }
    }
    return infos;
}

+ (NSDictionary *) getRecognizerInfo:(NSSet <UITouch *> *)touches eventType:(NSString *)eventType;
{
    NSMutableDictionary* infos = [[NSMutableDictionary alloc] init];
    
    NSMutableArray* gestureRecognizers = [[NSMutableArray alloc] init];
    
    UITouch* touch = [touches anyObject];
    UIView * touchedView = touch.view;
    if (!touchedView) {
        for (UITouch* t in touches) {
            if (t.view) {
                touchedView = t.view;
                touch = t;
                break;
            }
        }
    }
    
    if(touchedView) {
        if([touchedView respondsToSelector:@selector(gestureRecognizers)]) {
            [gestureRecognizers addObjectsFromArray:touchedView.gestureRecognizers];
        }
    }
    
    if([touch respondsToSelector:@selector(gestureRecognizers)] && gestureRecognizers.count == 0) {
        [gestureRecognizers addObjectsFromArray:touch.gestureRecognizers];
    }
    
    for (NSInteger i = gestureRecognizers.count-1; i >= 0; i--) {
        if ([eventType isEqualToString:@"tap"]) {
            if (![gestureRecognizers[i] isKindOfClass:[UITapGestureRecognizer class]]) {
                [gestureRecognizers removeObjectAtIndex:i];
            }
        }
        else if ([eventType isEqualToString:@"swipe"]) {
            if (![gestureRecognizers[i] isKindOfClass:[UISwipeGestureRecognizer class]] && ![gestureRecognizers[i] isKindOfClass:[UIPanGestureRecognizer class]]) {
                [gestureRecognizers removeObjectAtIndex:i];
            }
        }
        else if ([eventType isEqualToString:@"pinch"]) {
            if (![gestureRecognizers[i] isKindOfClass:[UIPinchGestureRecognizer class]]) {
                [gestureRecognizers removeObjectAtIndex:i];
            }
        }
        else if ([eventType isEqualToString:@"rotate"]) {
            if (![gestureRecognizers[i] isKindOfClass:[UIRotationGestureRecognizer class]]) {
                [gestureRecognizers removeObjectAtIndex:i];
            }
        }
    }
    
    for(UIGestureRecognizer* recogniser in gestureRecognizers) {
        if(recogniser.state == UIGestureRecognizerStateChanged || ([recogniser isKindOfClass: [UITapGestureRecognizer class]] && recogniser.state == UIGestureRecognizerStatePossible && ((UITapGestureRecognizer*)recogniser).numberOfTapsRequired == touch.tapCount))
        {
            Ivar targetsIvar = class_getInstanceVariable([UIGestureRecognizer class], "_targets");
            id targetActionPairs = object_getIvar(recogniser, targetsIvar);
            
            Class targetActionPairClass = NSClassFromString(@"UIGestureRecognizerTarget");
            Ivar actionIvar = class_getInstanceVariable(targetActionPairClass, "_action");

            for (id targetActionPair in targetActionPairs)
            {
                SEL action = (__bridge void *)object_getIvar(targetActionPair, actionIvar);
                infos[@"action"] = NSStringFromSelector(action);
                
                if([recogniser isKindOfClass:[UITapGestureRecognizer class]]) {
                    infos[@"eventType"] = @"tap";
                } else if([recogniser isKindOfClass:[UISwipeGestureRecognizer class]]) {
                    infos[@"eventType"] = @"swipe";
                } else if([recogniser isKindOfClass:[UIPinchGestureRecognizer class]]) {
                    infos[@"eventType"] = @"pinch";
                } else if([recogniser isMemberOfClass:[UIPanGestureRecognizer class]]) {
                    infos[@"eventType"] = @"pan";
                } else if([recogniser isKindOfClass:[UIRotationGestureRecognizer class]]) {
                    infos[@"eventType"] = @"rotate";
                }
                return infos;
            }
        }
    }
    
    
    return infos;
}

@end
