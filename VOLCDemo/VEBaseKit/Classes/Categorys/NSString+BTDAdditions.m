
#import "NSString+BTDAdditions.h"
#import <CommonCrypto/CommonDigest.h>
#import <CoreText/CTFramesetter.h>
#import "BTDMacros.h"
#import "NSURL+BTDAdditions.h"
#import "NSData+BTDAdditions.h"
#import "NSNumber+BTDAdditions.h"
#import "NSDictionary+BTDAdditions.h"
#import "NSURLComponents+BTDAdditions.h"

#if TARGET_OS_OSX
#define UIFont NSFont
#endif

@implementation NSString (BTDAdditions)

static BOOL _btd_fullyEncodeURLParams = NO;
static BTDURLParameterEncodeStrategy BTDStringParamsEncodeStrategy = BTDURLParameterEncodeStrategyDefault;
static BOOL BTDInvalidSchemeCompatible = NO;
static BOOL BTDFixMatchRegexEnabled = NO;

- (NSString *)btd_trimmed {
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [self stringByTrimmingCharactersInSet:set];
}

#pragma mark - crypto

- (NSString *)btd_md5String
{
    return [[self dataUsingEncoding:NSUTF8StringEncoding] btd_md5String];
}

- (NSString *)btd_sha256String
{
    return [[self dataUsingEncoding:NSUTF8StringEncoding] btd_sha256String];
}

- (NSString *)btd_sha1String
{
    return [[self dataUsingEncoding:NSUTF8StringEncoding] btd_sha1String];
}

+ (NSString *)btd_stringWithUUID
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    
    CFStringRef fullStr = CFUUIDCreateString(NULL, uuid);
    
    CFRelease(uuid);
    
    return (__bridge_transfer NSString *)fullStr;
}

+ (NSString *)btd_HMACMD5WithKey:(NSString *)key andData:(NSString *)data
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    const unsigned int blockSize = 64;
    char ipad[blockSize], opad[blockSize], keypad[blockSize];
    unsigned long keyLen = strlen(cKey);
    CC_MD5_CTX ctxt;
    if(keyLen > blockSize) {
        //CC_MD5(cKey, keyLen, keypad);
        CC_MD5_Init(&ctxt);
        CC_MD5_Update(&ctxt, cKey, (unsigned int)keyLen);
        CC_MD5_Final((unsigned char *)keypad, &ctxt);
        keyLen = CC_MD5_DIGEST_LENGTH;
    } else {
        memcpy(keypad, cKey, keyLen);
    }
    memset(ipad, 0x36, blockSize);
    memset(opad, 0x5c, blockSize);
    
    int i;
    for(i = 0; i < keyLen; i++) {
        ipad[i] ^= keypad[i];
        opad[i] ^= keypad[i];
    }
    
    CC_MD5_Init(&ctxt);
    CC_MD5_Update(&ctxt, ipad, blockSize);
    CC_MD5_Update(&ctxt, cData, (unsigned int)strlen(cData));
    unsigned char md5[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(md5, &ctxt);
    
    CC_MD5_Init(&ctxt);
    CC_MD5_Update(&ctxt, opad, blockSize);
    CC_MD5_Update(&ctxt, md5, CC_MD5_DIGEST_LENGTH);
    CC_MD5_Final(md5, &ctxt);
    
    const unsigned int hex_len = CC_MD5_DIGEST_LENGTH*2+2;
    char hex[hex_len];
    for(i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        snprintf(&hex[i*2], hex_len-i*2, "%02x", md5[i]);
    }
    
    NSData *HMAC = [[NSData alloc] initWithBytes:hex length:strlen(hex)];
    NSString * hash =[NSString stringWithUTF8String:[HMAC bytes]];
    return hash;
}

- (NSString *)btd_hexString {
    NSUInteger len = self.length;
    if (len == 0) {
        return @"";
    }
    unichar *chars = malloc(len * sizeof(unichar));
    [self getCharacters:chars];
    
    NSMutableString *hexString = [[NSMutableString alloc] init];
    
    for(NSUInteger i = 0; i < len; i++ )
    {
        [hexString appendString:[NSString stringWithFormat:@"%x", chars[i]]];
    }
    free(chars);
    
    return hexString;
}

