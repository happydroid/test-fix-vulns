//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

#import "OWSOutgoingSenderKeyDistributionMessage.h"
#import <SignalServiceKit/SignalServiceKit-Swift.h>

@interface OWSOutgoingSenderKeyDistributionMessage ()
@property (strong, nonatomic, readonly) NSData *serializedSKDM;
@property (assign, atomic) BOOL isSentOnBehalfOfOnlineMessage;
@end

@implementation OWSOutgoingSenderKeyDistributionMessage

- (instancetype)initWithThread:(TSContactThread *)destinationThread
    senderKeyDistributionMessageBytes:(NSData *)skdmBytes;
{
    OWSAssertDebug(destinationThread);
    OWSAssertDebug(skdmBytes);
    if (!destinationThread || !skdmBytes) {
        return nil;
    }

    TSOutgoingMessageBuilder *messageBuilder =
        [TSOutgoingMessageBuilder outgoingMessageBuilderWithThread:destinationThread];
    self = [super initOutgoingMessageWithBuilder:messageBuilder];
    if (self) {
        _serializedSKDM = [skdmBytes copy];
    }
    return self;
}

- (BOOL)shouldBeSaved
{
    return NO;
}

- (nullable NSData *)buildPlainTextData:(TSThread *)thread transaction:(SDSAnyWriteTransaction *)transaction
{
    SSKProtoContentBuilder *builder = [SSKProtoContent builder];
    [builder setSenderKeyDistributionMessage:self.serializedSKDM];

    NSError *_Nullable error = nil;
    NSData *_Nullable data = [builder buildSerializedDataAndReturnError:&error];
    if (error || !data) {
        OWSFailDebug(@"could not serialize protobuf: %@", error);
        return nil;
    }
    return data;
}

- (void)configureAsSentOnBehalfOf:(TSOutgoingMessage *)message
{
    self.isSentOnBehalfOfOnlineMessage = message.isOnline;
}

@end
