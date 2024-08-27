//
//  NSData+BTDAdditions.h
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const BTDRSADecryptionErrorDomain;

@interface NSData (BTDAdditions)
/**
 @return A md5 string.
 */
- (nonnull NSString *)btd_md5String;
/**
 @return A sha1 string.
 */
- (nonnull NSString *)btd_sha1String;
/**

 @return A sha256 string.
 */
- (nonnull NSString *)btd_sha256String;

- (nullable NSData *)btd_aes256EncryptWithKey:(nonnull NSData *)key iv:(nullable NSData *)iv __attribute__((deprecated("Please use the AES API provided by BDDataDecorator.")));
- (nullable NSData *)btd_aes256DecryptWithkey:(nonnull NSData *)key iv:(nullable NSData *)iv __attribute__((deprecated("Please use the AES API provided by BDDataDecorator.")));

/**
 Convert a NSData to a hex string.
 
 @return A hex string.
 */
- (NSString *)btd_hexString;

/**
 Convert a NSData to a NSArray or a NSDictionary.

 @return These functions will return a NSArray or a NSDictionary. If an error happened, these would return nil.
 */
- (nullable id)btd_jsonValueDecoded;
- (nullable id)btd_jsonValueDecoded:(NSError * _Nullable __autoreleasing * _Nullable)error;

- (nullable NSArray *)btd_jsonArray;
- (nullable NSDictionary *)btd_jsonDictionary;

- (nullable NSArray *)btd_jsonArray:(NSError * _Nullable __autoreleasing * _Nullable)error;
- (nullable NSDictionary *)btd_jsonDictionary:(NSError * _Nullable __autoreleasing * _Nullable)error;

/// Use RSA algorithm to encrypt data.
+ (NSData *)btd_encryptData:(NSData *)data publicKey:(NSString *)pubKey error:(NSError **)error;
+ (NSData *)btd_encryptData:(NSData *)data privateKey:(NSString *)privKey error:(NSError **)error;

/// Use RSA algorithm to decrypt data.
+ (NSData *)btd_decryptData:(NSData *)data publicKey:(NSString *)pubKey error:(NSError **)error;
+ (NSData *)btd_decryptData:(NSData *)data privateKey:(NSString *)privKey error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
