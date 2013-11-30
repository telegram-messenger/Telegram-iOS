#import "TGSession.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import <UIKit/UIKit.h>

#import "NSObject+TGLock.h"

#import "TGTcpSocket.h"

#import "TGZeroOutputStream.h"

#import "TLCompressedObject.h"

#import "TLSerializationEnvironment.h"

#include <set>
#include <vector>

#import "TGSecurity.h"
#import "TGEncryption.h"

#import "TLMetaClassStore.h"
#import "TL/TLMetaSchemeData.h"

#import "TLMessageContainer.h"
#import "TLFutureSalts.h"
#import "TLRpcResult.h"

#import "NSData+GZip.h"

#import "TGRPCRequest.h"

#import "TGTimer.h"

#import "TGDatacenterContext.h"

#import <libkern/OSAtomic.h>
#import <Security/Security.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

#import "TGTcpWorker.h"

#import "TGUpdateMessage.h"
#import "TGUpdate.h"

#import "TLUpdate$updateChangePts.h"

#import "TGNetworkMessage.h"

#define TG_DISCONNECT_DELAY 130

#define TLCurrentLayer 8

#define TLInvokeWithLayerClass(N) TLInvokeWithLayer##N##$invokeWithLayer##N
#define TLInvokeWithCurrentLayerClass TLInvokeWithLayerClass(8)

static inline id wrapInCurrentLayer(id<TLObject> object)
{
#if TLCurrentLayer == 0
    return object;
#else
    TLInvokeWithCurrentLayerClass *wrap = [[TLInvokeWithCurrentLayerClass alloc] init];
    wrap.query = object;
    return wrap;
#endif
}

static inline id unwrapFromCurrentLayer(id object)
{
#if TLCurrentLayer > 0
    if ([object isKindOfClass:[TLInvokeWithCurrentLayerClass class]])
        return (id<TLObject>)((TLInvokeWithCurrentLayerClass *)object).query;
#endif
    return object;
}

static const char *networkQueueSpecific = "ph.telegra.network-queue";

dispatch_queue_t mainNetworkDispatchQueue = nil;

typedef void (^TGNetworkReachabilityStatusBlock)(TGNetworkReachabilityStatus status);

#pragma mark -

static void addProcessedMessageId(std::map<int64_t, std::tr1::shared_ptr<std::set<int64_t> > > *pMap, int64_t sessionId, int64_t messageId)
{
    auto it = pMap->find(sessionId);
    if (it != pMap->end())
    {
        const int eraseLimit = 1000;
        const int eraseThreshold = 224;
        
        if (it->second->size() > eraseLimit + eraseThreshold)
        {   
            std::set<int64_t>::iterator endIt = it->second->begin();
            
            int removedCount = 0;
            for (std::set<int64_t>::iterator setIt = it->second->begin(); setIt != it->second->end() && removedCount <= eraseThreshold + 1; setIt++, removedCount++)
            {
                endIt = setIt;
            }
            it->second->erase(it->second->begin(), endIt);
#ifdef DEBUG
            TGLog(@"After GC: %d messageIds", it->second->size());
#endif
        }
        
        it->second->insert(messageId);
    }
    else
    {
        std::tr1::shared_ptr<std::set<int64_t> > sessionMap(new std::set<int64_t>());
        sessionMap->insert(messageId);
        pMap->insert(std::make_pair(sessionId, sessionMap));
    }
}

static void maybeCollectGarbageInOutgoingContainers(std::map<int64_t, std::vector<int64_t> > *pContainerIdToMessageIds)
{
    const int eraseLimit = 1000;
    const int eraseThreshold = 224;
    
    if (pContainerIdToMessageIds->size() > eraseLimit + eraseThreshold)
    {
        auto endIt = pContainerIdToMessageIds->begin();
        
        int removedCount = 0;
        for (auto curIt = pContainerIdToMessageIds->begin(); curIt != pContainerIdToMessageIds->end() && removedCount <= eraseThreshold + 1; curIt++, removedCount++)
        {
            endIt = curIt;
        }
        pContainerIdToMessageIds->erase(pContainerIdToMessageIds->begin(), endIt);
    }
}

static bool isMessageIdProcessed(std::map<int64_t, std::tr1::shared_ptr<std::set<int64_t> > > *pMap, int64_t sessionId, int64_t messageId)
{
    std::map<int64_t, std::tr1::shared_ptr<std::set<int64_t> > >::iterator it = pMap->find(sessionId);
    if (it != pMap->end())
        return it->second->find(messageId) != it->second->end();

    return false;
}

class TGStatefulUpdatesDesc
{
public:
    __strong NSMutableArray *array;
    
    TGStatefulUpdatesDesc()
    {
        array = nil;
    }
    
    TGStatefulUpdatesDesc(const TGStatefulUpdatesDesc &other)
    {
        array = other.array;
    }
    
    ~TGStatefulUpdatesDesc()
    {
        array = nil;
    }

    TGStatefulUpdatesDesc & operator= (const TGStatefulUpdatesDesc &other)
    {
        if (this != &other)
        {
            array = other.array;
        }
        return *this;
    }
};

@interface TGSession () <TGTcpWorkerHandler, TLSerializationEnvironment>
{
    std::vector<int64_t> _sessionsToDestroy;
    
    std::map<int64_t, std::tr1::shared_ptr<std::set<int64_t> > > _processedMessageIdsSet;
    std::map<int64_t, std::pair<std::set<int64_t>, int> > _messagesIdsForConfirmation;
    
    std::map<int64_t, std::set<int64_t> > _processedSessionChanges;
    
    std::map<int64_t, int32_t> _nextSeqNoInSession;
    
    std::map<int64_t, NSTimeInterval> _pingIdToDate;
    
    std::set<int> _holdUpdateMessagesInDatacenter;
    
    std::map<int64_t, TGStatefulUpdatesDesc> _statefulUpdatesToProcess;
    std::map<int64_t, NSMutableArray *> _statelessUpdatesToProcess;
    
    std::map<int, TGDatacenterContext *> _datacenters;
    
    std::set<int> _unavailableDatacenterIds;
    
    std::map<int, std::set<int64_t> > _quickAckIdToRequestIds;
    
    std::map<int64_t, std::vector<int64_t> > _containerIdToMessageIds;
}

@property (nonatomic) bool isReady;
@property (nonatomic) bool isSuspended;

@property (nonatomic) bool isDebugSessionEnabled;

@property (nonatomic) int movingToDatacenterId;
@property (nonatomic, strong) TLauth_ExportedAuthorization *movingAuthorization;

@property (nonatomic) SCNetworkReachabilityRef networkReachability;
@property (nonatomic) TGNetworkReachabilityStatus networkStatus;

@property (nonatomic, strong) TGTimer *serviceTimer;

@property (nonatomic) NSTimeInterval lastDestroySessionRequestTime;

@property (nonatomic) int currentDatacenterId;

@property (nonatomic) int64_t lastOutgoingMessageId;

@property (nonatomic, strong) NSMutableArray *requestQueue;
@property (nonatomic, strong) NSMutableArray *runningRequests;

@property (nonatomic, strong) NSMutableArray *downloadFreeWorkers;
@property (nonatomic, strong) NSMutableArray *downloadBusyWorkers;

@property (nonatomic) NSTimeInterval currentPingTime;

@end

@implementation TGSession

- (id)init
{
    self = [super init];
    if (self != nil)
    {
#if TARGET_IPHONE_SIMULATOR
        //_isDebugSessionEnabled = true;
#endif
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:false];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        
        _networkStatus = TGNetworkReachabilityStatusUnknown;
        
        _lastOutgoingMessageId = 0;
        
        _movingToDatacenterId = TG_DEFAULT_DATACENTER_ID;
        
        _requestQueue = [[NSMutableArray alloc] init];
        _runningRequests = [[NSMutableArray alloc] init];
        
        _downloadFreeWorkers = [[NSMutableArray alloc] init];
        _downloadBusyWorkers = [[NSMutableArray alloc] init];
        
        _serviceTimer = [[TGTimer alloc] initWithTimeout:2 repeat:true completion:^
        {
            if ([self datacenterWithId:_currentDatacenterId].authKey != nil)
                [self processRequestQueue:std::pair<int, int>()];
        } queue:[ActionStageInstance() globalStageDispatchQueue]];
        [_serviceTimer start];
        
        [self startMonitoringNetworkReachability];
    }
    return self;
}

+ (TGSession *)instance
{
    static TGSession *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        singleton = [[TGSession alloc] init];
    });
    return singleton;
}

- (dispatch_queue_t)networkDispatchQueue
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        mainNetworkDispatchQueue = dispatch_queue_create("com.telegraph.networkdispatchqueue", 0);
        if (dispatch_queue_set_specific != NULL)
            dispatch_queue_set_specific(mainNetworkDispatchQueue, networkQueueSpecific, (void *)networkQueueSpecific, NULL);
    });

    return mainNetworkDispatchQueue;
}

- (bool)isCurrentQueueNetworkQueue
{
    return dispatch_get_specific(networkQueueSpecific) != NULL;
}

- (void)dispatchOnNetworkQueue:(dispatch_block_t)block
{
    if ([self isCurrentQueueNetworkQueue])
        block();
    else
    {
        dispatch_async([self networkDispatchQueue], block);
    }
}

- (TGDatacenterContext *)datacenterWithId:(int)datacenterId
{
    std::map<int, TGDatacenterContext *>::iterator it = _datacenters.find(datacenterId == TG_DEFAULT_DATACENTER_ID ? _currentDatacenterId : datacenterId);
    
    return it == _datacenters.end() ? nil : it->second;
}

- (void)mergeDatacenterData:(NSArray *)datacenters
{
    if (datacenters.count == 0)
        return;
    
    for (TGDatacenterContext *datacenter in datacenters)
    {
        std::map<int, TGDatacenterContext *>::iterator it = _datacenters.find(datacenter.datacenterId);
        if (it == _datacenters.end())
        {
            _datacenters.insert(std::pair<int, TGDatacenterContext *>(datacenter.datacenterId, datacenter));
        }
        else
        {
            TGDatacenterContext *existingDatacenter = it->second;
            existingDatacenter.addressSet = datacenter.addressSet;
        }
    }
    
    [self storeSession];
}

static bool TGHostIsIP(NSURL *url)
{
    struct sockaddr_in sa_in;
    struct sockaddr_in6 sa_in6;
    
    return [url host] && (inet_pton(AF_INET, [[url host] UTF8String], &sa_in) == 1 || inet_pton(AF_INET6, [[url host] UTF8String], &sa_in6) == 1);
}

static TGNetworkReachabilityStatus TGNetworkReachabilityStatusForFlags(SCNetworkReachabilityFlags flags)
{
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL canConnectionAutomatically = (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
                                       ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
    BOOL canConnectWithoutUserInteraction = (canConnectionAutomatically &&
                                             (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
    BOOL isNetworkReachable = (isReachable && (!needsConnection || canConnectWithoutUserInteraction));
    
    TGNetworkReachabilityStatus status = TGNetworkReachabilityStatusUnknown;
    if (isNetworkReachable == NO)
    {
        status = TGNetworkReachabilityStatusNotReachable;
    }
#if	TARGET_OS_IPHONE
    else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0)
    {
        status = TGNetworkReachabilityStatusReachableViaWWAN;
    }
#endif
    else
    {
        status = TGNetworkReachabilityStatusReachableViaWiFi;
    }
    
    return status;
}

static void TGNetworkReachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void *info)
{
    TGNetworkReachabilityStatus status = TGNetworkReachabilityStatusForFlags(flags);

    TGNetworkReachabilityStatusBlock block = (__bridge TGNetworkReachabilityStatusBlock)info;
    if (block)
        block(status);
}

static const void * TGNetworkReachabilityRetainCallback(const void *info)
{
    return (__bridge_retained const void *)([(__bridge TGNetworkReachabilityStatusBlock)info copy]);
}

static void TGNetworkReachabilityReleaseCallback(__unused const void *info)
{
}

- (void)startMonitoringNetworkReachability
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        [self stopMonitoringNetworkReachability];
        
        struct sockaddr_in zeroAddress;
        bzero(&zeroAddress, sizeof(zeroAddress));
        zeroAddress.sin_len = sizeof(zeroAddress);
        zeroAddress.sin_family = AF_INET;
        
        self.networkReachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&zeroAddress);
        
        TGNetworkReachabilityStatusBlock callback = ^(TGNetworkReachabilityStatus status)
        {
            [self networkReachabilityCallback:status];
        };
        
        SCNetworkReachabilityContext context = {0, (__bridge void *)callback, TGNetworkReachabilityRetainCallback, TGNetworkReachabilityReleaseCallback, NULL};
        SCNetworkReachabilitySetCallback(self.networkReachability, TGNetworkReachabilityCallback, &context);
        SCNetworkReachabilityScheduleWithRunLoop(self.networkReachability, CFRunLoopGetMain(), (CFStringRef)NSRunLoopCommonModes);
        
        SCNetworkReachabilityFlags flags;
        SCNetworkReachabilityGetFlags(self.networkReachability, &flags);
        dispatch_async(dispatch_get_main_queue(), ^
        {
            TGNetworkReachabilityStatus status = TGNetworkReachabilityStatusForFlags(flags);
            callback(status);
        }); 
    });
}

- (void)networkReachabilityCallback:(TGNetworkReachabilityStatus)status
{
    [self networkStatusWillChange:status];
    
    TGLog(@"Network status: %d", status);
}

- (void)forceUpdateReachability
{
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityGetFlags(self.networkReachability, &flags);
    dispatch_async(dispatch_get_main_queue(), ^
    {
        TGNetworkReachabilityStatus status = TGNetworkReachabilityStatusForFlags(flags);
        [self networkReachabilityCallback:status];
    });
}

- (void)stopMonitoringNetworkReachability
{
    if (_networkReachability)
    {
        SCNetworkReachabilityUnscheduleFromRunLoop(_networkReachability, CFRunLoopGetMain(), (CFStringRef)NSRunLoopCommonModes);
        CFRelease(_networkReachability);
        _networkReachability = NULL;
    }
}

- (void)networkStatusWillChange:(TGNetworkReachabilityStatus)newStatus
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        if (newStatus != _networkStatus)
        {
            TGNetworkReachabilityStatus oldStatus = _networkStatus;
            _networkStatus = newStatus;
            
            _isOffline = _networkStatus == TGNetworkReachabilityStatusNotReachable;
            [self dispatchConnectingState];

            if (oldStatus != TGNetworkReachabilityStatusUnknown)
            {
                for (std::map<int, TGDatacenterContext *>::iterator it = _datacenters.begin(); it != _datacenters.end(); it++)
                {
                    [it->second.datacenterTransport forceTransportReconnection];
                }
            }
            
            for (int i = 0; i < (int)_runningRequests.count; i++)
            {
                TGRPCRequest *request = [_runningRequests objectAtIndex:i];
                
                if ((request.requestClass & TGRequestClassDownloadMedia))
                {
                    if (request.worker != nil)
                        [self clearRequestWorker:request reuseable:false];
                }
            }
            
            [self processRequestQueue:std::pair<int, int>(TGRequestClassTransportMask, TG_ALL_DATACENTERS)];
        }
    }];
}

- (void)didEnterBackground:(NSNotification *)__unused notification
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [_serviceTimer resetTimeout:60];
        [self setTransportsTimeouts:120];
    }];
}

- (void)willEnterForeground:(NSNotification *)__unused notification
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [_serviceTimer resetTimeout:2];
        [self setTransportsTimeouts:120];
        
        [self forceUpdateReachability];
    }];
}

- (void)setTimeDifference:(int)timeDifference
{
    bool store = ABS(timeDifference - _timeDifference) > 25;
    _timeDifference = timeDifference;
    _timeOffsetFromUTC = _timeDifference + (int)[[NSTimeZone localTimeZone] secondsFromGMT];
    
    if (store)
        [self storeSession];
    
    id<TGSessionDelegate> delegate = _delegate;
    [delegate timeDifferenceChanged:timeDifference majorChange:store];
}

- (NSMutableDictionary *)getKeychainQuery
{
    NSString *service = @"com.telegraph.Telegraph";
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge id)kSecClassGenericPassword, (__bridge id)kSecClass,
            service, (__bridge id)kSecAttrService,
            service, (__bridge id)kSecAttrAccount,
            (__bridge id)kSecAttrAccessibleAfterFirstUnlock, (__bridge id)kSecAttrAccessible,
            nil];
}

- (void)clearSession
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        NSMutableDictionary *keychainQuery = [self getKeychainQuery];
        SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
        
        while (_requestQueue.count != 0)
        {
            TGRPCRequest *request = [_requestQueue objectAtIndex:0];
            [_requestQueue removeObjectAtIndex:0];
            
            if (request.completionBlock != nil)
            {
                TLError *implicitError = nil;
                implicitError = [[TLError$error alloc] init];
                ((TLError$error *)implicitError).code = -1000;
                
                request.completionBlock(nil, 0, implicitError);
            }
            
            if (request.worker != nil)
                [self clearRequestWorker:request reuseable:false];
        }
        
        while (_runningRequests.count != 0)
        {
            TGRPCRequest *request = [_runningRequests objectAtIndex:0];
            [_runningRequests removeObjectAtIndex:0];
            
            if (request.completionBlock != nil)
            {
                TLError *implicitError = nil;
                implicitError = [[TLError$error alloc] init];
                ((TLError$error *)implicitError).code = -1000;
                
                request.completionBlock(nil, 0, implicitError);
            }
            
            if (request.worker != nil)
                [self clearRequestWorker:request reuseable:false];
        }
        
        [ActionStageInstance() removeWatcher:self];
        
        _unavailableDatacenterIds.clear();
        
        [_requestQueue removeAllObjects];
        [_runningRequests removeAllObjects];
        [_downloadFreeWorkers removeAllObjects];
        [_downloadBusyWorkers removeAllObjects];
        
        _processedMessageIdsSet.clear();
        _messagesIdsForConfirmation.clear();
        _processedSessionChanges.clear();
        
        _pingIdToDate.clear();
        
        _quickAckIdToRequestIds.clear();
        
        for (std::map<int, TGDatacenterContext *>::iterator it = _datacenters.begin(); it != _datacenters.end(); it++)
        {
            TGDatacenterContext *datacenter = it->second;

            int64_t authSessionId = [self generateSessionId];
            int64_t authUploadSessionId = [self generateSessionId];
            int64_t authDownloadSessionId = [self generateSessionId];
            
            datacenter.authSessionId = authSessionId;
            datacenter.authDownloadSessionId = authDownloadSessionId;
            datacenter.authUploadSessionId = authUploadSessionId;
            
            [datacenter clearServerSalts];
            datacenter.authorized = false;
            
            [datacenter stopDatacenterTransport];
        }
        
        _sessionsToDestroy.clear();
        
        [self loadSession];
        [self storeSession];
    }];
}

