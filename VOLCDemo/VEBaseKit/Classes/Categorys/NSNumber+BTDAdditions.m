//
//  NSNumber+BTDAdditions.m
//

#import "NSNumber+BTDAdditions.h"
#import "NSString+BTDAdditions.h"

@implementation NSNumber (BTDAdditions)

+ (NSNumber *)btd_numberWithString:(NSString *)string {
    NSString *str = [[string btd_stringByRemoveAllWhitespaceAndNewlineCharacters] lowercaseString];
    if (!str || !str.length) {
        return nil;
    }
    
    static NSDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dic = @{@"true" :   @(YES),
                @"yes" :    @(YES),
                @"false" :  @(NO),
                @"no" :     @(NO),
                @"nil" :    [NSNull null],
                @"null" :   [NSNull null],
                @"<null>" : [NSNull null]};
    });
    NSNumber *num = dic[str];
    if (num != nil) {
        if (num == (id)[NSNull null]) return nil;
        return num;
    }
    
    // hex number
    int sign = 0;
    if ([str hasPrefix:@"0x"]) sign = 1;
    else if ([str hasPrefix:@"-0x"]) { sign = -1; str = [str substringFromIndex:1]; }
    if (sign != 0) {
        NSScanner *scan = [NSScanner scannerWithString:str];
        unsigned num = -1;
        BOOL suc = [scan scanHexInt:&num];
        if (suc)
            return [NSNumber numberWithLong:((long)num * sign)];
        else
            return nil;
    }
    // normal number
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter numberFromString:string];
}

- (BOOL)btd_isNaN
{
    return isnan(self.doubleValue);
}

- (id)btd_safeJsonObject
{
    if (self.btd_isNaN) {
        return @"nan";
    } else {
        return self.copy;
    }
}

@end
