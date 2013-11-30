#import "TGDatacenterHandshakeActor.h"

#import "SGraphObjectNode.h"

#import "TGTcpTransport.h"
#import "TGSession.h"

#import "TL/TLMetaScheme.h"
#import "TLMetaClassStore.h"

#import "NSOutputStream+TL.h"
#import "NSInputStream+TL.h"

#import "TGSecurity.h"
#import "TGEncryption.h"

#include <set>

static NSDictionary *selectPublicKey(NSArray *fingerprints)
{
    static NSArray *serverPublicKeys = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        serverPublicKeys = [[NSArray alloc] initWithObjects:
                             [[NSDictionary alloc] initWithObjectsAndKeys:@"-----BEGIN RSA PUBLIC KEY-----\n"
                              "MIIBCgKCAQEAxq7aeLAqJR20tkQQMfRn+ocfrtMlJsQ2Uksfs7Xcoo77jAid0bRt\n"
                              "ksiVmT2HEIJUlRxfABoPBV8wY9zRTUMaMA654pUX41mhyVN+XoerGxFvrs9dF1Ru\n"
                              "vCHbI02dM2ppPvyytvvMoefRoL5BTcpAihFgm5xCaakgsJ/tH5oVl74CdhQw8J5L\n"
                              "xI/K++KJBUyZ26Uba1632cOiq05JBUW0Z2vWIOk4BLysk7+U9z+SxynKiZR3/xdi\n"
                              "XvFKk01R3BHV+GUKM2RYazpS/P8v7eyKhAbKxOdRcFpHLlVwfjyM1VlDQrEZxsMp\n"
                              "NTLYXb6Sce1Uov0YtNx5wEowlREH1WOTlwIDAQAB\n"
                              "-----END RSA PUBLIC KEY-----", @"key", [[NSNumber alloc] initWithLongLong:0x9a996a1db11c729b], @"fingerprint", nil],
                             [[NSDictionary alloc] initWithObjectsAndKeys:@"-----BEGIN RSA PUBLIC KEY-----\n"
                              "MIIBCgKCAQEAsQZnSWVZNfClk29RcDTJQ76n8zZaiTGuUsi8sUhW8AS4PSbPKDm+\n"
                              "DyJgdHDWdIF3HBzl7DHeFrILuqTs0vfS7Pa2NW8nUBwiaYQmPtwEa4n7bTmBVGsB\n"
                              "1700/tz8wQWOLUlL2nMv+BPlDhxq4kmJCyJfgrIrHlX8sGPcPA4Y6Rwo0MSqYn3s\n"
                              "g1Pu5gOKlaT9HKmE6wn5Sut6IiBjWozrRQ6n5h2RXNtO7O2qCDqjgB2vBxhV7B+z\n"
                              "hRbLbCmW0tYMDsvPpX5M8fsO05svN+lKtCAuz1leFns8piZpptpSCFn7bWxiA9/f\n"
                              "x5x17D7pfah3Sy2pA+NDXyzSlGcKdaUmwQIDAQAB\n"
                              "-----END RSA PUBLIC KEY-----", @"key", [[NSNumber alloc] initWithLongLong:0xb05b2a6f70cdea78], @"fingerprint", nil],
                             [[NSDictionary alloc] initWithObjectsAndKeys:@"-----BEGIN RSA PUBLIC KEY-----\n"
                              "MIIBCgKCAQEAwVACPi9w23mF3tBkdZz+zwrzKOaaQdr01vAbU4E1pvkfj4sqDsm6\n"
                              "lyDONS789sVoD/xCS9Y0hkkC3gtL1tSfTlgCMOOul9lcixlEKzwKENj1Yz/s7daS\n"
                              "an9tqw3bfUV/nqgbhGX81v/+7RFAEd+RwFnK7a+XYl9sluzHRyVVaTTveB2GazTw\n"
                              "Efzk2DWgkBluml8OREmvfraX3bkHZJTKX4EQSjBbbdJ2ZXIsRrYOXfaA+xayEGB+\n"
                              "8hdlLmAjbCVfaigxX0CDqWeR1yFL9kwd9P0NsZRPsmoqVwMbMu7mStFai6aIhc3n\n"
                              "Slv8kg9qv1m6XHVQY3PnEw+QQtqSIXklHwIDAQAB\n"
                              "-----END RSA PUBLIC KEY-----", @"key", [[NSNumber alloc] initWithLongLong:0xc3b42b026ce86b21], @"fingerprint", nil],
                             [[NSDictionary alloc] initWithObjectsAndKeys:@"-----BEGIN RSA PUBLIC KEY-----\n"
                              "MIIBCgKCAQEAwqjFW0pi4reKGbkc9pK83Eunwj/k0G8ZTioMMPbZmW99GivMibwa\n"
                              "xDM9RDWabEMyUtGoQC2ZcDeLWRK3W8jMP6dnEKAlvLkDLfC4fXYHzFO5KHEqF06i\n"
                              "qAqBdmI1iBGdQv/OQCBcbXIWCGDY2AsiqLhlGQfPOI7/vvKc188rTriocgUtoTUc\n"
                              "/n/sIUzkgwTqRyvWYynWARWzQg0I9olLBBC2q5RQJJlnYXZwyTL3y9tdb7zOHkks\n"
                              "WV9IMQmZmyZh/N7sMbGWQpt4NMchGpPGeJ2e5gHBjDnlIf2p1yZOYeUYrdbwcS0t\n"
                              "UiggS4UeE8TzIuXFQxw7fzEIlmhIaq3FnwIDAQAB\n"
                              "-----END RSA PUBLIC KEY-----", @"key", [[NSNumber alloc] initWithLongLong:0x71e025b6c76033e3], @"fingerprint", nil],
                             nil];
    });
    
    for (NSDictionary *keyDesc in serverPublicKeys)
    {
        int64_t keyFingerprint = [[keyDesc objectForKey:@"fingerprint"] longLongValue];
        for (NSNumber *nFingerprint in fingerprints)
        {
            if ([nFingerprint longLongValue] == keyFingerprint)
                return keyDesc;
        }
    }
    
    return nil;
}

