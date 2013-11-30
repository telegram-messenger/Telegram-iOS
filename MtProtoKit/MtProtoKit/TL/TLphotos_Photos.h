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


@interface TLphotos_Photos : NSObject <TLObject>

@property (nonatomic, retain) NSArray *photos;
@property (nonatomic, retain) NSArray *users;

@end

@interface TLphotos_Photos$photos_photos : TLphotos_Photos


@end

@interface TLphotos_Photos$photos_photosSlice : TLphotos_Photos

@property (nonatomic) int32_t count;

@end

