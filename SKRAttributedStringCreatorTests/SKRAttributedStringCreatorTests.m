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
    // Basic functionality
    NSDictionary *tags = @{@"red": @{NSForegroundColorAttributeName: [UIColor redColor]},
                           @"green": @{NSForegroundColorAttributeName: [UIColor greenColor]},
                           @"blue": @{NSForegroundColorAttributeName: [UIColor blueColor]}
                          };
    SKRAttributedStringCreator *creator = [[SKRAttributedStringCreator alloc] initWithTags:tags];
    XCTAssertNotNil(creator);
    NSString *template = @"here's #red{red} and #green<green> and #blue[blue]";
    NSAttributedString *as = [creator attributedStringFromTemplate:template];
    XCTAssertEqualObjects(as.string, @"here's red and green and blue");
    XCTAssertEqualObjects([as attribute:NSForegroundColorAttributeName atIndex:7 effectiveRange:nil],
                          [UIColor redColor]);
    XCTAssertEqualObjects([as attribute:NSForegroundColorAttributeName atIndex:16 effectiveRange:nil],
                          [UIColor greenColor]);
    
    // Emojis ok
    tags = @{@"💜": @{NSForegroundColorAttributeName: [UIColor purpleColor]},
             @"💛": @{NSForegroundColorAttributeName: [UIColor yellowColor]},
             @"💚": @{NSForegroundColorAttributeName: [UIColor greenColor]},
             @"💙": @{NSForegroundColorAttributeName: [UIColor blueColor]}};
    creator = [[SKRAttributedStringCreator alloc] initWithTags:tags prefix:@""];
    template = @"💜[1]💛(2)💚{3}💙<4>💜⟦5⟧";
    as = [creator attributedStringFromTemplate:template];
    XCTAssertEqualObjects(as.string, @"12345");
    NSArray *colors = @[[UIColor purpleColor], [UIColor yellowColor], [UIColor greenColor],
                        [UIColor blueColor], [UIColor purpleColor]];
    for (int i = 0; i < colors.count; i++) {
        XCTAssertEqualObjects([as attribute:NSForegroundColorAttributeName
                                    atIndex:i
                             effectiveRange:nil], colors[i]);
    }

    // Nesting
    tags = @{@"u": @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleDouble)},
             @"r": @{NSForegroundColorAttributeName: [UIColor redColor]}};
    creator = [[SKRAttributedStringCreator alloc] initWithTags:tags];
    template = @"#u{#r{X}}";
    as = [creator attributedStringFromTemplate:template];
    XCTAssertEqualObjects(as.string, @"X");
    XCTAssertEqualObjects([as attribute:NSForegroundColorAttributeName
                                atIndex:0
                         effectiveRange:nil],
                          [UIColor redColor]);
    XCTAssertEqualObjects([as attribute:NSUnderlineStyleAttributeName
                                atIndex:0
                         effectiveRange:nil],
                          @(NSUnderlineStyleDouble));
    
    // Auto-close open tags
    template = @"#u{#r{X";
    as = [creator attributedStringFromTemplate:template];
    XCTAssertEqualObjects(as.string, @"X");
    XCTAssertEqualObjects([as attribute:NSForegroundColorAttributeName
                                atIndex:0
                         effectiveRange:nil],
                          [UIColor redColor]);
    XCTAssertEqualObjects([as attribute:NSUnderlineStyleAttributeName
                                atIndex:0
                         effectiveRange:nil],
                          @(NSUnderlineStyleDouble));
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
