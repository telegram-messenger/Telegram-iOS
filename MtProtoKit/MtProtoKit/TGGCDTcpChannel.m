#import "TGGCDTcpChannel.h"

#import "TGWeakDelegate.h"

#define TG_USE_GCD_SOCKET 1

#if TG_USE_GCD_SOCKET
#import "GCDAsyncSocket.h"
#else
#import "AsyncSocket.h"
#endif

#import "TGTimer.h"

#import <zlib.h>

#import <UIKit/UIKit.h>

#import "ActionStage.h"

#define TGPacketHeaderSize 152

#define TGTcpMinified true

@interface TGGCDTcpChannel ()
#if !TG_USE_GCD_SOCKET
<AsyncSocketDelegate>
#endif

@property (nonatomic, strong) TGWeakDelegate *weakDelegate;

#if TG_USE_GCD_SOCKET
@property (nonatomic, strong) GCDAsyncSocket *socket;
#else
@property (nonatomic, strong) AsyncSocket *socket;
#endif
@property (nonatomic, strong) TGTimer *reconnectTimer;

@property (nonatomic, strong) TGTimer *timeoutTimer;

@property (nonatomic) bool isConnected;
@property (nonatomic) bool isDisconnected;

@property (nonatomic) int currentPacketLength;
@property (nonatomic) int currentPacketId;

@property (nonatomic) uint8_t currentAckByte;

@property (nonatomic) int outgoingPacketId;

@property (nonatomic) int timeout;
@property (nonatomic) bool channelClosed;

@property (nonatomic) NSTimeInterval lastActivity;

@property (nonatomic) int failedConnectionCount;

@property (nonatomic, strong) NSMutableData *currentPacketData;
@property (nonatomic) bool notifyAboutPartialData;
@property (nonatomic) int currentDataReadBytes;
@property (nonatomic) int64_t notifyRequestMsgId;

@property (nonatomic) int64_t dropRequestMsgId;

@property (nonatomic) int downloadToken;

@end

@implementation TGGCDTcpChannel

@synthesize weakDelegate = _weakDelegate;

@synthesize channelId = _channelId;
@synthesize channelToken = _channelToken;

@synthesize hostAddress = _hostAddress;
@synthesize hostPort = _hostPort;

@synthesize listener = _listener;

@synthesize socket = _socket;
@synthesize reconnectTimer = _reconnectTimer;

@synthesize timeoutTimer = _timeoutTimer;

@synthesize isConnected = _isConnected;
@synthesize isDisconnected = _isDisconnected;

@synthesize currentPacketLength = _currentPacketLength;
@synthesize currentPacketId = _currentPacketId;

@synthesize currentAckByte = _currentAckByte;

@synthesize outgoingPacketId = _outgoingPacketId;

@synthesize timeout = _timeout;
@synthesize channelClosed = _channelClosed;

@synthesize lastActivity = _lastActivity;

@synthesize failedConnectionCount = _failedConnectionCount;

@synthesize currentPacketData = _currentPacketData;
@synthesize notifyAboutPartialData = _notifyAboutPartialData;
@synthesize currentDataReadBytes = _currentDataReadBytes;
@synthesize notifyRequestMsgId = _notifyRequestMsgId;

@synthesize dropRequestMsgId = _dropRequestMsgId;

@synthesize downloadToken = _downloadToken;

static NSThread *runLoopThreadInstance = nil;

+ (void)startRunLoopThreadIfNeeded
{
	static dispatch_once_t predicate;
	dispatch_once(&predicate, ^
    {
        runLoopThreadInstance = [[NSThread alloc] initWithTarget:self selector:@selector(runLoopThread) object:nil];
        [runLoopThreadInstance start];
    });
}

+ (void)runLoopThread
{
    @autoreleasepool
    {
        [NSTimer scheduledTimerWithTimeInterval:[[NSDate distantFuture] timeIntervalSinceNow] target:self selector:@selector(doNothingAtAll:) userInfo:nil repeats:YES];
        
        [[NSRunLoop currentRunLoop] run];
    }
}

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _weakDelegate = [[TGWeakDelegate alloc] init];
        _weakDelegate.object = self;
        
        _isDisconnected = true;
        
