//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

#import "OWSMessageHandler.h"
#import <SignalServiceKit/SignalServiceKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

// used in log formatting
NSString *envelopeAddress(SSKProtoEnvelope *envelope)
{
    return [NSString stringWithFormat:@"%@.%d", envelope.sourceAddress, (unsigned int)envelope.sourceDevice];
}

@implementation OWSMessageHandler

+ (NSString *)descriptionForEnvelopeType:(SSKProtoEnvelope *)envelope
{
    OWSAssertDebug(envelope != nil);

    if (!envelope.hasType) {
        OWSProdFail([OWSAnalyticsEvents messageManagerErrorEnvelopeTypeUnknown]);
        return @"Missing Type.";
    }
    switch (envelope.unwrappedType) {
        case SSKProtoEnvelopeTypeUnknown:
            // Shouldn't happen
            OWSProdFail([OWSAnalyticsEvents messageManagerErrorEnvelopeTypeUnknown]);
            return @"Unknown";
        case SSKProtoEnvelopeTypeCiphertext:
            return @"SignalEncryptedMessage";
        case SSKProtoEnvelopeTypeKeyExchange:
            // Unsupported
            OWSProdFail([OWSAnalyticsEvents messageManagerErrorEnvelopeTypeKeyExchange]);
            return @"KeyExchange";
        case SSKProtoEnvelopeTypePrekeyBundle:
            return @"PreKeyEncryptedMessage";
        case SSKProtoEnvelopeTypeReceipt:
            return @"DeliveryReceipt";
        case SSKProtoEnvelopeTypeUnidentifiedSender:
            return @"UnidentifiedSender";
        case SSKProtoEnvelopeTypeSenderkeyMessage:
            return @"SenderKey";
        case SSKProtoEnvelopeTypePlaintextContent:
            return @"PlaintextContent";
        default:
            // Shouldn't happen
            OWSProdFail([OWSAnalyticsEvents messageManagerErrorEnvelopeTypeOther]);
            return @"Other";
    }
}

+ (NSString *)descriptionForEnvelope:(SSKProtoEnvelope *)envelope
{
    OWSAssertDebug(envelope != nil);

    return [NSString stringWithFormat:@"<Envelope type: %@, source: %@, timestamp: %llu, serverTimestamp: %llu, "
                                      @"serverGuid: %@, content.length: %lu />",
                     [self descriptionForEnvelopeType:envelope],
                     envelopeAddress(envelope),
                     envelope.timestamp,
                     envelope.serverTimestamp,
                     envelope.serverGuid,
                     (unsigned long)envelope.content.length];
}

- (NSString *)descriptionForEnvelope:(SSKProtoEnvelope *)envelope
{
    return [[self class] descriptionForEnvelope:envelope];
}


/**
 * We don't want to just log `content.description` because we'd potentially log message bodies for dataMesssages and
 * sync transcripts
 */
- (NSString *)descriptionForContent:(SSKProtoContent *)content
{
    NSMutableString *message = [[NSMutableString alloc] init];
    if (content.syncMessage) {
        [message appendFormat:@"<SyncMessage: %@ />", [self descriptionForSyncMessage:content.syncMessage]];
    } else if (content.dataMessage) {
        [message appendFormat:@"<DataMessage: %@ />", [self descriptionForDataMessage:content.dataMessage]];
    } else if (content.callMessage) {
        [message appendFormat:@"<CallMessage %@ />", [self descriptionForCallMessage:content.callMessage]];
    } else if (content.nullMessage) {
        [message appendFormat:@"<NullMessage: %@ />", content.nullMessage];
    } else if (content.receiptMessage) {
        [message appendFormat:@"<ReceiptMessage: %@ />", content.receiptMessage];
    } else if (content.typingMessage) {
        [message appendFormat:@"<TypingMessage: %@ />", content.typingMessage];
    } else if (content.decryptionErrorMessage) {
        [message appendFormat:@"<DecryptionErrorMessage: %@ />", content.decryptionErrorMessage];
    }

    // SKDM's are not mutually exclusive with other content types
    if (content.hasSenderKeyDistributionMessage) {
        if (message.length > 0) {
            [message appendString:@" + "];
        }
        [message appendString:@"SenderKeyDistributionMessage"];
    }

    if (message.length > 0) {
        return message;
    } else {
        // Don't fire an analytics event; if we ever add a new content type, we'd generate a ton of
        // analytics traffic.
        OWSFailDebug(@"Unknown content type.");
        return @"UnknownContent";
    }
}

- (NSString *)descriptionForCallMessage:(SSKProtoCallMessage *)callMessage
{
    NSString *messageType;
    UInt64 callId;

    if (callMessage.offer) {
        messageType = @"Offer";
        callId = callMessage.offer.id;
    } else if (callMessage.busy) {
        messageType = @"Busy";
        callId = callMessage.busy.id;
    } else if (callMessage.answer) {
        messageType = @"Answer";
        callId = callMessage.answer.id;
    } else if (callMessage.legacyHangup) {
        messageType = @"legacyHangup";
        callId = callMessage.legacyHangup.id;
    } else if (callMessage.hangup) {
        messageType = @"Hangup";
        callId = callMessage.hangup.id;
    } else if (callMessage.iceUpdate.count > 0) {
        messageType = [NSString stringWithFormat:@"Ice Updates (%lu)", (unsigned long)callMessage.iceUpdate.count];
        callId = callMessage.iceUpdate.firstObject.id;
    } else if (callMessage.opaque) {
        messageType = @"Opaque";
        if (callMessage.opaque.hasUrgency) {
            messageType = [NSString stringWithFormat:@"Opaque (%@)",
                                    [self descriptionForCallMessageOpaqueUrgency:callMessage.opaque.unwrappedUrgency]];
        }
        callId = 0;
    } else {
        OWSFailDebug(@"failure: unexpected call message type: %@", callMessage);
        messageType = @"Unknown";
        callId = 0;
    }

    return [NSString stringWithFormat:@"type: %@, id: %llu", messageType, callId];
}

