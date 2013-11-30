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

@class TLhelp_AppPrefs;

@interface TLRPChelp_getAppPrefs : TLMetaRpc

@property (nonatomic) int32_t api_id;
@property (nonatomic, retain) NSString *api_hash;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPChelp_getAppPrefs$help_getAppPrefs : TLRPChelp_getAppPrefs


@end