- (NSString *)btd_base64EncodedString {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    if (data.length > 0) {
        return [data base64EncodedStringWithOptions:0];
    }
    return nil;
}

- (NSString *)btd_base64DecodedString {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:self options:0];
    if (data.length > 0) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (NSString *)btd_stringByRemoveAllCharactersInSet:(NSCharacterSet *)characterSet {
    return [[self componentsSeparatedByCharactersInSet:characterSet] componentsJoinedByString:@""];
}

- (NSString *)btd_stringByRemoveAllWhitespaceAndNewlineCharacters {
    return [self btd_stringByRemoveAllCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (CGRect)btd_boundingRectWithSize:(CGSize)size options:(NSStringDrawingOptions)options attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes {
#if TARGET_OS_IPHONE
    return [self boundingRectWithSize:size options:options attributes:attributes context:nil];
#else
    if (@available(macOS 10.11, *)) {
        return [self boundingRectWithSize:size options:options attributes:attributes context:nil];
    } else {
        return [self boundingRectWithSize:size options:options attributes:attributes];
    }
#endif
}

- (CGFloat)btd_heightWithFont:(UIFont *)font width:(CGFloat)maxWidth
{
    return [self btd_sizeWithFont:font width:maxWidth].height;
}

- (CGFloat)btd_widthWithFont:(UIFont *)font height:(CGFloat)maxHeight
{
    CGRect rect = [self btd_boundingRectWithSize:CGSizeMake(MAXFLOAT, maxHeight)
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:@{ NSFontAttributeName : font }];
    CGFloat width = ceil(rect.size.width);
    return width;
}

- (CGSize)btd_sizeWithFont:(UIFont *)font width:(CGFloat)maxWidth {
    return [self btd_sizeWithFont:font width:maxWidth maxLine:0];
}

- (CGSize)btd_sizeWithFont:(UIFont *)font width:(CGFloat)maxWidth maxLine:(NSInteger)maxLine {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
#if TARGET_OS_IPHONE
    CGFloat lineHeight = font.lineHeight;
#else
    CGFloat lineHeight = [[NSLayoutManager new] defaultLineHeightForFont:font];
#endif
    style.minimumLineHeight = lineHeight;
    style.maximumLineHeight = lineHeight;
    CGFloat maxHeight = maxLine ? maxLine * lineHeight : CGFLOAT_MAX;
    CGRect rect = [self btd_boundingRectWithSize:CGSizeMake(maxWidth, maxHeight)
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:@{NSFontAttributeName:font, NSParagraphStyleAttributeName:style}];
    return CGSizeMake(ceil(rect.size.width), ceil(rect.size.height));
}

- (NSString *)btd_stringByMergingContinuousNewLine {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\n{2,}+" options:NSRegularExpressionCaseInsensitive error:NULL];
    return [regex stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, self.length) withTemplate:@"\n"];
}

- (NSString *)btd_urlStringByAddingComponentString:(NSString *)componentString
{
    NSArray *array = nil;
    if (componentString && [componentString length] > 0) {
        array = @[componentString];
    }
    return [self btd_urlStringByAddingComponentArray:array];
}

- (NSString *)btd_urlStringByAddingComponentArray:(NSArray<NSString *> *)componentArray
{
    // trim
    NSMutableCharacterSet *trimCharacterSet = [NSMutableCharacterSet characterSetWithCharactersInString:@"/?&"];
    [trimCharacterSet formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *trimedString = [self stringByTrimmingCharactersInSet:trimCharacterSet];
    if (!trimedString || [trimedString length] == 0) {
        return nil;
    }
    
    if (!componentArray || componentArray.count == 0) {
        return trimedString;
    }
    // 组合？、&
    NSString *componentString = [componentArray componentsJoinedByString:@"&"];
    if ([trimedString rangeOfString:@"?"].location == NSNotFound) {
        return [trimedString stringByAppendingFormat:@"?%@", componentString];
    } else {
        return [trimedString stringByAppendingFormat:@"&%@", componentString];
    }
}

- (BOOL)btd_containsNumberOnly
{
    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    return [self rangeOfCharacterFromSet:notDigits].location == NSNotFound;
}

- (BOOL)btd_matchsRegex:(NSString *)regex
{
    if (BTD_isEmptyString(regex)) {
        return NO;
    }
    if (!BTDFixMatchRegexEnabled) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        return [predicate evaluateWithObject:self];
    }
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:regex options:0 error:nil];
    if (!regularExpression) {
        return NO;
    }
    NSUInteger matchCount = [regularExpression numberOfMatchesInString:self
                                                               options:NSMatchingReportProgress
                                                                 range:NSMakeRange(0, self.length)];
    return matchCount != 0;
}

