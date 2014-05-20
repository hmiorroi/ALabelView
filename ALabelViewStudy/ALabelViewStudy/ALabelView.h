//
//  ALabelView.h
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


#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

enum {
  kALabelViewVirticalAlignmentModeTop = 0,
  kALabelViewVirticalAlignmentModeMiddle = 1,
  kALabelViewVirticalAlignmentModeBottom = 2
};
typedef NSInteger ALabelViewVirticalAlignmentMode;

enum {
    kALabelViewTruncateModeNone = 0,
    kALabelViewTruncateModeTrail = 1
};
typedef NSInteger ALabelViewTruncateMode;

@interface ALabelView : UIView

@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic) float lineHeight;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic) NSInteger numberOfLines;
@property (nonatomic) ALabelViewVirticalAlignmentMode virticalAlignment;
@property (nonatomic) ALabelViewTruncateMode truncateMode;
@property (nonatomic) BOOL indentBraketAtFirstLine;
@property (nonatomic) BOOL kernBrakets;

@property (readonly, getter = getTextBounds) CGSize textBounds;
@property (readonly, getter = getTextLocation) NSInteger textlocation;

@property (nonatomic, copy) NSString *trancateCharacters;
@property (nonatomic, copy) NSString *braketsMK;
@property (nonatomic, copy) NSString *braketsAK;
@property (nonatomic, copy) NSString *braketsKT;
@property (nonatomic, copy) NSString *braketsNK;
@property (nonatomic, copy) NSString *braketsGTKS;
@property (nonatomic, copy) NSString *braketsGMKS;

-(void)addAttribute:(NSString*)attribute value:(id)value range:(NSRange)range;
-(NSInteger)getTextLocation;

@end
