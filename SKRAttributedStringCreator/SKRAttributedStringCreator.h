//
//  SKRAttributedStringMaker.h
//  SKRAttributedStringMaker
//
//  Created by Simon Kågedal Reimer on 2015-07-01.
//  Copyright © 2015 Simon Kågedal Reimer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKRAttributedStringCreator : NSObject

- (instancetype)initWithTags:(NSDictionary *)tags
             escapeCharacter:(unichar)escape;

- (instancetype)initWithTags:(NSDictionary *)tags;

- (NSMutableAttributedString *)attributedStringFromTemplate:(NSString *)template;

@end