- (void)clearRequestsForRequestClass:(int)requestClass datacenter:(TGDatacenterContext *)datacenter
{
    for (TGRPCRequest *request in _runningRequests)
    {
        if ((request.requestClass & requestClass) && [self datacenterWithId:request.runningDatacenterId].datacenterId == datacenter.datacenterId)
        {
            if (request.worker != nil)
                [self clearRequestWorker:request reuseable:false];
            
            request.runningMessageId = 0;
            request.runningMessageSeqNo = 0;
            request.runningStartTime = 0;
            request.runningMinStartTime = 0;
            request.transportChannelToken = 0;
        }
    }
}

- (int64_t)generateSessionId
{
    int64_t newSessionId = 0;
    arc4random_buf(&newSessionId, 8);
    newSessionId = _isDebugSessionEnabled ? ((0xabcd000000000000) | (newSessionId & 0x0000ffffffffffff)) : newSessionId;
    
    return newSessionId;
}

- (void)recreateSession:(int64_t)sessionId datacenter:(TGDatacenterContext *)datacenter
{
    _messagesIdsForConfirmation.erase(sessionId);
    _processedMessageIdsSet.erase(sessionId);
    _nextSeqNoInSession.erase(sessionId);
    _processedSessionChanges.erase(sessionId);
    _pingIdToDate.erase(sessionId);
    
    if (sessionId == datacenter.authSessionId)
    {
        [self clearRequestsForRequestClass:TGRequestClassGeneric datacenter:datacenter];
        
        TGLog(@"***** Recreate generic session");
        datacenter.authSessionId = [self generateSessionId];
    }
    else if (sessionId == datacenter.authDownloadSessionId)
    {
        [self clearRequestsForRequestClass:TGRequestClassDownloadMedia datacenter:datacenter];
        
        TGLog(@"***** Recreate download session");
        datacenter.authDownloadSessionId = [self generateSessionId];
    }
    else if (sessionId == datacenter.authUploadSessionId)
    {
        [self clearRequestsForRequestClass:TGRequestClassUploadMedia datacenter:datacenter];
        
        TGLog(@"***** Recreate upload session");
        datacenter.authUploadSessionId = [self generateSessionId];
    }
}

- (int64_t)clientKeychainId
{
    static int64_t value = 0;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^
    {
        int64_t storedValue = [[[NSUserDefaults standardUserDefaults] objectForKey:@"clientKeychainId"] longLongValue];
        if (storedValue == 0)
        {
            arc4random_buf(&storedValue, 8);
            [[NSUserDefaults standardUserDefaults] setObject:[[NSNumber alloc] initWithLongLong:storedValue] forKey:@"clientKeychainId"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        value = storedValue;
    });
    
    return value;
}

- (void)loadSession
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        
        id ret = nil;
        NSMutableDictionary *keychainQuery = [self getKeychainQuery];
        [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
        [keychainQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
        CFDataRef keyData = NULL;
        if (SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr)
        {
            @try
            {
                ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
            }
            @catch (NSException *e)
            {
                TGLog(@"Unarchive of credentials failed: %@", e);
            }
        }
        
        TGLog(@"SecLoad time: %f ms", (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0);
        
        if (ret != nil && [ret isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *dict = (NSDictionary *)ret;
            
            int datacenterSetId = [[dict objectForKey:@"backendId"] intValue];
            NSNumber *keychainId = [dict objectForKey:@"clientKeychainId"];
            int64_t currentClientKeychainId = [self clientKeychainId];
            bool keychainKeyMatches = (keychainId == nil || [keychainId longLongValue] == currentClientKeychainId);
            if ((datacenterSetId == [_delegate useDifferentBackend]? 1 : 0) && [[dict objectForKey:@"version"] intValue] == 5 && keychainKeyMatches)
            {
                _sessionsToDestroy.clear();
                for (NSNumber *nSessionId in [dict objectForKey:@"sessionIds"])
                    _sessionsToDestroy.push_back([nSessionId longLongValue]);
     
                 _timeDifference = [[dict objectForKey:@"timeDifference"] intValue];
                [self setTimeDifference:_timeDifference];
                
                [_delegate timeDifferenceChanged:_timeDifference majorChange:true];
                
                NSArray *datacenterDatas = [dict objectForKey:@"datacenters"];
                for (NSData *data in datacenterDatas)
                {
                    TGDatacenterContext *datacenter = [[TGDatacenterContext alloc] initWithSerializedData:data];
                    if (datacenter != nil)
                        _datacenters[datacenter.datacenterId] = datacenter;
                }
                
                self.currentDatacenterId = [[dict objectForKey:@"currentDatacenter"] intValue];
            }
            else
            {
                _delegate.clientUserId = 0;
                _delegate.clientIsActivated = false;
                [_delegate saveSettings];
            }
        }
        else
        {
            _delegate.clientUserId = 0;
            _delegate.clientIsActivated = false;
            [_delegate saveSettings];
        }
        
        if (_datacenters.size() == 0)
        {
            if (_delegate.useDifferentBackend)
            {
                TGDatacenterContext *datacenter1 = [[TGDatacenterContext alloc] init];
                datacenter1.datacenterId = 1;
                datacenter1.addressSet = [[NSArray alloc] initWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys:@"173.240.5.1", @"address", [[NSNumber alloc] initWithInt:443], @"port", nil], nil];
                _datacenters[datacenter1.datacenterId] = datacenter1;
                
                TGDatacenterContext *datacenter2 = [[TGDatacenterContext alloc] init];
                datacenter2.datacenterId = 2;
                datacenter2.addressSet = [[NSArray alloc] initWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys:@"95.142.192.66", @"address", [[NSNumber alloc] initWithInt:443], @"port", nil], nil];
                _datacenters[datacenter2.datacenterId] = datacenter2;
                
                TGDatacenterContext *datacenter3 = [[TGDatacenterContext alloc] init];
                datacenter3.datacenterId = 3;
                datacenter3.addressSet = [[NSArray alloc] initWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys:@"174.140.142.6", @"address", [[NSNumber alloc] initWithInt:443], @"port", nil], nil];
                _datacenters[datacenter3.datacenterId] = datacenter3;
                
                TGDatacenterContext *datacenter4 = [[TGDatacenterContext alloc] init];
                datacenter4.datacenterId = 4;
                datacenter4.addressSet = [[NSArray alloc] initWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys:@"31.210.235.12", @"address", [[NSNumber alloc] initWithInt:443], @"port", nil], nil];
                _datacenters[datacenter4.datacenterId] = datacenter4;
                
                TGDatacenterContext *datacenter5 = [[TGDatacenterContext alloc] init];
                datacenter5.datacenterId = 5;
                datacenter5.addressSet = [[NSArray alloc] initWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys:@"116.51.22.2", @"address", [[NSNumber alloc] initWithInt:443], @"port", nil], nil];
                _datacenters[datacenter5.datacenterId] = datacenter5;
            }
            else
            {
                TGDatacenterContext *datacenter1 = [[TGDatacenterContext alloc] init];
                datacenter1.datacenterId = 1;
                datacenter1.addressSet = [[NSArray alloc] initWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys:@"173.240.5.253", @"address", [[NSNumber alloc] initWithInt:1488], @"port", nil], nil];
                _datacenters[datacenter1.datacenterId] = datacenter1;
                
                TGDatacenterContext *datacenter2 = [[TGDatacenterContext alloc] init];
                datacenter2.datacenterId = 2;
                datacenter2.addressSet = [[NSArray alloc] initWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys:@"95.142.192.65", @"address", [[NSNumber alloc] initWithInt:1488], @"port", nil], nil];
                _datacenters[datacenter2.datacenterId] = datacenter2;
                
                TGDatacenterContext *datacenter3 = [[TGDatacenterContext alloc] init];
                datacenter3.datacenterId = 3;
                datacenter3.addressSet = [[NSArray alloc] initWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys:@"174.140.142.5", @"address", [[NSNumber alloc] initWithInt:1488], @"port", nil], nil];
                _datacenters[datacenter3.datacenterId] = datacenter3;
            }
        }
        
        if (_datacenters.size() < 5)
        {
            TGDatacenterContext *datacenter5 = [[TGDatacenterContext alloc] init];
            datacenter5.datacenterId = 5;
            datacenter5.addressSet = [[NSArray alloc] initWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys:@"116.51.22.2", @"address", [[NSNumber alloc] initWithInt:443], @"port", nil], nil];
            _datacenters[datacenter5.datacenterId] = datacenter5;
        }
        
        for (std::map<int, TGDatacenterContext *>::iterator it = _datacenters.begin(); it != _datacenters.end(); it++)
        {
            TGDatacenterContext *datacenter = it->second;
            
            int64_t authSessionId = [self generateSessionId];
            int64_t authUploadSessionId = [self generateSessionId];
            int64_t authDownloadSessionId = [self generateSessionId];
            
            datacenter.authSessionId = authSessionId;
            datacenter.authDownloadSessionId = authDownloadSessionId;
            datacenter.authUploadSessionId = authUploadSessionId;
            
            TGLog(@"DC%d: Auth key id: %@", datacenter.datacenterId, datacenter.authKeyId);
        }
        
        if (!_datacenters.empty() && _datacenters.find(_currentDatacenterId) == _datacenters.end())
        {
            self.currentDatacenterId = _datacenters.begin()->first;
        }
        
/*#ifdef DEBUG
        for (std::map<int, TGDatacenterContext *>::iterator it = _datacenters.begin(); it != _datacenters.end(); it++)
        {
            [it->second clearServerSalts];
        }
#endif*/
        
        if (keyData != nil)
            CFRelease(keyData);
        
        _movingToDatacenterId = TG_DEFAULT_DATACENTER_ID;
    }];
}

- (void)storeSession
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        [data setObject:[NSNumber numberWithInt:5] forKey:@"version"];
        [data setObject:[[NSNumber alloc] initWithLongLong:[self clientKeychainId]] forKey:@"clientKeychainId"];
        [data setObject:[NSNumber numberWithInt:_delegate.useDifferentBackend ? 1 : 0] forKey:@"backendId"];
        NSMutableArray *sessionIds = [[NSMutableArray alloc] init];
        TGDatacenterContext *currentDatacenter = [self datacenterWithId:_currentDatacenterId];
        if (currentDatacenter.authSessionId != 0)
            [sessionIds addObject:[NSNumber numberWithLongLong:currentDatacenter.authSessionId]];
        if (currentDatacenter.authDownloadSessionId != 0)
            [sessionIds addObject:[NSNumber numberWithLongLong:currentDatacenter.authDownloadSessionId]];
        if (currentDatacenter.authUploadSessionId != 0)
            [sessionIds addObject:[NSNumber numberWithLongLong:currentDatacenter.authUploadSessionId]];
        [data setObject:sessionIds forKey:@"sessionIds"];
        
        [data setObject:[NSNumber numberWithInt:_timeDifference] forKey:@"timeDifference"];
        
        NSMutableArray *datacenterDatas = [[NSMutableArray alloc] init];
        for (std::map<int, TGDatacenterContext *>::iterator it = _datacenters.begin(); it != _datacenters.end(); it++)
        {
            NSData *data = [it->second serialize];
            if (data != nil)
                [datacenterDatas addObject:data];
        }
        
        [data setObject:datacenterDatas forKey:@"datacenters"];
        
        [data setObject:[[NSNumber alloc] initWithInt:_currentDatacenterId] forKey:@"currentDatacenter"];
        
        NSMutableDictionary *keychainQuery = [self getKeychainQuery];
        SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
        [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge id)kSecValueData];
        SecItemAdd((__bridge CFDictionaryRef)keychainQuery, NULL);
    }];
}

- (void)setTransportsTimeouts:(NSTimeInterval)timeoutGeneric
{
    for (std::map<int, TGDatacenterContext *>::iterator it = _datacenters.begin(); it != _datacenters.end(); it++)
    {
        [it->second.datacenterTransport setTransportTimeout:timeoutGeneric];
    }
}

- (void)clearRequestWorker:(TGRPCRequest *)request reuseable:(bool)reuseable
{
    if (request.worker != nil)
    {
        if (request.requestClass & TGRequestClassDownloadMedia)
        {
            [request.worker removeRequestToken:request.token];
            if (reuseable)
            {
                if (request.worker.currentRequestTokens.count == 0)
                {
                    request.worker.mergingEnabled = false;
                    [request.worker setIsBusy:false];
                    [_downloadFreeWorkers addObject:request.worker];
                    [_downloadBusyWorkers removeObject:request.worker];
                }
            }
            else
            {
                if (request.worker.currentRequestTokens.count != 0)
                {
                    NSMutableSet *workerRequestTokens = [request.worker.currentRequestTokens copy];
                    dispatch_async([ActionStageInstance() globalStageDispatchQueue], ^
                    {
                        for (TGRPCRequest *runningRequest in _runningRequests)
                        {
                            if ([workerRequestTokens containsObject:[[NSNumber alloc] initWithInt:runningRequest.token]])
                            {
                                runningRequest.worker = nil;
                                runningRequest.runningStartTime = 0;
                            }
                        }
                        
                        [self processRequestQueue:(std::pair<int, int>())];
                    });
                }
                [request.worker prepareForRemoval];
                [_downloadBusyWorkers removeObject:request.worker];
            }
        }
        
        request.worker = nil;
    }
}

- (void)setupRequestWorker:(TGRPCRequest *)request worker:(TGTcpWorker *)worker
{
    if (request.requestClass & TGRequestClassDownloadMedia)
    {
        request.worker = worker;
        [worker addRequestToken:request.token];
        [worker setIsBusy:true];
        if (![_downloadBusyWorkers containsObject:worker])
            [_downloadBusyWorkers addObject:worker];
    }
}

- (void)sendRequestDataToWorker:(TGRPCRequest *)request
{
    TGDatacenterContext *datacenter = [self datacenterWithId:request.runningDatacenterId];
    
    if (request.worker == nil)
    {
        request.worker = [self dequeueWorkerForRequest:request datacenter:datacenter enableMerging:request.requestClass & TGRequestClassEnableMerging];
        [request.worker setIsBusy:true];
    }
    
    int64_t messageId = [self generateMessageId];
    
    TGZeroOutputStream *os = [[TGZeroOutputStream alloc] init];
    TLMetaClassStore::serializeObject(os, request.rpcRequest, true);
    
    if (os.currentLength != 0)
    {
        int64_t sessionId = 0;
        if (request.requestClass & TGRequestClassGeneric)
            sessionId = datacenter.authSessionId;
        else if (request.requestClass & TGRequestClassUploadMedia)
            sessionId = datacenter.authUploadSessionId;
        else if (request.requestClass & TGRequestClassDownloadMedia)
            sessionId = datacenter.authDownloadSessionId;
        
        TGNetworkMessage *networkMessage = [[TGNetworkMessage alloc] init];
        networkMessage.protoMessage = [[TLProtoMessage$protoMessage alloc] init];
        
        networkMessage.protoMessage.msg_id = messageId;
        networkMessage.protoMessage.seqno = [self generateMessageSeqNo:sessionId incerement:true];
        networkMessage.protoMessage.bytes = os.currentLength;
        networkMessage.protoMessage.body = request.rpcRequest;
        networkMessage.rawRequest = request.rawRequest;
        networkMessage.requestId = request.token;
        
        request.runningMessageId = messageId;
        request.runningMessageSeqNo = networkMessage.protoMessage.seqno;
        request.serializedLength = os.currentLength;
        request.runningStartTime = CFAbsoluteTimeGetCurrent();
        
        if ((request.requestClass & TGRequestClassDownloadMedia))
        {   
            [self proceedToSendingMessages:[NSArray arrayWithObject:networkMessage] sessionId:sessionId transport:request.worker.transport reportAck:false requestShortTimeout:false allowAcks:true];
        }
    }
}

- (void)workerFailed:(TGTcpWorker *)worker
{
    if (worker == nil)
        return;
    
    bool found = false;
    
    for (TGRPCRequest *request in _runningRequests)
    {
        if (request.worker == worker)
        {
            found = true;
            [self sendRequestDataToWorker:request];
        }
    }
    
    if (!found)
    {
        [worker prepareForRemoval];
        [_downloadBusyWorkers removeObject:worker];
    }
}

- (void)freeWorkerTimedOut:(TGTcpWorker *)worker
{
    [worker prepareForRemoval];
    
    if (worker.requestClasses & TGRequestClassDownloadMedia)
        [_downloadFreeWorkers removeObject:worker];
}

- (void)switchBackends
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [self clearSession];
        
        [_delegate willSwitchBackends];
        
        exit(0);
    }];
}

- (void)takeOff
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
            TLRegisterClasses();
            
            TGLog(@"Registered classes in %f ms", (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0);
            
            TLMetaClassStore::registerObjectClass([[TLMessageContainer$msg_container alloc] init]);
            TLMetaClassStore::registerObjectClass([[TLFutureSalts$future_salts alloc] init]);
            
            TLMetaClassStore::mergeScheme(TLgetMetaScheme());
            
            TGLog(@"Parsed scheme in %f ms", (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0);
        });
        
        TGDatacenterContext *datacenter = [self datacenterWithId:_currentDatacenterId];
        
        if (datacenter.authKey == nil)
            [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/network/datacenterHandshake/(%d)", datacenter.datacenterId] options:[[NSDictionary alloc] initWithObjectsAndKeys:datacenter, @"datacenter", nil] watcher:self];
        
        _isOffline = _networkStatus == TGNetworkReachabilityStatusNotReachable;
        
        bool isConnecting = datacenter != nil && ![datacenter.datacenterTransport connectedChannelToken];
        
        _isConnecting = isConnecting;
        [self dispatchConnectingState];
        
        _statefulUpdatesToProcess.clear();
        _statelessUpdatesToProcess.clear();
        
        //[self dumpScheme];
        
        _isReady = true;
    }];
}

- (void)clearSessionAndTakeOff
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [self clearSession];
        
        [self takeOff];
    }];
}

- (void)suspendNetwork
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        _isSuspended = true;

        for (std::map<int, TGDatacenterContext *>::iterator it = _datacenters.begin(); it != _datacenters.end(); it++)
        {
            [it->second.datacenterTransport suspendTransport];
        }
    }];
}

- (void)resumeNetwork
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        _isSuspended = false;
        
        [self processRequestQueue:(std::pair<int, int>(TGRequestClassTransportMask, TG_ALL_DATACENTERS))];
    }];
}

- (int64_t)currentDatacenterGenericSessionId
{
    return [self datacenterWithId:_currentDatacenterId].authSessionId;
}

- (int64_t)switchToDebugSession:(bool)debugSession
{
    int64_t sessionId = [self currentDatacenterGenericSessionId];
    
    if (_isDebugSessionEnabled != debugSession)
    {
        _isDebugSessionEnabled = debugSession;

        [self recreateSession:sessionId datacenter:[self datacenterWithId:_currentDatacenterId]];
        sessionId = [self currentDatacenterGenericSessionId];
    }
    
    return sessionId;
}

