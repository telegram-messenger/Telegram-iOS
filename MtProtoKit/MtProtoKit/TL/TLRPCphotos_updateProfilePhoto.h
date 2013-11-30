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

@class TLInputPhoto;
@class TLInputPhotoCrop;
@class TLUserProfilePhoto;

@interface TLRPCphotos_updateProfilePhoto : TLMetaRpc

@property (nonatomic, retain) TLInputPhoto *n_id;
@property (nonatomic, retain) TLInputPhotoCrop *crop;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCphotos_updateProfilePhoto$photos_updateProfilePhoto : TLRPCphotos_updateProfilePhoto


@end

