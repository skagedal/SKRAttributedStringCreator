//
//  SKRAttributedStringCreatorTests.m
//  SKRAttributedStringCreatorTests
//
//  Created by Simon Kågedal Reimer on 2015-07-02.
//  Copyright (c) 2015 Simon Kågedal Reimer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SKRAttributedStringCreator.h"

@interface SKRAttributedStringCreatorTests : XCTestCase

@end

@implementation SKRAttributedStringCreatorTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSKRASC {
    NSDictionary *myTags = @{@"red": @{NSForegroundColorAttributeName: [UIColor redColor]},
                             @"green": @{NSForegroundColorAttributeName: [UIColor greenColor]},
                             @"blue": @{NSForegroundColorAttributeName: [UIColor blueColor]}
                             };
    SKRAttributedStringCreator *maker = [[SKRAttributedStringCreator alloc] initWithTags:myTags];
    XCTAssertNotNil(maker);
    NSString *template = @"here's #red{red} and #green<green> and #blue[blue]";
    NSAttributedString *as = [maker attributedStringFromTemplate:template];
    XCTAssertEqualObjects(as.string, @"here's red and green and blue");
    XCTAssertEqualObjects([as attribute:NSForegroundColorAttributeName atIndex:7 effectiveRange:nil],
                          [UIColor redColor]);
    XCTAssertEqualObjects([as attribute:NSForegroundColorAttributeName atIndex:16 effectiveRange:nil],
                          [UIColor greenColor]);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
