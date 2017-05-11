#import "Reachability+RACExtensions.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation Reachability (RACExtensions)

+ (RACSignal *)rac_reachabilitySignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        Reachability *reach = [Reachability reachabilityForInternetConnection];
        reach.reachableBlock = ^(Reachability *reach) {
            [subscriber sendNext:reach];
        };
        reach.unreachableBlock = ^(Reachability *reach) {
            [subscriber sendNext:reach];
        };
        [reach startNotifier];
        
        return nil;
    }];
}

@end