- (TLProtoMessage *)wrapMessage:(id<TLObject>)message sessionId:(int64_t)sessionId meaningful:(bool)meaningful
{
    TGZeroOutputStream *os = [[TGZeroOutputStream alloc] init];
    TLMetaClassStore::serializeObject(os, message, true);
    
    if (os.currentLength != 0)
    {
        TLProtoMessage$protoMessage *protoMessage = [[TLProtoMessage$protoMessage alloc] init];
        protoMessage.msg_id = [self generateMessageId];
        protoMessage.bytes = os.currentLength;
        protoMessage.body = message;
        protoMessage.seqno = [self generateMessageSeqNo:sessionId incerement:meaningful];
        
        return protoMessage;
    }
    else
    {
        TGLog(@"***** Couldn't serialize %@", message);
        return nil;
    }
}

- (NSObject *)performRpc:(TLMetaRpc *)rpc completionBlock:(void (^)(id<TLObject> response, int64_t responseTime, TLError *error))completionBlock progressBlock:(void (^)(int length, float progress))progressBlock requiresCompletion:(bool)requiresCompletion requestClass:(int)requestClass
{
    return [self performRpc:rpc completionBlock:completionBlock progressBlock:progressBlock requiresCompletion:requiresCompletion requestClass:requestClass datacenterId:TG_DEFAULT_DATACENTER_ID];
}

- (NSObject *)performRpc:(TLMetaRpc *)rpc completionBlock:(void (^)(id<TLObject> response, int64_t responseTime, TLError *error))completionBlock progressBlock:(void (^)(int length, float progress))progressBlock requiresCompletion:(bool)requiresCompletion requestClass:(int)requestClass datacenterId:(int)datacenterId
{
    return [self performRpc:rpc completionBlock:completionBlock progressBlock:progressBlock quickAckBlock:nil requiresCompletion:requiresCompletion requestClass:requestClass datacenterId:datacenterId];
}

- (NSObject *)performRpc:(TLMetaRpc *)rpc completionBlock:(void (^)(id<TLObject> response, int64_t responseTime, TLError *error))completionBlock progressBlock:(void (^)(int length, float progress))progressBlock quickAckBlock:(void (^)())quickAckBlock requiresCompletion:(bool)requiresCompletion requestClass:(int)requestClass datacenterId:(int)datacenterId
{
    static int nextCallToken = 0;
    int requestToken = OSAtomicIncrement32(&nextCallToken);
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        id<TLObject> requestBody = rpc;
        if ([rpc isKindOfClass:[TLMetaRpc class]] && [(TLMetaRpc *)rpc layerVersion] > 0)
            requestBody = wrapInCurrentLayer(rpc);
        
        if ([rpc isKindOfClass:[TLRPCmessages_sendMessage class]])
        {
            TGLog(@"(ENQUEUE: message)");
        }
        
        static NSArray *compressRpcClasses = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            compressRpcClasses = @[
               [TLRPCmessages_sendMessage class],
               [TLRPCcontacts_importContacts class],
               
            ];
        });
        
        for (Class rpcClass in compressRpcClasses)
        {
            if ([rpc isKindOfClass:rpcClass])
            {
                NSOutputStream *os = [[NSOutputStream alloc] initToMemory];
                [os open];
                TLMetaClassStore::serializeObject(os, requestBody, true);
                TLCompressedObject *compressedObject = [[TLCompressedObject alloc] init];
                NSData *objectData = [os currentBytes];
                compressedObject.compressedData = [objectData compressGZip];
                [os close];
                
                if (compressedObject.compressedData != nil && objectData.length > compressedObject.compressedData.length)
                {
                    TGLog(@"Compression saved %d bytes", objectData.length - compressedObject.compressedData.length);
                    requestBody = compressedObject;
                }
                
                break;
            }
        }
        
        TGRPCRequest *request = [[TGRPCRequest alloc] init];
        request.token = requestToken;
        request.requestClass = requestClass;
        
        request.runningDatacenterId = datacenterId;
        
        request.rawRequest = rpc;
        request.rpcRequest = requestBody;
        request.completionBlock = completionBlock;
        request.progressBlock = progressBlock;
        request.quickAckBlock = quickAckBlock;
        request.requiresCompletion = requiresCompletion;
        
        request.serializationContext = [[TLSerializationContext alloc] init];
        
        if ([rpc isKindOfClass:[TLMetaRpc class]])
            request.serializationContext.impliedSignature = [(TLMetaRpc *)rpc impliedResponseSignature];
        
        [_requestQueue addObject:request];
        
        [self processRequestQueue:(std::pair<int, int>())];
    }];
    
    return [NSNumber numberWithInt:requestToken];
}

- (int64_t)generateMessageId
{
    int64_t messageId = (int64_t)(([[NSDate date] timeIntervalSince1970] + _timeDifference) * 4294967296);
    if (messageId <= _lastOutgoingMessageId)
        messageId = _lastOutgoingMessageId + 1;
    while (messageId % 4 != 0)
        messageId++;
    
    _lastOutgoingMessageId = messageId;
    return messageId;
}

- (int32_t)generateMessageSeqNo:(int64_t)session incerement:(bool)increment
{
    int value = _nextSeqNoInSession[session];
    if (increment)
        _nextSeqNoInSession[session]++;
    return value * 2 + (increment ? 1 : 0);
}

- (MessageKeyData)generateMessageKeyData:(NSData *)messageKey incoming:(bool)incoming datacenter:(TGDatacenterContext *)datacenter
{
    MessageKeyData keyData;
    
    NSData *authKey = datacenter.authKey;
    if (authKey == nil || authKey.length == 0)
    {
        MessageKeyData keyData;
        keyData.aesIv = nil;
        keyData.aesKey = nil;
        return keyData;
    }
    
    int x = incoming ? 8 : 0;
    
    NSData *sha1_a = nil;
    {
        NSMutableData *data = [[NSMutableData alloc] init];
        [data appendData:messageKey];
        [data appendBytes:(((int8_t *)authKey.bytes) + x) length:32];
        sha1_a = computeSHA1(data);
    }
    
    NSData *sha1_b = nil;
    {
        NSMutableData *data = [[NSMutableData alloc] init];
        [data appendBytes:(((int8_t *)authKey.bytes) + 32 + x) length:16];
        [data appendData:messageKey];
        [data appendBytes:(((int8_t *)authKey.bytes) + 48 + x) length:16];
        sha1_b = computeSHA1(data);
    }
    
    NSData *sha1_c = nil;
    {
        NSMutableData *data = [[NSMutableData alloc] init];
        [data appendBytes:(((int8_t *)authKey.bytes) + 64 + x) length:32];
        [data appendData:messageKey];
        sha1_c = computeSHA1(data);
    }
    
    NSData *sha1_d = nil;
    {
        NSMutableData *data = [[NSMutableData alloc] init];
        [data appendData:messageKey];
        [data appendBytes:(((int8_t *)authKey.bytes) + 96 + x) length:32];
        sha1_d = computeSHA1(data);
    }
    
    NSMutableData *aesKey = [[NSMutableData alloc] init];
    [aesKey appendBytes:(((int8_t *)sha1_a.bytes)) length:8];
    [aesKey appendBytes:(((int8_t *)sha1_b.bytes) + 8) length:12];
    [aesKey appendBytes:(((int8_t *)sha1_c.bytes) + 4) length:12];
    keyData.aesKey = [[NSData alloc] initWithData:aesKey];
    
    NSMutableData *aesIv = [[NSMutableData alloc] init];
    [aesIv appendBytes:(((int8_t *)sha1_a.bytes) + 8) length:12];
    [aesIv appendBytes:(((int8_t *)sha1_b.bytes)) length:8];
    [aesIv appendBytes:(((int8_t *)sha1_c.bytes) + 16) length:4];
    [aesIv appendBytes:(((int8_t *)sha1_d.bytes)) length:8];
    keyData.aesIv = [[NSData alloc] initWithData:aesIv];
    
    return keyData;
}

- (void)proceedToSendingMessages:(NSArray *)messageList sessionId:(int64_t)sessionId transport:(id<TGTransport>)transport reportAck:(bool)reportAck requestShortTimeout:(bool)requestShortTimeout allowAcks:(bool)allowAcks
{
    if (messageList.count != 0 || !_messagesIdsForConfirmation[sessionId].first.empty())
    {
        NSMutableArray *messages = [[NSMutableArray alloc] initWithArray:messageList];
        
        if (sessionId == 0)
        {
            TGLog(@"Warning: sessionId is 0");
            return;
        }
        
        bool didAddPing = false;
        
        if (allowAcks && !_messagesIdsForConfirmation[sessionId].first.empty())
        {
            NSMutableArray *confirmMessageIds = [[NSMutableArray alloc] init];
            
            std::set<int64_t>::iterator messagesIdsForConfirmationEnd = _messagesIdsForConfirmation[sessionId].first.end();
            
            for (std::set<int64_t>::iterator it = _messagesIdsForConfirmation[sessionId].first.begin(); it != messagesIdsForConfirmationEnd; it++)
            {
                [confirmMessageIds addObject:[NSNumber numberWithLongLong:*it]];
            }
            
            if (confirmMessageIds.count != 0)
            {
                TLMsgsAck$msgs_ack *msgAck = [[TLMsgsAck$msgs_ack alloc] init];
                msgAck.msg_ids = confirmMessageIds;
                
                TGZeroOutputStream *os = [[TGZeroOutputStream alloc] init];
                TLMetaClassStore::serializeObject(os, msgAck, true);
                
                if (os.currentLength != 0)
                {
                    TGNetworkMessage *networkMessage = [[TGNetworkMessage alloc] init];
                    networkMessage.protoMessage = [[TLProtoMessage$protoMessage alloc] init];
                    
                    networkMessage.protoMessage.msg_id = [self generateMessageId];
                    networkMessage.protoMessage.seqno = [self generateMessageSeqNo:sessionId incerement:false];
                    
                    networkMessage.protoMessage.bytes = os.currentLength;
                    networkMessage.protoMessage.body = msgAck;
                    
                    [messages addObject:networkMessage];
                }
                else
                {
                    TGLog(@"***** Couldn't serialize %@", msgAck);
                }
                
                if ([transport transportRequestClass] & TGRequestClassGeneric)
                {
                    didAddPing = true;
                    
                    TLRPCping_delay_disconnect$ping_delay_disconnect *ping = [[TLRPCping_delay_disconnect$ping_delay_disconnect alloc] init];
                    ping.ping_id = 1;
                    ping.disconnect_delay = TG_DISCONNECT_DELAY;
                    
                    os = [[TGZeroOutputStream alloc] init];
                    TLMetaClassStore::serializeObject(os, ping, true);
                    
                    if (os.currentLength != 0)
                    {
                        TGNetworkMessage *networkMessage = [[TGNetworkMessage alloc] init];
                        networkMessage.protoMessage = [[TLProtoMessage$protoMessage alloc] init];
                        
                        networkMessage.protoMessage.msg_id = [self generateMessageId];
                        networkMessage.protoMessage.seqno = [self generateMessageSeqNo:sessionId incerement:false];
                        
                        networkMessage.protoMessage.bytes = os.currentLength;
                        networkMessage.protoMessage.body = ping;
                        
                        [messages addObject:networkMessage];
                    }
                    else
                    {
                        TGLog(@"***** Couldn't serialize %@", ping);
                    }
                }
            }
            
            _messagesIdsForConfirmation[sessionId].first.clear();
            _messagesIdsForConfirmation[sessionId].second = 0;
        }
        
        if (!didAddPing && allowAcks)
        {
            for (TGNetworkMessage *message in messages)
            {
                if ([message.rawRequest isKindOfClass:[TLRPCaccount_updateStatus class]])
                {
                    TLRPCping_delay_disconnect$ping_delay_disconnect *ping = [[TLRPCping_delay_disconnect$ping_delay_disconnect alloc] init];
                    ping.ping_id = 1;
                    ping.disconnect_delay = TG_DISCONNECT_DELAY;
                    
                    TGZeroOutputStream *os = [[TGZeroOutputStream alloc] init];
                    TLMetaClassStore::serializeObject(os, ping, true);
                    
                    if (os.currentLength != 0)
                    {
                        TGNetworkMessage *networkMessage = [[TGNetworkMessage alloc] init];
                        networkMessage.protoMessage = [[TLProtoMessage$protoMessage alloc] init];
                        
                        networkMessage.protoMessage.msg_id = [self generateMessageId];
                        networkMessage.protoMessage.seqno = [self generateMessageSeqNo:sessionId incerement:false];
                        
                        networkMessage.protoMessage.bytes = os.currentLength;
                        networkMessage.protoMessage.body = ping;
                        
                        [messages addObject:networkMessage];
                    }
                    else
                    {
                        TGLog(@"***** Couldn't serialize %@", ping);
                    }
                    
                    break;
                }
            }
        }
        
        [self sendMessagesToTransport:messages transport:transport sessionId:sessionId reportAck:reportAck requestShortTimeout:requestShortTimeout];
    }
}

- (TGTcpWorker *)dequeueWorkerForRequest:(TGRPCRequest *)request datacenter:(TGDatacenterContext *)datacenter enableMerging:(bool)enableMerging
{
    if (request.requestClass & TGRequestClassDownloadMedia)
    {
        if (enableMerging)
        {
            for (TGTcpWorker *worker in _downloadBusyWorkers)
            {
                if (worker.mergingEnabled && worker.currentRequestTokens.count < 2)
                {
                    return worker;
                }
            }
        }
        
        if (_downloadFreeWorkers.count != 0)
        {
            int index = -1;
            for (TGTcpWorker *worker in _downloadFreeWorkers)
            {
                index++;
                if (worker.datacenter.datacenterId == datacenter.datacenterId)
                {
                    TGTcpWorker *returnWorker = worker;
                    worker.mergingEnabled = enableMerging;
                    
                    [_downloadFreeWorkers removeObjectAtIndex:index];
                    
                    return returnWorker;
                }
            }
        }
        
        TGTcpWorker *worker = [[TGTcpWorker alloc] initWithRequestClasses:TGRequestClassDownloadMedia datacenter:datacenter];
        worker.workerHandler = self;
        worker.mergingEnabled = enableMerging;
        return worker;
    }
    
    return nil;
}

static inline void addMessageToDatacenter(std::map<int, NSMutableArray *> *pMap, int datacenterId, id message)
{
    std::map<int, NSMutableArray *>::iterator it = pMap->find(datacenterId);
    if (it == pMap->end())
    {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:message];
        pMap->insert(std::pair<int, NSMutableArray *>(datacenterId, array));
    }
    else
        [it->second addObject:message];
}

static bool isKindOneOfClasses(id object, NSArray *classList)
{
    for (Class className in classList)
    {
        if ([object isKindOfClass:className])
            return true;
    }
    
    return false;
}

