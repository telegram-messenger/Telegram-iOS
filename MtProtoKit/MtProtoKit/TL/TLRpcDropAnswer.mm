#import "TLRpcDropAnswer.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLRpcDropAnswer


- (int32_t)TLconstructorSignature
{
    TGLog(@"constructorSignature is not implemented for base type");
    return 0;
}

- (int32_t)TLconstructorName
{
    TGLog(@"constructorName is not implemented for base type");
    return 0;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TGLog(@"TLbuildFromMetaObject is not implemented for base type");
    return nil;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
    TGLog(@"TLfillFieldsWithValues is not implemented for base type");
}


@end

@implementation TLRpcDropAnswer$rpc_answer_unknown : TLRpcDropAnswer


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x5e2ad36e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xf656bba1;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLRpcDropAnswer$rpc_answer_unknown *object = [[TLRpcDropAnswer$rpc_answer_unknown alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLRpcDropAnswer$rpc_answer_dropped_running : TLRpcDropAnswer


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xcd78e586;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x59e94eb6;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLRpcDropAnswer$rpc_answer_dropped_running *object = [[TLRpcDropAnswer$rpc_answer_dropped_running alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLRpcDropAnswer$rpc_answer_dropped : TLRpcDropAnswer

@synthesize msg_id = _msg_id;
@synthesize seq_no = _seq_no;
@synthesize bytes = _bytes;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa43ad8b7;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x57b1a9a2;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLRpcDropAnswer$rpc_answer_dropped *object = [[TLRpcDropAnswer$rpc_answer_dropped alloc] init];
    object.msg_id = metaObject->getInt64(0xf1cc383f);
    object.seq_no = metaObject->getInt32(0x888c67fb);
    object.bytes = metaObject->getInt32(0xec5ef20a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.msg_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xf1cc383f, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.seq_no;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x888c67fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.bytes;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xec5ef20a, value));
    }
}


@end

