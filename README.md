SKRAttributedStringCreator
==========================

This is a Cocoa (Touch) class that lets you create NSAttributedStrings
with a simple inline markup that tries to get out of your way.

Set up some tags that map to the attributes you need.

    NSDictionary *tags = @{
        @"red": @{NSForegroundColorAttributeName: [UIColor redColor]},
        @"green": @{NSForegroundColorAttributeName: [UIColor greenColor]},
        @"sweden": @{NSForegroundColorAttributeName: [UIColor yellowColor],
                     NSBackgroundColorAttributeName: [UIColor blueColor]},
        @"U": @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)}
    };

Create an SKRAttributedStringCreator with the tags. 

    SKRAttributedStringCreator *asCreator =
        [[SKRAttributedStringCreator alloc] initWithTags:tags];

Then render your markup.  Here's an example.

    NSString *template =
        @"#red[This is in red], and #blue{this is blue #U{and underlined}}. "
        @"#sweden<This is Sweden's flag-colored.>";
    NSAttributedString *as = [asCreator attributedStringFromTemplate:template];
    
As you see, tags are prefixed with a '#' - this, however is just a
default and can be changed.  The content is delimited with any of
these brackets: [ ], { }, ( ), < >, ⟦ ⟧.  The last pair are the
unicode characters "mathematical left/right white square bracket",
found at code points U+27E6 and U+27E7 respectively.

You may change the tag prefix by using the initializer
`initWithTags:prefix:`, it may be the empty string.

There is, by purpose, no way to escape special characters; such syntax
is annoying.  Instead, the parser will just pass through anything it
doesn't parse as a tag, so just write it as is:

    #sometag{My # is 3, which is > 2}.
    
Just use delimiters, tags and tag prefix that don't clash with your
content.  The use of emoji characters as tags is allowed and
encouraged.