@interface TGDatacenterHandshakeActor () <TLSerializationEnvironment>
{
    std::set<int64_t> _processedMessageIds;
}

@property (nonatomic, strong) id<TGTransport> transport;
@property (nonatomic, strong) TGDatacenterContext *datacenter;

@property (nonatomic) int64_t lastOutgoingMessageId;

@property (nonatomic) bool connectedOnce;
@property (nonatomic) bool processedPQRes;

@property (nonatomic, strong) NSData *reqPQMsgData;
@property (nonatomic, strong) NSData *reqDHMsgData;
@property (nonatomic, strong) NSData *setClientDHParamsMsgData;

@property (nonatomic, strong) NSData *authNonce;
@property (nonatomic, strong) NSData *authServerNonce;
@property (nonatomic, strong) NSData *authNewNonce;

@property (nonatomic, strong) NSData *authKey;
@property (nonatomic, strong) NSData *authKeyId;

@property (nonatomic) int timeDifference;
@property (nonatomic) TGServerSalt serverSalt;

@property (nonatomic, strong) TLSerializationContext *serializationContext;

@end

@implementation TGDatacenterHandshakeActor

+ (NSString *)genericPath
{
    return @"/tg/network/datacenterHandshake/@";
}

- (void)dealloc
{
    if (_transport != nil && [_transport transportHandler] == self)
        [_transport setTransportHandler:nil];
    
    _transport = nil;
}

- (TLSerializationContext *)serializationContextForRpcResult:(int64_t)__unused requestMessageId
{
    if (_serializationContext == nil)
        _serializationContext = [[TLSerializationContext alloc] init];
    
    return _serializationContext;
}

- (void)execute:(NSDictionary *)options
{
    _datacenter = [options objectForKey:@"datacenter"];
    if (_datacenter == nil)
    {
        [ActionStageInstance() actionFailed:self.path reason:-1];
        return;
    }
    
    TGLog(@"Begin handshake with DC%d", _datacenter.datacenterId);
    
    [self beginConnection];
}

