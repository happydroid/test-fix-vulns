//
//  Copyright (c) 2022 Open Whisper Systems. All rights reserved.
//

import Foundation
import SignalCoreKit

@objc
public enum SSKWebSocketState: UInt {
    case open, connecting, disconnected
}

// MARK: -

extension SSKWebSocketState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .open:
            return "SSKWebSocketState.open"
        case .connecting:
            return "SSKWebSocketState.connecting"
        case .disconnected:
            return "SSKWebSocketState.disconnected"
        }
    }
}

// MARK: -

@objc
public protocol SSKWebSocket: AnyObject {

    var delegate: SSKWebSocketDelegate? { get set }

    var id: UInt { get }

    var state: SSKWebSocketState { get }

    func connect()
    func disconnect()

    func write(data: Data)

    func writePing()
}

// MARK: -

public extension SSKWebSocket {
    func sendResponse(for request: WebSocketProtoWebSocketRequestMessage,
                      status: UInt32,
                      message: String) throws {
        let responseBuilder = WebSocketProtoWebSocketResponseMessage.builder(requestID: request.requestID,
                                                                             status: status)
        responseBuilder.setMessage(message)
        let response = try responseBuilder.build()

        let messageBuilder = WebSocketProtoWebSocketMessage.builder()
        messageBuilder.setType(.response)
        messageBuilder.setResponse(response)

        let messageData = try messageBuilder.buildSerializedData()

        write(data: messageData)
    }
}

// MARK: -

@objc
public protocol SSKWebSocketDelegate: AnyObject {
    func websocketDidConnect(socket: SSKWebSocket)

    func websocketDidDisconnectOrFail(socket: SSKWebSocket, error: Error?)

    func websocket(_ socket: SSKWebSocket, didReceiveData data: Data)
}

// MARK: -

@objc
public protocol WebSocketFactory: AnyObject {

    var canBuildWebSocket: Bool { get }

    func buildSocket(request: URLRequest,
                     callbackQueue: DispatchQueue) -> SSKWebSocket?

    func statusCode(forError error: Error) -> Int
}

// MARK: -

@objc
public class WebSocketFactoryMock: NSObject, WebSocketFactory {

    public var canBuildWebSocket: Bool { false }

    public func buildSocket(request: URLRequest,
                            callbackQueue: DispatchQueue) -> SSKWebSocket? {
        owsFailDebug("Cannot build websocket.")
        return nil
    }

    public func statusCode(forError error: Error) -> Int {
        error.httpStatusCode ?? 0
    }
}

// MARK: -

@objc
public class WebSocketFactoryNative: NSObject, WebSocketFactory {

    public var canBuildWebSocket: Bool {
        if FeatureFlags.canUseNativeWebsocket,
           #available(iOS 13, *) {
            return true
        } else {
            return false
        }
    }

    public func buildSocket(request: URLRequest,
                            callbackQueue: DispatchQueue) -> SSKWebSocket? {
        guard FeatureFlags.canUseNativeWebsocket,
              #available(iOS 13, *) else {
                  return nil
              }
        return SSKWebSocketNative(request: request, callbackQueue: callbackQueue)
    }

    public func statusCode(forError error: Error) -> Int {
        switch error {
        case SSKWebSocketNativeError.remoteClosed(let statusCode, _):
            return statusCode
        default:
            return error.httpStatusCode ?? 0
        }
    }
}

// MARK: -

@available(iOS 13, *)
public class SSKWebSocketNative: SSKWebSocket {

    private static let idCounter = AtomicUInt()
    public let id = SSKWebSocketNative.idCounter.increment()
    private var webSocketTask = AtomicOptional<URLSessionWebSocketTask>(nil)
    private let request: URLRequest
    private let session = OWSURLSession(
        securityPolicy: OWSURLSession.signalServiceSecurityPolicy,
        configuration: OWSURLSession.defaultConfigurationWithoutCaching
    )
    private let callbackQueue: DispatchQueue

    public init(request: URLRequest,
                callbackQueue: DispatchQueue? = nil) {

        self.request = request
        self.callbackQueue = callbackQueue ?? .main
    }

    // MARK: - SSKWebSocket

    public weak var delegate: SSKWebSocketDelegate?

    private let hasEverConnected = AtomicBool(false)
    private let isConnected = AtomicBool(false)
    private let isDisconnecting = AtomicBool(false)

    // This method is thread-safe.
    public var state: SSKWebSocketState {
        if isConnected.get() {
            return .open
        }

        if hasEverConnected.get() {
            return .disconnected
        }

        return .connecting
    }

    public func connect() {
        guard webSocketTask.get() == nil else { return }

        let task = session.webSocketTask(request: request, didOpenBlock: { [weak self] _ in
            guard let self = self else { return }
            self.isConnected.set(true)
            self.hasEverConnected.set(true)

            self.listenForNextMessage()

            self.callbackQueue.async {
                self.delegate?.websocketDidConnect(socket: self)
            }
        }, didCloseBlock: { [weak self] closeCode, reason in
            guard let self = self else { return }
            self.isConnected.set(false)
            self.webSocketTask.set(nil)
            self.reportError(SSKWebSocketNativeError.remoteClosed(closeCode.rawValue, reason))
        })
        webSocketTask.set(task)
        task.resume()
    }

    func listenForNextMessage() {
        DispatchQueue.global().async { [weak self] in
            self?.webSocketTask.get()?.receive { result in
                switch result {
                case .success(let message):
                    switch message {
                    case .data(let data):
                        guard let self = self else { return }
                        self.callbackQueue.async {
                            self.delegate?.websocket(self, didReceiveData: data)
                        }

                    case .string:
                        owsFailDebug("We only expect binary frames.")
                    @unknown default:
                        owsFailDebug("We only expect binary frames.")
                    }
                case .failure(let error):
                    Logger.warn("Error receiving websocket message \(error)")
                    self?.reportError(error)
                    // Don't try to listen again.
                    return
                }

                self?.listenForNextMessage()
            }
        }
    }

    public func disconnect() {
        isDisconnecting.set(true)
        webSocketTask.swap(nil)?.cancel()
    }

    public func write(data: Data) {
        owsAssertDebug(hasEverConnected.get())
        guard let webSocketTask = webSocketTask.get() else {
            reportError(OWSGenericError("Missing webSocketTask."))
            return
        }
        webSocketTask.send(.data(data)) { [weak self] error in
            guard let self = self, let error = error else { return }
            Logger.warn("Error sending websocket data \(error), [\(self.id)]")
            self.reportError(error)
        }
    }

    public func writePing() {
        owsAssertDebug(hasEverConnected.get())
        guard let webSocketTask = webSocketTask.get() else {
            reportError(OWSGenericError("Missing webSocketTask."))
            return
        }
        webSocketTask.sendPing { [weak self] error in
            guard let self = self, let error = error else { return }
            Logger.warn("Error sending websocket ping \(error), [\(self.id)]")
            self.reportError(error)
        }
    }

    private func reportError(_ error: Error) {
        guard !isDisconnecting.get() else {
            // This is expected.
            Logger.verbose("Error after disconnecting: \(error), [\(self.id)]")
            return
        }
        callbackQueue.async { [weak self] in
            if let self = self,
               let delegate = self.delegate {
                delegate.websocketDidDisconnectOrFail(socket: self, error: error)
            }
        }
    }
}

public enum SSKWebSocketNativeError: Error {
    case remoteClosed(Int, Data?)

    var description: String {
        switch self {
        case .remoteClosed(let code, _):
            return "WebSocket remotely closed with code \(code)"
        }
    }
}
