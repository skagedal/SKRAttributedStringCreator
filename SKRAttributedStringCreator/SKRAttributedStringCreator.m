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

@property (strong, nonatomic) NSDictionary *tags;
@property (strong, readonly, nonatomic) NSMutableSet *tagPrefixes;

@end

@implementation SKRAttributedStringCreator

@synthesize tagPrefixes = _tagPrefixes;

- (instancetype)initWithTags:(NSDictionary *)tags
                      prefix:(NSString *)prefix
{
    self = [super init];
    [self buildTags:tags prefix:prefix];
    return self;
}

- (instancetype)initWithTags:(NSDictionary *)tags
{
    return [self initWithTags:tags prefix:@"#"];
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
        set = [NSCharacterSet characterSetWithCharactersInString:@"<{[(⟦"];
    });

    return set;
}

static bool isOpeningBrace(unichar c)
{
    return [openingBraces() characterIsMember:c];
}

- (void)buildTags:(NSDictionary *)tags
           prefix:(NSString *)prefix
{
    NSMutableDictionary *buildTags = [NSMutableDictionary new];
    
    for (id key in [tags allKeys]) {
        if (![key isKindOfClass:[NSString class]]) {
            [NSException raise:NSInvalidArgumentException
                        format:@"Tags must have string keys, got: %@", key];
        }
        NSString *newKey = [prefix stringByAppendingString:key];
        if ([newKey rangeOfCharacterFromSet:openingBraces()].location != NSNotFound) {
            [NSException raise:NSInvalidArgumentException
                        format:@"Invalid tag: %@ - can not contain opening braces", newKey];
        }
//        if (newKey.length == 0) {
//            [NSException raise:NSInvalidArgumentException
//                        format:@"Tags can not be the empty string"];
//        }
        
        buildTags[newKey] = tags[key];
    }

    self.tags = buildTags;
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

- (SKRAttributedStringTagRange *)parseStartTagFromString:(NSString *)string
                                                 atIndex:(NSUInteger)index
{
    NSMutableString *tag = [NSMutableString new];
    NSUInteger length = [string length];
    for (NSUInteger i = index; i < length; i++) {
        unichar c = [string characterAtIndex:i];
        if (isOpeningBrace(c)) {
            if (self.tags[tag]) {
                SKRAttributedStringTagRange *tagRange;
                tagRange = [[SKRAttributedStringTagRange alloc]
                            initWithTag:tag
                            openingBrace:c];
                return tagRange;
            }
            break;
        }
        [tag appendFormat:@"%C", c];
        if (![self.tagPrefixes containsObject:tag]) {
            break;
        }
    }
    return nil;
}

- (void)parseTemplate:(NSString *)template
             toString:(NSString **)outputPointer
         andTagRanges:(NSArray **)tagRangesPointer
{
    NSAssert(outputPointer, @"Output string can't be nil");
    NSAssert(tagRangesPointer, @"tagRanges can't be nil");
    
    NSMutableString *output = [NSMutableString new];
    NSMutableArray *tagRangesInOrder = [NSMutableArray new]; // of SKRAttributedStringTagRange
    
    NSMutableArray *tagRangesStack = [NSMutableArray new];  // of SKRAttributedStringTagRange
    
    NSUInteger length = [template length];
    for (NSUInteger i = 0; i < length; i++) {
        SKRAttributedStringTagRange *topTagRange = tagRangesStack.lastObject;
        SKRAttributedStringTagRange *tagRange;
        tagRange = [self parseStartTagFromString:template atIndex:i];
        if (tagRange) {
            [tagRange openAtLocation:output.length];
            [tagRangesStack addObject:tagRange];
            [tagRangesInOrder addObject:tagRange];
            i += [tagRange.tag length];
        } else if ([template characterAtIndex:i] == topTagRange.closingBrace) {
            [topTagRange closeAtLocation:output.length];
            [tagRangesStack removeLastObject];
        } else {
            NSString *oneChar = [template substringWithRange:NSMakeRange(i, 1)];
            [output appendString:oneChar];
        }
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
