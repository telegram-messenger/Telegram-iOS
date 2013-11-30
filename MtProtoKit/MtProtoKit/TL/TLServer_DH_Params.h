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


@interface TLServer_DH_Params : NSObject <TLObject>

@property (nonatomic, retain) NSData *nonce;
@property (nonatomic, retain) NSData *server_nonce;

@end

@interface TLServer_DH_Params$server_DH_params_fail : TLServer_DH_Params

@property (nonatomic, retain) NSData *n_new_nonce_hash;

@end

@interface TLServer_DH_Params$server_DH_params_ok : TLServer_DH_Params

@property (nonatomic, retain) NSData *encrypted_answer;

@end

