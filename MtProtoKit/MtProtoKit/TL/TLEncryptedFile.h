/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLEncryptedFile : NSObject <TLObject>


@end

@interface TLEncryptedFile$encryptedFileEmpty : TLEncryptedFile


@end

@interface TLEncryptedFile$encryptedFile : TLEncryptedFile

@property (nonatomic) int64_t n_id;
@property (nonatomic) int64_t access_hash;
@property (nonatomic) int32_t size;
@property (nonatomic) int32_t dc_id;
@property (nonatomic) int32_t key_fingerprint;

@end

