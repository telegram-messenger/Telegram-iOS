#import "TGSimpleTcpChannel.h"

#import "ActionStage.h"

static NSThread *runLoopThread()
{
    static NSThread *thread = nil;
    
	static dispatch_once_t predicate;
	dispatch_once(&predicate, ^
    {
        thread = [[NSThread alloc] initWithTarget:[TGSimpleTcpChannel class] selector:@selector(runLoopThread) object:nil];
        [thread start];
    });
    
    return thread;
}

@interface TGSimpleTcpChannel () <NSStreamDelegate>

@property (nonatomic, strong) NSInputStream *is;
@property (nonatomic, strong) NSOutputStream *os;

@property (nonatomic) bool isConnected;
@property (nonatomic) bool isConnecting;

@property (nonatomic, strong) NSMutableData *bufferedWrites;
@property (nonatomic, strong) NSMutableData *bufferedReads;

@property (nonatomic) bool streamWriteable;

@end

@implementation TGSimpleTcpChannel

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
        _bufferedWrites = [[NSMutableData alloc] init];
        _bufferedReads = [[NSMutableData alloc] init];
    }
    return self;
}

- (void)connect
{
    if ([NSThread currentThread] != runLoopThread())
    {
        [self performSelector:@selector(connect) onThread:runLoopThread() withObject:nil waitUntilDone:false];
        return;
    }
    
    if (_isConnected || _isConnecting)
        return;
    
    _isConnecting = true;
    _streamWriteable = false;
    
    _channelToken = TGGenerateChannelToken();
    
    uint8_t firstByte = 0xef;
    [_bufferedWrites setLength:0];
    [_bufferedWrites replaceBytesInRange:NSMakeRange(0, 0) withBytes:&firstByte length:1];
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)_hostAddress, _hostPort, &readStream, &writeStream);
    _is = (__bridge NSInputStream *)readStream;
    _os = (__bridge NSOutputStream *)writeStream;
    
    [_is setDelegate:self];
    [_os setDelegate:self];
    
    [_is scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [_os scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    [_is open];
    [_os open];
}

- (void)clearFailCountAndConnect
{
    if ([NSThread currentThread] != runLoopThread())
    {
        [self performSelector:@selector(clearFailCountAndConnect) onThread:runLoopThread() withObject:nil waitUntilDone:false];
        return;
    }
    
    [self connect];
}

- (void)disconnect
{
    if ([NSThread currentThread] != runLoopThread())
    {
        [self performSelector:@selector(disconnect) onThread:runLoopThread() withObject:nil waitUntilDone:false];
        return;
    }
    
    [_is close];
    [_os close];
    [self _streamsClosed];
}

- (void)_sendDataTask:(NSArray *)args
{
    int flagsValue = [[args objectAtIndex:1] intValue];
    [self sendData:[args objectAtIndex:0] reportAck:flagsValue & 1 startResponseTimeout:flagsValue & 2];
}

- (void)sendData:(NSData *)data reportAck:(bool)reportAck startResponseTimeout:(bool)startResponseTimeout
{
    if ([NSThread currentThread] != runLoopThread())
    {
        [self performSelector:@selector(_sendDataTask:) onThread:runLoopThread() withObject:[[NSArray alloc] initWithObjects:data, [[NSNumber alloc] initWithInt:(reportAck ? 1 : 0) | (startResponseTimeout ? 2 : 0)], nil] waitUntilDone:false];
        return;
    }
    
    NSMutableData *socketData = [[NSMutableData alloc] initWithCapacity:data.length + 4];
    if (data.length <= (0x7f - 1) * 4)
    {
        uint8_t length = (uint8_t)(data.length / 4);
        [socketData appendBytes:&length length:1];
    }
    else
    {
        uint8_t markByte = 0x7f;
        [socketData appendBytes:&markByte length:1];
        
        int length = data.length / 4;
        [socketData appendBytes:&length length:3];
    }
    
    [socketData appendData:data];
    
    if (!_isConnected && !_isConnecting && _streamWriteable)
    {
        if (!_isConnected && !_isConnecting)
            [self connect];
        
        [_bufferedWrites appendData:socketData];
    }
    else
    {
        [_os write:socketData.bytes maxLength:socketData.length];
    }
}

- (void)_processBufferedData
{
    if (_bufferedReads.length < 4)
        return;
    
    unsigned int headerLength = 0;
    unsigned int bodyLength = 0;
    
    uint8_t firstByte = 0;
    [_bufferedReads getBytes:&firstByte range:NSMakeRange(0, 1)];
    if (firstByte < 0x7f)
    {
        headerLength = 1;
        bodyLength = firstByte * 4;
    }
    else
    {
        headerLength = 4;
        
        [_bufferedReads getBytes:&bodyLength range:NSMakeRange(1, 3)];
        bodyLength *= 4;
    }
    
    if (_bufferedReads.length < headerLength + bodyLength)
        return;
    
    NSData *bodyData = [_bufferedReads subdataWithRange:NSMakeRange(headerLength, bodyLength)];
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        id<TGTcpChannelListener> listener = _listener;
        [listener dataReceivedFromChannel:bodyData];
    }];
    
    [_bufferedReads replaceBytesInRange:NSMakeRange(0, headerLength + bodyLength) withBytes:NULL length:0];
}

- (void)_streamsOpened
{
    if (!_isConnecting)
        return;
    
    _isConnected = true;
    _isConnecting = false;
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        id<TGTcpChannelListener> listener = _listener;
        [listener channelConnected:self];
    }];
}

- (void)_streamsClosed
{
    TGLog(@"Stream closed");
    
    _isConnected = false;
    _isConnecting = false;
    _streamWriteable = false;
    
    [_is removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [_is setDelegate:nil];
    [_os removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [_os setDelegate:nil];
    
    _is = nil;
    _os = nil;
    
    [_bufferedReads setLength:0];
    [_bufferedWrites setLength:0];
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        id<TGTcpChannelListener> listener = _listener;
        [listener channelDisconnected:self];
    }];
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode)
    {
        case NSStreamEventOpenCompleted:
        {
            switch ([_is streamStatus])
            {
                case NSStreamStatusOpen:
                case NSStreamStatusReading:
                case NSStreamStatusWriting:
                {
                    switch ([_os streamStatus])
                    {
                        case NSStreamStatusOpen:
                        case NSStreamStatusReading:
                        case NSStreamStatusWriting:
                        {
                            [self _streamsOpened];
                            
                            break;
                        }
                        default:
                            break;
                    }
                    
                    break;
                }
                default:
                    break;
            }
            
            break;
        }
        case NSStreamEventHasBytesAvailable:
        {
            if (stream == _is)
            {
                uint8_t buffer[1024];
                long len = 0;
                while ([_is hasBytesAvailable])
                {
                    len = [_is read:buffer maxLength:sizeof(buffer)];
                    if (len > 0)
                    {
                        [_bufferedReads appendBytes:buffer length:len];
                    }
                }
                
                [self _processBufferedData];
            }
            
            break;
        }
        case NSStreamEventHasSpaceAvailable:
        {
            if (stream == _os)
            {
                if (_bufferedWrites.length != 0)
                {
                    int length = [_os write:_bufferedWrites.bytes maxLength:_bufferedWrites.length];
                    
                    [_bufferedWrites replaceBytesInRange:NSMakeRange(0, length) withBytes:NULL length:0];
                }
                else
                {
                    _streamWriteable = true;
                }
            }
            
            break;
        }
        case NSStreamEventErrorOccurred:
        case NSStreamEventEndEncountered:
        {
            [self _streamsClosed];
            
            break;
        }
        default:
            break;
    }
}

@end