- (void)btd_enumerateRegexMatches:(NSString *)regex options:(NSRegularExpressionOptions)options usingBlock:(void (^)(NSString *, NSRange, BOOL *))block
{
    if (regex.length == 0 || !block) return;
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:nil];
    if (!regex) return;
    [pattern enumerateMatchesInString:self options:kNilOptions range:NSMakeRange(0, self.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        block([self substringWithRange:result.range], result.range, stop);
    }];
}

- (id)btd_jsonValueDecoded
{
    NSError *error = nil;
    return [self btd_jsonValueDecoded:&error];
}

- (id)btd_jsonValueDecoded:(NSError *__autoreleasing *)error
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data btd_jsonValueDecoded:error];
}

- (NSArray *)btd_jsonArray
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data btd_jsonArray];
}

- (NSDictionary *)btd_jsonDictionary
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data btd_jsonDictionary];
}

- (NSArray *)btd_jsonArray:(NSError * _Nullable __autoreleasing *)error
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data btd_jsonArray:error];
}

- (NSDictionary *)btd_jsonDictionary:(NSError * _Nullable __autoreleasing *)error
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data btd_jsonDictionary:error];
}

- (NSNumber *)btd_numberValue
{
    return [NSNumber btd_numberWithString:self];
}

- (NSString *)btd_stringByURLEncode
{
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)self,
                                                                                 NULL, // characters to leave unescaped
                                                                                 CFSTR(":!*();@/&?+$,='"),
                                                                                 kCFStringEncodingUTF8);
}

- (NSString *)btd_stringByURLDecode
{
    CFStringEncoding en = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
    NSString *decoded = [self stringByReplacingOccurrencesOfString:@"+"
                                                        withString:@" "];
    decoded = (__bridge_transfer NSString *)
    CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
                                                            NULL,
                                                            (__bridge CFStringRef)decoded,
                                                            CFSTR(""),
                                                            en);
    return decoded;
}

- (NSString *)btd_urlStringByAddingParameters:(NSDictionary<NSString *,NSString *> *)parameters {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (NSString.btd_fullyEncodeURLParams) {
        return [self btd_urlStringByAddingParameters:parameters fullyEncoded:YES];
    }
#pragma clang diagnostic pop
    
    return [self btd_urlStringByAddingParameters:parameters strategy:NSString.btd_stringURLParamsEncodeStrategy];
}

- (NSString *)btd_urlStringByAddingParameters:(NSDictionary<NSString *,NSString *> *)parameters strategy:(BTDURLParameterEncodeStrategy)strategy {
    switch (strategy) {
        case BTDURLParameterEncodeStrategyDefault:
            return [self _btd_urlStringByAddingParameters:parameters];
        case BTDURLParameterEncodeStrategyEncodeByNSURLComponents:
            return [self btd_urlStringByAddingParametersEncodeByNSURLComponents:parameters];
        case BTDURLParameterEncodeStrategyNoEncode:
            return [self btd_urlStringByAddingParameters:parameters haveEncoded:YES];
        case BTDURLParameterEncodeStrategyEncode:
            return [self btd_urlStringByAddingParameters:parameters haveEncoded:NO];
        case BTDURLParameterEncodeStrategyFullyEncode:
            return [self btd_urlStringByAddingParametersFullyEncode:parameters];
    }
    
    return nil;
}

- (NSString *)btd_urlStringByAddingParameters:(NSDictionary<NSString *,NSString *> *)parameters fullyEncoded:(BOOL)fullyEncoded {
    if (!fullyEncoded) {
        return [self _btd_urlStringByAddingParameters:parameters];
    }
    return [self btd_urlStringByAddingParametersFullyEncode:parameters];
}

