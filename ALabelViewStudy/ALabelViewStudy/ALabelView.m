//
//  ALabelView.m
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


#import "ALabelView.h"

@implementation ALabelView {
  NSMutableAttributedString *_attributedString;
  NSMutableDictionary *_attributes;
  CTTypesetterRef _typesetter;
  NSMutableArray *_lines;
  NSMutableArray *_lineOffsets;
  CGPoint _linePosition;
  CGSize _textBounds;
  NSInteger _textlocation;
  BOOL _needsInitAttributedString;
  BOOL _needsInitLines;
  BOOL _needsInitTypesetter;
}

-(id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if(self){
    self.backgroundColor = [UIColor clearColor];
    
    _lines = [[NSMutableArray alloc] init];
    _lineOffsets = [[NSMutableArray alloc] init];
    _attributes = [[NSMutableDictionary alloc] init];
    
    _virticalAlignment = kALabelViewVirticalAlignmentModeTop;
    _trancateCharacters = @"...";
    _braketsMK = @"｛［「『（｟〈《〔〘【〖　";
    _braketsAK = @"｝］」』）｠〉》〕〙】〗　";
    _braketsKT = @"、，。．";
    _braketsNK = @"・：；！";
    _indentBraketAtFirstLine = NO;
    
    _text = @"";
    _font = [UIFont systemFontOfSize:16];
    _textColor = [UIColor blackColor];
    _numberOfLines = 0;
    [self setNeedsInitAttributedString];
  }
  return self;
}

-(void)dealloc {
  if(_typesetter){
    CFRelease(_typesetter);
    _typesetter = NULL;
  }
}


#pragma mark - Setter

-(void)setFrame:(CGRect)frame {
  if(!CGRectEqualToRect(self.frame, frame)){
    [super setFrame:frame];
    [self setNeedsInitAttributedString];
  }
}

-(void)setText:(NSString *)aText {
  if(![_text isEqualToString:aText]){
    _text = aText != nil ? aText : @"";
    [self setNeedsInitAttributedString];
  }
}

-(void)setFont:(UIFont *)aFont {
  if(_font != aFont){
    _font = aFont;
    if(!_lineHeight){
      _lineHeight = (int)(_font.pointSize * 1.4);
    }
    [self setNeedsInitAttributedString];
  }
}

-(void)setLineHeight:(float)aLineHeight {
  if(_lineHeight != aLineHeight){
    _lineHeight = aLineHeight;
    [self setNeedsDisplay];
  }
}

-(void)setTextColor:(UIColor *)aTextColor {
  if(_textColor != aTextColor){
    _textColor = aTextColor;
    [self setNeedsInitAttributedString];
  }
}

-(void)setNumberOfLines:(NSInteger)aNumberOfLines {
  if(_numberOfLines != aNumberOfLines){
    _numberOfLines = aNumberOfLines;
    [self setNeedsInitLines];
  }
}

#pragma mark - Getter

-(CGSize)getTextBounds {
  CGSize size;
  [self initAttributedString];
  [self initTypesetter];
  [self initLines];
  if(_lines.count == 0){
    size = CGSizeMake(0, 0);
  }else{
    float h = (_lines.count - 1) * self.lineHeight + self.font.pointSize + (self.font.descender * -1);
    size = CGSizeMake(self.frame.size.width, h);
  }
  return size;
}

-(NSInteger)getTextLocation {
  [self initAttributedString];
  [self initTypesetter];
  [self initLines];
  return _textlocation;
}


#pragma mark - Typesetting

-(float)getFirstLinePosition {
  switch (self.virticalAlignment) {
    case kALabelViewVirticalAlignmentModeTop:
      return 0.0;
      break;
    case kALabelViewVirticalAlignmentModeMiddle:
      return (self.frame.size.height - [self getTextBounds].height + (self.font.descender/2))/2;
      break;
    case kALabelViewVirticalAlignmentModeBottom:
      return self.frame.size.height - [self getTextBounds].height;
      break;
    default:
      return 0.0;
      break;
  }
}

