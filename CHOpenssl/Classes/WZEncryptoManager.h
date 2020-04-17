//
//  WZEncryptoManager.h
//  WZOpenSSLCrypt
//
//  Created by wang on 2019/12/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WZEncryptoManager : NSObject

+ (instancetype)manager;

- (void)encryptoFiles:(NSString *)sourceDir desDir:(NSString *)desDir deleteSource:(BOOL)isDelete;

- (void)decryptoFiles:(NSString *)sourceDir desDir:(NSString *)desDir;

@end

NS_ASSUME_NONNULL_END
