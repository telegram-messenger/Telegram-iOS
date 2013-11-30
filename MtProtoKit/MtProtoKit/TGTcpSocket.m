#import "TGTcpSocket.h"

#import "ActionStage.h"

#import "GCDAsyncSocket.h"

#import "NSOutputStream+TL.h"

@interface TGTcpSocket () <GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;

@property (nonatomic) int64_t lastOutgoingMessageId;

@end

@implementation TGTcpSocket

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:[ActionStageInstance() globalStageDispatchQueue]];
        _socket.useTcpNodelay = true;
        
        [self connect];
    }
    return self;
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

- (void)connect
{
    [_socket connectToHost:@"192.168.0.122" onPort:25 error:nil];
    
    [_socket readDataToLength:8 withTimeout:-1 tag:0];
    [self timerEvent];
    
    NSTimer *timer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:2.0] interval:2.0 target:self selector:@selector(timerEvent) userInfo:nil repeats:true];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)timerEvent
{
    [self sendMessage];
    [self sendMessage];
    [self sendMessage];
}

- (void)socket:(GCDAsyncSocket *)__unused sock didReadData:(NSData *)data withTag:(long)tag
{
    if (tag == 0)
    {
        int length = 0;
        [data getBytes:&length range:NSMakeRange(0, 4)];
        length = ntohl(length);
        
        [_socket readDataToLength:length withTimeout:-1 tag:1];
    }
    else if (tag == 1)
    {
        [_socket readDataToLength:8 withTimeout:-1 tag:0];
    }
}

- (void)sendMessage
{
    NSMutableData *data = [[NSMutableData alloc] init];
    
    int dataLength = 89 - 8;
    
    int length = dataLength;
    [data appendBytes:&length length:4];
    
    int responseLength = 70;
    [data appendBytes:&responseLength length:4];
    
    uint8_t buf[dataLength];
    arc4random_buf(buf, dataLength);
    [data appendBytes:buf length:dataLength];
    
    [_socket writeData:data withTimeout:-1 tag:0];
}

@end