-(NSInteger)getNumberOfLinesInFrame {
  float n = (self.frame.size.height + self.font.descender - self.font.ascender) / self.lineHeight;
  int l = (int)n + 1;
  return (self.numberOfLines == 0)? l : MIN(l, self.numberOfLines);
}

-(float)getTruncateOffset {
  return [self.trancateCharacters sizeWithFont:self.font].width;
}

-(BOOL)isMK:(NSString *)aChar {
  if([aChar isEqualToString:@"　"]) return NO;
  NSError *error;
  NSString *pattern = [NSString stringWithFormat:@"[%@]", self.braketsMK];
  NSRegularExpression *brackets = [NSRegularExpression regularExpressionWithPattern: pattern options:0 error:&error];
  if(!error){
    NSArray *arr = [brackets matchesInString:aChar options:0 range:NSMakeRange(0, aChar.length)];
    if(arr.count > 0) return YES;
  }
  return NO;
}

-(float)getLineheadOffset:(NSString*)linehead {
  float offset = 0;
  if([self isMK:linehead]){
    offset = self.font.pointSize / 2;
  }
  return offset;
}

-(BOOL)trancateWithRage:(NSRange)aRange width:(float)aWidth {
  NSInteger allStringLength = _attributedString.length;
  NSInteger max = [self getNumberOfLinesInFrame];
  if(_lines.count >= max && aRange.location < allStringLength) {
    [_lines removeLastObject];
    aRange.location -= aRange.length;
    float w = aWidth - [self getTruncateOffset];
    CFIndex count = CTTypesetterSuggestLineBreak(_typesetter, aRange.location, w);
    NSInteger c = aRange.location + count;
    
    _textlocation = c;
    [_attributedString deleteCharactersInRange:NSMakeRange(c, allStringLength - c)];
    [_attributedString replaceCharactersInRange:NSMakeRange(c, 0) withString:self.trancateCharacters];
    [_lines addObject:[NSValue valueWithRange:NSMakeRange(aRange.location, count + self.trancateCharacters.length)]];
    return YES;
  }
  return NO;
}


-(void)setKerning:(NSMutableAttributedString*)aAttributedString {
  NSError *error;
  NSString *pattern = [NSString stringWithFormat:@"(([%@]{1,})([%@]{1,}))|([%@%@]{1,}[%@%@%@]{1,})|([%@]{2,})|([%@][%@])|([%@]{2,})",
                    self.braketsAK, self.braketsMK,
                    self.braketsAK, self.braketsKT,  self.braketsMK, self.braketsKT, self.braketsNK,
                    self.braketsMK,
                    self.braketsNK, self.braketsMK,
                    self.braketsNK];
  NSRegularExpression *brackets = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
  
  if(!error){
    id block = ^(NSTextCheckingResult *match, NSMatchingFlags flag, BOOL *stop){
      NSRange nr = [match rangeAtIndex:0];
      if(nr.length > 1){
        float _kern = self.font.pointSize/2 * -1;
        nr.length = nr.length -1;
        [aAttributedString addAttribute:(NSString*)kCTKernAttributeName value:[NSNumber numberWithFloat:_kern] range:nr];
      }
    };
    
    [brackets enumerateMatchesInString:[aAttributedString string] options:0 range:NSMakeRange(0, aAttributedString.length) usingBlock:block];
  }
}


#pragma mark - Flag initialize

-(void)setNeedsInitAttributedString {
  _needsInitAttributedString = YES;
  [self setNeedsInitTypesetter];
}

-(void)setNeedsInitTypesetter {
  _needsInitTypesetter = YES;
  [self setNeedsInitLines];
}

-(void)setNeedsInitLines {
  _needsInitLines = YES;
  [self setNeedsDisplay];
}


#pragma mark - Initialize

-(void)addAttribute:(NSString *)attribute value:(id)value range:(NSRange)range {
  NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                       value, @"value",
                       [NSValue valueWithRange:range], @"range",
                       nil];
  [_attributes setObject:dic forKey:attribute];
}

