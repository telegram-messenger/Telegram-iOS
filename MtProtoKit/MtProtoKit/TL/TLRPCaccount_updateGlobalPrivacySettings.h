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


@interface TLRPCaccount_updateGlobalPrivacySettings : TLMetaRpc

@property (nonatomic) bool no_suggestions;
@property (nonatomic) bool hide_contacts;
@property (nonatomic) bool hide_located;
@property (nonatomic) bool hide_last_visit;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCaccount_updateGlobalPrivacySettings$account_updateGlobalPrivacySettings : TLRPCaccount_updateGlobalPrivacySettings


@end

