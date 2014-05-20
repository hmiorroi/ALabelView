//
//  ViewController.m
//  ALabelViewStudy
//
//  Copyright (c) 2014 hiroaki mori
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "ViewController.h"
#import "ALabelView.h"

@interface ViewController (){
  NSArray *articles;
  ALabelView *type;
  UILabel *label;
}

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  articles = [NSArray arrayWithObjects:@"また小使を呼んで、「さっきのバッタを持ってこい」と云ったら、「もう掃溜はきだめへ棄すててしまいましたが、拾って参りましょうか」と聞いた。",
              @"『吾輩は猫である』上篇自序　（新字新仮名、作品ID：47148）",
              @"「abcdあああ」（ああ（ああ）ああ｛あ］あ）。「あああ。」（ああ）：（ああああ）",
              nil];
    
  NSString *_t = [self getText];
  
  CATextLayer *cap1 = [[CATextLayer alloc] init];
  cap1.string = @"CoreText Text Drawing";
  cap1.fontSize = 16.0;
  cap1.foregroundColor = [UIColor redColor].CGColor;
  cap1.frame = CGRectMake(15, 50, 290, 50);
  [self.view.layer addSublayer:cap1];
  
  type = [[ALabelView alloc] initWithFrame:CGRectMake(15, 80, 290, 120)];
  type.text = _t;
  type.lineHeight = 24;
  type.font = [UIFont systemFontOfSize:16];
  type.numberOfLines = 3;
  type.kernBrakets = YES;
  type.virticalAlignment = kALabelViewVirticalAlignmentModeTop;
  type.kernBrakets = YES;
  type.truncateMode = kALabelViewTruncateModeTrail;
  [self.view addSubview:type];

  
  CATextLayer *cap2 = [[CATextLayer alloc] init];
  cap2.string = @"UILabel";
  cap2.fontSize = 16.0;
  cap2.foregroundColor = [UIColor redColor].CGColor;
  cap2.frame = CGRectMake(15, 180, 290, 50);
  [self.view.layer addSublayer:cap2];
  
  label = [[UILabel alloc] initWithFrame:CGRectMake(15, 200, 290, 90)];
  label.text = _t;
  label.numberOfLines = 3;
  label.lineBreakMode = UILineBreakModeTailTruncation;
  label.font = [UIFont systemFontOfSize:16];
  [self.view addSubview:label];
}

-(NSString*)getText {
  return [articles objectAtIndex:arc4random() % articles.count];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  NSString *t = [self getText];
  type.text = t;
  label.text = t;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