#if TG_USE_GCD_SOCKET
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:[ActionStageInstance() globalStageDispatchQueue]];
#else
        [[self class] startRunLoopThreadIfNeeded];
        
        _socket = [[AsyncSocket alloc] initWithDelegate:self];
        [self performSelector:@selector(moveSocket) onThread:runLoopThreadInstance withObject:nil waitUntilDone:true];
#endif
        
        _timeout = -1;
    }
    return self;
}

#if !TG_USE_GCD_SOCKET
- (void)moveSocket
{
    [_socket moveToRunLoop:[NSRunLoop currentRunLoop]];
}
#endif

- (void)dealloc
{
    _weakDelegate.object = nil;
    if (_timeoutTimer != nil)
    {
        [_timeoutTimer invalidate];
        _timeoutTimer = nil;
    }
    
    _channelClosed = true;
    _socket.delegate = nil;
#if TG_USE_GCD_SOCKET
    _socket.delegateQueue = nil;
#endif
    [_socket disconnect];
}

- (void)clearFailCountAndConnect
{
    _failedConnectionCount = 0;
    
    [_reconnectTimer invalidate];
    _reconnectTimer = nil;
    
    [self connect];
}

- (void)connect
{
#if !TG_USE_GCD_SOCKET
    if ([NSThread currentThread] != runLoopThreadInstance)
    {
        [self performSelector:@selector(connect) onThread:runLoopThreadInstance withObject:nil waitUntilDone:false];
        return;
    }
#endif
    
    if (_channelClosed)
        return;
    
    if (!_isConnected && !_isDisconnected)
        return;
    if (_isConnected)
        return;
    
    if (_reconnectTimer != nil)
        return;
    
    _isDisconnected = false;
    
    _outgoingPacketId = 0;
    _lastActivity = 0;
    
    _channelToken = TGGenerateChannelToken();
    
    NSError *error = nil;
    
    _socket.useTcpNodelay = true;
    
    int16_t hostPort = (int16_t)_hostPort;
    
    TGLog(@"===== Channel %d: connecting (%@:%d)...", _channelId, _hostAddress, _hostPort);
    if (![_socket connectToHost:_hostAddress onPort:hostPort viaInterface:nil withTimeout:12 error:&error])
    {
        _isDisconnected = true;
        _isConnected = false;
        
        TGLog(@"***** Channel %d: connection error: %@", _channelId, error);
        
        [self reconnect];
        
        return;
    }
    
    [_socket readDataToLength:1 withTimeout:_timeout tag:100];
}

- (void)disconnect
{
    [_reconnectTimer invalidate];
    
    _reconnectTimer = nil;
    _channelClosed = true;
    
    if (!_isDisconnected)
    {
        _isConnected = false;
        _isDisconnected = true;
        
        [_socket disconnect];
    }
    else
    {
        id<TGTcpChannelListener> listener = _listener;
        [listener channelClosed:self];
    }
}

- (void)reconnect
{
    _failedConnectionCount = 0;
    
    [_reconnectTimer invalidate];
    _reconnectTimer = nil;
    
    _isConnected = false;
    _isDisconnected = true;
    [_socket disconnect];
}

#if TG_USE_GCD_SOCKET
- (void)socket:(GCDAsyncSocket *)__unused sender didConnectToHost:(NSString *)__unused host port:(UInt16)__unused port
#else
- (void)onSocket:(AsyncSocket *)__unused socket didConnectToHost:(NSString *)__unused host port:(UInt16)__unused port
#endif
{
    _isConnected = true;
    _isDisconnected = false;
    
    TGLog(@"===== Channel %d: connected", _channelId);
    _lastActivity = CFAbsoluteTimeGetCurrent();
    
    _failedConnectionCount = 0;
    
    id<TGTcpChannelListener> listener = _listener;
    [listener channelConnected:self];
}

#if TG_USE_GCD_SOCKET
- (NSTimeInterval)socket:(GCDAsyncSocket *)socket shouldTimeoutReadWithTag:(long)__unused tag elapsed:(NSTimeInterval)__unused elapsed bytesDone:(NSUInteger)__unused length
#else
- (NSTimeInterval)onSocket:(AsyncSocket *)socket shouldTimeoutReadWithTag:(long)__unused tag elapsed:(NSTimeInterval)__unused elapsed bytesDone:(NSUInteger)__unused length
#endif
{
    if (socket == _socket)
    {
        if (CFAbsoluteTimeGetCurrent() - _lastActivity < _timeout)
        {
            TGLog(@"Extending tcps timeout");
            
            return _timeout;
        }
    }
    
    return 0.0;
}

