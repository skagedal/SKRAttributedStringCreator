//
//  SKRAttributedStringTemplateParserInfo.h
//  SKRAttributedStringMaker
//
//  Created by Simon Kågedal Reimer on 2015-07-01.
//  Copyright © 2015 Simon Kågedal Reimer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKRAttributedStringTagRange : NSObject

@property (nonatomic, readonly) unichar openingBrace;
@property (nonatomic, readonly) unichar closingBrace;
@property (nonatomic, readonly) NSRange range;
@property (nonatomic, readonly, copy) NSString *tag;

- (instancetype)initWithTag:(NSString *)tag
               openingBrace:(unichar) openingBrace;
- (void)openAtLocation:(NSUInteger)loc;
- (void)closeAtLocation:(NSUInteger)loc;

@end