- (NSString *)btd_urlStringByAddingParametersFullyEncode:(NSDictionary<NSString *, NSString *> *)parameters {
    NSURLComponents *components = [self btd_URLComponents];
    if (!components) {
        return self;
    }
    
    NSMutableDictionary<NSString*, NSString*> *dict = [[self btd_queryParamDictDecoded] mutableCopy];
    [dict addEntriesFromDictionary:parameters];
    
    NSMutableArray<NSString *> *queryArray = [NSMutableArray new];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [queryArray addObject:[NSString stringWithFormat:@"%@=%@", ([key isKindOfClass:NSString.class]? ([key btd_stringByURLEncode]?: key) : key), ([obj isKindOfClass:NSString.class]? ([obj btd_stringByURLEncode]?: obj) : obj)]];
    }];
    
    components.percentEncodedQuery = queryArray.count > 0 ? [queryArray componentsJoinedByString:@"&"] : nil;
    
    return components.string;
}

- (NSString *)_btd_urlStringByAddingParameters:(NSDictionary<NSString *, NSString *> *)parameters
{
    NSURLComponents *components = [self btd_URLComponents];
    if (!components) {
        return self;
    }
    
    NSMutableDictionary<NSString*, NSString*> *dict = [[self btd_queryParamDict] mutableCopy];
    [dict addEntriesFromDictionary:parameters];
    
    NSMutableArray<NSString *> *queryArray = [NSMutableArray new];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [queryArray addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
    }];
    
    components.query = queryArray.count > 0 ? [queryArray componentsJoinedByString:@"&"] : nil;
    
    return components.string;
}

- (NSString *)btd_urlStringByAddingParametersEncodeByNSURLComponents:(NSDictionary<NSString *, NSString *> *)parameters
{
    NSURLComponents *components = [self btd_URLComponents];
    if (!components) {
        return self;
    }
    
    NSMutableDictionary<NSString*, NSString*> *dict = [[self btd_queryParamDictDecoded] mutableCopy];
    [dict addEntriesFromDictionary:parameters];
    
    NSMutableArray<NSString *> *queryArray = [NSMutableArray new];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [queryArray addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
    }];
    
    components.query = queryArray.count > 0 ? [queryArray componentsJoinedByString:@"&"] : nil;
    
    return components.string;
}

- (NSString *)btd_urlStringByAddingParameters:(NSDictionary<NSString *,NSString *> *)parameters haveEncoded:(BOOL)haveEncoded {
    if (parameters.count == 0) {
        return self;
    }
    NSURLComponents *components = [self btd_URLComponents];
    if (!components) {
        return self;
    }
    
    NSMutableDictionary<NSString*, NSString*> *allParam = [self btd_queryParamDict].mutableCopy;
    if (haveEncoded) {
        [allParam addEntriesFromDictionary:parameters];
    } else {
        [parameters enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            [allParam btd_setObject:([obj isKindOfClass:NSString.class]? ([obj btd_stringByURLEncode]?: obj) : obj) forKey:([key isKindOfClass:NSString.class]? ([key btd_stringByURLEncode]?: key) : key)];
        }];
    }
    
    NSMutableArray<NSString *> *queryArray = [NSMutableArray new];
    [allParam enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [queryArray addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
    }];
    components.percentEncodedQuery = queryArray.count > 0 ? [queryArray componentsJoinedByString:@"&"] : nil;
    return components.string;
}

- (NSString *)btd_urlStringByRemovingParameters:(NSArray<NSString *> *)parameters
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (NSString.btd_fullyEncodeURLParams) {
        return [self btd_urlStringByRemovingParametersFullyEncode:parameters];
    }
#pragma clang diagnostic pop
    
    return [self btd_urlStringByRemovingParameters:parameters strategy:NSString.btd_stringURLParamsEncodeStrategy];
}

