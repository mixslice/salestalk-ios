//
// Created by Zhang Zeqing on 4/19/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import "NTTextcodeField.h"


@interface NTTextcodeField ()
@property(strong, nonatomic) NSMutableString *mutableTextcode;
@property(strong, nonatomic) NSRegularExpression *nonDigitRegularExpression;
@end

@implementation NTTextcodeField

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _initialize];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self _initialize];
    }
    return self;
}

- (void)_initialize {
    _maximumLength = 4;
    _dotSize = CGSizeMake(18.0f, 19.0f);
    _font = [UIFont boldSystemFontOfSize:24];
    _dotSpacing = 25.0f;
    _lineHeight = 3.0f;
    _dotColor = [UIColor whiteColor];
    self.keyboardType = UIKeyboardTypeNumberPad;

    self.backgroundColor = [UIColor clearColor];

    _mutableTextcode = [[NSMutableString alloc] initWithCapacity:4];

    [self addTarget:self action:@selector(didTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
}

- (NSRegularExpression *)nonDigitRegularExpression {
    if (nil == _nonDigitRegularExpression) {
        _nonDigitRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"[^0-9]+" options:0 error:nil];
    }
    return _nonDigitRegularExpression;
}

- (NSString *)textcode {
    return self.mutableTextcode;
}

- (void)setTextcode:(NSString *)textcode {
    if (textcode) {
        if (textcode.length > self.maximumLength) {
            textcode = [textcode substringWithRange:NSMakeRange(0, self.maximumLength)];
        }
        self.mutableTextcode = [NSMutableString stringWithString:textcode];
    } else {
        self.mutableTextcode = [NSMutableString string];
    }

    [self setNeedsDisplay];
}

#pragma mark - UIKeyInput

- (BOOL)hasText {
    return (self.mutableTextcode.length > 0);
}

- (void)insertText:(NSString *)text {
    if (!self.enabled) {
        return;
    }

    if (self.keyboardType == UIKeyboardTypeNumberPad) {
        text = [self.nonDigitRegularExpression stringByReplacingMatchesInString:text options:0 range:NSMakeRange(0, text.length) withTemplate:@""];
    }

    if (text.length == 0) {
        return;
    }

    NSInteger newLength = self.mutableTextcode.length + text.length;
    if (newLength > self.maximumLength) {
        return;
    }

    if ([self.delegate respondsToSelector:@selector(textcodeField:shouldInsertText:)]) {
        if (![self.delegate textcodeField:self shouldInsertText:text]) {
            return;
        }
    }

    [self.mutableTextcode appendString:text];

    [self setNeedsDisplay];

    if (newLength == self.maximumLength && [self.delegate respondsToSelector:@selector(textcodeFieldDidFinishInsert:)]) {
        [self.delegate textcodeFieldDidFinishInsert:self];
    }

    [self sendActionsForControlEvents:UIControlEventEditingChanged];
}

- (void)deleteBackward {
    if (!self.enabled) {
        return;
    }

    if ([self.delegate respondsToSelector:@selector(textcodeFieldShouldDeleteBackward:)]) {
        if ([self.delegate textcodeFieldShouldDeleteBackward:self] == NULL) {
            return;
        }
    }

    if (self.mutableTextcode.length == 0) {
        return;
    }

    [self.mutableTextcode deleteCharactersInRange:NSMakeRange(self.mutableTextcode.length - 1, 1)];

    [self setNeedsDisplay];

    [self sendActionsForControlEvents:UIControlEventEditingChanged];
}

- (UITextAutocapitalizationType)autocapitalizationType {
    return UITextAutocapitalizationTypeNone;
}

- (UITextAutocorrectionType)autocorrectionType {
    return UITextAutocorrectionTypeNo;
}

- (UITextSpellCheckingType)spellCheckingType {
    return UITextSpellCheckingTypeNo;
}

- (BOOL)enablesReturnKeyAutomatically {
    return YES;
}

- (UIKeyboardAppearance)keyboardAppearance {
    return UIKeyboardAppearanceDefault;
}

- (UIReturnKeyType)returnKeyType {
    return UIReturnKeyDone;
}

- (BOOL)isSecureTextEntry {
    return NO;
}

#pragma mark - UIView

- (CGSize)contentSize {
    return CGSizeMake(self.maximumLength * _dotSize.width + (self.maximumLength - 1) * _dotSpacing,
            _dotSize.height);
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGSize contentSize = [self contentSize];

    CGPoint origin = CGPointMake(floorf((self.frame.size.width - contentSize.width) * 0.5f),
            floorf((self.frame.size.height - contentSize.height) * 0.5f));

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.dotColor.CGColor);

    for (NSUInteger i = 0; i < self.maximumLength; i++) {

        if (i < self.mutableTextcode.length) {
            // draw circle
            NSString *character = [_mutableTextcode substringWithRange:NSMakeRange(i, 1)];
            NSDictionary *attributes = @{
                    NSFontAttributeName : _font,
                    NSForegroundColorAttributeName : _dotColor
            };
            CGRect charRect = [character boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                    options:NSStringDrawingUsesLineFragmentOrigin
                                 attributes:attributes
                                    context:nil];
            CGPoint charPoint = CGPointMake(origin.x + self.dotSize.width * 0.5f, origin.y + self.dotSize.height * 0.5f);
            charPoint.x -= charRect.size.width * 0.5;
            charPoint.y -= charRect.size.height * 0.5;

            [character drawAtPoint:charPoint withAttributes:attributes];
        } else {
            // draw line
            CGRect lineFrame = CGRectMake(origin.x, origin.y + floorf((self.dotSize.height - self.lineHeight) * 0.5f),
                    self.dotSize.width, self.lineHeight);
            CGContextFillRect(context, lineFrame);
        }

        origin.x += (self.dotSize.width + self.dotSpacing);
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self contentSize];
}

#pragma mark - UIResponder

- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - Actions

- (void)didTouchUpInside:(id)sender {
    [self becomeFirstResponder];
}


@end