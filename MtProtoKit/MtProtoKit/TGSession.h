/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#import "ActionStage.h"

#import "TGTransport.h"
#import "TLObject.h"
#import "TL/TLMetaScheme.h"

@class TGDatacenterContext;

#ifdef __cplusplus
#include <map>
#endif

typedef enum {
    TGRequestClassGeneric = 1,
    TGRequestClassDownloadMedia = 2,
    TGRequestClassUploadMedia = 4,
    TGRequestClassEnableUnauthorized = 8,
    TGRequestClassEnableMerging = 16,
    TGRequestClassHidesActivityIndicator = 64,
    TGRequestClassLargeMedia = 128,
    TGRequestClassFailOnServerErrors = 256
} TGRequestClass;

typedef enum {
    TGNetworkReachabilityStatusUnknown = -1,
    TGNetworkReachabilityStatusNotReachable = 0,
    TGNetworkReachabilityStatusReachableViaWWAN = 1,
    TGNetworkReachabilityStatusReachableViaWiFi = 2,
} TGNetworkReachabilityStatus;

#define TG_DEFAULT_DATACENTER_ID INT_MAX
#define TG_ALL_DATACENTERS INT_MIN

#define TGRequestClassTransportMask (TGRequestClassGeneric | TGRequestClassDownloadMedia | TGRequestClassUploadMedia)

@protocol TGSessionDelegate

- (void)timeDifferenceChanged:(NSTimeInterval)timeDifference majorChange:(bool)majorChange;
- (bool)useDifferentBackend;

- (int)clientUserId;
- (void)setClientUserId:(int)clientUserId;
- (bool)clientIsActivated;
- (void)setClientIsActivated:(bool)userIsActivated;

- (void)saveSettings;
- (void)willSwitchBackends;
- (void)stateUpdateRequired;

- (void)setNetworkActivity:(bool)networkActivity;

- (NSArray *)filterStatelessUpdates:(TLUpdates *)updates;
- (NSArray *)makeStatelessUpdates:(TLUpdates *)updates;

@end

@interface TGSession : NSObject <TGTransportHandler, ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;
@property (nonatomic, unsafe_unretained) id<TGSessionDelegate> delegate;

@property (nonatomic) int timeDifference;
@property (nonatomic) int timeOffsetFromUTC;

@property (nonatomic) bool isOffline;
@property (nonatomic) bool isConnecting;
@property (nonatomic) bool isWaitingForFirstData;

@property (nonatomic) int stateConsistencyFails;
@property (nonatomic) int saltFails;

+ (TGSession *)instance;

- (dispatch_queue_t)networkDispatchQueue;
- (void)dispatchOnNetworkQueue:(dispatch_block_t)block;

- (void)clearSession;
- (void)loadSession;
- (void)storeSession;
- (void)clearSessionAndTakeOff;
- (void)takeOff;

- (void)switchBackends;

- (void)suspendNetwork;
- (void)resumeNetwork;

- (int64_t)currentDatacenterGenericSessionId;
- (int64_t)switchToDebugSession:(bool)debugSession;

- (int64_t)generateSessionId;

- (TGDatacenterContext *)datacenterWithId:(int)datacenterId;

- (NSObject *)performRpc:(TLMetaRpc *)rpc completionBlock:(void (^)(id<TLObject> response, int64_t responseTime, TLError *error))completionBlock progressBlock:(void (^)(int length, float progress))progressBlock requiresCompletion:(bool)requiresCompletion requestClass:(int)requestClass;
- (NSObject *)performRpc:(TLMetaRpc *)rpc completionBlock:(void (^)(id<TLObject> response, int64_t responseTime, TLError *error))completionBlock progressBlock:(void (^)(int length, float progress))progressBlock requiresCompletion:(bool)requiresCompletion requestClass:(int)requestClass datacenterId:(int)datacenterId;
- (NSObject *)performRpc:(TLMetaRpc *)rpc completionBlock:(void (^)(id<TLObject> response, int64_t responseTime, TLError *error))completionBlock progressBlock:(void (^)(int length, float progress))progressBlock quickAckBlock:(void (^)())quickAckBlock requiresCompletion:(bool)requiresCompletion requestClass:(int)requestClass datacenterId:(int)datacenterId;

- (void)cancelRpc:(NSObject *)token notifyServer:(bool)notifyServer;

- (void)updatePts:(int)pts date:(int)date seq:(int)seq;

@end