- (void)processRequestQueue:(std::pair<int, int>)forceRequestClassesInDatacenter
{
#warning test
    
#if TARGET_IPHONE_SIMULATOR
    if (_isSuspended)
        return;
#endif
    
    std::map<int, int> datacenterActiveTransportTokens;
    std::set<int> datacenterTransportsToResume;
    
    std::map<int, int> datacenterActiveUploadTransportTokens;
    std::set<int> datacenterUploadTransportsToResume;
    
    for (std::map<int, TGDatacenterContext *>::iterator it = _datacenters.begin(); it != _datacenters.end(); it++)
    {
        TGDatacenterContext *datacenter = it->second;
        int channelToken = [datacenter.datacenterTransport connectedChannelToken];
        if (channelToken)
            datacenterActiveTransportTokens.insert(std::pair<int, int>(it->first, channelToken));
        
        int uploadChannelToken = [datacenter.datacenterUploadTransport connectedChannelToken];
        if (uploadChannelToken)
            datacenterActiveUploadTransportTokens.insert(std::pair<int, int>(it->first, uploadChannelToken));
    }

    for (TGRPCRequest *request in _runningRequests)
    {
        if ((request.requestClass & TGRequestClassGeneric))
        {
            TGDatacenterContext *requestDatacenter = [self datacenterWithId:request.runningDatacenterId];
            if (datacenterActiveTransportTokens.find(requestDatacenter.datacenterId) == datacenterActiveTransportTokens.end())
                datacenterTransportsToResume.insert(requestDatacenter.datacenterId);
        }
        else if ((request.requestClass & TGRequestClassUploadMedia))
        {
            TGDatacenterContext *requestDatacenter = [self datacenterWithId:request.runningDatacenterId];
            if (datacenterActiveUploadTransportTokens.find(requestDatacenter.datacenterId) == datacenterActiveUploadTransportTokens.end())
                datacenterUploadTransportsToResume.insert(requestDatacenter.datacenterId);
        }
    }
    for (TGRPCRequest *request in _requestQueue)
    {
        if ((request.requestClass & TGRequestClassGeneric))
        {
            TGDatacenterContext *requestDatacenter = [self datacenterWithId:request.runningDatacenterId];
            if (datacenterActiveTransportTokens.find(requestDatacenter.datacenterId) == datacenterActiveTransportTokens.end())
                datacenterTransportsToResume.insert(requestDatacenter.datacenterId);
        }
        else if ((request.requestClass & TGRequestClassUploadMedia))
        {
            TGDatacenterContext *requestDatacenter = [self datacenterWithId:request.runningDatacenterId];
            if (datacenterActiveUploadTransportTokens.find(requestDatacenter.datacenterId) == datacenterActiveUploadTransportTokens.end())
                datacenterUploadTransportsToResume.insert(requestDatacenter.datacenterId);
        }
    }
    
    bool haveNetwork = !datacenterActiveTransportTokens.empty() || !datacenterActiveUploadTransportTokens.empty() || _networkStatus != TGNetworkReachabilityStatusNotReachable;
    
    if (datacenterActiveTransportTokens.find(_currentDatacenterId) == datacenterActiveTransportTokens.end())
        datacenterTransportsToResume.insert(_currentDatacenterId);
    
    for (std::set<int>::iterator it = datacenterTransportsToResume.begin(); it != datacenterTransportsToResume.end(); it++)
    {
        TGDatacenterContext *datacenter = [self datacenterWithId:*it];
        if (datacenter.authKey != nil)
        {
            [datacenter.activeDatacenterTransport resumeTransport];
            if (*it == _currentDatacenterId)
            {
                bool isConnecting = ![datacenter.datacenterTransport connectedChannelToken];
                
                if (_isConnecting != isConnecting)
                {
                    _isConnecting = isConnecting;
                    [self dispatchConnectingState];
                }
            }
        }
    }
    
    for (std::set<int>::iterator it = datacenterUploadTransportsToResume.begin(); it != datacenterUploadTransportsToResume.end(); it++)
    {
        TGDatacenterContext *datacenter = [self datacenterWithId:*it];
        [datacenter.activeDatacenterUploadTransport resumeTransport];
    }
    
    std::map<int, NSMutableArray *> genericMessagesToDatacenters;
    std::map<int, NSMutableArray *> uploadMessagesToDatacenters;
    
    std::set<int> unknownDatacenterIds;
    std::set<int> neededDatacenterIds;
    std::set<int> unauthorizedDatacenterIds;
    
    NSTimeInterval currentTime = CFAbsoluteTimeGetCurrent();
    int numberOfRunningRequests = _runningRequests.count;
    for (int i = 0; i < numberOfRunningRequests; i++)
    {
        TGRPCRequest *request = [_runningRequests objectAtIndex:i];
        
        int datacenterId = request.runningDatacenterId;
        if (datacenterId == TG_DEFAULT_DATACENTER_ID)
        {
            if (_movingToDatacenterId != TG_DEFAULT_DATACENTER_ID)
                continue;
            
            datacenterId = _currentDatacenterId;
        }
        
        TGDatacenterContext *requestDatacenter = [self datacenterWithId:datacenterId];
        if (requestDatacenter == nil)
        {
            unknownDatacenterIds.insert(datacenterId);
            continue;
        }
        else if (requestDatacenter.authKey == nil)
        {
            neededDatacenterIds.insert(datacenterId);
            continue;
        }
        else if (!requestDatacenter.authorized && request.runningDatacenterId != TG_DEFAULT_DATACENTER_ID && request.runningDatacenterId != _currentDatacenterId && !(request.requestClass & TGRequestClassEnableUnauthorized))
        {
            unauthorizedDatacenterIds.insert(datacenterId);
            continue;
        }
        
        std::map<int, int>::iterator tokenIt = datacenterActiveTransportTokens.find(requestDatacenter.datacenterId);
        int datacenterTransportToken = tokenIt != datacenterActiveTransportTokens.end() ? tokenIt->second : 0;
        
        std::map<int, int>::iterator uploadTokenIt = datacenterActiveUploadTransportTokens.find(requestDatacenter.datacenterId);
        int datacenterUploadTransportToken = uploadTokenIt != datacenterActiveUploadTransportTokens.end() ? uploadTokenIt->second : 0;
        
        NSTimeInterval maxTimeout = 8.0;
        
        if (request.requestClass & TGRequestClassGeneric)
        {
            if (datacenterTransportToken == 0)
                continue;
        }
        
        if (request.requestClass & TGRequestClassDownloadMedia)
        {
            if (!haveNetwork)
            {
                TGLog(@"Don't have any network connection, skipping download request");
                continue;
            }
            
            maxTimeout = 40.0;
        }
        else if (request.requestClass & TGRequestClassUploadMedia)
        {
            if (datacenterUploadTransportToken == 0)
                continue;
            
            maxTimeout = 30.0;
        }
        
        int64_t sessionId = 0;
        if (request.requestClass & TGRequestClassGeneric)
            sessionId = requestDatacenter.authSessionId;
        else if (request.requestClass & TGRequestClassUploadMedia)
            sessionId = requestDatacenter.authUploadSessionId;
        else if (request.requestClass & TGRequestClassDownloadMedia)
            sessionId = requestDatacenter.authDownloadSessionId;
        
        bool forceThisRequest = (request.requestClass & forceRequestClassesInDatacenter.first) && (forceRequestClassesInDatacenter.second == TG_ALL_DATACENTERS || requestDatacenter.datacenterId == forceRequestClassesInDatacenter.second);
        
        if ([request.rawRequest isKindOfClass:[TLRPCget_future_salts class]] || [request.rawRequest isKindOfClass:[TLRPCdestroy_session class]])
        {
            if (request.runningMessageId != 0)
                [request addRespondMessageId:request.runningMessageId];
            request.runningMessageId = 0;
            request.runningMessageSeqNo = 0;
            request.transportChannelToken = 0;
            forceThisRequest = false;
        }
        
        if (((ABS(currentTime - request.runningStartTime) > maxTimeout) && (currentTime > request.runningMinStartTime || ABS(currentTime - request.runningMinStartTime) > 60.0)) || forceThisRequest)
        {
            if (!forceThisRequest && request.transportChannelToken > 0)
            {
                if ((request.requestClass & TGRequestClassGeneric) && datacenterTransportToken == request.transportChannelToken)
                {
                    TGLog(@"Request token is valid, not retrying %@", request.rawRequest);
                    continue;
                }
                else if ((request.requestClass & TGRequestClassUploadMedia) && datacenterUploadTransportToken == request.transportChannelToken)
                {
                    TGLog(@"Request token is valid, not retrying %@", request.rawRequest);
                    continue;
                }
                else if ((request.requestClass & TGRequestClassDownloadMedia) && request.worker != nil)
                {
                    int downloadToken = [request.worker.transport connectedChannelToken];
                    if (downloadToken != 0 && request.transportChannelToken == downloadToken)
                    {
                        TGLog(@"Request token is valid, not retrying %@", request.rawRequest);
                        continue;
                    }
                }
            }
            
            TGNetworkMessage *networkMessage = [[TGNetworkMessage alloc] init];
            networkMessage.protoMessage = [[TLProtoMessage$protoMessage alloc] init];
            
            if (request.runningMessageSeqNo == 0)
            {
                request.runningMessageSeqNo = [self generateMessageSeqNo:sessionId incerement:true];
                request.runningMessageId = [self generateMessageId];
            }
            networkMessage.protoMessage.msg_id = request.runningMessageId;
            networkMessage.protoMessage.seqno = request.runningMessageSeqNo;
            networkMessage.protoMessage.bytes = request.serializedLength;
            networkMessage.protoMessage.body = request.rpcRequest;
            networkMessage.rawRequest = request.rawRequest;
            networkMessage.requestId = request.token;
            
            request.runningStartTime = currentTime;
            
            if (request.requestClass & TGRequestClassGeneric)
            {
                request.transportChannelToken = datacenterTransportToken;
                addMessageToDatacenter(&genericMessagesToDatacenters, requestDatacenter.datacenterId, networkMessage);
            }
            else if (request.requestClass & TGRequestClassUploadMedia)
            {
                request.transportChannelToken = datacenterUploadTransportToken;
                addMessageToDatacenter(&uploadMessagesToDatacenters, requestDatacenter.datacenterId, networkMessage);
            }
            else if (request.requestClass & TGRequestClassDownloadMedia)
            {
                if (request.worker != nil)
                {
                    [self proceedToSendingMessages:[NSArray arrayWithObject:networkMessage] sessionId:sessionId transport:request.worker.transport reportAck:false requestShortTimeout:false allowAcks:true];
                }
                else
                {
                    [self clearRequestWorker:request reuseable:false];
                    
                    TGTcpWorker *worker = [self dequeueWorkerForRequest:request datacenter:requestDatacenter enableMerging:request.requestClass & TGRequestClassEnableMerging];
                    [self setupRequestWorker:request worker:worker];
                    
                    [self proceedToSendingMessages:[NSArray arrayWithObject:networkMessage] sessionId:sessionId transport:worker.transport reportAck:false requestShortTimeout:false allowAcks:true];
                }
            }
        }
    }
    
    bool updatingState = [ActionStageInstance() requestActorStateNow:@"/tg/service/updatestate"];
    
    if (datacenterActiveTransportTokens.find(_currentDatacenterId) != datacenterActiveTransportTokens.end())
    {   
        if (!updatingState)
        {
            TGDatacenterContext *currentDatacenter = [self datacenterWithId:_currentDatacenterId];
            
            for (std::vector<int64_t>::iterator it = _sessionsToDestroy.begin(); it != _sessionsToDestroy.end(); it++)
            {
                bool alreadyDestroying = false;
                for (TGRPCRequest *request in _runningRequests)
                {
                    if ([request.rawRequest isKindOfClass:[TLRPCdestroy_session class]])
                    {
                        TLRPCdestroy_session *destroySession = (TLRPCdestroy_session *)request.rawRequest;
                        if (destroySession.session_id == *it)
                        {
                            alreadyDestroying = true;
                            break;
                        }
                    }
                }
                if (!alreadyDestroying && CFAbsoluteTimeGetCurrent() - _lastDestroySessionRequestTime > 10.0)
                {
                    _lastDestroySessionRequestTime = CFAbsoluteTimeGetCurrent();
                    TLRPCdestroy_session$destroy_session *destroySession = [[TLRPCdestroy_session$destroy_session alloc] init];
                    destroySession.session_id = *it;
                    
                    TGNetworkMessage *networkMessage = [[TGNetworkMessage alloc] init];
                    networkMessage.protoMessage = [self wrapMessage:destroySession sessionId:currentDatacenter.authSessionId meaningful:false];
                    if (networkMessage.protoMessage != nil)
                        addMessageToDatacenter(&genericMessagesToDatacenters, currentDatacenter.datacenterId, networkMessage);
                }
            }
        }
    }
    
    int genericRunningRequestCount = 0;
    int uploadRunningRequestCount = 0;
    int downloadRunningRequestCount = 0;
    
    for (TGRPCRequest *request in _runningRequests)
    {
        if (request.requestClass & TGRequestClassGeneric)
            genericRunningRequestCount++;
        else if (request.requestClass & TGRequestClassUploadMedia)
            uploadRunningRequestCount++;
        else if (request.requestClass & TGRequestClassDownloadMedia)
            downloadRunningRequestCount++;
    }
    
    for (int i = 0; i < (int)_requestQueue.count; i++)
    {
        TGRPCRequest *request = [_requestQueue objectAtIndex:i];
        if (request.cancelled)
        {
            [self clearRequestWorker:request reuseable:false];
            
            [_requestQueue removeObjectAtIndex:i];
            i--;
            
            continue;
        }
        
        int datacenterId = request.runningDatacenterId;
        if (datacenterId == TG_DEFAULT_DATACENTER_ID)
        {
            if (_movingToDatacenterId != TG_DEFAULT_DATACENTER_ID)
                continue;
            
            datacenterId = _currentDatacenterId;
        }
        
        TGDatacenterContext *requestDatacenter = [self datacenterWithId:datacenterId];
        if (requestDatacenter == nil)
        {
            unknownDatacenterIds.insert(datacenterId);
            continue;
        }
        else if (requestDatacenter.authKey == nil)
        {
            neededDatacenterIds.insert(datacenterId);
            continue;
        }
        else if (!requestDatacenter.authorized && request.runningDatacenterId != TG_DEFAULT_DATACENTER_ID && request.runningDatacenterId != _currentDatacenterId && !(request.requestClass & TGRequestClassEnableUnauthorized))
        {
            unauthorizedDatacenterIds.insert(datacenterId);
            continue;
        }
        
        if ((request.requestClass & TGRequestClassGeneric) && datacenterActiveTransportTokens.find(requestDatacenter.datacenterId) == datacenterActiveTransportTokens.end())
            continue;
        
        if ((request.requestClass & TGRequestClassUploadMedia) && datacenterActiveUploadTransportTokens.find(requestDatacenter.datacenterId) == datacenterActiveUploadTransportTokens.end())
            continue;
        
        if (updatingState && ([request.rawRequest isKindOfClass:[TLRPCaccount_updateStatus class]] || [request.rawRequest isKindOfClass:[TLRPCaccount_registerDevice class]]))
            continue;
        
        if (request.requiresCompletion)
        {
            if (request.requestClass & TGRequestClassGeneric)
            {
                if (genericRunningRequestCount >= 60)
                    continue;
                
                genericRunningRequestCount++;
                
                std::map<int, int>::iterator tokenIt = datacenterActiveTransportTokens.find(requestDatacenter.datacenterId);
                request.transportChannelToken = tokenIt != datacenterActiveTransportTokens.end() ? tokenIt->second : 0;
            }
            else if (request.requestClass & TGRequestClassUploadMedia)
            {
                if (uploadRunningRequestCount >= 20)
                    continue;
                
                std::map<int, int>::iterator uploadTokenIt = datacenterActiveUploadTransportTokens.find(requestDatacenter.datacenterId);
                request.transportChannelToken = uploadTokenIt != datacenterActiveUploadTransportTokens.end() ? uploadTokenIt->second : 0;

                uploadRunningRequestCount++;
            }
            else if (request.requestClass & TGRequestClassDownloadMedia)
            {
                if (!haveNetwork)
                {
                    TGLog(@"Don't have any network connection, skipping download request");
                    continue;
                }
                
                if (downloadRunningRequestCount >= 5 || _downloadBusyWorkers.count >= 5)
                    continue;
                
                downloadRunningRequestCount++;
            }
        }
        
        int64_t messageId = [self generateMessageId];
        
        TGZeroOutputStream *os = [[TGZeroOutputStream alloc] init];
        
        TLMetaClassStore::serializeObject(os, request.rpcRequest, true);
        
        if (os.currentLength != 0)
        {
            int64_t sessionId = 0;
            if (request.requestClass & TGRequestClassGeneric)
                sessionId = requestDatacenter.authSessionId;
            else if (request.requestClass & TGRequestClassUploadMedia)
                sessionId = requestDatacenter.authUploadSessionId;
            else if (request.requestClass & TGRequestClassDownloadMedia)
                sessionId = requestDatacenter.authDownloadSessionId;
            
            TGNetworkMessage *networkMessage = [[TGNetworkMessage alloc] init];
            networkMessage.protoMessage = [[TLProtoMessage$protoMessage alloc] init];
            networkMessage.protoMessage.msg_id = messageId;
            networkMessage.protoMessage.seqno = [self generateMessageSeqNo:sessionId incerement:true];
            networkMessage.protoMessage.bytes = os.currentLength;
            networkMessage.protoMessage.body = request.rpcRequest;
            networkMessage.rawRequest = request.rawRequest;
            networkMessage.requestId = request.token;
            
            request.runningMessageId = messageId;
            request.runningMessageSeqNo = networkMessage.protoMessage.seqno;
            request.serializedLength = os.currentLength;
            request.runningStartTime = CFAbsoluteTimeGetCurrent();
            if (request.requiresCompletion)
                [_runningRequests addObject:request];
            
            if (request.requestClass & TGRequestClassGeneric)
                addMessageToDatacenter(&genericMessagesToDatacenters, requestDatacenter.datacenterId, networkMessage);
            else if (request.requestClass & TGRequestClassUploadMedia)
                addMessageToDatacenter(&uploadMessagesToDatacenters, requestDatacenter.datacenterId, networkMessage);
            else if ((request.requestClass & TGRequestClassDownloadMedia))
            {
                [self clearRequestWorker:request reuseable:false];
                
                TGTcpWorker *worker = [self dequeueWorkerForRequest:request datacenter:requestDatacenter enableMerging:request.requestClass & TGRequestClassEnableMerging];
                [self setupRequestWorker:request worker:worker];
                
                [self proceedToSendingMessages:[NSArray arrayWithObject:networkMessage] sessionId:sessionId transport:worker.transport reportAck:false requestShortTimeout:false allowAcks:true];
            }
            else
                TGLog(@"***** Error: request %@ has undefined session", request.rawRequest);
        }
        else
        {
            TGLog(@"***** Couldn't serialize %@", request.rawRequest);
        }
        
        [_requestQueue removeObjectAtIndex:i];
        i--;
    }
    
    for (std::map<int, TGDatacenterContext *>::iterator it = _datacenters.begin(); it != _datacenters.end(); it++)
    {
        if (genericMessagesToDatacenters.find(it->first) == genericMessagesToDatacenters.end() && [it->second.datacenterTransport connectedChannelToken] && !_messagesIdsForConfirmation[it->second.authSessionId].first.empty())
        {
            //genericMessagesToDatacenters.insert(std::pair<int, NSMutableArray *>(it->first, [[NSMutableArray alloc] init]));
        }
    }
    
    for (std::map<int, TGDatacenterContext *>::iterator it = _datacenters.begin(); it != _datacenters.end(); it++)
    {
        if (uploadMessagesToDatacenters.find(it->first) == uploadMessagesToDatacenters.end() && [it->second.datacenterUploadTransport connectedChannelToken] && !_messagesIdsForConfirmation[it->second.authUploadSessionId].first.empty())
        {
            uploadMessagesToDatacenters.insert(std::pair<int, NSMutableArray *>(it->first, [[NSMutableArray alloc] init]));
        }
    }
    
    if ((forceRequestClassesInDatacenter.first & TGRequestClassGeneric))
    {
        if (forceRequestClassesInDatacenter.second == TG_ALL_DATACENTERS)
        {
            for (std::map<int, TGDatacenterContext *>::iterator it = _datacenters.begin(); it != _datacenters.end(); it++)
            {
                if ([it->second.datacenterTransport connectedChannelToken])
                {
                    TLRPCping_delay_disconnect$ping_delay_disconnect *ping = [[TLRPCping_delay_disconnect$ping_delay_disconnect alloc] init];
                    ping.disconnect_delay = TG_DISCONNECT_DELAY;
                    ping.ping_id = -it->first;
                    
                    if (!_isWaitingForFirstData && it->second.datacenterId == _currentDatacenterId)
                    {
                        self.isWaitingForFirstData = true;
                        [self dispatchConnectingState];
                    }
                    
                    _holdUpdateMessagesInDatacenter.insert(it->first);
                    
                    TGNetworkMessage *networkMessage = [[TGNetworkMessage alloc] init];
                    networkMessage.protoMessage = [self wrapMessage:ping sessionId:it->second.authSessionId meaningful:false];
                    
                    addMessageToDatacenter(&genericMessagesToDatacenters, it->first, networkMessage);
                }
            }
        }
        else
        {
            TGDatacenterContext *datacenter = [self datacenterWithId:forceRequestClassesInDatacenter.second];
            
            if ([datacenter.datacenterTransport connectedChannelToken])
            {
                TLRPCping_delay_disconnect$ping_delay_disconnect *ping = [[TLRPCping_delay_disconnect$ping_delay_disconnect alloc] init];
                ping.disconnect_delay = TG_DISCONNECT_DELAY;
                ping.ping_id = -datacenter.datacenterId;
                
                if (!_isWaitingForFirstData && datacenter.datacenterId == _currentDatacenterId)
                {
                    self.isWaitingForFirstData = true;
                    [self dispatchConnectingState];
                }
                
                _holdUpdateMessagesInDatacenter.insert(datacenter.datacenterId);
                
                TGNetworkMessage *networkMessage = [[TGNetworkMessage alloc] init];
                networkMessage.protoMessage = [self wrapMessage:ping sessionId:datacenter.authSessionId meaningful:false];
                
                addMessageToDatacenter(&genericMessagesToDatacenters, datacenter.datacenterId, networkMessage);
            }
        }
    }
    
    for (std::map<int, NSMutableArray *>::iterator it = genericMessagesToDatacenters.begin(); it != genericMessagesToDatacenters.end(); it++)
    {
        TGDatacenterContext *datacenter = [self datacenterWithId:it->first];
        if (datacenter != nil)
        {
            bool scannedPreviousRequests = false;
            int64_t lastSendMessageRpcId = 0;
            
            bool hasSendMessage = false;
            bool hasTyping = false;
            
            static NSArray *sequentialMessageClasses = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
            {
                sequentialMessageClasses = @[
                    [TLRPCmessages_sendMessage class],
                    [TLRPCmessages_sendMedia class],
                    [TLRPCmessages_forwardMessage class],
                    [TLRPCmessages_sendEncrypted class],
                    [TLRPCmessages_sendEncryptedFile class]
                ];
            });
            
            for (TGNetworkMessage *networkMessage in it->second)
            {
                TLProtoMessage *message = networkMessage.protoMessage;
                
                id rawRequest = networkMessage.rawRequest;
                
                if (isKindOneOfClasses(rawRequest, sequentialMessageClasses))
                {
                    if ([rawRequest isKindOfClass:[TLRPCmessages_sendMessage class]])
                        hasSendMessage = true;
                    
                    if (!scannedPreviousRequests)
                    {
                        scannedPreviousRequests = true;
                        
                        std::set<int64_t> currentRequests;
                        for (TGNetworkMessage *currentNetworkMessage in it->second)
                        {
                            TLProtoMessage *currentMessage = currentNetworkMessage.protoMessage;
                            
                            id currentRawRequest = currentNetworkMessage.rawRequest;
                            
                            if (isKindOneOfClasses(currentRawRequest, sequentialMessageClasses))
                            {
                                currentRequests.insert(currentMessage.msg_id);
                            }
                        }
                        
                        int64_t maxRequestId = 0;
                        for (TGRPCRequest *request in _runningRequests)
                        {
                            if (isKindOneOfClasses(request.rawRequest, sequentialMessageClasses))
                            {
                                if (currentRequests.find(request.runningMessageId) == currentRequests.end())
                                    maxRequestId = MAX(maxRequestId, request.runningMessageId);
                            }
                        }
                        
                        lastSendMessageRpcId = maxRequestId;
                    }
                    
                    if (lastSendMessageRpcId != 0 && lastSendMessageRpcId != message.msg_id)
                    {
                        TLInvokeAfterMsg$invokeAfterMsg *invokeAfterMsg = [[TLInvokeAfterMsg$invokeAfterMsg alloc] init];
                        invokeAfterMsg.msg_id = lastSendMessageRpcId;
                        invokeAfterMsg.query = message.body;
                        
#if TARGET_IPHONE_SIMULATOR
                        if ([rawRequest isKindOfClass:[TLRPCmessages_sendMessage class]])
                            TGLog(@"%@ [%lld] depends on [%lld]", ((TLRPCmessages_sendMessage *)rawRequest).message, message.msg_id, lastSendMessageRpcId);
#endif
                        
                        message.body = invokeAfterMsg;
                        message.bytes = message.bytes + 4 + 8;
                    }
                    else
                    {
#if TARGET_IPHONE_SIMULATOR
                        if ([rawRequest isKindOfClass:[TLRPCmessages_sendMessage class]])
                            TGLog(@"%@ [%lld] depends on nothing", ((TLRPCmessages_sendMessage *)rawRequest).message, message.msg_id);
#endif
                    }
                    
                    lastSendMessageRpcId = message.msg_id;
                }
                else if ([rawRequest isKindOfClass:[TLRPCmessages_setTyping class]])
                {
                    hasTyping = true;
                }
            }
            
            bool forceRequest = (forceRequestClassesInDatacenter.first & TGRequestClassGeneric);
            
            [self proceedToSendingMessages:it->second sessionId:datacenter.authSessionId transport:datacenter.activeDatacenterTransport reportAck:hasSendMessage requestShortTimeout:it->second.count != 0 allowAcks:forceRequest || (!hasSendMessage && !hasTyping)];
        }
    }
    
    for (std::map<int, NSMutableArray *>::iterator it = uploadMessagesToDatacenters.begin(); it != uploadMessagesToDatacenters.end(); it++)
    {
        TGDatacenterContext *datacenter = [self datacenterWithId:it->first];
        if (datacenter != nil)
            [self proceedToSendingMessages:it->second sessionId:datacenter.authUploadSessionId transport:datacenter.activeDatacenterUploadTransport reportAck:false requestShortTimeout:false allowAcks:true];
    }
    
    bool hasActiveRequests = false;
    for (TGRPCRequest *request in _runningRequests)
    {
        if (request.requestClass & TGRequestClassHidesActivityIndicator)
            continue;
        
        if (request.requestClass & (TGRequestClassGeneric | TGRequestClassUploadMedia))
        {
            hasActiveRequests = true;
            break;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [_delegate setNetworkActivity:hasActiveRequests];
    });
    
    for (std::set<int>::iterator it = unknownDatacenterIds.begin(); it != unknownDatacenterIds.end(); it++)
    {
        if (![ActionStageInstance() requestActorStateNow:[[NSString alloc] initWithFormat:@"/tg/network/updateDatacenterData/(%d)", *it]])
        {
            [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/network/updateDatacenterData/(%d)", *it] options:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:*it], @"datacenterId", nil] watcher:self];
        }
    }
    
    for (std::set<int>::iterator it = neededDatacenterIds.begin(); it != neededDatacenterIds.end(); it++)
    {
        if (*it != _currentDatacenterId && *it != _movingToDatacenterId)
        {
            if (![ActionStageInstance() requestActorStateNow:[[NSString alloc] initWithFormat:@"/tg/network/datacenterHandshake/(%d)", *it]])
            {
                [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/network/datacenterHandshake/(%d)", *it] options:[[NSDictionary alloc] initWithObjectsAndKeys:[self datacenterWithId:*it], @"datacenter", nil] watcher:self];
            }
        }
    }
    
    for (std::set<int>::iterator it = unauthorizedDatacenterIds.begin(); it != unauthorizedDatacenterIds.end(); it++)
    {
        if (*it != _currentDatacenterId && *it != _movingToDatacenterId && _delegate.clientUserId != 0 && _unavailableDatacenterIds.find(*it) == _unavailableDatacenterIds.end())
        {
            if (![ActionStageInstance() requestActorStateNow:[[NSString alloc] initWithFormat:@"/tg/network/exportDatacenterAuthorization/(%d)", *it]])
            {
                [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/network/exportDatacenterAuthorization/(%d)", *it] options:[[NSDictionary alloc] initWithObjectsAndKeys:[self datacenterWithId:*it], @"datacenter", nil] watcher:self];
            }
        }
    }
}

- (NSData *)createTransportData:(NSArray *)messages sessionId:(int64_t)sessionId quickAckId:(int *)quickAckId transport:(id<TGTransport>)transport
{
    TGDatacenterContext *datacenter = [transport datacenter];
    if (datacenter.authKey == nil)
        return nil;
    
    NSData *transportData = nil;
    
    int64_t messageId = 0;
    id<TLObject> messageBody = 0;
    int32_t messageSeqNo = 0;
    
    if (messages.count == 1)
    {
        TGNetworkMessage *networkMessage = [messages objectAtIndex:0];
        TLProtoMessage *message = networkMessage.protoMessage;
        
#if (defined(DEBUG) || defined(INTERNAL_RELEASE)) && !defined(DISABLE_LOGGING)
        int layer = 0;
        id body = nil;
#if TLCurrentLayer > 0
        if ([message.body isKindOfClass:[TLInvokeWithCurrentLayerClass class]])
        {
            body = [(TLInvokeWithCurrentLayerClass *)message.body query];
            layer = 1;
        }
        else
#endif
            body = message.body;
        TGLog(@"%llx:DC%d> Send message (%d, %lld): %@ (%d)", sessionId, datacenter.datacenterId, message.seqno, message.msg_id, body, layer);
#endif
        
        int64_t currentTime = (int)(CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970) + _timeDifference;
        if (datacenter.authKey != nil && (message.msg_id < (currentTime - 30) * 4294967296L || message.msg_id > (currentTime + 25) * 4294967296L))
        {
            TLMessageContainer$msg_container *messageContainer = [[TLMessageContainer$msg_container alloc] init];
            messageContainer.messages = [NSArray arrayWithObject:message];
            
            messageId = [self generateMessageId];
            messageBody = messageContainer;
            messageSeqNo = [self generateMessageSeqNo:sessionId incerement:false];
            
            std::vector<int64_t> &vector = _containerIdToMessageIds[messageId] = std::vector<int64_t>();
            vector.push_back(message.msg_id);
            
            maybeCollectGarbageInOutgoingContainers(&_containerIdToMessageIds);
        }
        else
        {
            messageId = message.msg_id;
            messageBody = (id<TLObject>)message.body;
            messageSeqNo = message.seqno;
        }
    }
    else
    {
        TLMessageContainer$msg_container *messageContainer = [[TLMessageContainer$msg_container alloc] init];
        
        NSMutableArray *containerMessages = [[NSMutableArray alloc] initWithCapacity:messages.count];
        
        for (TGNetworkMessage *networkMessage in messages)
        {
            TLProtoMessage *message = networkMessage.protoMessage;
            [containerMessages addObject:message];
            
#if (defined(DEBUG) || defined(INTERNAL_RELEASE)) && !defined(DISABLE_LOGGING)
            int layer = 0;
            id body = nil;
#if TLCurrentLayer > 0
            if ([message.body isKindOfClass:[TLInvokeWithCurrentLayerClass class]])
            {
                body = [(TLInvokeWithCurrentLayerClass *)message.body query];
                layer = 1;
            }
            else
#endif
                body = message.body;
            TGLog(@"%llx:DC%d> Send message (%d, %lld): %@ (%d)", sessionId, datacenter.datacenterId, message.seqno, message.msg_id, body, layer);
#endif
        }
        
        messageContainer.messages = containerMessages;
        
        messageId = [self generateMessageId];
        messageBody = messageContainer;
        messageSeqNo = [self generateMessageSeqNo:sessionId incerement:false];
        
        std::vector<int64_t> &vector = _containerIdToMessageIds.insert(std::pair<int64_t, std::vector<int64_t> >(messageId, std::vector<int64_t>())).first->second;
        for (TLProtoMessage *message in containerMessages)
        {
            vector.push_back(message.msg_id);
        }
        
        maybeCollectGarbageInOutgoingContainers(&_containerIdToMessageIds);
    }
    
    NSData *messageData = nil;
    NSOutputStream *innerMessageOs = [[NSOutputStream alloc] initToMemory];
    [innerMessageOs open];
    TLMetaClassStore::serializeObject(innerMessageOs, messageBody, true);
    messageData = [innerMessageOs currentBytes];
    [innerMessageOs close];
    
    if (datacenter.authKey == nil)
    {
        TGLog(@"***** Session state is not 'handshake', but auth key is nil");
        return nil;
    }
    
    NSOutputStream *innerOs = [NSOutputStream outputStreamToMemory];
    [innerOs open];
    int64_t serverSalt = [datacenter selectServerSalt:((int)(CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970) + _timeDifference)];
    if (serverSalt == 0)
        [innerOs writeInt64:0];
    else
        [innerOs writeInt64:serverSalt];
    [innerOs writeInt64:sessionId];
    [innerOs writeInt64:messageId];
    [innerOs writeInt32:messageSeqNo];
    [innerOs writeInt32:messageData.length];
    [innerOs writeData:messageData];
    NSData *innerData = [innerOs currentBytes];
    [innerOs close];
    
    NSData *messageKeyFull = computeSHA1(innerData);
    NSData *messageKey = [[NSData alloc] initWithBytes:(((int8_t *)messageKeyFull.bytes) + messageKeyFull.length - 16) length:16];
    
    if (quickAckId != NULL)
    {
        int fullAckId = *((int *)(messageKeyFull.bytes));
        *quickAckId = fullAckId & 0x7fffffff;
    }
    
    MessageKeyData keyData = [self generateMessageKeyData:messageKey incoming:false datacenter:[transport datacenter]];
    
    NSMutableData *dataForEncryption = [[NSMutableData alloc] init];
    [dataForEncryption appendData:innerData];
    while (dataForEncryption.length % 16 != 0)
    {
        int8_t zero = 0;//TODO random
        [dataForEncryption appendBytes:&zero length:1];
    }
    
    encryptWithAESInplace(dataForEncryption, keyData.aesKey, keyData.aesIv, true);
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:datacenter.authKeyId];
    [data appendData:messageKey];
    [data appendData:dataForEncryption];
    transportData = data;
    
    return transportData;
}

- (void)sendMessagesToTransport:(NSArray *)messagesToSend transport:(id<TGTransport>)transport sessionId:(int64_t)sessionId reportAck:(bool)reportAck requestShortTimeout:(bool)requestShortTimeout
{
    if (messagesToSend.count == 0)
        return;
    
    if (transport == nil)
    {
        TGLog(@"***** Transport for session 0x%x not found", sessionId);
        return;
    }
    
    NSMutableArray *currentMessages = nil;
    NSArray *leftMessages = nil;
    
    if (messagesToSend.count > 1)
    {
        currentMessages = [[NSMutableArray alloc] initWithCapacity:messagesToSend.count];
        leftMessages = currentMessages;
        
        int currentSize = 0;
        for (TGNetworkMessage *networkMessage in messagesToSend)
        {
            [currentMessages addObject:networkMessage];
            
            TLProtoMessage *protoMessage = networkMessage.protoMessage;
            
            currentSize += protoMessage.bytes;
            
            if (currentSize >= 3 * 1024)
            {
                int quickAckId = 0;
                NSData *transportData = [self createTransportData:currentMessages sessionId:sessionId quickAckId:&quickAckId transport:transport];
                
                if (transportData != nil)
                {
                    if (reportAck && quickAckId != 0)
                    {
                        std::vector<int64_t> requestIds;
                        
                        for (TGNetworkMessage *networkMessage in currentMessages)
                        {
                            if (networkMessage.requestId != 0)
                                requestIds.push_back(networkMessage.requestId);
                        }
                        
                        if (!requestIds.empty())
                            _quickAckIdToRequestIds[quickAckId].insert(requestIds.begin(), requestIds.end());
                    }
                    [transport sendData:transportData reportAck:reportAck startResponseTimeout:requestShortTimeout];
                }
                else
                    TGLog(@"***** Transport data is nil");
                
                currentSize = 0;
                [currentMessages removeAllObjects];
            }
        }
    }
    else
        leftMessages = messagesToSend;
    
    if (leftMessages.count != 0)
    {
        int quickAckId = 0;
        NSData *transportData = [self createTransportData:leftMessages sessionId:sessionId quickAckId:&quickAckId transport:transport];
        
        if (transportData != nil)
        {
            if (reportAck && quickAckId != 0)
            {
                std::vector<int64_t> requestIds;
                
                for (TGNetworkMessage *networkMessage in leftMessages)
                {
                    if (networkMessage.requestId != 0)
                        requestIds.push_back(networkMessage.requestId);
                }
                
                if (!requestIds.empty())
                    _quickAckIdToRequestIds[quickAckId].insert(requestIds.begin(), requestIds.end());
            }
            
            [transport sendData:transportData reportAck:reportAck startResponseTimeout:requestShortTimeout];
        }
        else
            TGLog(@"***** Transport data is nil");
    }
}

- (void)messagesConfirmed:(NSArray *)messageIds
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        std::set<int64_t> ids;
        for (NSNumber *nMid in messageIds)
        {
            ids.insert([nMid longLongValue]);
        }
        
        int nRequests = _runningRequests.count;
        for (int i = 0; i < nRequests; i++)
        {
            TGRPCRequest *request = [_runningRequests objectAtIndex:i];
            if (ids.find(request.runningMessageId) != ids.end())
            {
                request.confirmed = true;
            }
        }
    }];
}