- (void)beginConnection
{
    _transport = [[TGTcpTransport alloc] init];
    [_transport setDatacenter:_datacenter];
    [_transport setTransportTimeout:16];
    [_transport setTransportHandler:self];
    [_transport setTransportRequestClass:TGRequestClassGeneric];
    
    [self beginHandshake:true];
}

- (void)beginHandshake:(bool)dropConnection
{
    _processedMessageIds.clear();
    
    _authNonce = nil;
    _authServerNonce = nil;
    
    _authKey = nil;
    _authKeyId = nil;
    
    _processedPQRes = false;
    
    _reqPQMsgData = nil;
    _reqDHMsgData = nil;
    _setClientDHParamsMsgData = nil;
    
    if (dropConnection)
    {
        _connectedOnce = false;
        [_transport forceTransportReconnection];
    }
    
    TLRPCreq_pq$req_pq *reqPq = [[TLRPCreq_pq$req_pq alloc] init];
    uint8_t nonceBytes[16];
    SecRandomCopyBytes(kSecRandomDefault, 16, nonceBytes);
    _authNonce = [[NSData alloc] initWithBytes:nonceBytes length:16];
    reqPq.nonce = _authNonce;
    
    _reqPQMsgData = [self sendMessageData:reqPq messageId:[self generateMessageId]];
}

- (int64_t)generateMessageId
{
    int64_t messageId = (int64_t)(([[NSDate date] timeIntervalSince1970]) * 4294967296);
    if (messageId <= _lastOutgoingMessageId)
        messageId = _lastOutgoingMessageId + 1;
    while (messageId % 4 != 0)
        messageId++;
    
    _lastOutgoingMessageId = messageId;
    return messageId;
}

- (NSData *)sendMessageData:(id<TLObject>)message messageId:(int64_t)messageId
{
    NSData *messageData = nil;
    NSOutputStream *innerOs = [NSOutputStream outputStreamToMemory];
    [innerOs open];
    TLMetaClassStore::serializeObject(innerOs, message, true);
    messageData = [innerOs currentBytes];
    [innerOs close];
    
    NSOutputStream *messageOs = [NSOutputStream outputStreamToMemory];
    [messageOs open];
    
    [messageOs writeInt64:0];
    [messageOs writeInt64:messageId];
    [messageOs writeInt32:messageData.length];
    [messageOs writeData:messageData];
    
    NSData *transportData = [messageOs currentBytes];
    [messageOs close];
    
    [_transport sendData:transportData reportAck:false startResponseTimeout:false];
    
    return transportData;
}

- (void)transport:(id<TGTransport>)__unused transport receivedData:(NSData *)data
{
    NSInputStream *is = [[NSInputStream alloc] initWithData:data];
    [is open];
    
    int64_t keyId = [is readInt64];
    
    if (keyId == 0)
    {
        int64_t messageId = [is readInt64];
        if (_processedMessageIds.find(messageId) != _processedMessageIds.end())
        {
            TGLog(@"===== Duplicate message id %lld received, ignoring", messageId);
            [is close];
            
            return;
        }
        
        __unused int32_t messageLength = [is readInt32];
        
        NSError *error = nil;
        int32_t signature = [is readInt32];
        id<TLObject> object = TLMetaClassStore::constructObject(is, signature, nil, nil, &error);
        
        [is close];
        
        if (object != nil)
            _processedMessageIds.insert(messageId);
        
        [self processMessage:object messageId:messageId];
    }
    else
    {
        TGLog(@"***** Received encrypted message while in handshake, restarting");
        [self beginHandshake:true];
    }
}

