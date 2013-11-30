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

@class TLGeoPlaceName;

@interface TLGeoPoint : NSObject <TLObject>


@end

@interface TLGeoPoint$geoPointEmpty : TLGeoPoint


@end

@interface TLGeoPoint$geoPoint : TLGeoPoint

@property (nonatomic) double n_long;
@property (nonatomic) double lat;

@end

@interface TLGeoPoint$geoPlace : TLGeoPoint

@property (nonatomic) double n_long;
@property (nonatomic) double lat;
@property (nonatomic, retain) TLGeoPlaceName *name;

@end

