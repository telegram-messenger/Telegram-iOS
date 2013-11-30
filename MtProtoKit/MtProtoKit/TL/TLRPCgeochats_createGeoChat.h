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
@class TLgeochats_StatedMessage;

@interface TLRPCgeochats_createGeoChat : TLMetaRpc

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) TLInputGeoPoint *geo_point;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *venue;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCgeochats_createGeoChat$geochats_createGeoChat : TLRPCgeochats_createGeoChat


@end

