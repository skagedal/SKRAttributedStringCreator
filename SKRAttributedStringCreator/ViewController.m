//
//  ViewController.m
//  SKRAttributedStringCreator
//
//  Created by Simon Kågedal Reimer on 2015-07-02.
//  Copyright (c) 2015 Simon Kågedal Reimer. All rights reserved.
//

#import "ViewController.h"
#import "SKRAttributedStringCreator.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *templateEditor;
@property (weak, nonatomic) IBOutlet UILabel *outputLabel;
@property (strong, nonatomic) SKRAttributedStringCreator *asCreator;

@end

@implementation ViewController

- (SKRAttributedStringCreator *)asCreator {
    if (!_asCreator) {
        NSDictionary *tags = @{@"red": @{NSForegroundColorAttributeName: [UIColor redColor]},
                               @"green": @{NSForegroundColorAttributeName: [UIColor greenColor]},
                               @"sweden": @{NSForegroundColorAttributeName: [UIColor yellowColor],
                                            NSBackgroundColorAttributeName: [UIColor blueColor]},
                               @"U": @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)}
                               };

        _asCreator = [[SKRAttributedStringCreator alloc]
                      initWithTags:tags];
    }
    return _asCreator;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *template = @"#red{Red} and #green(green). #green<#U<Nice!>>";
    self.templateEditor.text = template;
    [self updateTemplate:template];

    self.templateEditor.delegate = self;
}

- (void)viewDidLayoutSubviews
{
    [self.outputLabel sizeToFit];
}

- (void)updateTemplate:(NSString *)template
{
    self.outputLabel.attributedText = [self.asCreator attributedStringFromTemplate:template];
//     [self.outputLabel sizeToFit];
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateTemplate:textView.text];
}

@end
