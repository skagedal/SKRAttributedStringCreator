//
//  SKRAttributedStringMaker.m
//  SKRAttributedStringMaker
//
//  Created by Simon Kågedal Reimer on 2015-07-01.
//  Copyright © 2015 Simon Kågedal Reimer. All rights reserved.
//

#import "SKRAttributedStringCreator.h"
#import "SKRAttributedStringTagRange.h"

@interface SKRAttributedStringCreator ()

@property (nonatomic) unichar escapeChar;
@property (strong, nonatomic) NSDictionary *tags;
@property (strong, readonly, nonatomic) NSMutableSet *tagPrefixes;

@end

@implementation SKRAttributedStringCreator

@synthesize tagPrefixes = _tagPrefixes;

- (instancetype)initWithTags:(NSDictionary *)tags
             escapeCharacter:(unichar)escapeChar
{
    self = [super init];
    if (self) {
        if ([self checkValidTags:tags escapeCharacter:escapeChar]) {
            self.escapeChar = escapeChar;
            self.tags = tags;
        } else {
            self = nil;
        }
    }
    return self;
}

- (instancetype)initWithTags:(NSDictionary *)tags
{
    return [self initWithTags:tags escapeCharacter:'#'];
}

static NSSet *allPrefixesOfString (NSString *s)
{
    NSMutableSet *set = [NSMutableSet new];
    for (NSUInteger i = 1; i <= [s length]; i++) {
        [set addObject: [s substringToIndex:i]];
    }
    return set;
}

static NSCharacterSet *openingBraces()
{
    static NSCharacterSet *set = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once (&onceToken, ^{
        set = [NSCharacterSet characterSetWithCharactersInString:@"<{[("];
    });

    return set;
}

static bool isOpeningBrace(unichar c)
{
    return [openingBraces() characterIsMember:c];
}



- (BOOL)checkValidTags:(NSDictionary *)tags
       escapeCharacter:(unichar)escapeChar {
    
    NSString *escapeString = [NSString stringWithFormat:@"%C", escapeChar];
    for (id keyObj in [tags allKeys]) {
        if (![keyObj isKindOfClass:[NSString class]]) {
            [NSException raise:NSInvalidArgumentException
                        format:@"Tags must have string keys, got: %@", keyObj];
        }
        NSString *key = keyObj;
        if ([key rangeOfCharacterFromSet:openingBraces()].location != NSNotFound) {
            [NSException raise:NSInvalidArgumentException
                        format:@"Invalid tag: %@ - cannot contain symbols used for opening braces", key];
        }
        if ([key rangeOfString:escapeString].location != NSNotFound) {
            [NSException raise:NSInvalidArgumentException
                        format:@"Invalid tag: %@ - cannot contain escape character", key];
        }
    }

    return YES;
}

- (NSMutableSet *)tagPrefixes {
    if (!_tagPrefixes && _tags) {
        // Build tag prefixes
        _tagPrefixes = [NSMutableSet new];
        for (NSString *key in [_tags allKeys]) {
            [_tagPrefixes unionSet:allPrefixesOfString(key)];
        }
    }
    return _tagPrefixes;
}

- (void)parseTemplate:(NSString *)template
             toString:(NSString **)outputPointer
         andTagRanges:(NSArray **)tagRangesPointer
{
    NSAssert(outputPointer, @"Output string can't be nil");
    NSAssert(tagRangesPointer, @"tagRanges can't be nil");
    
    // The result of parsing
    NSMutableString *output = [NSMutableString new];
    NSMutableArray *tagRangesInOrder = [NSMutableArray new]; // of SKRAttributedStringTemplateParserInfo
    
    // Parser state variables
    enum {
        kParserStateNormal,
        kParserStateReadingOpenTag
    } state = kParserStateNormal;
    NSMutableArray *tagRangesStack = [NSMutableArray new];  // of SKRAttributedStringTemplateParserInfo
    NSMutableString *currentlyParsedTag;
    
    NSUInteger length = [template length];
    for (NSUInteger i = 0; i < length; i++) {
        unichar c = [template characterAtIndex:i];
        SKRAttributedStringTagRange *currentTagRange = tagRangesStack.lastObject;
        switch (state) {
            case kParserStateNormal:
                if (c == self.escapeChar) {
                    currentlyParsedTag = [NSMutableString new];
                    state = kParserStateReadingOpenTag;
                } else if (currentTagRange && c == currentTagRange.closingBrace) {
                    [currentTagRange closeAtLocation:output.length];
                    [tagRangesStack removeLastObject];
                } else {
                    [output appendFormat:@"%C", c];
                }
                break;
                
            case kParserStateReadingOpenTag:
                if (isOpeningBrace(c)) {
                    if (self.tags[currentlyParsedTag]) {
                        SKRAttributedStringTagRange *tagRange =
                        [[SKRAttributedStringTagRange alloc]
                         initWithTag:currentlyParsedTag
                         openingBrace:c];
                        [tagRange openAtLocation:output.length];
                        [tagRangesStack addObject:tagRange];
                        [tagRangesInOrder addObject:tagRange];
                        
                        state = kParserStateNormal;
                    } else {
                        // Wrong end, output parsed input
                        [output appendFormat:@"%C%@%C", self.escapeChar, currentlyParsedTag, c];
                        state = kParserStateNormal;
                    }
                } else if (c == self.escapeChar) {
                    // Start over
                    [output appendFormat:@"%C%@", self.escapeChar, currentlyParsedTag];
                    currentlyParsedTag = [NSMutableString new];
                } else {
                    [currentlyParsedTag appendFormat:@"%C", c];
                    if (![self.tagPrefixes containsObject:currentlyParsedTag]) {
                        // Wrong end, output parsed input
                        [output appendFormat:@"%C%@", self.escapeChar, currentlyParsedTag];
                        state = kParserStateNormal;
                    }
                }
            default:
                break;
        }
    }
    if (state == kParserStateReadingOpenTag) {
        [output appendFormat:@"%C%@", self.escapeChar, currentlyParsedTag];
    }
    // Auto-close all open tags
    SKRAttributedStringTagRange *tagRange;
    while ((tagRange = tagRangesStack.lastObject)) {
        [tagRange closeAtLocation:output.length];
        [tagRangesStack removeLastObject];
    }

    *outputPointer = output;
    *tagRangesPointer = tagRangesInOrder;
}

- (NSMutableAttributedString *)attributedStringFromTemplate:(NSString *)template
{
    NSString *output;
    NSArray *tagRanges;
    
    [self parseTemplate:template toString:&output andTagRanges:&tagRanges];
    
    NSMutableAttributedString *mas = [[NSMutableAttributedString alloc]
                                      initWithString:output];
    [mas beginEditing];
    for (SKRAttributedStringTagRange *tagRange in tagRanges) {
        [mas addAttributes:self.tags[tagRange.tag] range:tagRange.range];
    }
    [mas endEditing];
    return mas;
}

@end