- (void)rpcCompleted:(int64_t)requestMsgId
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        int nRequests = _runningRequests.count;
        for (int i = 0; i < nRequests; i++)
        {
            TGRPCRequest *request = [_runningRequests objectAtIndex:i];
            if ([request respondsToMessageId:requestMsgId])
            {
                [self clearRequestWorker:request reuseable:true];
                
                [_runningRequests removeObjectAtIndex:i];
                i--;
                nRequests--;
            }
        }
    }];
}

- (void)dumpScheme
{
    TLRPChelp_getScheme$help_getScheme *getScheme = [[TLRPChelp_getScheme$help_getScheme alloc] init];
    
    [self performRpc:getScheme completionBlock:^(TLScheme *response, __unused int64_t responseTime, TLError *error)
    {
        if (error == nil)
        {
            if ([response isKindOfClass:[TLScheme$scheme class]])
            {
                TLScheme$scheme *concreteScheme = (TLScheme$scheme *)response;
                
                //TLMetaClassStore::mergeScheme(concreteScheme);
                
                TGLog(@"%@", concreteScheme.scheme_raw);
            }
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (void)transportHasDisconnectedAllChannels:(id<TGTransport>)transport
{
    TGDatacenterContext *datacenter = [transport datacenter];
    if (datacenter.datacenterId == _currentDatacenterId)
    {
        if ([transport transportRequestClass] & TGRequestClassGeneric)
        {
            if (!_isConnecting)
            {
                _isConnecting = true;
                
                [self dispatchConnectingState];
            }
        }
        else if ([transport transportRequestClass] & TGRequestClassUploadMedia)
        {
            [datacenter stopDatacenterUploadTransport];
        }
    }
    
    if (datacenter.datacenterId != _currentDatacenterId)
    {
        if ([transport transportRequestClass] & TGRequestClassGeneric)
        {
            TGLog(@"===== Suspending secondary DC connection");
            [datacenter stopDatacenterTransport];
        }
        else if ([transport transportRequestClass] & TGRequestClassUploadMedia)
        {
            TGLog(@"===== Suspending secondary DC upload connection");
            [datacenter stopDatacenterUploadTransport];
        }
    }
}

- (void)transportReceivedQuickAck:(int)quickAckId
{
    bool found = false;
    
    std::map<int, std::set<int64_t> >::iterator it = _quickAckIdToRequestIds.find(quickAckId);
    if (it != _quickAckIdToRequestIds.end())
    {
        for (TGRPCRequest *request in _runningRequests)
        {
            if (it->second.find(request.token) != it->second.end())
            {
                found = true;
                
                //TGLog(@"Received QuickAck %x for request %@", quickAckId, request.rawRequest);
                
                if (request.quickAckBlock)
                    request.quickAckBlock();
            }
        }
        
        _quickAckIdToRequestIds.erase(it);
    }
    
    /*if (!found)
    {
        TGLog(@"QuickAck %x ingored, waiting for the following:");
        for (std::map<int, std::set<int64_t> >::iterator it = _quickAckIdToRequestIds.begin(); it != _quickAckIdToRequestIds.end(); it++)
        {
            TGLog(@"   %x", it->first);
        }
    }*/
}

- (void)transportHasConnectedChannels:(id<TGTransport>)transport
{
    int requestClass = [transport transportRequestClass];
    if ([transport datacenter].datacenterId == _currentDatacenterId && requestClass & TGRequestClassGeneric)
    {
        if (_isConnecting)
        {
            _isConnecting = false;
            [self dispatchConnectingState];
        }

        if (!_isReady)
            return;
    }
    
    if ([transport datacenter].authKey != nil)
        [self processRequestQueue:std::pair<int, int>([transport transportRequestClass], transport.datacenter.datacenterId)];
}

- (void)setIsWaitingForFirstData:(bool)isWaitingForFirstData
{
    _isWaitingForFirstData = isWaitingForFirstData;
}

- (void)dispatchConnectingState
{
    int state = [ActionStageInstance() requestActorStateNow:@"/tg/service/updatestate"] ? 1 : 0;
    if (_isWaitingForFirstData)
        state |= 1;
    if (_isConnecting)
        state |= 2;
    if (_isOffline)
        state |= 4;
    
    [ActionStageInstance() dispatchResource:@"/tg/service/synchronizationstate" resource:[[SGraphObjectNode alloc] initWithObject:[NSNumber numberWithInt:state]]];
}

- (void)cancelRpc:(NSObject *)token notifyServer:(bool)notifyServer
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        if ([token isKindOfClass:[NSNumber class]])
        {            
            int callToken = [(NSNumber *)token intValue];
            
            bool found = false;
            
            for (int i = 0; i < (int)_requestQueue.count; i++)
            {
                TGRPCRequest *request = [_requestQueue objectAtIndex:i];
                if (request.token == callToken)
                {
                    found = true;
                    [self clearRequestWorker:request reuseable:false];
                    
                    request.cancelled = true;
                    TGLog(@"===== Cancelled queued rpc request %@", [request.rawRequest description]);
                    [_requestQueue removeObjectAtIndex:i];
                    i--;
                    
                    break;
                }
            }
            
            for (int i = 0; i < (int)_runningRequests.count; i++)
            {
                TGRPCRequest *request = [_runningRequests objectAtIndex:i];
                if (request.token == callToken)
                {
                    found = true;
                    [self clearRequestWorker:request reuseable:false];
                    
                    TGLog(@"===== Cancelled running rpc request %@", [request.rawRequest description]);
                    
                    if (request.requestClass & TGRequestClassGeneric)
                    {
                        if (notifyServer)
                        {
                            TLRPCrpc_drop_answer$rpc_drop_answer *dropAnswer = [[TLRPCrpc_drop_answer$rpc_drop_answer alloc] init];
                            dropAnswer.req_msg_id = request.runningMessageId;
                            [self performRpc:dropAnswer completionBlock:nil progressBlock:nil requiresCompletion:false requestClass:request.requestClass];
                        }
                    }
                    else if (request.requestClass & TGRequestClassUploadMedia)
                    {
                        TGDatacenterContext *requestDatacenter = [self datacenterWithId:request.runningDatacenterId];
                        if (requestDatacenter != nil && [requestDatacenter.datacenterUploadTransport connectedChannelToken])
                            [requestDatacenter stopDatacenterUploadTransport];
                    }
                    
                    request.cancelled = true;
                    [_runningRequests removeObjectAtIndex:i];
                    i--;
                    
                    break;
                }
            }
            
            if (!found)
                TGLog(@"***** Warning: cancelling unknown request");
        }
        else
        {
            TGLog(@"***** Error: cancelRpc: unknown cancel token type");
        }
    }];
}

#if (defined(DEBUG) || defined(INTERNAL_RELEASE)) && !defined(DISABLE_LOGGING)
static void dumpObject(id<TLObject> message, NSString *indent)
{
    if (indent.length == 0)
        TGLog(@"Received message: %@", [message class]);
    else
        TGLog(@"%@%@", indent, message);
    
    if ([message isKindOfClass:[TLMessageContainer class]])
    {
        int count = 0;
        for (TLProtoMessage *protoMessage in ((TLMessageContainer *)message).messages)
        {
            count++;
#if !TARGET_IPHONE_SIMULATOR
            if (count > 8)
                return;
#endif
            dumpObject((id<TLObject>)protoMessage.body, [[NSString alloc] initWithFormat:@"%@ id %lld >", indent, protoMessage.msg_id]);
        }
    }
}
#else
#define dumpObject(x, ...) ((void)x)
#endif

static inline bool messageNeedsConfirmation(int32_t seqNo)
{
    return ((seqNo % 2) != 0);
}

- (void)transport:(id<TGTransport>)__unused transport updatedRequestProgress:(int64_t)requestMessageId length:(int)length progress:(float)progress
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        for (TGRPCRequest *request in _runningRequests)
        {
            if ([request respondsToMessageId:requestMessageId])
            {
                if (request.progressBlock)
                    request.progressBlock(length, progress);
                
                break;
            }
        }
    }];
}