#if !TG_USE_GCD_SOCKET
- (void)onSocket:(AsyncSocket *)__unused socket willDisconnectWithError:(NSError *)error
{
    if (error != nil)
        TGLog(@"***** Channel %d: disconnected with error: %@", _channelId, error);
}
#endif

#if TG_USE_GCD_SOCKET
- (void)socketDidDisconnect:(GCDAsyncSocket *)__unused sender withError:(NSError *)error
{
#else
- (void)onSocketDidDisconnect:(AsyncSocket *)__unused socket
{
    NSError *error = nil;
#endif
    
    [self clearRequestTimeout];
    
    _isConnected = false;
    _isDisconnected = true;
    
    if (error != nil)
    {
        TGLog(@"***** Channel %d: disconnected with error: %@", _channelId, error);
    }
    else
    {
        TGLog(@"===== Channel %d: disconnected", _channelId);
    }
    
    _lastActivity = 0;
    
    id<TGTcpChannelListener> listener = _listener;
    
    if (!_channelClosed)
    {
        [listener channelDisconnected:self];
        
        _failedConnectionCount++;
        
        float selectedTime = 0.1f;
        
        if (_failedConnectionCount > 1)
        {
            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
            {
                int maxTime = (int)(powf(1.2f, MIN(_failedConnectionCount, 8)));
                if (maxTime == 0)
                    maxTime = 1;
                selectedTime = ABS(arc4random() % maxTime);
            }
            else
            {
                int maxTime = (int)(powf(1.2f, MIN(_failedConnectionCount, 18)));
                if (maxTime == 0)
                    maxTime = 1;
                selectedTime = ABS(arc4random() % maxTime);
            }
            
            selectedTime = MAX(selectedTime, 1);
            selectedTime = MIN(selectedTime, 30);
        }
        
        TGLog(@"Time: %f", selectedTime);
        
        _reconnectTimer = [[TGTimer alloc] initWithTimeout:selectedTime repeat:false completion:^
                           {
                               [_reconnectTimer invalidate];
                               _reconnectTimer = nil;
                               
                               [self connect];
                           } queue:[ActionStageInstance() globalStageDispatchQueue]];
        [_reconnectTimer start];
    }
    else
        [listener channelClosed:self];
}
    
- (void)sendDataIndirect:(NSArray *)args
{
    [self sendData:[args objectAtIndex:0] reportAck:[[args objectAtIndex:1] boolValue] startResponseTimeout:[[args objectAtIndex:2] boolValue]];
}

- (void)sendData:(NSData *)data reportAck:(bool)reportAck startResponseTimeout:(bool)startResponseTimeout
{
#if !TG_USE_GCD_SOCKET
    if ([NSThread currentThread] != runLoopThreadInstance)
    {
        [self performSelector:@selector(sendDataIndirect:) onThread:runLoopThreadInstance withObject:[[NSArray alloc] initWithObjects:data, [[NSNumber alloc] initWithBool:reportAck], [[NSNumber alloc] initWithBool:startResponseTimeout], nil] waitUntilDone:false];
        
        return;
    }
#else
    [ActionStageInstance() dispatchOnStageQueue:^
     {
#endif
         if (_isDisconnected)
             [self connect];
         
#if TGTcpMinified
         NSMutableData *packetData = nil;
         
         if (data.length <= 0x7e * 4)
         {
             packetData = [[NSMutableData alloc] initWithCapacity:1 + data.length];
             uint8_t lengthByte = (uint8_t)(data.length / 4);
             if (reportAck)
                 lengthByte |= 0x80;
             [packetData appendBytes:&lengthByte length:1];
         }
         else
         {
             packetData = [[NSMutableData alloc] initWithCapacity:4 + data.length];
             uint8_t markByte = 0x7f;
             if (reportAck)
                 markByte |= 0x80;
             [packetData appendBytes:&markByte length:1];
             uint32_t lengthInt = data.length / 4;
             [packetData appendBytes:&lengthInt length:3];
         }
         
         [packetData appendData:data];
         
#if TARGET_IPHONE_SIMULATOR
         TGLog(@"(OUT: %d bytes)", packetData.length);
#endif
         
         [_socket writeData:packetData withTimeout:-1 tag:0];
#else
         int packetId = _outgoingPacketId;
         _outgoingPacketId++;
         
         uint8_t *buffer = malloc(8 + data.length + 4);
         
         int packetLength = 8 + data.length + 4;
         
         int sendPacketLength = reportAck ? (packetLength | (1 << 31)) : packetLength;
         
         memcpy(buffer, &sendPacketLength, 4);
         memcpy(buffer + 4, &packetId, 4);
         memcpy(buffer + 8, data.bytes, data.length);
         
         int calculatedCrc32 = crc32(0, buffer, 8 + data.length);
         memcpy(buffer + 8 + data.length, &calculatedCrc32, 4);
         
#if TARGET_IPHONE_SIMULATOR
         TGLog(@"(OUT: %d bytes)", packetLength);
#endif
         
         [_socket writeData:[[NSData alloc] initWithBytesNoCopy:buffer length:packetLength freeWhenDone:true] withTimeout:-1 tag:0];
#endif
         
         if (startResponseTimeout)
         {
             if (_timeoutTimer == nil)
             {
                 //TGLog(@"**** Start request timeout");
                 TGWeakDelegate *weakDelegate = _weakDelegate;
                 _timeoutTimer = [[TGTimer alloc] initWithTimeout:10.0 repeat:false completion:^
                 {
                     __strong id strongSelf = [weakDelegate object];
                     [strongSelf timeoutRequest];
                 } queue:[ActionStageInstance() globalStageDispatchQueue]];
                 [_timeoutTimer start];
             }
         }
#if TG_USE_GCD_SOCKET
     }];
#endif
}

- (void)timeoutRequest
{
    TGLog(@"**** Request timeout");
    
    [_timeoutTimer invalidate];
    _timeoutTimer = nil;
    
    [self reconnect];
}

- (void)clearRequestTimeout
{
    if (_timeoutTimer != nil)
    {
        //TGLog(@"**** Clear request timeout");
        
        [_timeoutTimer invalidate];
        _timeoutTimer = nil;
    }
}

#if TG_USE_GCD_SOCKET
- (void)socket:(GCDAsyncSocket *)__unused sender didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)__unused tag
#else
- (void)onSocket:(AsyncSocket *)__unused socket didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)__unused tag
#endif
{
    [self clearRequestTimeout];
    
    _lastActivity = CFAbsoluteTimeGetCurrent();
    
    if (_notifyAboutPartialData && _notifyRequestMsgId != 0)
    {   
        float lastProgress = _currentPacketLength < 10 ? 1.0f : ((float)_currentDataReadBytes / (float)_currentPacketLength);
        if (lastProgress < 0.0f)
            lastProgress = 0.0f;
        else if (lastProgress > 1.0f)
            lastProgress = 1.0f;
        
        if (lastProgress >= 0.999f)
            lastProgress = 1.0f;
        
        _currentDataReadBytes += partialLength;
        
        float progress = _currentPacketLength < 10 ? 1.0f : ((float)_currentDataReadBytes / (float)_currentPacketLength);
        if (progress < 0.0f)
            progress = 0.0f;
        else if (progress > 1.0f)
            progress = 1.0f;
        
        if (progress >= 0.999f)
            progress = 1.0f;
        
        if (((int)(lastProgress * 100)) != ((int)(progress * 100)))
        {
            id<TGTcpChannelListener> listener = _listener;
            [listener requestProgressUpdated:_notifyRequestMsgId length:_currentPacketLength progress:progress];
        }
    }
}
    
