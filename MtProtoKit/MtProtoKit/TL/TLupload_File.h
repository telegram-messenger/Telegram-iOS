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

@class TLstorage_FileType;

@interface TLupload_File : NSObject <TLObject>

@property (nonatomic, retain) TLstorage_FileType *type;
@property (nonatomic) int32_t mtime;
@property (nonatomic, retain) NSData *bytes;

@end

@interface TLupload_File$upload_file : TLupload_File


@end