- (void)transport:(id<TGTransport>)transport receivedData:(NSData *)data
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        TGDatacenterContext *datacenter = [transport datacenter];
        
#if TARGET_IPHONE_SIMULATOR
        TGLog(@"(IN: %d bytes)", data.length);
#endif
        
        NSInputStream *is = [[NSInputStream alloc] initWithData:data];
        [is open];
        
        int64_t keyId = [is readInt64];
        
        if (keyId == 0)
        {
            TGLog(@"***** Error: unencrypted message received, ignoring");
            
            [is close];
        }
        else
        {
            if (datacenter.authKeyId == nil || memcmp(&keyId, datacenter.authKeyId.bytes, 8))
            {
                TGLog(@"***** Error: invalid auth key id");
                [is close];
                return;
            }
            
            NSData *messageKey = [is readData:16];
            MessageKeyData keyData = [self generateMessageKeyData:messageKey incoming:true datacenter:datacenter];
            
            NSMutableData *messageData = [is readMutableData:(data.length - 24)];
            encryptWithAESInplace(messageData, keyData.aesKey, keyData.aesIv, false);
            
            NSInputStream *messageIs = [NSInputStream inputStreamWithData:messageData];
            [messageIs open];
            int64_t messageServerSalt = [messageIs readInt64];
            int64_t messageSessionId = [messageIs readInt64];
            
            bool doNotProcess = false;
            
            int64_t messageId = [messageIs readInt64];
            int32_t messageSeqNo = [messageIs readInt32];
            int32_t messageLength = [messageIs readInt32];
            
            if (messageSessionId != datacenter.authSessionId && messageSessionId != datacenter.authUploadSessionId && messageSessionId != datacenter.authDownloadSessionId)
            {
                TGLog(@"***** Error: invalid message session ID (0x%llx instead of 0x%llx, 0x%llx, 0x%llx)", messageSessionId, datacenter.authSessionId, datacenter.authUploadSessionId, datacenter.authDownloadSessionId);
                [messageIs close];
                
                if (datacenter.datacenterId == _currentDatacenterId && _isWaitingForFirstData)
                {
                    TLRPCping_delay_disconnect$ping_delay_disconnect *ping = [[TLRPCping_delay_disconnect$ping_delay_disconnect alloc] init];
                    ping.disconnect_delay = TG_DISCONNECT_DELAY;
                    ping.ping_id = -datacenter.datacenterId;
                    
                    TGNetworkMessage *networkMessage = [[TGNetworkMessage alloc] init];
                    networkMessage.protoMessage = [self wrapMessage:ping sessionId:datacenter.authSessionId meaningful:false];
                    
                    [self proceedToSendingMessages:@[networkMessage] sessionId:datacenter.authSessionId transport:datacenter.datacenterTransport reportAck:false requestShortTimeout:false allowAcks:false];
                }
                
                return;
            }
            
            if (isMessageIdProcessed(&_processedMessageIdsSet, messageSessionId, messageId))
            {
                TGLog(@"===== Duplicate message id %lld received, ignoring", messageId);
                [messageIs close];
                doNotProcess = true;
            }
            
            NSData *realMessageKeyFull = computeSHA1ForSubdata(messageData, 0, MIN(messageLength + 4 + 4 + 8 + 8 + 8, (int)messageData.length));
            NSData *realMessageKey = [[NSData alloc] initWithBytes:(((uint8_t *)realMessageKeyFull.bytes) + realMessageKeyFull.length - 16) length:16];
            
            if (![realMessageKey isEqual:messageKey])
            {
                TGLog(@"***** Error: invalid message key");
                [is close];
                return;
            }
            
            if (messageNeedsConfirmation(messageSeqNo))
            {
                if ([transport transportRequestClass] & TGRequestClassGeneric)
                    [self addMessageIdForConfirmation:messageSessionId messageId:messageId messageSize:messageLength];
                else
                {
                    _messagesIdsForConfirmation[messageSessionId].first.insert(messageId);
                    _messagesIdsForConfirmation[messageSessionId].second += messageLength;
                }
            }
            
            if (!doNotProcess)
            {                
                NSError *error = nil;
                int32_t signature = [messageIs readInt32];
                id<TLObject> message = TLMetaClassStore::constructObject(messageIs, signature, self, nil, &error);
                [messageIs close];
                
                if (error != nil)
                {
                    TGLog(@"***** Error parsing message: %@", error);
                    TGLog(@"Data: %@", messageData);
                }
                else
                {
                    if ([message isKindOfClass:[TLMessageContainer class]])
                    {
                        TLMessageContainer *messageContainer = (TLMessageContainer *)message;
                        for (TLProtoMessage *innerMessage in messageContainer.messages)
                        {
                            int64_t innerMessageId = innerMessage.msg_id;
                            if (messageNeedsConfirmation(innerMessage.seqno))
                            {
                                if ([transport transportRequestClass] & TGRequestClassGeneric)
                                    [self addMessageIdForConfirmation:messageSessionId messageId:innerMessageId messageSize:innerMessage.bytes];
                                else
                                {
                                    _messagesIdsForConfirmation[messageSessionId].first.insert(innerMessageId);
                                    _messagesIdsForConfirmation[messageSessionId].second += innerMessage.bytes;
                                }
                            }
                        }
                    }
                    
                    dumpObject(message, [NSString stringWithFormat:@"%llx(%lld)> ", messageSessionId, messageId]);
                    
                    [self processMessage:message messageId:messageId messageSeqNo:messageSeqNo messageSalt:messageServerSalt fromTransport:transport sessionId:messageSessionId innerMessageId:0 containerMessageId:0];
                    
                    addProcessedMessageId(&_processedMessageIdsSet, messageSessionId, messageId);
                }
            }
            else
            {
                if ([transport transportRequestClass] & TGRequestClassGeneric)
                {
                    [self addMessageIdForConfirmation:messageSessionId messageId:messageId messageSize:messageLength];
                }
            }
            
            if (!([transport transportRequestClass] & TGRequestClassGeneric))
            {
                if (!_messagesIdsForConfirmation[messageSessionId].first.empty())
                    [self proceedToSendingMessages:nil sessionId:messageSessionId transport:transport reportAck:false requestShortTimeout:false allowAcks:true];
            }
        }
    }];
}

- (void)addMessageIdForConfirmation:(int64_t)sessionId messageId:(int64_t)messageId messageSize:(int)messageSize
{
    _messagesIdsForConfirmation[sessionId].first.insert(messageId);
    _messagesIdsForConfirmation[sessionId].second += messageSize;
    
    if (_messagesIdsForConfirmation[sessionId].second >= 16 * 1024)
    {
        TGLog(@"Sending 16Kb acks");
        [self _sendConfirmationsForSessionId:sessionId];
    }
}

- (void)_sendConfirmationsForSessionId:(int64_t)sessionId
{
    for (std::map<int, TGDatacenterContext *>::iterator it = _datacenters.begin(); it != _datacenters.end(); it++)
    {
        TGDatacenterContext *datacenter = it->second;
        if (datacenter.authSessionId == sessionId)
        {
            [self proceedToSendingMessages:[NSArray array] sessionId:sessionId transport:datacenter.datacenterTransport reportAck:false requestShortTimeout:false allowAcks:true];
            
            break;
        }
    }
    
    _messagesIdsForConfirmation.erase(sessionId);
}

- (int64_t)transport:(id<TGTransport>)__unused transport needsToDecodeMessageIdFromPartialData:(NSData *)data
{
    if (data == nil)
        return 0;
    
    TGDatacenterContext *datacenter = [transport datacenter];
    
    NSInputStream *is = [[NSInputStream alloc] initWithData:data];
    [is open];
    
    int64_t keyId = [is readInt64];
    
    if (keyId == 0)
    {
        return 0;
    }
    else
    {
        if (datacenter.authKeyId == nil || memcmp(&keyId, datacenter.authKeyId.bytes, 8))
        {
            TGLog(@"***** Error: invalid auth key id");
            [is close];
            return 0;
        }
        
        NSData *messageKey = [is readData:16];
        MessageKeyData keyData = [self generateMessageKeyData:messageKey incoming:true datacenter:datacenter];
        
        NSMutableData *messageData = [is readMutableData:(data.length - 24)];
        encryptWithAESInplace(messageData, keyData.aesKey, keyData.aesIv, false);
        
        NSInputStream *messageIs = [NSInputStream inputStreamWithData:messageData];
        [messageIs open];
        __unused int64_t messageServerSalt = [messageIs readInt64];
        int64_t messageSessionId = [messageIs readInt64];
        
        if (messageSessionId != datacenter.authSessionId && messageSessionId != datacenter.authUploadSessionId && messageSessionId != datacenter.authDownloadSessionId)
        {
            TGLog(@"***** Error: invalid message session ID");
            [messageIs close];
            return 0;
        }
        
        __unused int64_t messageId = [messageIs readInt64];
        __unused int32_t messageSeqNo = [messageIs readInt32];
        __unused int32_t messageLength = [messageIs readInt32];
        
        bool stop = false;
        int64_t reqMsgId = 0;
        
        if (true)
        {
            while (!stop && reqMsgId == 0)
            {
                int32_t signature = [messageIs readInt32:&stop];
                [self findReqMsgId:messageIs signature:signature reqMsgId:&reqMsgId failed:&stop];
            }
        }
        else
        {
            int32_t signature = [messageIs readInt32];
            if (signature == (int)0xf35c6d01)
                reqMsgId = [messageIs readInt64];
            else if (signature == (int)0x73f1f8dc)
            {
                int count = [messageIs readInt32];
                if (count != 0)
                {
                    [messageIs readInt64];
                    [messageIs readInt32];
                    [messageIs readInt32];
                    
                    signature = [messageIs readInt32];
                    if (signature == (int)0xf35c6d01)
                        reqMsgId = [messageIs readInt64];
                }
            }
        }
        
#ifdef DEBUG
        if (reqMsgId == 0)
            TGLog(@"Failed to decode request message id");
#endif
        
        return reqMsgId;
    }
}

- (void)findReqMsgId:(NSInputStream *)is signature:(int32_t)signature reqMsgId:(int64_t *)reqMsgId failed:(bool *)failed
{
    if (signature == (int)0x73f1f8dc) //msg_container
    {
        int count = [is readInt32:failed];
        if (*failed)
            return;
        
        for (int i = 0; i < count; i++)
        {
            [is readInt64:failed];
            [is readInt32:failed];
            [is readInt32:failed];
            if (*failed)
                return;
            
            int innerSignature = [is readInt32:failed];
            if (*failed)
                return;
            
            [self findReqMsgId:is signature:innerSignature reqMsgId:reqMsgId failed:failed];
            if (*failed || *reqMsgId != 0)
                return;
        }
    }
    else if (signature == (int)0xf35c6d01) //rpc_result
    {
        int64_t value = [is readInt64:failed];
        if (*failed)
            return;
        
        *reqMsgId = value;
    }
    else if (signature == (int)0x62d6b459) // msgs_ack
    {
        [is readInt32:failed];
        if (*failed)
            return;
        
        int count = [is readInt32:failed];
        if (*failed)
            return;
        
        for (int i = 0; i < count; i++)
        {
            [is readInt32:failed];
            if (*failed)
                return;
        }
    }
    else if (signature == (int)0x347773c5) // pong
    {
        [is readInt64:failed];
        [is readInt64:failed];
        if (*failed)
            return;
    }
}

- (TLSerializationContext *)serializationContextForRpcResult:(int64_t)requestMessageId
{
    for (TGRPCRequest *request in _runningRequests)
    {
        if ([request respondsToMessageId:requestMessageId])
        {
            return request.serializationContext;
        }
    }
    
    return nil;
}

- (void)clearRequestsForMessageId:(int64_t)messageId
{
    auto it = _containerIdToMessageIds.find(messageId);
    if (it != _containerIdToMessageIds.end())
    {
        for (TGRPCRequest *request in _runningRequests)
        {
            if (request.runningMessageId != 0 && std::find(it->second.begin(), it->second.end(), request.runningMessageId) != it->second.end())
            {
                if (request.worker != nil)
                    [self clearRequestWorker:request reuseable:false];
                
                request.runningMessageId = 0;
                request.runningMessageSeqNo = 0;
                request.runningStartTime = 0;
                request.runningMinStartTime = 0;
                request.transportChannelToken = 0;
            }
        }
    }
    else
    {
        for (TGRPCRequest *request in _runningRequests)
        {
            if (request.runningMessageId != 0 && request.runningMessageId == messageId)
            {
                if (request.worker != nil)
                    [self clearRequestWorker:request reuseable:false];
                
                request.runningMessageId = 0;
                request.runningMessageSeqNo = 0;
                request.runningStartTime = 0;
                request.runningMinStartTime = 0;
                request.transportChannelToken = 0;
            }
        }
    }
}

