//
//  TestTest.m
//  SmartTracker
//
//  Created by Théo Damaville on 16/11/2015.
//  Copyright © 2015 AT Internet. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "objc/runtime.h"
#import "ATGestureRecognizer.h"

@interface RecognizerTests : XCTestCase

@end

@implementation RecognizerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

/*
- (void)testDetectGestureRecognizerAction {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    NSMutableSet<UITouch*>* touches = [[NSMutableSet alloc] init];
    
    
    UITouch *touch = [[UITouch alloc] init];
    [touches addObject:touch];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(test_action)];
    
    Ivar ivar_tapcount = class_getInstanceVariable([UITouch class], "_tapCount");
    ((void (*)(id, Ivar, NSUInteger))object_setIvar)(touch, ivar_tapcount, 1);
    
    Ivar ivar = class_getInstanceVariable([UITouch class], "_gestureRecognizers");
    object_setIvar(touch, ivar, @[tap]);
    
    NSString *expected = @"test_action";
    //NSDictionary *result   = [ATGestureRecognizer getRecognizerInfo:touches ];
    NSDictionary *result   = [ATGestureRecognizer
                              getRecognizerInfo: touches
                              eventType:@"tap"];
                              
    XCTAssertTrue([expected isEqualToString:result[@"action"]]);
}*/

// for test purpose to cancel warnings
- (void) test_action{}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