- (NSString *)btd_urlStringByRemovingParameters:(NSArray<NSString *> *)parameters strategy:(BTDURLParameterEncodeStrategy)strategy {
    switch (strategy) {
        case BTDURLParameterEncodeStrategyDefault:
            return [self _btd_urlStringByRemovingParameters:parameters];
        case BTDURLParameterEncodeStrategyEncodeByNSURLComponents:
            return [self btd_urlStringByRemovingParametersDecodeFirst:parameters];
        case BTDURLParameterEncodeStrategyNoEncode:
            return [self btd_urlStringByRemovingParameters:parameters haveEncoded:YES];
        case BTDURLParameterEncodeStrategyEncode:
            return [self btd_urlStringByRemovingParameters:parameters haveEncoded:NO];
        case BTDURLParameterEncodeStrategyFullyEncode:
            return [self btd_urlStringByRemovingParametersFullyEncode:parameters];
    }
    
    return nil;
}

- (NSString *)btd_urlStringByRemovingParameters:(NSArray<NSString *> *)parameters fullyEncoded:(BOOL)fullyEncoded {
    if (!fullyEncoded) {
        return [self _btd_urlStringByRemovingParameters:parameters];
    }
    return [self btd_urlStringByRemovingParametersFullyEncode:parameters];
}

- (NSString *)btd_urlStringByRemovingParametersFullyEncode:(NSArray<NSString *> *)parameters {
    NSURLComponents *components = [self btd_URLComponents];
    if (!components) {
        return self;
    }
    
    NSMutableDictionary<NSString*, NSString*> *dict = [[self btd_queryParamDictDecoded] mutableCopy];
    [parameters enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([dict objectForKey:obj]) {
            [dict removeObjectForKey:obj];
        }
    }];
    
    NSMutableArray<NSString *> *queryArray = [NSMutableArray new];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [queryArray addObject:[NSString stringWithFormat:@"%@=%@", ([key isKindOfClass:NSString.class]? ([key btd_stringByURLEncode]?: key) : key), ([obj isKindOfClass:NSString.class]? ([obj btd_stringByURLEncode]?: obj) : obj)]];
    }];
    
    components.percentEncodedQuery = queryArray.count > 0 ? [queryArray componentsJoinedByString:@"&"] : nil;
    
    return components.string;
}

- (NSString *)_btd_urlStringByRemovingParameters:(NSArray<NSString *> *)parameters
{
    NSURLComponents *components = [self btd_URLComponents];
    if (!components) {
        return self;
    }
    
    NSMutableDictionary<NSString*, NSString*> *dict = [[self btd_queryParamDict] mutableCopy];
    [parameters enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([dict objectForKey:obj]) {
            [dict removeObjectForKey:obj];
        }
    }];
    
    NSMutableArray<NSString *> *queryArray = [NSMutableArray new];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [queryArray addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
    }];
    
    components.query = queryArray.count > 0 ? [queryArray componentsJoinedByString:@"&"] : nil;
    
    return components.string;
}

- (NSString *)btd_urlStringByRemovingParametersDecodeFirst:(NSArray<NSString *> *)parameters
{
    NSURLComponents *components = [self btd_URLComponents];
    if (!components) {
        return self;
    }
    
    NSMutableDictionary<NSString*, NSString*> *dict = [[self btd_queryParamDictDecoded] mutableCopy];
    [parameters enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([dict objectForKey:obj]) {
            [dict removeObjectForKey:obj];
        }
    }];
    
    NSMutableArray<NSString *> *queryArray = [NSMutableArray new];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [queryArray addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
    }];
    
    components.query = queryArray.count > 0 ? [queryArray componentsJoinedByString:@"&"] : nil;
    
    return components.string;
}


- (NSString *)btd_urlStringByRemovingParameters:(NSArray<NSString *> *)parameters haveEncoded:(BOOL)haveEncoded {
    if (parameters.count == 0) {
        return self;
    }
    NSURLComponents *components = [self btd_URLComponents];
    if (!components) {
        return self;
    }
    
    NSMutableDictionary<NSString*, NSString*> *dict = [self btd_queryParamDict].mutableCopy;
    [parameters enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (haveEncoded) {
            [dict removeObjectForKey:obj];
        } else {
            [dict removeObjectForKey:[obj btd_stringByURLEncode]];
        }
    }];
    
    NSMutableArray<NSString *> *queryArray = [NSMutableArray new];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [queryArray addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
    }];
    components.percentEncodedQuery = queryArray.count > 0 ? [queryArray componentsJoinedByString:@"&"] : nil;
    return components.string;
}

