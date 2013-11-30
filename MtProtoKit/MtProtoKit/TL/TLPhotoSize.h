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

@class TLFileLocation;

@interface TLPhotoSize : NSObject <TLObject>

@property (nonatomic, retain) NSString *type;

@end

@interface TLPhotoSize$photoSizeEmpty : TLPhotoSize


@end

@interface TLPhotoSize$photoSize : TLPhotoSize

@property (nonatomic, retain) TLFileLocation *location;
@property (nonatomic) int32_t w;
@property (nonatomic) int32_t h;
@property (nonatomic) int32_t size;

@end

@interface TLPhotoSize$photoCachedSize : TLPhotoSize

@property (nonatomic, retain) TLFileLocation *location;
@property (nonatomic) int32_t w;
@property (nonatomic) int32_t h;
@property (nonatomic, retain) NSData *bytes;

@end