- (void)processMessage:(id<TLObject>)message messageId:(int64_t)messageId messageSeqNo:(int32_t)messageSeqNo messageSalt:(int64_t)messageSalt fromTransport:(id<TGTransport>)transport sessionId:(int64_t)sessionId innerMessageId:(int64_t)innerMessageId containerMessageId:(int64_t)containerMessageId
{
    TGDatacenterContext *datacenter = [transport datacenter];
    
    if ([message isKindOfClass:[TLNewSession class]])
    {
        TLNewSession *newSession = (TLNewSession *)message;
        
        if (_processedSessionChanges[sessionId].find(newSession.unique_id) == _processedSessionChanges[sessionId].end())
        {
            TGLog(@"New session:");
            TGLog(@"    first message id: %lld", newSession.first_msg_id);
            TGLog(@"    server salt: %llx", newSession.server_salt);
            TGLog(@"    unique id: %llx", newSession.unique_id);
            
            int64_t serverSalt = newSession.server_salt;
            
            TGServerSalt serverSaltDesc;
            serverSaltDesc.validSince = (int)(CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970) + _timeDifference;
            serverSaltDesc.validUntil = (int)(CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970) + _timeDifference + 30 * 60;
            serverSaltDesc.value = serverSalt;
            [datacenter addServerSalt:serverSaltDesc];
            
            //_lastOutgoingMessageId = newSession.first_msg_id;
            
            int requestClass = [transport transportRequestClass];
            for (TGRPCRequest *request in _runningRequests)
            {
                if ((request.requestClass & requestClass) && [self datacenterWithId:request.runningDatacenterId].datacenterId == datacenter.datacenterId)
                {
                    if (request.runningMessageId != 0&& request.runningMessageId < newSession.first_msg_id)
                    {
                        if (request.worker != nil)
                            [self clearRequestWorker:request reuseable:false];
                        
                        request.runningMessageId = 0;
                        request.runningMessageSeqNo = 0;
                        request.runningStartTime = 0;
                        request.runningMinStartTime = 0;
                        request.transportChannelToken = 0;
                    }
                }
            }
            
            [self storeSession];
            
            if (sessionId == datacenter.authSessionId && datacenter.datacenterId == _currentDatacenterId)
                [_delegate stateUpdateRequired];
            
            _processedSessionChanges[sessionId].insert(newSession.unique_id);
        }
    }
    else if ([message isKindOfClass:[TLMsgsAck class]])
    {
        
    }
    else if ([message isKindOfClass:[TLRPCping$ping class]])
    {
        /*TLRPCping *ping = (TLRPCping *)message;
        
        TLPong$pong *pong = [[TLPong$pong alloc] init];
        pong.ping_id = ping.ping_id;
        pong.msg_id = innerMessageId != 0 ? innerMessageId : (messageId != 0 ? messageId : (containerMessageId != 0 ? containerMessageId : 0));*/
    }
    else if ([message isKindOfClass:[TLPong class]])
    {
        TLPong *pong = (TLPong *)message;
        int64_t pingId = pong.ping_id;

        std::vector<int64_t> itemsToDelete;
        for (std::map<int64_t, NSTimeInterval>::iterator it = _pingIdToDate.begin(); it != _pingIdToDate.end(); it++)
        {
            if (it->first == pingId)
            {
                NSTimeInterval pingTime = CFAbsoluteTimeGetCurrent() - it->second;
                
                if (ABS(pingTime) < 10)
                    _currentPingTime = (pingTime + _currentPingTime) / 2;
                
                itemsToDelete.push_back(it->first);
            }
            else if (it->first < pingId)
            {
                itemsToDelete.push_back(it->first);
            }
        }
        
        for (std::vector<int64_t>::iterator it = itemsToDelete.begin(); it != itemsToDelete.end(); it++)
        {
            _pingIdToDate.erase(*it);
        }
        
        if (messageId != 0)
        {
            //NSTimeInterval serverTime = messageId / 4294967296.0;
            
            //self.timeDifference = serverTime - (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970) - _currentPingTime / 2.0;
        }
        
        if (pingId < 0)
        {
            auto it = _holdUpdateMessagesInDatacenter.find((int)(-pingId));
            if (it != _holdUpdateMessagesInDatacenter.end())
            {
                TGDatacenterContext *datacenter = [self datacenterWithId:*it];
                _holdUpdateMessagesInDatacenter.erase(it);
                
                if (datacenter != nil)
                {
                    if (_isWaitingForFirstData && datacenter.datacenterId == _currentDatacenterId)
                    {
                        self.isWaitingForFirstData = false;
                        [self dispatchConnectingState];
                    }
                    
                    TGLog(@"===== Process Updates");
                    [self processStatefulUpdates:datacenter];
                    [self processStatelessUpdates:datacenter];
                }
            }
        }
        
        //TGLog(@"Ping time: %f ms", _currentPingTime * 1000.0);
        //TGLog(@"Time difference: %d", _timeDifference);
    }
    else if ([message isKindOfClass:[TLMsgDetailedInfo class]])
    {   
        TLMsgDetailedInfo *detailedInfo = (TLMsgDetailedInfo *)message;
        
        bool requestResend = false;
        
        if ([detailedInfo isKindOfClass:[TLMsgDetailedInfo$msg_detailed_info class]])
        {
            int64_t requestMid = ((TLMsgDetailedInfo$msg_detailed_info *)detailedInfo).msg_id;
            for (int i = 0; i < (int)_runningRequests.count; i++)
            {
                TGRPCRequest *request = [_runningRequests objectAtIndex:i];
                
                if ([request respondsToMessageId:requestMid])
                {
                    if (request.requestClass & TGRequestClassDownloadMedia)
                    {
                        if (request.worker.transport == transport)
                            requestResend = true;
                    }
                    else
                        requestResend = true;
                    
                    break;
                }
            }
        }
        else
        {
            if (!isMessageIdProcessed(&_processedMessageIdsSet, sessionId, messageId))
                requestResend = true;
        }
        
        if (requestResend)
        {
            TLMsgResendReq$msg_resend_req *resendReq = [[TLMsgResendReq$msg_resend_req alloc] init];
            resendReq.msg_ids = [NSArray arrayWithObject:[NSNumber numberWithLongLong:detailedInfo.answer_msg_id]];
            TGLog(@"Request resend %lld", detailedInfo.answer_msg_id);
            
            TGNetworkMessage *networkMessage = [[TGNetworkMessage alloc] init];
            networkMessage.protoMessage = [self wrapMessage:resendReq sessionId:sessionId meaningful:false];
            
            [self sendMessagesToTransport:[NSArray arrayWithObject:networkMessage] transport:transport sessionId:sessionId reportAck:false requestShortTimeout:true];
        }
        else
        {
            if ([transport transportRequestClass] & TGRequestClassGeneric)
                [self addMessageIdForConfirmation:sessionId messageId:detailedInfo.answer_msg_id messageSize:detailedInfo.bytes];
            else
            {
                _messagesIdsForConfirmation[sessionId].first.insert(detailedInfo.answer_msg_id);
                _messagesIdsForConfirmation[sessionId].second += detailedInfo.bytes;
                [self proceedToSendingMessages:[NSArray array] sessionId:sessionId transport:transport reportAck:false requestShortTimeout:false allowAcks:true];
            }
        }
    }
    else if ([message isKindOfClass:[TLBadMsgNotification class]])
    {
        if ([message isKindOfClass:[TLBadMsgNotification$bad_msg_notification class]])
        {
            TLBadMsgNotification$bad_msg_notification *badMsgNotification = (TLBadMsgNotification$bad_msg_notification *)message;
            
            [self clearRequestsForMessageId:badMsgNotification.bad_msg_id];
            
            TGLog(@"***** Bad message: %d", badMsgNotification.error_code);
            if (badMsgNotification.error_code == 16 || badMsgNotification.error_code == 17 || badMsgNotification.error_code == 19 || badMsgNotification.error_code == 32 || badMsgNotification.error_code == 33 || badMsgNotification.error_code == 64)
            {
                int64_t realId = messageId != 0 ? messageId : containerMessageId;
                if (realId == 0)
                    realId = innerMessageId;
                
                if (realId != 0)
                {
                    NSTimeInterval serverTime = messageId / 4294967296.0;
                    
                    self.timeDifference = serverTime - (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970) - _currentPingTime / 2.0;
                }
                
                [self recreateSession:datacenter.authSessionId datacenter:datacenter];
                [self recreateSession:datacenter.authDownloadSessionId datacenter:datacenter];
                [self recreateSession:datacenter.authUploadSessionId datacenter:datacenter];
                
                [self storeSession];
                
                _lastOutgoingMessageId = 0;
                
                [self clearRequestsForRequestClass:[transport transportRequestClass] datacenter:datacenter];
                
                [transport forceTransportReconnection];
            }
        }
        else if ([message isKindOfClass:[TLBadMsgNotification$bad_server_salt class]])
        {
            _saltFails++;
            
            if (messageId != 0)
            {
                NSTimeInterval serverTime = messageId / 4294967296.0;
                
                self.timeDifference = serverTime - (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970) - _currentPingTime / 2.0;
                
                _lastOutgoingMessageId = MAX(messageId, _lastOutgoingMessageId);
            }
            
            int64_t badMessageId = ((TLBadMsgNotification$bad_server_salt *)message).bad_msg_id;
            [self clearRequestsForMessageId:badMessageId];
            
            [datacenter clearServerSalts];
            
            TGServerSalt serverSaltDesc;
            serverSaltDesc.validSince = (int)(CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970) + _timeDifference;
            serverSaltDesc.validUntil = (int)(CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970) + 30 * 60 + _timeDifference;
            serverSaltDesc.value = messageSalt;
            
            TGLog(@"===== Server salt changed");
            [datacenter addServerSalt:serverSaltDesc];
            [self storeSession];
            
            [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/network/requestFutureSalts/(%d)", datacenter.datacenterId] options:nil flags:0 watcher:self];
            
            if (datacenter.authKey != nil)
                [self processRequestQueue:std::pair<int, int>(TGRequestClassTransportMask, datacenter.datacenterId)];
        }
    }
    else if ([message isKindOfClass:[TLMessageContainer class]])
    {
        if (messageId != 0)
        {
            NSTimeInterval serverTime = messageId / 4294967296.0;
            
            self.timeDifference = serverTime - (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970) - _currentPingTime / 2.0;
        }
        
        TLMessageContainer *messageContainer = (TLMessageContainer *)message;
        for (TLProtoMessage *innerMessage in messageContainer.messages)
        {
            int64_t innerMessageId = innerMessage.msg_id;
            if (isMessageIdProcessed(&_processedMessageIdsSet, sessionId, innerMessageId))
            {
                TGLog(@"===== Duplicate message id %lld received, ignoring", innerMessageId);
                continue;
            }

/*#define DEBUG_RESEND 0
            
#if TARGET_IPHONE_SIMULATOR && DEBUG_RESEND
            static std::set<int64_t> resentIds;
            if (resentIds.find(innerMessageId) == resentIds.end() && innerMessage.seqno % 2 == 1)
            {
                resentIds.insert(innerMessageId);
                
                TLMsgResendReq$msg_resend_req *resendReq = [[TLMsgResendReq$msg_resend_req alloc] init];
                resendReq.msg_ids = [NSArray arrayWithObject:[NSNumber numberWithLongLong:innerMessageId]];
                TGLog(@"(d) Request resend %lld", innerMessageId);
                
                TGNetworkMessage *networkMessage = [[TGNetworkMessage alloc] init];
                networkMessage.protoMessage = [self wrapMessage:resendReq sessionId:sessionId meaningful:false];
                
                [self sendMessagesToTransport:[NSArray arrayWithObject:networkMessage] transport:transport sessionId:sessionId reportAck:false requestShortTimeout:true];
            }
            else
            {
#endif*/
            [self processMessage:(id<TLObject>)innerMessage.body messageId:0 messageSeqNo:innerMessage.seqno messageSalt:messageSalt fromTransport:transport sessionId:sessionId innerMessageId:innerMessageId containerMessageId:messageId];
            addProcessedMessageId(&_processedMessageIdsSet, sessionId, innerMessageId);
/*#if TARGET_IPHONE_SIMULATOR && DEBUG_RESEND
            }
#endif*/
        }
    }
    else if ([message isKindOfClass:[TLRpcResult class]])
    {
        TLRpcResult *resultContainer = (TLRpcResult *)message;
        int64_t resultMid = resultContainer.req_msg_id;
        
        bool ignoreResult = false;
        
        if ([resultContainer.result isKindOfClass:[TLRpcError class]])
        {
            NSString *errorMessage = ((TLRpcError *)resultContainer.result).error_message;
            TGLog(@"***** RPC error %d (for %lld): %@", ((TLRpcError *)resultContainer.result).error_code, resultMid, errorMessage);
            
            int migrateToDatacenterId = TG_DEFAULT_DATACENTER_ID;
            
            if (((TLRpcError *)resultContainer.result).error_code == 303)
            {
                NSArray *migrateErrors = [[NSArray alloc] initWithObjects:@"NETWORK_MIGRATE_", @"PHONE_MIGRATE_", @"USER_MIGRATE_", nil];
                for (NSString *possibleError in migrateErrors)
                {
                    if ([errorMessage rangeOfString:possibleError].location != NSNotFound)
                    {
                        NSScanner *scanner = [[NSScanner alloc] initWithString:errorMessage];
                        [scanner scanUpToString:possibleError intoString:nil];
                        [scanner scanString:possibleError intoString:nil];
                        if (![scanner scanInt:&migrateToDatacenterId])
                            migrateToDatacenterId = TG_DEFAULT_DATACENTER_ID;
                    }
                }
            }
            
            if (migrateToDatacenterId != TG_DEFAULT_DATACENTER_ID)
            {
                ignoreResult = true;
                
                [self moveToDatacenter:migrateToDatacenterId];
            }
        }
        
        int retryRequestsFromDatacenter = -1;
        int retryRequestsClass = 0;
        
        if (!ignoreResult)
        {
            bool found = false;
            
            for (int i = 0; i < (int)_runningRequests.count; i++)
            {
                TGRPCRequest *request = [_runningRequests objectAtIndex:i];
                
                if ([request respondsToMessageId:resultMid])
                {   
                    found = true;
                    
                    [self clearRequestWorker:request reuseable:true];
                    
                    bool discardResponse = false;
                    if (request.completionBlock != nil)
                    {
                        TLError *implicitError = nil;
                        if ([resultContainer.result isKindOfClass:[TLRpcError class]])
                        {
                            NSString *errorMessage = ((TLRpcError *)resultContainer.result).error_message;
                            TGLog(@"***** RPC error %d (for %lld): %@", ((TLRpcError *)resultContainer.result).error_code, resultMid, errorMessage);
                            
                            int errorCode = ((TLRpcError *)resultContainer.result).error_code;
                            
                            if (errorCode == 500 || errorCode < 0)
                            {
                                if (request.requestClass & TGRequestClassFailOnServerErrors)
                                {
                                    if (request.serverFailureCount < 1)
                                    {
                                        discardResponse = true;
                                        request.runningMinStartTime = request.runningStartTime + 1.0;
                                        request.serverFailureCount++;
                                    }
                                }
                                else
                                {
                                    discardResponse = true;
                                    request.runningMinStartTime = request.runningStartTime + 1.0;
                                    request.confirmed = false;
                                }
                            }
                            else if (errorCode == 420)
                            {
                                NSTimeInterval waitTime = 2.0;
                                
                                if ([errorMessage rangeOfString:@"FLOOD_WAIT_"].location != NSNotFound)
                                {
                                    int errorWaitTime = 0;
                                    
                                    NSScanner *scanner = [[NSScanner alloc] initWithString:errorMessage];
                                    [scanner scanUpToString:@"FLOOD_WAIT_" intoString:nil];
                                    [scanner scanString:@"FLOOD_WAIT_" intoString:nil];
                                    if ([scanner scanInt:&errorWaitTime])
                                        waitTime = errorWaitTime;
                                }
                                
                                waitTime = MIN(30, waitTime);
                                
                                discardResponse = true;
                                request.runningMinStartTime = CFAbsoluteTimeGetCurrent() + waitTime;
                                request.confirmed = false;
                            }
                            
                            implicitError = [[TLError$richError alloc] init];
                            ((TLError$richError*)implicitError).code = ((TLRpcError *)resultContainer.result).error_code;
                            ((TLError$richError*)implicitError).description = ((TLRpcError *)resultContainer.result).error_message;
                        }
                        else if (![resultContainer.result isKindOfClass:[TLError class]])
                        {
                            if (![resultContainer.result isKindOfClass:[request.rawRequest responseClass]])
                            {
                                TGLog(@"***** RPC error: invalid response class %@ (%@ expected)", [resultContainer.result class], [request.rawRequest responseClass]);
                                implicitError = [[TLError$error alloc] init];
                                ((TLError$error *)implicitError).code = -1000;
                            }
                        }
                        
                        if (!discardResponse)
                        {
                            if (implicitError != nil || [resultContainer.result isKindOfClass:[TLError class]])
                            {
                                request.completionBlock(nil, messageId, implicitError != nil ? implicitError : (TLError *)resultContainer.result);
                            }
                            else
                            {
                                request.completionBlock((id<TLObject>)resultContainer.result, messageId, nil);
                            }
                        }
                        
                        if (implicitError != nil && implicitError.code == 401)
                        {
                            if (datacenter.datacenterId == _currentDatacenterId || datacenter.datacenterId == _movingToDatacenterId)
                            {
                                if (request.requestClass & TGRequestClassGeneric)
                                {
                                    [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/auth/logout/(%d)", _delegate.clientUserId] options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:true] forKey:@"force"] watcher:(id<ASWatcher>)_delegate];
                                }
                            }
                            else
                            {
                                datacenter.authorized = false;
                                [self storeSession];
                                
                                discardResponse = true;
                                
                                if (request.requestClass & TGRequestClassDownloadMedia)
                                {
                                    retryRequestsFromDatacenter = datacenter.datacenterId;
                                    retryRequestsClass = request.requestClass;   
                                }
                            }
                        }
                    }
                    
                    if (!discardResponse)
                    {
                        [self rpcCompleted:resultMid];
                    }
                    else
                    {   
                        request.runningMessageId = 0;
                        request.runningMessageSeqNo = 0;
                        request.transportChannelToken = 0;
                    }
                    
                    break;
                }
            }
            
            if (!found)
            {
                TGLog(@"Response received, but request wasn't found.");
                
                [self rpcCompleted:resultMid];
            }
            
            [self messagesConfirmed:[NSArray arrayWithObject:[NSNumber numberWithLongLong:resultMid]]];
        }
        
        if (retryRequestsFromDatacenter >= 0)
            [self processRequestQueue:std::pair<int, int>(retryRequestsClass, retryRequestsFromDatacenter)];
        else
            [self processRequestQueue:std::pair<int, int>()];
    }
    else if ([message isKindOfClass:[TLUpdates class]])
    {
        if ([message isKindOfClass:[TLUpdates$updateShort class]])
        {
            [self addStatelessUpdates:[[NSArray alloc] initWithObjects:message, nil] datacenter:datacenter effectiveDate:(int)((containerMessageId == 0 ? messageId : containerMessageId) / 4294967296L)];
        }
        else if ([message isKindOfClass:[TLUpdates$updateShortMessage class]] || [message isKindOfClass:[TLUpdates$updateShortChatMessage class]])
        {
            TLUpdate$updateNewMessage *newMessageUpdate = [[TLUpdate$updateNewMessage alloc] init];
            
            TLMessage$message *newMessage = [[TLMessage$message alloc] init];
            newMessage.n_id = ((TLUpdates$updateShortMessage *)message).n_id;
            newMessage.from_id = ((TLUpdates$updateShortMessage *)message).from_id;
            
            if ([message isKindOfClass:[TLUpdates$updateShortMessage class]])
            {
                TLPeer$peerUser *peerUser = [[TLPeer$peerUser alloc] init];
                peerUser.user_id = _delegate.clientUserId;
                newMessage.to_id = peerUser;
            }
            else
            {
                TLPeer$peerChat *peerChat = [[TLPeer$peerChat alloc] init];
                peerChat.chat_id = ((TLUpdates$updateShortChatMessage *)message).chat_id;
                newMessage.to_id = peerChat;
            }
            
            newMessage.out = false;
            newMessage.unread = true;
            newMessage.date = ((TLUpdates$updateShortMessage *)message).date;
            newMessage.message = ((TLUpdates$updateShortMessage *)message).message;
            newMessage.media = [[TLMessageMedia$messageMediaEmpty alloc] init];
            
            newMessageUpdate.pts = ((TLUpdates$updateShortMessage *)message).pts;
            newMessageUpdate.message = newMessage;
            
            TLUpdates$updates *actualUpdates = [[TLUpdates$updates alloc] init];
            actualUpdates.updates = [[NSArray alloc] initWithObjects:newMessageUpdate, nil];
            actualUpdates.date = ((TLUpdates$updateShortMessage *)message).date;
            actualUpdates.seq = ((TLUpdates$updateShortMessage *)message).seq;
            
            [self processMessage:actualUpdates messageId:messageId messageSeqNo:messageSeqNo messageSalt:messageSalt fromTransport:transport sessionId:sessionId innerMessageId:innerMessageId containerMessageId:containerMessageId];
        }
        else if ([message isKindOfClass:[TLUpdates$updatesTooLong class]])
        {
            [_delegate stateUpdateRequired];
        }
        else if ([message isKindOfClass:[TLUpdates$updates class]] || [message isKindOfClass:[TLUpdates$updatesCombined class]])
        {
//#ifdef DEBUG
            if ([message isKindOfClass:[TLUpdates$updatesCombined class]])
                TGLog(@"#### Update seq = [%d..%d]", ((TLUpdates$updatesCombined *)message).seq_start, ((TLUpdates$updatesCombined *)message).seq);
            else
                TGLog(@"#### Update seq = %d", ((TLUpdates$updates *)message).seq);
//#endif

            NSArray *statelessUpdates = [_delegate filterStatelessUpdates:(TLUpdates *)message];
            
            if (statelessUpdates.count != 0)
            {
                [self addStatelessUpdates:statelessUpdates datacenter:datacenter effectiveDate:(int)((containerMessageId == 0 ? messageId : containerMessageId) / 4294967296L)];
            }
            
            if (((TLUpdates$updates *)message).seq != 0)
            {
                if (((TLUpdates$updates *)message).updates.count == 0)
                {
                    [self updatePts:0 date:0 seq:((TLUpdates$updates *)message).seq];
                }
                else
                {
                    std::map<int64_t, TGStatefulUpdatesDesc>::iterator it = _statefulUpdatesToProcess.find(datacenter.authSessionId);
                    if (it == _statefulUpdatesToProcess.end())
                    {
                        TGStatefulUpdatesDesc updatesDesc;
                        updatesDesc.array = [[NSMutableArray alloc] init];
                        
                        _statefulUpdatesToProcess.insert(std::pair<int64_t, TGStatefulUpdatesDesc>(datacenter.authSessionId, updatesDesc));
                        it = _statefulUpdatesToProcess.find(datacenter.authSessionId);
                    }
                    
                    bool scheduleProcess = it->second.array.count == 0 && _holdUpdateMessagesInDatacenter.find(datacenter.datacenterId) == _holdUpdateMessagesInDatacenter.end();
                    int updateMessageDate = (int)((containerMessageId == 0 ? messageId : containerMessageId) / 4294967296L);
                    [it->second.array addObject:[[TGUpdateMessage alloc] initWithMessage:message messageDate:updateMessageDate]];
                    
                    if (scheduleProcess)
                    {
                        dispatch_async([ActionStageInstance() globalStageDispatchQueue], ^
                        {
                            [self processStatefulUpdates:datacenter];
                        });
                    }
                }
            }
            else if (((TLUpdates$updates *)message).updates.count != 0)
            {
                NSArray *convertedUpdates = [_delegate makeStatelessUpdates:(TLUpdates *)message];
                [self addStatelessUpdates:convertedUpdates datacenter:datacenter effectiveDate:(int)((containerMessageId == 0 ? messageId : containerMessageId) / 4294967296L)];
            }
            else
                TGLog(@"##### All stateful updates were filtered out");
        }
    }
    else if ([message isKindOfClass:[TLFutureSalts class]])
    {
        TLFutureSalts *futureSalts = (TLFutureSalts *)message;
        
        TLRpcResult$rpc_result *rpcResult = [[TLRpcResult$rpc_result alloc] init];
        rpcResult.req_msg_id = futureSalts.req_msg_id;
        rpcResult.result = futureSalts;
        
        [self processMessage:rpcResult messageId:messageId messageSeqNo:messageSeqNo messageSalt:messageSalt fromTransport:transport sessionId:sessionId innerMessageId:innerMessageId containerMessageId:containerMessageId];
    }
    else if ([message isKindOfClass:[TLDestroySessionRes class]])
    {
        TLDestroySessionRes *res = (TLDestroySessionRes *)message;
        for (std::vector<int64_t>::iterator it = _sessionsToDestroy.begin(); it != _sessionsToDestroy.end(); it++)
        {
            if (res.session_id == *it)
            {
                _sessionsToDestroy.erase(it);
                TGLog(@"Destroyed session %llx (%s)", res.session_id, [res isKindOfClass:[TLDestroySessionRes$destroy_session_ok class]] ? "ok" : "not found");
                break;
            }
        }
    }
    else
    {
        TGLog(@"***** Error: unknown message class %@", [message description]);
    }
}

- (void)addStatelessUpdates:(NSArray *)updateMessageArray datacenter:(TGDatacenterContext *)datacenter effectiveDate:(int)effectiveDate
{
    if (updateMessageArray.count == 0)
        return;
    
    NSMutableArray *statelessUpdatesArray = nil;
    
    std::map<int64_t, NSMutableArray *>::iterator it = _statelessUpdatesToProcess.find(datacenter.authSessionId);
    if (it == _statelessUpdatesToProcess.end())
    {
        statelessUpdatesArray = [[NSMutableArray alloc] init];
        _statelessUpdatesToProcess.insert(std::pair<int64_t, NSMutableArray *>(datacenter.authSessionId,statelessUpdatesArray));
    }
    else
        statelessUpdatesArray = it->second;
    
    bool scheduleProcess = statelessUpdatesArray.count == 0 && _holdUpdateMessagesInDatacenter.find(datacenter.datacenterId) == _holdUpdateMessagesInDatacenter.end();
    int updateMessageDate = effectiveDate;
    
    for (id message in updateMessageArray)
    {
        [statelessUpdatesArray addObject:[[TGUpdateMessage alloc] initWithMessage:message messageDate:updateMessageDate]];
    }
    
    if (scheduleProcess)
    {
        dispatch_async([ActionStageInstance() globalStageDispatchQueue], ^
        {
            [self processStatelessUpdates:datacenter];
        });
    }
}

- (void)processStatelessUpdates:(TGDatacenterContext *)datacenter
{
    NSMutableArray *statelessUpdates = nil;
    
    std::map<int64_t, NSMutableArray *>::iterator it = _statelessUpdatesToProcess.find(datacenter.authSessionId);
    if (it != _statelessUpdatesToProcess.end())
        statelessUpdates = it->second;
    
    if (statelessUpdates == nil || statelessUpdates.count == 0)
        return;
    
    [statelessUpdates sortUsingComparator:^NSComparisonResult(TGUpdateMessage *updateMessage1, TGUpdateMessage *updateMessage2)
    {
        TLUpdates$updateShort *message1 = updateMessage1.message;
        TLUpdates$updateShort *message2 = updateMessage2.message;
        return message1.date < message2.date ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    NSMutableArray *statelessUpdatesSequence = [[NSMutableArray alloc] init];
    
    for (TGUpdateMessage *updateMessage in statelessUpdates)
    {
        TLUpdates$updateShort *message = updateMessage.message;
        
        [statelessUpdatesSequence addObject:[[TGUpdate alloc] initWithUpdates:[[NSArray alloc] initWithObjects:message.update, nil] date:message.date beginSeq:0 endSeq:0 messageDate:updateMessage.messageDate usersDesc:nil chatsDesc:nil]];
    }
    
    [statelessUpdates removeAllObjects];
    
    if (statelessUpdatesSequence.count != 0)
    {
        static int statelessUpdatesId = 0;
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/service/tryupdates/(stateless%d)", statelessUpdatesId++] options:[NSDictionary dictionaryWithObjectsAndKeys:statelessUpdatesSequence, @"multipleUpdates", [NSNumber numberWithInt:-1], @"unreadCount", nil] watcher:(id<ASWatcher>)_delegate];
    }
}

- (void)processStatefulUpdates:(TGDatacenterContext *)datacenter
{
    std::map<int64_t, TGStatefulUpdatesDesc>::iterator it = _statefulUpdatesToProcess.find(datacenter.authSessionId);
    if (it == _statefulUpdatesToProcess.end() || it->second.array.count == 0)
        return;
    
    NSMutableArray *updatesArray = [[NSMutableArray alloc] init];
    
    for (TGUpdateMessage *updateMessage in it->second.array)
    {
        if ([updateMessage.message isKindOfClass:[TLUpdates$updates class]])
        {
            TLUpdates$updates *update = updateMessage.message;
            
            [updatesArray addObject:[[TGUpdate alloc] initWithUpdates:update.updates date:update.date beginSeq:update.seq endSeq:update.seq messageDate:updateMessage.messageDate usersDesc:update.users chatsDesc:update.chats]];
        }
        else if ([updateMessage.message isKindOfClass:[TLUpdates$updatesCombined class]])
        {
            TLUpdates$updatesCombined *updatesCombined = updateMessage.message;
            
            [updatesArray addObject:[[TGUpdate alloc] initWithUpdates:updatesCombined.updates date:updatesCombined.date beginSeq:updatesCombined.seq_start endSeq:updatesCombined.seq messageDate:updateMessage.messageDate usersDesc:updatesCombined.users chatsDesc:updatesCombined.chats]];
        }
    }
    
    [ActionStageInstance() requestActor:@"/tg/service/tryupdates/(stateful)" options:[[NSDictionary alloc] initWithObjectsAndKeys:updatesArray, @"multipleUpdates", [[NSNumber alloc] initWithBool:true], @"stateful", nil] watcher:(id<ASWatcher>)_delegate];
    
    [it->second.array removeAllObjects];
}

- (void)updatePts:(int)pts date:(int)date seq:(int)seq
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        TLUpdate$updateChangePts *ptsUpdate = [[TLUpdate$updateChangePts alloc] init];
        ptsUpdate.pts = pts;
        NSArray *updatesArray = [[NSArray alloc] initWithObjects:[[TGUpdate alloc] initWithUpdates:[[NSArray alloc] initWithObjects:ptsUpdate, nil] date:date beginSeq:seq endSeq:seq messageDate:date usersDesc:nil chatsDesc:nil], nil];
        [ActionStageInstance() requestActor:@"/tg/service/tryupdates/(stateful)" options:[[NSDictionary alloc] initWithObjectsAndKeys:updatesArray, @"multipleUpdates", [[NSNumber alloc] initWithBool:true], @"stateful", nil] watcher:(id<ASWatcher>)_delegate];
    }];
}

#pragma mark -

- (void)actorCompleted:(int)resultCode path:(NSString *)path result:(id)result
{
    if ([path hasPrefix:@"/tg/network/updateDatacenterData"])
    {
        if (resultCode == ASStatusSuccess)
        {
            NSDictionary *resultDict = ((SGraphObjectNode *)result).object;
            
            NSArray *datacenters = [resultDict objectForKey:@"datacenters"];
            if (datacenters.count != 0)
            {
                [self mergeDatacenterData:datacenters];
                [self processRequestQueue:std::pair<int, int>()];
            }
        }
    }
    else if ([path hasPrefix:@"/tg/network/datacenterHandshake"])
    {
        if (resultCode == ASStatusSuccess)
        {
            NSDictionary *resultDict = ((SGraphObjectNode *)result).object;
            
            int datacenterId = [[resultDict objectForKey:@"datacenterId"] intValue];
            
            id<TGTransport> transport = [resultDict objectForKey:@"transport"];
            
            int timeDifference = [[resultDict objectForKey:@"timeDifference"] intValue];
            NSData *authKey = [resultDict objectForKey:@"authKey"];
            NSData *authKeyId = [resultDict objectForKey:@"authKeyId"];
            
            TGServerSalt serverSalt;
            serverSalt.validSince = 0;
            serverSalt.validUntil = 0;
            serverSalt.value = 0;
            NSValue *serverSaltValue = [resultDict objectForKey:@"serverSalt"];
            if (serverSaltValue != nil)
                [serverSaltValue getValue:&serverSalt];
            
            TGDatacenterContext *datacenter = [self datacenterWithId:datacenterId];
            if (datacenter != nil)
            {
                datacenter.authKey = authKey;
                datacenter.authKeyId = authKeyId;
                if (serverSalt.value != 0)
                    [datacenter addServerSalt:serverSalt];
                
                [self storeSession];
            }
            
            if (datacenterId == _currentDatacenterId || datacenterId == _movingToDatacenterId)
            {  
                _timeDifference = timeDifference;

                if (transport != nil)
                {
                    [datacenter replaceDatacenterTransport:transport];
                    _isConnecting = [transport connectedChannelToken] == 0;
                    [self dispatchConnectingState];
                }
                
                [self recreateSession:datacenter.authSessionId datacenter:datacenter];
                [self recreateSession:datacenter.authDownloadSessionId datacenter:datacenter];
                [self recreateSession:datacenter.authUploadSessionId datacenter:datacenter];
            }
            
            [self processRequestQueue:std::pair<int, int>()];
        }
    }
    else if ([path hasPrefix:@"/tg/network/exportDatacenterAuthorization"])
    {
        if (resultCode == ASStatusSuccess)
        {
            NSDictionary *resultDict = ((SGraphObjectNode *)result).object;
            
            TGDatacenterContext *datacenter = [self datacenterWithId:[[resultDict objectForKey:@"datacenterId"] intValue]];
            datacenter.authorized = true;
            [self storeSession];
            
            [self processRequestQueue:std::pair<int, int>(TGRequestClassTransportMask, datacenter.datacenterId)];
        }
        else
        {
            int numberLocation = @"/tg/network/exportDatacenterAuthorization/(".length;
            int datacenterId = [[path substringWithRange:NSMakeRange(numberLocation, path.length - 1 - numberLocation)] intValue];
            _unavailableDatacenterIds.insert(datacenterId);
        }
    }
}

#pragma mark -

- (void)moveToDatacenter:(int)datacenterId
{
    if (false)
    {
        if (_currentDatacenterId == datacenterId)
            return;
        
        TGDatacenterContext *currentDatacenter = [self datacenterWithId:_currentDatacenterId];
        [self clearRequestsForRequestClass:TGRequestClassGeneric datacenter:currentDatacenter];
        [self clearRequestsForRequestClass:TGRequestClassDownloadMedia datacenter:currentDatacenter];
        [self clearRequestsForRequestClass:TGRequestClassUploadMedia datacenter:currentDatacenter];
        
        self.currentDatacenterId = datacenterId;
        [self processRequestQueue:std::pair<int, int>(TGRequestClassGeneric, TG_ALL_DATACENTERS)];
    }
    else
    {
        if (_movingToDatacenterId == datacenterId)
            return;
        _movingToDatacenterId = datacenterId;
        
        TGDatacenterContext *currentDatacenter = [self datacenterWithId:_currentDatacenterId];
        [self clearRequestsForRequestClass:TGRequestClassGeneric datacenter:currentDatacenter];
        [self clearRequestsForRequestClass:TGRequestClassDownloadMedia datacenter:currentDatacenter];
        [self clearRequestsForRequestClass:TGRequestClassUploadMedia datacenter:currentDatacenter];
        
        if (_delegate.clientUserId != 0)
        {
            TLRPCauth_exportAuthorization$auth_exportAuthorization *exportAuthorization = [[TLRPCauth_exportAuthorization$auth_exportAuthorization alloc] init];
            exportAuthorization.dc_id = datacenterId;
            
            [self performRpc:exportAuthorization completionBlock:^(TLauth_ExportedAuthorization *result, __unused int64_t responseTime, TLError *error)
            {
                if (error == nil)
                {
                    _movingAuthorization = result;
                    
                    [self authorizeOnMovingDatacenter];
                }
                else
                {
                    double delayInSeconds = 1.0;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, [ActionStageInstance() globalStageDispatchQueue], ^
                    {
                        [self moveToDatacenter:datacenterId];
                    });
                }
            } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric datacenterId:_currentDatacenterId];
        }
        else
        {
            [self authorizeOnMovingDatacenter];
        }
    }
}

