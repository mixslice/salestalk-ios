//
// Created by Zhang Zeqing on 4/20/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

#import <ObjectiveSugar/NSArray+ObjectiveSugar.h>
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "NTTabBar.h"
#import "NTTabBarItem.h"

@interface NTTabBar()
@property (nonatomic, strong) NSArray *buttons;
@end

@implementation NTTabBar

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialize];
    }

    return self;
}

- (void)initialize {
    _selectedIndex = NSNotFound;
}

- (void)setItems:(NSArray *)items {
    _items = [items mutableCopy];

    _buttons = [_items map:^id(UITabBarItem *item) {
        NTTabBarItem *tabBarItem = [[NTTabBarItem alloc] initWithItem:item];

        [self addSubview:tabBarItem];
        return tabBarItem;
    }];

    [_buttons mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self);
        make.centerY.equalTo(self);
    }];

    [_buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
            if (!sender.isSelected) {
                [self setSelectedIndex:idx];
                if ([self.delegate respondsToSelector:@selector(tabBar:didSelectItemAtIndex:)]) {
                    [self.delegate tabBar:self didSelectItemAtIndex:idx];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(tabBar:didDoubleSelectItemAtIndex:)]) {
                    [self.delegate tabBar:self didDoubleSelectItemAtIndex:idx];
                }
            }
        }];

        if (idx == 0) {
            [button mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(_buttons);
                make.left.equalTo(@0);
            }];
        }
        else if (idx == _buttons.count - 1) {
            [button mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(((UIButton *) _buttons[idx - 1]).mas_right);
                make.right.equalTo(@0);
            }];
        }
        else {
            [button mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(((UIButton *) _buttons[idx - 1]).mas_right);
            }];
        }
    }];

    [self setNeedsLayout];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (_selectedIndex != selectedIndex) {
        _selectedIndex = selectedIndex;
        [self.buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
            button.selected = (selectedIndex == idx);
        }];
    }
}

@end