#if TG_USE_GCD_SOCKET
- (void)socket:(GCDAsyncSocket *)__unused socket didReadData:(NSData *)data withTag:(long)tag
#else
- (void)onSocket:(AsyncSocket *)__unused socket didReadData:(NSData *)data withTag:(long)tag
#endif
{
    [self clearRequestTimeout];
    
    _lastActivity = CFAbsoluteTimeGetCurrent();
    
    if (tag == 0)
    {
        if (data.length != 4)
        {
            TGLog(@"***** Channel %d: invalid packet header", _channelId);
            [self reconnect];
            
            return;
        }
        
        int packetLength = 0;
        memcpy(&packetLength, data.bytes, 4);
        
        if (packetLength & (1 << 31))
        {
            int ackId = packetLength & (0xffffffff ^ (1 << 31));
            
            id<TGTcpChannelListener> listener = _listener;
            [listener quiackAckReceived:ackId];
            
            [_socket readDataToLength:4 withTimeout:_timeout tag:0];
        }
        else
        {
            _currentPacketLength = packetLength;
            
            if (packetLength % 4 != 0 || packetLength > 2 * 1024 * 1024)
            {
                TGLog(@"***** Channel %d: invalid packet length (bytes: %@)", _channelId, data);
                [self reconnect];
                
                return;
            }
            
            [_socket readDataToLength:4 withTimeout:_timeout tag:4];
        }
    }
    else if (tag == 100)
    {
        if (data.length != 1)
        {
            TGLog(@"***** Channel %d: invalid packet header", _channelId);
            [self reconnect];
            
            return;
        }
        
        const uint8_t *dataBytes = (const uint8_t *)[data bytes];
        if ((dataBytes[0] & 0x80) == 0x80)
        {
            _currentAckByte = dataBytes[0];
            [_socket readDataToLength:3 withTimeout:_timeout tag:107];
        }
        else if (dataBytes[0] == 0x7f)
        {
            [_socket readDataToLength:3 withTimeout:_timeout tag:101];
        }
        else
        {
            _currentPacketLength = dataBytes[0] * 4;
            
            if (_currentPacketLength > 2 * 1024 * 1024)
            {
                TGLog(@"***** Channel %d: invalid packet length (bytes: %@)", _channelId, data);
                [self reconnect];
                
                return;
            }
            
            [_socket readDataToLength:_currentPacketLength withTimeout:_timeout tag:105];
        }
    }
    else if (tag == 101)
    {
        if (data.length != 3)
        {
            TGLog(@"***** Channel %d: invalid packet header", _channelId);
            [self reconnect];
            
            return;
        }
        
        const uint8_t *dataBytes = (const uint8_t *)[data bytes];
        
        int packetLength = 0;
        memcpy(((uint8_t *)&packetLength), dataBytes, 3);
        packetLength *= 4;
        
        _currentPacketLength = packetLength;
        
        if (_currentPacketLength > 2 * 1024 * 1024)
        {
            TGLog(@"***** Channel %d: invalid packet length (bytes: %@)", _channelId, data);
            [self reconnect];
            
            return;
        }
        
        _currentDataReadBytes = 0;
        
        if (_currentPacketLength >= 4 * 1024)
        {
            static int nextDownloadToken = 0;
            _downloadToken = nextDownloadToken++;
            TGLog(@"+ Receiving %d kbytes (%d)", _currentPacketLength / 1024, _downloadToken);
            _currentPacketData = [[NSMutableData alloc] initWithCapacity:_currentPacketLength];
            [_socket readDataToLength:TGPacketHeaderSize withTimeout:_timeout buffer:_currentPacketData bufferOffset:0 tag:104];
        }
        else
        {
            _currentPacketData = nil;
            [_socket readDataToLength:_currentPacketLength withTimeout:_timeout tag:105];
        }
    }
    else if (tag == 4)
    {
        if (data.length != 4)
        {
            TGLog(@"***** Channel %d: invalid packet header", _channelId);
            [self reconnect];
            
            return;
        }
        
        int packetId = 0;
        memcpy(&packetId, ((uint8_t *)data.bytes), 4);
        
        _currentDataReadBytes = 0;
        _currentPacketId = packetId;
        
        _notifyAboutPartialData = false;
        
        if (_currentPacketLength >= 4 * 1024)
        {
            static int nextDownloadToken = 0;
            _downloadToken = nextDownloadToken++;
            TGLog(@"+ Receiving %d kbytes (%d)", _currentPacketLength / 1024, _downloadToken);
            _currentPacketData = [[NSMutableData alloc] initWithCapacity:(_currentPacketLength - 8)];
            [_socket readDataToLength:TGPacketHeaderSize withTimeout:_timeout buffer:_currentPacketData bufferOffset:0 tag:2];
        }
        else
        {
            _currentPacketData = nil;
            [_socket readDataToLength:(_currentPacketLength - 8) withTimeout:_timeout tag:1];
        }
    }
    else if (tag == 2)
    {
        id<TGTcpChannelListener> listener = _listener;
        int64_t requestMessageId = [listener decodeMessageIdFromPartialData:_currentPacketData];
        _notifyAboutPartialData = requestMessageId != 0;
        _notifyRequestMsgId = requestMessageId;
        
        [_socket readDataToLength:((_currentPacketLength - 8) - TGPacketHeaderSize) withTimeout:_timeout buffer:_currentPacketData bufferOffset:TGPacketHeaderSize tag:3];
    }
    else if (tag == 1 || tag == 3)
    {
        NSData *packetData = tag == 1 ? data : _currentPacketData;
        
        if (packetData.length != (unsigned int)(_currentPacketLength - 8))
        {
            TGLog(@"***** Channel %d: invalid packet length: %d (should be %d)", _channelId, packetData.length, _currentPacketLength);
            [self reconnect];
            
            return;
        }
        
        if (_currentPacketLength >= 4 * 1024)
        {
            TGLog(@"- Received %d kbytes (%d)", _currentPacketLength / 1024, _downloadToken);
        }
        
        int packetCrc32 = 0;
        memcpy(&packetCrc32, ((uint8_t *)packetData.bytes) + packetData.length - 4, 4);
        
        uint8_t *buffer = malloc(packetData.length + 4);
        memcpy(buffer, &_currentPacketLength, 4);
        memcpy(buffer + 4, &_currentPacketId, 4);
        memcpy(buffer + 8, packetData.bytes, packetData.length - 4);
        
        int calculatedCrc32 = crc32(0, buffer, packetData.length + 4);
        
        if (calculatedCrc32 != packetCrc32)
        {
            free(buffer);
            
            TGLog(@"***** Channel %d: invalid packet CRC: 0x%.8x (should be 0x%.8x)", _channelId, packetCrc32, calculatedCrc32);
            [self reconnect];
            
            return;
        }
        
        //TGLog(@"%d kbytes from %d (0x%x)", (packetData.length - 4) / 1024, _channelId, (int)self);
        id<TGTcpChannelListener> listener = _listener;
        [listener dataReceivedFromChannel:[[NSData alloc] initWithBytes:(buffer + 8) length:(packetData.length - 4)]];
        free(buffer);
        
        _currentPacketData = nil;
        
        [_socket readDataToLength:4 withTimeout:_timeout tag:0];
    }
    else if (tag == 104)
    {
        id<TGTcpChannelListener> listener = _listener;
        int64_t requestMessageId = [listener decodeMessageIdFromPartialData:_currentPacketData];
        _notifyAboutPartialData = requestMessageId != 0;
        _notifyRequestMsgId = requestMessageId;
        
        [_socket readDataToLength:(_currentPacketLength - TGPacketHeaderSize) withTimeout:_timeout buffer:_currentPacketData bufferOffset:TGPacketHeaderSize tag:106];
    }
    else if (tag == 105 || tag == 106)
    {
        NSData *packetData = tag == 105 ? data : _currentPacketData;
        
        if (packetData.length != (unsigned int)(_currentPacketLength))
        {
            TGLog(@"***** Channel %d: invalid packet length: %d (should be %d)", _channelId, packetData.length, _currentPacketLength);
            [self reconnect];
            
            return;
        }
        
        if (_currentPacketLength >= 4 * 1024)
        {
            TGLog(@"- Received %d kbytes (%d)", _currentPacketLength / 1024, _downloadToken);
        }
        
        id<TGTcpChannelListener> listener = _listener;
        [listener dataReceivedFromChannel:[[NSData alloc] initWithData:packetData]];
        
        _currentPacketData = nil;
        
        [_socket readDataToLength:1 withTimeout:_timeout tag:100];
    }
    else if (tag == 107)
    {
        if (data.length != 3)
        {
            TGLog(@"***** Channel %d: invalid packet length: %d (should be %d)", _channelId, data.length, 3);
            [self reconnect];
            
            return;
        }
        
        int ackId = 0;
        ((uint8_t *)&ackId)[0] = _currentAckByte;
        memcpy(((uint8_t *)&ackId) + 1, data.bytes, 3);
        ackId = OSSwapInt32(ackId);
        ackId &= (0xffffffff ^ (1 << 31));
        id<TGTcpChannelListener> listener = _listener;
        [listener quiackAckReceived:ackId];
        
        [_socket readDataToLength:1 withTimeout:_timeout tag:100];
    }
}

@end