- (NSString *)descriptionForCallMessageOpaqueUrgency:(SSKProtoCallMessageOpaqueUrgency)urgency
{
    switch (urgency) {
        case SSKProtoCallMessageOpaqueUrgencyDroppable:
            return @"Droppable";
        case SSKProtoCallMessageOpaqueUrgencyHandleImmediately:
            return @"HandleImmediately";
        default:
            return @"Unknown";
    }
}

/**
 * We don't want to just log `dataMessage.description` because we'd potentially log message contents
 */
- (NSString *)descriptionForDataMessage:(SSKProtoDataMessage *)dataMessage
{
    NSMutableString *description = [NSMutableString new];

    if (dataMessage.group) {
        [description appendString:@"(Group:YES) "];
    }

    if ((dataMessage.flags & SSKProtoDataMessageFlagsEndSession) != 0) {
        [description appendString:@"EndSession"];
    } else if ((dataMessage.flags & SSKProtoDataMessageFlagsExpirationTimerUpdate) != 0) {
        [description appendString:@"ExpirationTimerUpdate"];
    } else if ((dataMessage.flags & SSKProtoDataMessageFlagsProfileKeyUpdate) != 0) {
        [description appendString:@"ProfileKey"];
    } else if (dataMessage.attachments.count > 0) {
        [description appendString:@"MessageWithAttachment"];
    } else {
        [description appendString:@"Plain"];
    }

    return [NSString stringWithFormat:@"<%@ />", description];
}

/**
 * We don't want to just log `syncMessage.description` because we'd potentially log message contents in sent transcripts
 */
- (NSString *)descriptionForSyncMessage:(SSKProtoSyncMessage *)syncMessage
{
    if (syncMessage.sent) {
        return @"SentTranscript";
    } else if (syncMessage.request) {
        if (!syncMessage.request.hasType) {
            return @"Unknown sync request.";
        }
        if (syncMessage.request.unwrappedType == SSKProtoSyncMessageRequestTypeContacts) {
            return @"ContactRequest";
        } else if (syncMessage.request.unwrappedType == SSKProtoSyncMessageRequestTypeGroups) {
            return @"GroupRequest";
        } else if (syncMessage.request.unwrappedType == SSKProtoSyncMessageRequestTypeBlocked) {
            return @"BlockedRequest";
        } else if (syncMessage.request.unwrappedType == SSKProtoSyncMessageRequestTypeConfiguration) {
            return @"ConfigurationRequest";
        } else if (syncMessage.request.unwrappedType == SSKProtoSyncMessageRequestTypeKeys) {
            return @"KeysRequest";
        } else {
            OWSFailDebug(@"Unknown sync message request type");
            return @"UnknownRequest";
        }
    } else if (syncMessage.blocked) {
        return @"Blocked";
    } else if (syncMessage.read.count > 0) {
        return @"ReadReceipt";
    } else if (syncMessage.verified) {
        return [NSString stringWithFormat:@"Verification for: %@", syncMessage.verified.destinationAddress];
    } else if (syncMessage.stickerPackOperation) {
        NSMutableString *description = [NSMutableString new];
        NSMutableArray<NSString *> *operationTypes = [NSMutableArray new];
        for (SSKProtoSyncMessageStickerPackOperation *packOperationProto in syncMessage.stickerPackOperation) {
            if (!packOperationProto.hasType) {
                [operationTypes addObject:@"unknown"];
                continue;
            }
            switch (packOperationProto.unwrappedType) {
                case SSKProtoSyncMessageStickerPackOperationTypeInstall:
                    [operationTypes addObject:@"install"];
                    break;
                case SSKProtoSyncMessageStickerPackOperationTypeRemove:
                    [operationTypes addObject:@"remove"];
                    break;
                default:
                    [operationTypes addObject:@"unknown"];
                    break;
            }
        }
        [description appendFormat:@"StickerPackOperation: %@", [operationTypes componentsJoinedByString:@", "]];
        return description;
    } else if (syncMessage.fetchLatest) {
        switch (syncMessage.fetchLatest.unwrappedType) {
            case SSKProtoSyncMessageFetchLatestTypeUnknown:
                return @"FetchLatest_Unknown";
            case SSKProtoSyncMessageFetchLatestTypeLocalProfile:
                return @"FetchLatest_LocalProfile";
            case SSKProtoSyncMessageFetchLatestTypeStorageManifest:
                return @"FetchLatest_StorageManifest";
            case SSKProtoSyncMessageFetchLatestTypeSubscriptionStatus:
                return @"FetchLatest_SubscriptionStatus";
        }
    } else {
        OWSFailDebug(@"Unknown sync message type");
        return @"Unknown";
    }
}

@end

NS_ASSUME_NONNULL_END