#pragma mark - Parse

- (NSArray<NSString *> *)btd_pathComponentArray
{
    NSString *encodedString = [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (!encodedString) {
        return nil;
    }
    
    NSString *path = [encodedString btd_path];
    if (!path) {
        return nil;
    }
    
    NSMutableArray<NSString *> *resultPathComponentArray = [NSMutableArray new];
    NSArray *pathComponents = [path componentsSeparatedByString:@"/"];
    for (NSString *pathItem in pathComponents) {
        [resultPathComponentArray addObject:[pathItem stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    
    return resultPathComponentArray;
}

- (NSDictionary<NSString*, NSString*> *)btd_queryParamDict
{
    return [self _btd_queryParamDictDecoded:NO];
}

- (NSDictionary<NSString*, NSString*> *)btd_queryParamDictDecoded
{
    return [self _btd_queryParamDictDecoded:YES];
}

- (NSDictionary<NSString *,NSString *> *)_btd_queryParamDictDecoded:(BOOL)decoded {
    NSString *queryString = [BTDCreateUrl(self) query];
    if (!queryString) {
        return [NSDictionary dictionary];
    }
    
    NSMutableDictionary<NSString*, NSString*> *queryDict = [NSMutableDictionary new];
    NSArray<NSString *> *queryArray = [queryString componentsSeparatedByString:@"&"];
    for (NSString *queryItem in queryArray) {
        NSArray<NSString *> *pair = [queryItem componentsSeparatedByString:@"="];
        if (pair.count < 2
            || !pair[0] || [pair[0] length] == 0
            || !pair[1] || [pair[1] length] == 0) {
            continue;
        }
        //
        NSString *key = pair[0];
        NSString *value = pair[1];
        if (key && [key length] > 0 && value && [value length] > 0) {
            if (decoded) {
                [queryDict setObject:([value btd_stringByURLDecode] ?: value) forKey:([key btd_stringByURLDecode] ?: key)];
            } else {
                [queryDict setObject:value forKey:key];
            }
        }
    }
    
    if (queryDict.count == 0) {
        return [NSDictionary dictionary];
    }
    
    return [queryDict copy];
}

- (NSString *)btd_scheme
{
    return [BTDCreateUrl(self) scheme];
}

- (NSString *)btd_path
{
    NSString *encodedString = [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (!encodedString) {
        return nil;
    }
    
    NSArray<NSString *> *urlComponents = [encodedString componentsSeparatedByString:@"://"];
    if (urlComponents.count < 2 || !urlComponents[1] || [urlComponents[1] length] == 0) {
        return nil;
    }
    
    urlComponents = [urlComponents[1] componentsSeparatedByString:@"?"];
    NSString *path = urlComponents[0];
    if ([path hasSuffix:@"/"]) {
        path = [path substringToIndex:([path length] - 1)];
    }
    
    if ([path length] == 0) {
        return nil;
    }
    
    return [path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)btd_prependingLibraryPath {
    NSString *libraryDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    return [libraryDir stringByAppendingPathComponent:self];
}

- (NSString *)btd_prependingCachePath {
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    return [cacheDir stringByAppendingPathComponent:self];
}

- (NSString *)btd_prependingDocumentsPath {
    NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [documentDir stringByAppendingPathComponent:self];
}

- (NSString *)btd_prependingTemporaryPath {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:self];
}

+ (BOOL)btd_fullyEncodeURLParams {
    return _btd_fullyEncodeURLParams;
}

+ (void)setBtd_fullyEncodeURLParams:(BOOL)btd_fullyEncodeURLParams {
    _btd_fullyEncodeURLParams = btd_fullyEncodeURLParams;
}

+ (BTDURLParameterEncodeStrategy)btd_stringURLParamsEncodeStrategy {
    return BTDStringParamsEncodeStrategy;
}

+ (void)setBtd_stringURLParamsEncodeStrategy:(BTDURLParameterEncodeStrategy)btd_stringURLParamsEncodeStrategy {
    BTDStringParamsEncodeStrategy = btd_stringURLParamsEncodeStrategy;
}

+ (BOOL)btd_invalidSchemeCompatible {
    return BTDInvalidSchemeCompatible;
}

+ (void)setBtd_invalidSchemeCompatible:(BOOL)btd_invalidSchemeCompatible {
    BTDInvalidSchemeCompatible = btd_invalidSchemeCompatible;
}

+ (BOOL)btd_fixMatchRegexEnabled {
    return BTDFixMatchRegexEnabled;
}

+ (void)setBtd_fixMatchRegexEnabled:(BOOL)btd_fixMatchRegexEnabled {
    BTDFixMatchRegexEnabled = btd_fixMatchRegexEnabled;
}

- (NSURLComponents *)btd_URLComponents {
    if (NSString.btd_invalidSchemeCompatible) {
        return [NSURLComponents btd_componentsWithString:self];
    }
    return [NSURLComponents componentsWithString:self];
}

- (NSRange)btd_rangeOfString:(NSString *)searchString options:(NSStringCompareOptions)mask range:(NSRange)rangeOfReceiverToSearch {
    return [self btd_rangeOfString:searchString options:mask range:rangeOfReceiverToSearch locale:nil];
}

- (NSRange)btd_rangeOfString:(NSString *)searchString options:(NSStringCompareOptions)mask range:(NSRange)rangeOfReceiverToSearch locale:(NSLocale *)locale {
    if (searchString.length == 0) {
        return NSMakeRange(NSNotFound, 0);
    }
    
    NSRange fixedRange = [self btd_validRange:rangeOfReceiverToSearch];
    if (fixedRange.location == NSNotFound) {
        return fixedRange;
    }
    return [self rangeOfString:searchString options:mask range:fixedRange locale:locale];
}

- (NSString *)btd_substringFromIndex:(NSUInteger)from {
    return from >= self.length ? @"" : [self substringFromIndex:from];
}

- (NSString *)btd_substringToIndex:(NSUInteger)to {
    return to >= self.length ? self.copy : [self substringToIndex:to];
}

- (NSString *)btd_substringWithRange:(NSRange)range {
    NSRange fixedRange = [self btd_validRange:range];
    if (fixedRange.location == NSNotFound) {
        return @"";
    }
    return [self substringWithRange:fixedRange];
}

- (NSRange)btd_validRange:(NSRange)range {
    if (range.length == 0 || range.location >= self.length) {
        return NSMakeRange(NSNotFound, 0);
    }
    NSUInteger tailLength = self.length - range.location;
    if (range.length > tailLength || NSMaxRange(range) < range.location) {
        range.length = tailLength;
    }
    return range;
}

@end

@implementation NSMutableString (BTDAdditions)

- (void)btd_appendString:(NSString *)aString {
    if (aString.length != 0) {
        [self appendString:aString];
    }
}

- (void)btd_insertString:(NSString *)aString atIndex:(NSUInteger)loc {
    if (aString.length == 0 || loc > self.length) {
        return;
    }
    [self insertString:aString atIndex:loc];
}

- (void)btd_replaceCharactersInRange:(NSRange)range withString:(NSString *)aString {
    if (aString.length == 0 || range.location > self.length) {
        return;
    }
    NSUInteger ValidLength = self.length - range.location;
    if (range.length > ValidLength || NSMaxRange(range) < range.location) {
        range.length = ValidLength;
    }
    [self replaceCharactersInRange:range withString:aString];
}

- (void)btd_deleteCharactersInRange:(NSRange)range {
    NSRange fixedRange = [self btd_validRange:range];
    if (fixedRange.location == NSNotFound) {
        return;
    }
    [self deleteCharactersInRange:fixedRange];
}

@end

@implementation NSAttributedString (BTDToBeDeprecated)

- (CGFloat)btd_heightWithWidth:(CGFloat)maxWidth
{
    if (!self) {
        return 0;
    }
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self);
    
    CGSize targetSize = CGSizeMake(maxWidth, CGFLOAT_MAX);
    CGSize fitSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [self length]), NULL, targetSize, NULL);
    
    CFRelease(framesetter);
    
    return ceilf(fitSize.height);
}

@end
