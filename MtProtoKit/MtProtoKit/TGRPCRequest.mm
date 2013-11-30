#import "TGRPCRequest.h"

@implementation TGRPCRequest

- (void)addRespondMessageId:(int64_t)messageId
{
    _respondsToMessageIds.insert(messageId);
}

- (bool)respondsToMessageId:(int64_t)messageId
{
    return _runningMessageId == messageId || _respondsToMessageIds.find(messageId) != _respondsToMessageIds.end();
}

@end
