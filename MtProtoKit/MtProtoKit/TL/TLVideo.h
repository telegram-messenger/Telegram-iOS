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

@class TLPhotoSize;

@interface TLVideo : NSObject <TLObject>

@property (nonatomic) int64_t n_id;

@end

@interface TLVideo$videoEmpty : TLVideo


@end

@interface TLVideo$video : TLVideo

@property (nonatomic) int64_t access_hash;
@property (nonatomic) int32_t user_id;
@property (nonatomic) int32_t date;
@property (nonatomic, retain) NSString *caption;
@property (nonatomic) int32_t duration;
@property (nonatomic) int32_t size;
@property (nonatomic, retain) TLPhotoSize *thumb;
@property (nonatomic) int32_t dc_id;
@property (nonatomic) int32_t w;
@property (nonatomic) int32_t h;

@end

