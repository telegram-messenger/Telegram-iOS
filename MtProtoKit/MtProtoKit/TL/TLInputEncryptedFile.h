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


@interface TLInputEncryptedFile : NSObject <TLObject>


@end

@interface TLInputEncryptedFile$inputEncryptedFileEmpty : TLInputEncryptedFile


@end

@interface TLInputEncryptedFile$inputEncryptedFileUploaded : TLInputEncryptedFile

@property (nonatomic) int64_t n_id;
@property (nonatomic) int32_t parts;
@property (nonatomic, retain) NSString *md5_checksum;
@property (nonatomic) int32_t key_fingerprint;

@end

@interface TLInputEncryptedFile$inputEncryptedFile : TLInputEncryptedFile

@property (nonatomic) int64_t n_id;
@property (nonatomic) int64_t access_hash;

@end

