#import <Reachability/Reachability.h>

@class RACSignal;

@interface Reachability (RACExtensions)

+ (RACSignal *)rac_reachabilitySignal;

@end
