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


@interface TLSet_client_DH_params_answer : NSObject <TLObject>

@property (nonatomic, retain) NSData *nonce;
@property (nonatomic, retain) NSData *server_nonce;

@end

@interface TLSet_client_DH_params_answer$dh_gen_ok : TLSet_client_DH_params_answer

@property (nonatomic, retain) NSData *n_new_nonce_hash1;

@end

@interface TLSet_client_DH_params_answer$dh_gen_retry : TLSet_client_DH_params_answer

@property (nonatomic, retain) NSData *n_new_nonce_hash2;

@end

@interface TLSet_client_DH_params_answer$dh_gen_fail : TLSet_client_DH_params_answer

@property (nonatomic, retain) NSData *n_new_nonce_hash3;

@end