-(void)initAttributedString {
  if(!_needsInitAttributedString) return;
  _attributedString = NULL;
  CTFontRef ctfont = CTFontCreateWithName((__bridge CFStringRef)self.font.fontName, self.font.pointSize, NULL);
  NSMutableDictionary *attr = [[NSMutableDictionary alloc] init];
  [attr setObject:(__bridge id)ctfont forKey:(NSString *)kCTFontAttributeName];
  [attr setObject:(id)self.textColor.CGColor forKey:(NSString *)kCTForegroundColorAttributeName];
  _attributedString = [[NSMutableAttributedString alloc] initWithString:self.text attributes:attr];
  CFRelease(ctfont);
  
  for (NSString* key in _attributes) {
    NSDictionary *dic = [_attributes objectForKey:key];
    [_attributedString addAttribute:key value:[dic objectForKey:@"value"] range:[[dic objectForKey:@"range"] rangeValue]];
  }
  
  if(self.kernBrakets) [self setKerning:_attributedString];
  
  _needsInitAttributedString = NO;
}

-(void)initTypesetter {
  if(!_needsInitTypesetter) return;
  if(_typesetter){
    CFRelease(_typesetter);
    _typesetter = NULL;
  }
  _typesetter = CTTypesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_attributedString);
  _linePosition = CGPointMake(0, 0);
  _needsInitTypesetter = NO;
}


-(void)initLines {
  if(!_needsInitLines) return;
  [_lines removeAllObjects];
  [_lineOffsets removeAllObjects];
  _textlocation = 0;
  NSInteger _length = _attributedString.length;
  float _with = self.frame.size.width;
  
  while (_textlocation < _length){
    NSString *linehead = [_attributedString.string substringWithRange:NSMakeRange(_textlocation, 1)];
    float offset = [self getLineheadOffset:linehead];
    if(_lines.count == 0 && self.indentBraketAtFirstLine) offset = 0;
    [_lineOffsets addObject:[NSNumber numberWithFloat:offset]];
    if([linehead isEqualToString:@"　"] && _textlocation != 0) _textlocation += 1;
    CFIndex count = CTTypesetterSuggestLineBreak(_typesetter, _textlocation, _with + offset);
    [_lines addObject:[NSValue valueWithRange:NSMakeRange(_textlocation, count)]];
    _textlocation += count;
    
    if(self.truncateMode == kALabelViewTruncateModeTrail){
      if([self trancateWithRage:NSMakeRange(_textlocation, count) width:_with]){
        [self setNeedsInitTypesetter];
        [self initTypesetter];
        break;
      }
    }
  }
  
  _needsInitLines = NO;
}


#pragma mark - Draw text

-(void)setType:(CGContextRef)context{
  if(!_typesetter) return;
  _linePosition.y = [self getFirstLinePosition];
  CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1, -1));
  CGContextSetTextPosition(context, _linePosition.x, _linePosition.y);
  NSInteger limit = _lines.count;

  for (int i = 0; i < limit; i++) {
    if(i==0){
      _linePosition.y += self.font.pointSize;
    }else{
      _linePosition.y += self.lineHeight;
    }
    NSRange range = [[_lines objectAtIndex:i] rangeValue];
    float offset = [[_lineOffsets objectAtIndex:i] floatValue];
    CGContextSetTextPosition(context, _linePosition.x - offset, _linePosition.y);
    CTLineRef ctline = CTTypesetterCreateLine(_typesetter, CFRangeMake(range.location, range.length));
    CTLineDraw(ctline, context);
    CFRelease(ctline);
  }
  
  CFRelease(_typesetter);
  _typesetter = NULL;
  [self setNeedsInitTypesetter];
}

-(void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);
  [self initAttributedString];
  [self initTypesetter];
  [self initLines];
  [self setType:context];
  CGContextRestoreGState(context);
}


#pragma mark - Accessibility

-(BOOL)isAccessibilityElement {
  return YES;
}

-(NSString*)accessibilityLabel {
  return  self.text;
}

-(UIAccessibilityTraits)accessibilityTraits {
  return UIAccessibilityTraitStaticText;
}

@end

