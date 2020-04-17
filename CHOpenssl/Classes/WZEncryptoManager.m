//
//  WZEncryptoManager.m
//  WZOpenSSLCrypt
//
//  Created by wang on 2019/12/30.
//

#import "WZEncryptoManager.h"
#import "OpenSSLAesCrypto.h"

@implementation WZEncryptoManager
+ (instancetype)manager{
    
    static WZEncryptoManager *manager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (void)encryptoFiles:(NSString *)sourceDir desDir:(NSString *)desDir deleteSource:(BOOL)isDelete
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:sourceDir];
    if (!fileExists) {
        return;
    }
    fileExists = [fileManager fileExistsAtPath:desDir];
    if (!fileExists) {
        [fileManager createDirectoryAtPath:desDir  withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *key = @"1234fcfsvte0000000000000000000000000000000000000000000000000000";
    NSString *iv = @"saf3t4gw3qd5t5e000000000000000000";
    NSArray<NSString *> *fileList = [fileManager contentsOfDirectoryAtPath:sourceDir error:nil];
    for (NSString *fileName in fileList) {
        NSString *cryptoFilePathTmp = [sourceDir stringByAppendingPathComponent:fileName];
        NSString *cryptoFile = [fileName stringByReplacingOccurrencesOfString:@".log" withString:@".lc"];
        NSString *cryptoFilePath = [desDir stringByAppendingPathComponent:cryptoFile];
        OpenSSL_AES256CBC_Encrypt_File(cryptoFilePathTmp, cryptoFilePath, key, iv);
        if (isDelete) {
            [fileManager removeItemAtPath:cryptoFilePathTmp error:nil];
        }
    }
    
    if (isDelete == NO) return;
    fileList = [fileManager contentsOfDirectoryAtPath:desDir error:nil];
    if (fileList.count < 20) return;
    
    while ([self fileSize:desDir] > 1000 * 60) { // 60M
        // 删除 5个log文件
        fileList = [fileManager contentsOfDirectoryAtPath:desDir error:nil];
        for (int idx = 5; idx > 0; idx --) {
            NSString *deleteTem = [sourceDir stringByAppendingPathComponent:fileList[fileList.count - idx]];
            [fileManager removeItemAtPath:deleteTem error:nil];
        }
    }
}

- (void)decryptoFiles:(NSString *)sourceDir desDir:(NSString *)desDir
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray<NSString *> *fileList = [fileManager contentsOfDirectoryAtPath:sourceDir error:nil];
    for (NSString *fileName in fileList) {
        if (![fileName containsString:@".lc"]) {
            continue;
        }
        NSString *cryptoFilePathTmp = [sourceDir stringByAppendingPathComponent:fileName];
        NSString *cryptoFile = [fileName stringByReplacingOccurrencesOfString:@".lc" withString:@".log"];
        NSString *cryptoFilePath = [desDir stringByAppendingPathComponent:cryptoFile];
        NSString *key = @"1234fcfsvte0000000000000000000000000000000000000000000000000000";
        NSString *iv = @"saf3t4gw3qd5t5e000000000000000000";
        OpenSSL_AES256CBC_Decrypt_File(cryptoFilePathTmp, cryptoFilePath, key, iv);
    }
}

- (unsigned long long)fileSize:(NSString *)dir
{
    // 总大小
    unsigned long long size = 0;
    NSFileManager *manager = [NSFileManager defaultManager];
    
    BOOL isDir = NO;
    BOOL exist = [manager fileExistsAtPath:dir isDirectory:&isDir];
    // 判断路径是否存在
    if (!exist) return size;
    if (isDir) { // 是文件夹
        NSDirectoryEnumerator *enumerator = [manager enumeratorAtPath:dir];
        for (NSString *subPath in enumerator) {
            NSString *fullPath = [dir stringByAppendingPathComponent:subPath];
            size += [manager attributesOfItemAtPath:fullPath error:nil].fileSize;
        }
    }else{ // 是文件
        size += [manager attributesOfItemAtPath:dir error:nil].fileSize;
    }
    long sizeKB = size/1000.f;
    return sizeKB;
}


@end
