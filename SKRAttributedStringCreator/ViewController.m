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
                               @"blue": @{NSForegroundColorAttributeName: [UIColor blueColor]},
                               @"U": @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)}
                               };

        _asCreator = [[SKRAttributedStringCreator alloc]
                      initWithTags:tags];
    }
    return _asCreator;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.templateEditor.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.outputLabel.attributedText = [self.asCreator attributedStringFromTemplate:textView.text];
}

@end