- (void)processMessage:(id<TLObject>)message messageId:(int64_t)messageId
{
    if ([message isKindOfClass:[TLResPQ class]])
    {
        if (_processedPQRes)
        {
            TLMsgsAck$msgs_ack *msgsAck = [[TLMsgsAck$msgs_ack alloc] init];
            msgsAck.msg_ids = [[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithLongLong:messageId], nil];
            [self sendMessageData:msgsAck messageId:[self generateMessageId]];
            
            return;
        }
        
        _processedPQRes = true;
        
        NSData *authNonce = _authNonce;
        
        TLResPQ *resPq = (TLResPQ *)message;
        
        if ([authNonce isEqualToData:resPq.nonce])
        {
            NSDictionary *publicKey = selectPublicKey(resPq.server_public_key_fingerprints);
            if (publicKey == nil)
            {
                TGLog(@"***** Couldn't find valid server public key");
                [self beginHandshake:false];
                
                return;
            }
            
            _authServerNonce = resPq.server_nonce;
            
            uint64_t pq = 0;
            for (int i = 0; i < (int)resPq.pq.length; i++)
            {
                pq <<= 8;
                pq |= ((uint8_t *)[resPq.pq bytes])[i];
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
            {
                TGFactorizedValue factorizedPq = getFactorizedValue(pq);
                
                [ActionStageInstance() dispatchOnStageQueue:^
                {
                    std::vector<uint8_t> pBytes;
                    uint64_t p = factorizedPq.p;
                    do
                    {
                        pBytes.insert(pBytes.begin(), (uint8_t *)&p, ((uint8_t *)&p) + 1);
                        p >>= 8;
                    } while (p > 0);
                    NSData *pData = [[NSData alloc] initWithBytes:pBytes.data() length:pBytes.size()];
                    
                    std::vector<uint8_t> qBytes;
                    uint64_t q = factorizedPq.q;
                    do
                    {
                        qBytes.insert(qBytes.begin(), (uint8_t *)&q, ((uint8_t *)&q) + 1);
                        q >>= 8;
                    } while (q > 0);
                    NSData *qData = [[NSData alloc] initWithBytes:qBytes.data() length:qBytes.size()];
                    
                    TLRPCreq_DH_params$req_DH_params *reqDH = [[TLRPCreq_DH_params$req_DH_params alloc] init];
                    reqDH.nonce = _authNonce;
                    reqDH.server_nonce = _authServerNonce;
                    reqDH.p = pData;
                    reqDH.q = qData;
                    reqDH.public_key_fingerprint = [[publicKey objectForKey:@"fingerprint"] longLongValue];
                    
                    NSOutputStream *os = [NSOutputStream outputStreamToMemory];
                    [os open];
                    
                    TLP_Q_inner_data$p_q_inner_data *innerData = [[TLP_Q_inner_data$p_q_inner_data alloc] init];
                    innerData.nonce = _authNonce;
                    innerData.server_nonce = _authServerNonce;
                    innerData.pq = resPq.pq;
                    innerData.p = reqDH.p;
                    innerData.q = reqDH.q;
                    
                    uint8_t nonceBytes[32];
                    SecRandomCopyBytes(kSecRandomDefault, 32, nonceBytes);
                    NSData *authNewNonce = [[NSData alloc] initWithBytes:nonceBytes length:32];
                    innerData.n_new_nonce = authNewNonce;
                    _authNewNonce = authNewNonce;
                    
                    TLMetaClassStore::serializeObject(os, innerData, true);
                    
                    NSData *innerDataBytes = [os currentBytes];
                    [os close];
                    
                    NSMutableData *dataWithHash = [[NSMutableData alloc] init];
                    [dataWithHash appendData:computeSHA1(innerDataBytes)];
                    [dataWithHash appendData:innerDataBytes];
                    while (dataWithHash.length < 255)
                    {
                        uint8_t zero = 0;
                        [dataWithHash appendBytes:&zero length:1];
                    }
                    
                    NSData *encryptedData = encryptWithRSA([publicKey objectForKey:@"key"], dataWithHash);
                    if (encryptedData.length < 256)
                    {
                        NSMutableData *newEncryptedData = [[NSMutableData alloc] init];
                        uint8_t zero = 0;
                        for (int i = 0; i < 256 - (int)encryptedData.length; i++)
                            [newEncryptedData appendBytes:&zero length:1];
                        [newEncryptedData appendData:encryptedData];
                        encryptedData = newEncryptedData;
                    }
                    reqDH.encrypted_data = encryptedData;
                    
                    TLMsgsAck$msgs_ack *msgsAck = [[TLMsgsAck$msgs_ack alloc] init];
                    msgsAck.msg_ids = [[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithLongLong:messageId], nil];
                    [self sendMessageData:msgsAck messageId:[self generateMessageId]];
                    
                    _reqPQMsgData = nil;
                    _reqDHMsgData = [self sendMessageData:reqDH messageId:[self generateMessageId]];
                }];
            });
        }
        else
        {
            TGLog(@"***** Error: invalid handshake nonce %@", resPq.nonce);
        }
    }
    else if ([message isKindOfClass:[TLServer_DH_Params class]])
    {   
        if ([message isKindOfClass:[TLServer_DH_Params$server_DH_params_ok class]])
        {
            TLServer_DH_Params$server_DH_params_ok *serverDhParams = (TLServer_DH_Params$server_DH_params_ok *)message;
            
            NSMutableData *tmpAesKey = [[NSMutableData alloc] init];
            
            NSData *authNonce = _authNonce;
            NSData *authNewNonce = _authNewNonce;
            NSData *authServerNonce = _authServerNonce;
            
            NSMutableData *newNonceAndServerNonce = [[NSMutableData alloc] init];
            [newNonceAndServerNonce appendData:authNewNonce];
            [newNonceAndServerNonce appendData:authServerNonce];
            
            NSMutableData *serverNonceAndNewNonce = [[NSMutableData alloc] init];
            [serverNonceAndNewNonce appendData:authServerNonce];
            [serverNonceAndNewNonce appendData:authNewNonce];
            [tmpAesKey appendData:computeSHA1(newNonceAndServerNonce)];
            
            NSData *serverNonceAndNewNonceHash = computeSHA1(serverNonceAndNewNonce);
            NSData *serverNonceAndNewNonceHash0_12 = [[NSData alloc] initWithBytes:((uint8_t *)serverNonceAndNewNonceHash.bytes) length:12];
            
            [tmpAesKey appendData:serverNonceAndNewNonceHash0_12];
            
            NSMutableData *tmpAesIv = [[NSMutableData alloc] init];
            
            NSData *serverNonceAndNewNonceHash12_8 = [[NSData alloc] initWithBytes:(((uint8_t *)serverNonceAndNewNonceHash.bytes) + 12) length:8];
            [tmpAesIv appendData:serverNonceAndNewNonceHash12_8];
            
            NSMutableData *newNonceAndNewNonce = [[NSMutableData alloc] init];
            [newNonceAndNewNonce appendData:authNewNonce];
            [newNonceAndNewNonce appendData:authNewNonce];
            [tmpAesIv appendData:computeSHA1(newNonceAndNewNonce)];
            
            NSData *newNonce0_4 = [[NSData alloc] initWithBytes:((uint8_t *)authNewNonce.bytes) length:4];
            [tmpAesIv appendData:newNonce0_4];
            
            NSData *answerWithHash = encryptWithAES(serverDhParams.encrypted_answer, tmpAesKey, tmpAesIv, false);
            NSData *answerHash = [[NSData alloc] initWithBytes:((uint8_t *)answerWithHash.bytes) length:20];
            
            NSMutableData *answerData = [[NSMutableData alloc] initWithBytes:(((uint8_t *)answerWithHash.bytes) + 20) length:(answerWithHash.length - 20)];
            bool hashVerified = false;
            for (int i = 0; i < 16; i++)
            {
                NSData *computedAnswerHash = computeSHA1(answerData);
                if ([computedAnswerHash isEqualToData:answerHash])
                {
                    hashVerified = true;
                    break;
                }
                
                [answerData replaceBytesInRange:NSMakeRange(answerData.length - 1, 1) withBytes:NULL length:0];
            }
            
            if (!hashVerified)
            {
                TGLog(@"***** Couldn't decode DH params");
                [self beginHandshake:false];
                
                return;
            }
            
            NSInputStream *answerIs = [NSInputStream inputStreamWithData:answerData];
            [answerIs open];
            NSError *error = nil;
            int32_t signature = [answerIs readInt32];
            TLServer_DH_inner_data *dhInnerData = TLMetaClassStore::constructObject(answerIs, signature, self, nil, &error);
            
            [answerIs close];
            
            if (error != nil || ![dhInnerData isKindOfClass:[TLServer_DH_inner_data class]])
            {
                TGLog(@"***** Couldn't parse decoded DH params");
                [self beginHandshake:false];
                
                return;
            }
            
            if (![authNonce isEqualToData:dhInnerData.nonce])
            {
                TGLog(@"***** Invalid DH nonce");
                [self beginHandshake:false];
                
                return;
            }
            if (![authServerNonce isEqualToData:dhInnerData.server_nonce])
            {
                TGLog(@"***** Invalid DH server nonce");
                [self beginHandshake:false];
                return;
            }
            
            uint8_t bBytes[256];
            SecRandomCopyBytes(kSecRandomDefault, 256, bBytes);
            NSData *b = [[NSData alloc] initWithBytes:bBytes length:256];
            
            int32_t tmpG = dhInnerData.g;
            tmpG = NSSwapInt(tmpG);
            NSData *g = [[NSData alloc] initWithBytes:&tmpG length:4];
            
            NSData *g_b = computeExp(g, b, dhInnerData.dh_prime);
            
            _authKey = computeExp(dhInnerData.g_a, b, dhInnerData.dh_prime);
            
            NSData *authKeyHash = computeSHA1(_authKey);
            _authKeyId = [[NSData alloc] initWithBytes:(((uint8_t *)authKeyHash.bytes) + authKeyHash.length - 8) length:8];
            NSMutableData *serverSaltData = [[NSMutableData alloc] init];
            for (int i = 0; i < 8; i++)
            {
                int8_t a = ((int8_t *)authNewNonce.bytes)[i];
                int8_t b = ((int8_t *)authServerNonce.bytes)[i];
                int8_t x = a ^ b;
                [serverSaltData appendBytes:&x length:1];
            }
            
            self.timeDifference = (int)(dhInnerData.server_time - (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970));
            
            TGServerSalt serverSaltDesc;
            serverSaltDesc.validSince = (int)(CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970) + _timeDifference;
            serverSaltDesc.validUntil = (int)(CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970) + _timeDifference + 30 * 60;
            serverSaltDesc.value = *((int64_t *)serverSaltData.bytes);
            _serverSalt = serverSaltDesc;
            
            TGLog(@"===== Auth key ID: %@", _authKeyId);
            TGLog(@"===== Time difference: %d", _timeDifference);
            
            TLClient_DH_Inner_Data$client_DH_inner_data *clientInnerData = [[TLClient_DH_Inner_Data$client_DH_inner_data alloc] init];
            clientInnerData.nonce = authNonce;
            clientInnerData.server_nonce = authServerNonce;
            clientInnerData.g_b = g_b;
            clientInnerData.retry_id = 0;
            NSOutputStream *os = [NSOutputStream outputStreamToMemory];
            [os open];
            [os writeInt32:[clientInnerData TLconstructorSignature]];
            TLMetaClassStore::serializeObject(os, clientInnerData, false);
            NSData *clientInnerDataBytes = [os currentBytes];
            [os close];
            
            NSMutableData *clientDataWithHash = [[NSMutableData alloc] init];
            [clientDataWithHash appendData:computeSHA1(clientInnerDataBytes)];
            [clientDataWithHash appendData:clientInnerDataBytes];
            uint8_t zero = 0;
            while (clientDataWithHash.length % 16 != 0)
            {
                [clientDataWithHash appendBytes:&zero length:1];
            }
            
            TLRPCset_client_DH_params$set_client_DH_params *setClientDhParams = [[TLRPCset_client_DH_params$set_client_DH_params alloc] init];
            setClientDhParams.nonce = authNonce;
            setClientDhParams.server_nonce = authServerNonce;
            setClientDhParams.encrypted_data = encryptWithAES(clientDataWithHash, tmpAesKey, tmpAesIv, true);
            
            TLMsgsAck$msgs_ack *msgsAck = [[TLMsgsAck$msgs_ack alloc] init];
            msgsAck.msg_ids = [[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithLongLong:messageId], nil];
            [self sendMessageData:msgsAck messageId:[self generateMessageId]];
            
            _reqDHMsgData = nil;
            _setClientDHParamsMsgData = [self sendMessageData:setClientDhParams messageId:[self generateMessageId]];
        }
        else
        {
            TGLog(@"***** Couldn't set DH params");
            [self beginHandshake:false];
            
            return;
        }
    }
    else if ([message isKindOfClass:[TLSet_client_DH_params_answer class]])
    {   
        NSData *authNonce = _authNonce;
        NSData *authNewNonce = _authNewNonce;
        NSData *authServerNonce = _authServerNonce;
        
        TLSet_client_DH_params_answer *dhAnswer = (TLSet_client_DH_params_answer *)message;
        
        if (![authNonce isEqualToData:dhAnswer.nonce])
        {
            TGLog(@"***** Invalid DH answer nonce");
            [self beginHandshake:false];
            
            return;
        }
        if (![authServerNonce isEqualToData:dhAnswer.server_nonce])
        {
            TGLog(@"***** Invalid DH answer server nonce");
            [self beginHandshake:false];
            
            return;
        }
        
        _reqDHMsgData = nil;
        
        TLMsgsAck$msgs_ack *msgsAck = [[TLMsgsAck$msgs_ack alloc] init];
        msgsAck.msg_ids = [[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithLongLong:messageId], nil];
        [self sendMessageData:msgsAck messageId:[self generateMessageId]];
        
        NSData *authKeyAuxHashFull = computeSHA1(_authKey);
        NSData *authKeyAuxHash = [[NSData alloc] initWithBytes:((uint8_t *)authKeyAuxHashFull.bytes) length:8];
        
        NSMutableData *newNonce1 = [[NSMutableData alloc] init];
        [newNonce1 appendData:authNewNonce];
        uint8_t tmp1 = 1;
        [newNonce1 appendBytes:&tmp1 length:1];
        [newNonce1 appendData:authKeyAuxHash];
        NSData *newNonceHash1Full = computeSHA1(newNonce1);
        NSData *newNonceHash1 = [[NSData alloc] initWithBytes:(((uint8_t *)newNonceHash1Full.bytes) + newNonceHash1Full.length - 16) length:16];
        
        NSMutableData *newNonce2 = [[NSMutableData alloc] init];
        [newNonce2 appendData:authNewNonce];
        uint8_t tmp2 = 2;
        [newNonce2 appendBytes:&tmp2 length:1];
        [newNonce2 appendData:authKeyAuxHash];
        NSData *newNonceHash2Full = computeSHA1(newNonce2);
        NSData *newNonceHash2 = [[NSData alloc] initWithBytes:(((uint8_t *)newNonceHash2Full.bytes) + newNonceHash2Full.length - 16) length:16];
        
        NSMutableData *newNonce3 = [[NSMutableData alloc] init];
        [newNonce3 appendData:authNewNonce];
        uint8_t tmp3 = 3;
        [newNonce3 appendBytes:&tmp3 length:1];
        [newNonce3 appendData:authKeyAuxHash];
        NSData *newNonceHash3Full = computeSHA1(newNonce3);
        NSData *newNonceHash3 = [[NSData alloc] initWithBytes:(((uint8_t *)newNonceHash3Full.bytes) + newNonceHash3Full.length - 16) length:16];
        
        if ([message isKindOfClass:[TLSet_client_DH_params_answer$dh_gen_ok class]])
        {
            TLSet_client_DH_params_answer$dh_gen_ok *dhGenOk = (TLSet_client_DH_params_answer$dh_gen_ok *)message;
            if (![newNonceHash1 isEqualToData:dhGenOk.n_new_nonce_hash1])
            {
                TGLog(@"***** Invalid DH answer nonce hash 1");
                
                [self beginHandshake:false];
                
                return;
            }
            
            TGLog(@"Handshake with DC%d completed", _datacenter.datacenterId);
            [_transport setTransportHandler:nil];
            id<TGTransport> transport = _transport;
            _transport = nil;
            
            NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
            
            if (transport != nil)
                [resultDict setObject:transport forKey:@"transport"];
            [resultDict setObject:[[NSNumber alloc] initWithInt:_timeDifference] forKey:@"timeDifference"];
            [resultDict setObject:_authKey forKey:@"authKey"];
            [resultDict setObject:_authKeyId forKey:@"authKeyId"];
            [resultDict setObject:[NSValue valueWithBytes:&_serverSalt objCType:@encode(TGServerSalt)] forKey:@"serverSalt"];
            [resultDict setObject:[[NSNumber alloc] initWithInt:_datacenter.datacenterId] forKey:@"datacenterId"];
            
            [ActionStageInstance() actionCompleted:self.path result:[[SGraphObjectNode alloc] initWithObject:resultDict]];
        }
        else if ([message isKindOfClass:[TLSet_client_DH_params_answer$dh_gen_retry class]])
        {
            TLSet_client_DH_params_answer$dh_gen_retry *dhRetry = (TLSet_client_DH_params_answer$dh_gen_retry *)message;
            if (![newNonceHash2 isEqualToData:dhRetry.n_new_nonce_hash2])
            {
                TGLog(@"***** Invalid DH answer nonce hash 2");
                [self beginHandshake:false];
                
                return;
            }
            
            TGLog(@"***** Retry DH");
            [self beginHandshake:false];
            
            return;
        }
        else if ([message isKindOfClass:[TLSet_client_DH_params_answer$dh_gen_fail class]])
        {
            TLSet_client_DH_params_answer$dh_gen_fail *dhFail = (TLSet_client_DH_params_answer$dh_gen_fail *)message;
            if (![newNonceHash3 isEqualToData:dhFail.n_new_nonce_hash3])
            {
                TGLog(@"***** Invalid DH answer nonce hash 3");
                [self beginHandshake:false];
                
                return;
            }
            
            TGLog(@"***** Server declined DH params");
            [self beginHandshake:false];
            
            return;
        }
        else
        {
            TGLog(@"***** Unknown DH params response");
            [self beginHandshake:false];
            
            return;
        }
    }
    else
    {
        TLMsgsAck$msgs_ack *msgsAck = [[TLMsgsAck$msgs_ack alloc] init];
        msgsAck.msg_ids = [[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithLongLong:messageId], nil];
        [self sendMessageData:msgsAck messageId:[self generateMessageId]];
    }
}

- (int64_t)transport:(id<TGTransport>)__unused transport needsToDecodeMessageIdFromPartialData:(NSData *)__unused data
{
    return 0;
}

- (void)transport:(id<TGTransport>)__unused transport updatedRequestProgress:(int64_t)__unused requestMessageId length:(int)__unused length progress:(float)__unused progress
{
}

- (void)transportHasConnectedChannels:(id<TGTransport>)__unused transport
{
    if (_reqPQMsgData != nil)
        [_transport sendData:_reqPQMsgData reportAck:false startResponseTimeout:false];
    else if (_reqDHMsgData != nil)
        [_transport sendData:_reqDHMsgData reportAck:false startResponseTimeout:false];
    else if (_setClientDHParamsMsgData != nil)
        [_transport sendData:_setClientDHParamsMsgData reportAck:false startResponseTimeout:false];
}

- (void)transportHasDisconnectedAllChannels:(id<TGTransport>)__unused transport
{
    if (!_connectedOnce)
        _connectedOnce = true;
}

- (void)transportReceivedQuickAck:(int)__unused quickAckId
{
}

- (void)cancel
{
    [_transport setTransportHandler:nil];
    [_transport suspendTransport];
    _transport = nil;
    
    [super cancel];
}

@end
