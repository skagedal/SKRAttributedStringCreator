//
//  SKRAttributedStringTemplateParserInfo.m
//  SKRAttributedStringMaker
//
//  Created by Simon Kågedal Reimer on 2015-07-01.
//  Copyright © 2015 Simon Kågedal Reimer. All rights reserved.
//

#import "SKRAttributedStringTagRange.h"

@implementation SKRAttributedStringTagRange

@synthesize range = _range;
@synthesize openingBrace = _openingBrace;

- (instancetype)initWithTag:(NSString *)tag openingBrace:(unichar)openingBrace
{
    self = [super init];
    if (self) {
        _tag = tag;
        _openingBrace = openingBrace;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Tag \"%@\" with range %@ and closing char %C",
            self.tag, NSStringFromRange(self.range), self.closingBrace];
}

static unichar closingBraceForOpeningBrace(unichar openingBrace)
{
    switch (openingBrace) {
        case '<':
            return '>';
        case '{':
            return '}';
        case '[':
            return ']';
        case '(':
            return ')';
        case 0x27E6:       // ⟦
            return 0x27E7; // ⟧
    }
    assert(0);
    return 0;
}

- (unichar)closingBrace {
    return closingBraceForOpeningBrace(self.openingBrace);
}

- (void)openAtLocation:(NSUInteger)loc {
    _range = NSMakeRange(loc, 0);
}

- (void)closeAtLocation:(NSUInteger)loc {
    NSUInteger startLoc = _range.location;
    _range = NSMakeRange(startLoc, loc - startLoc);
}

@end
