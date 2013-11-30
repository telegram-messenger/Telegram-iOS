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

@class TLInputGeoPoint;
@class TLInputGeoPlaceName;

@interface TLRPCgeo_saveGeoPlace : TLMetaRpc

@property (nonatomic, retain) TLInputGeoPoint *geo_point;
@property (nonatomic, retain) NSString *lang_code;
@property (nonatomic, retain) TLInputGeoPlaceName *place_name;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCgeo_saveGeoPlace$geo_saveGeoPlace : TLRPCgeo_saveGeoPlace


@end