- (void)authorizeOnMovingDatacenter
{
    TGDatacenterContext *datacenter = [self datacenterWithId:_movingToDatacenterId];
    
    [self recreateSession:datacenter.authSessionId datacenter:datacenter];
    [self recreateSession:datacenter.authDownloadSessionId datacenter:datacenter];
    [self recreateSession:datacenter.authUploadSessionId datacenter:datacenter];
    
    if (datacenter.authKey == nil)
    {
        [datacenter clearServerSalts];
        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/network/datacenterHandshake/(%d)", datacenter.datacenterId] options:[[NSDictionary alloc] initWithObjectsAndKeys:datacenter, @"datacenter", nil] watcher:self];
    }
    
    if (_movingAuthorization != nil)
    {
        TLRPCauth_importAuthorization$auth_importAuthorization *importAuthorization = [[TLRPCauth_importAuthorization$auth_importAuthorization alloc] init];
        importAuthorization.n_id = _delegate.clientUserId;
        importAuthorization.bytes = _movingAuthorization.bytes;
        [self performRpc:importAuthorization completionBlock:^(__unused TLauth_Authorization *result, __unused int64_t responseTime, TLError *error)
        {
            _movingAuthorization = nil;
            
            if (error == nil)
            {
                [self authorizedOnMovingDatacenter];
            }
            else
            {
                [self moveToDatacenter:_movingToDatacenterId];
            }
        } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric datacenterId:datacenter.datacenterId];
    }
    else
    {
        [self authorizedOnMovingDatacenter];
    }
}

- (void)authorizedOnMovingDatacenter
{
    _movingAuthorization = nil;
    self.currentDatacenterId = _movingToDatacenterId;
    _movingToDatacenterId = TG_DEFAULT_DATACENTER_ID;
    [self storeSession];
    [self processRequestQueue:std::pair<int, int>()];
}

- (void)setCurrentDatacenterId:(int)currentDatacenterId
{
    _currentDatacenterId = currentDatacenterId;
    
    if ([[self datacenterWithId:currentDatacenterId].datacenterTransport connectedChannelToken] != 0)
    {
        _isConnecting = false;
        
        [self dispatchConnectingState];
    }
}

@end
