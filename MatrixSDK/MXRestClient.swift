/*
 Copyright 2017 Avery Pierce
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation

/**
 Captures the result of an API call and it's associated success data.
 
 # Examples:
 
 Use a switch statement to handle both a success and an error:
 
     mxRestClient.publicRooms { response in
        switch response {
        case .success(let rooms):
            // Do something useful with these rooms
            break
     
        case .failure(let error):
            // Handle the error in some way
            break
        }
     }
 
 Silently ignore the failure case:
 
     mxRestClient.publicRooms { response in
         guard let rooms = response.value else { return }
         // Do something useful with these rooms
     }

 */
public enum MXResponse<T> {
    case success(T)
    case failure(Error)
    
    /// Indicates whether the API call was successful
    public var isSuccess: Bool {
        switch self {
        case .success:   return true
        default:        return false
        }
    }
    
    /// The response's success value, if applicable
    public var value: T? {
        switch self {
        case .success(let value): return value
        default: return nil
        }
    }
    
    /// Indicates whether the API call failed
    public var isFailure: Bool {
        return !isSuccess
    }
    
    /// The response's error value, if applicable
    public var error: Error? {
        switch self {
        case .failure(let error): return error
        default: return nil
        }
    }
}

public enum MXProgress<T> {
    case progress(Progress)
    case success(T)
    case failure(Error)
    
    /// Indicates whether the call is complete.
    public var isComplete: Bool {
        switch self {
        case .success, .failure: return true
        default: return false
        }
    }
    
    /// The current progress. If the process is already complete, this will return nil.
    public var progress: Progress? {
        switch self {
        case .progress(let progress): return progress
        default: return nil
        }
    }
    
    /// Indicates whether the API call was successful
    public var isSuccess: Bool {
        switch self {
        case .success:   return true
        default:        return false
        }
    }
    
    /// The response's success value, if applicable
    public var value: T? {
        switch self {
        case .success(let value): return value
        default: return nil
        }
    }
    
    /// Indicates whether the API call failed
    public var isFailure: Bool {
        return !isSuccess
    }
    
    /// The response's error value, if applicable
    public var error: Error? {
        switch self {
        case .failure(let error): return error
        default: return nil
        }
    }
}

fileprivate extension MXResponse {
    
    /**
     Take the value from an optional, if it's available.
     Otherwise, return a failure with _MXUnknownError
     
     - parameter value: to be captured in a `.success` case, if it's not `nil` and the type is correct.
     
     - returns: `.success(value)` if the value is not `nil`, otherwise `.failure(_MXUnkownError())`
     */
    static func fromOptional(value: Any?) -> MXResponse<T> {
        if let value = value as? T {
            return .success(value)
        } else {
            return .failure(_MXUnknownError())
        }
    }
    
    /**
     Take the error from an optional, if it's available.
     Otherwise, return a failure with _MXUnknownError
     
     - parameter error: to be captured in a `.failure` case, if it's not `nil`.
     
     - returns: `.failure(error)` if the value is not `nil`, otherwise `.failure(_MXUnkownError())`
     */
    static func fromOptional(error: Error?) -> MXResponse<T> {
        return .failure(error ?? _MXUnknownError())
    }
}



/**
 Represents an error that was unexpectedly nil.
 
 This struct only exists to fill in the gaps formed by optionals that
 were created by ObjC headers that don't specify nullibility. Under
 normal controlled circumstances, this should probably never be used.
 */
struct _MXUnknownError : Error {
    var localizedDescription: String {
        return "error object was unexpectedly nil"
    }
}


/// Represents a login flow
public enum MXLoginFlowType : String {
    case password = "m.login.password"
    case recaptcha = "m.login.recaptcha"
    case OAuth2 = "m.login.oauth2"
    case emailIdentity = "m.login.email.identity"
    case token = "m.login.token"
    case dummy = "m.login.dummy"
    case emailCode = "m.login.email.code"
}

/// Represents account data type
public enum MXAccountDataType {
    case direct
    case pushRules
    case ignoredUserList
    case custom(String)
    
    var rawValue: String {
        switch self {
        case .direct:               return kMXAccountDataTypeDirect
        case .pushRules:            return kMXAccountDataTypePushRules
        case .ignoredUserList:      return kMXAccountDataKeyIgnoredUser
        case .custom(let value):    return value
        }
    }
}

/// Represents a mode for forwarding push notifications.
public enum MXPusherKind {
    case http, none, custom(String)

    var objectValue: NSObject {
        switch self {
        case .http: return "http" as NSString
        case .none: return NSNull()
        case .custom(let value): return value as NSString
        }
    }
}


/**
 Push rules kind.
 
 Push rules are separated into different kinds of rules. These categories have a priority order: verride rules
 have the highest priority.
 Some category may define implicit conditions.
 */
public enum MXPushRuleKind {
    case override, content, room, sender, underride

    var objc: __MXPushRuleKind {
        switch self  {
        case .override: return __MXPushRuleKindOverride
        case .content: return __MXPushRuleKindContent
        case .room: return __MXPushRuleKindRoom
        case .sender: return __MXPushRuleKindSender
        case .underride: return __MXPushRuleKindUnderride
        }
    }
}


/**
 Scope for a specific push rule.
 
 Push rules can be applied globally, or to a spefific device given a `profileTag`
 */
public enum MXPushRuleScope {
    case global, device(profileTag: String)

    var identifier: String {
        switch self {
        case .global: return "global"
        case .device(let profileTag): return "device/\(profileTag)"
        }
    }
}





/**
 Types of Matrix events
 
 Matrix events types are exchanged as strings with the home server. The types
 specified by the Matrix standard are listed here as NSUInteger enum in order
 to ease the type handling.
 
 Custom events types, out of the specification, may exist. In this case,
 `MXEventTypeString` must be checked.
 */
public enum MXEventType {
    case roomName
    case roomTopic
    case roomAvatar
    case roomMember
    case roomCreate
    case roomJoinRules
    case roomPowerLevels
    case roomAliases
    case roomCanonicalAlias
    case roomEncrypted
    case roomEncryption
    case roomGuestAccess
    case roomHistoryVisibility
    case roomKey
    case roomMessage
    case roomMessageFeedback
    case roomRedaction
    case roomThirdPartyInvite
    case roomTag
    case presence
    case typing
    case newDevice
    case callInvite
    case callCandidates
    case callAnswer
    case callHangup
    case receipt
    
    case custom(String)
    
    var identifier: String {
        switch self {
        case .roomName: return kMXEventTypeStringRoomName
        case .roomTopic: return kMXEventTypeStringRoomTopic
        case .roomAvatar: return kMXEventTypeStringRoomAvatar
        case .roomMember: return kMXEventTypeStringRoomMember
        case .roomCreate: return kMXEventTypeStringRoomCreate
        case .roomJoinRules: return kMXEventTypeStringRoomJoinRules
        case .roomPowerLevels: return kMXEventTypeStringRoomPowerLevels
        case .roomAliases: return kMXEventTypeStringRoomAliases
        case .roomCanonicalAlias: return kMXEventTypeStringRoomCanonicalAlias
        case .roomEncrypted: return kMXEventTypeStringRoomEncrypted
        case .roomEncryption: return kMXEventTypeStringRoomEncryption
        case .roomGuestAccess: return kMXEventTypeStringRoomGuestAccess
        case .roomHistoryVisibility: return kMXEventTypeStringRoomHistoryVisibility
        case .roomKey: return kMXEventTypeStringRoomKey
        case .roomMessage: return kMXEventTypeStringRoomMessage
        case .roomMessageFeedback: return kMXEventTypeStringRoomMessageFeedback
        case .roomRedaction: return kMXEventTypeStringRoomRedaction
        case .roomThirdPartyInvite: return kMXEventTypeStringRoomThirdPartyInvite
        case .roomTag: return kMXEventTypeStringRoomTag
        case .presence: return kMXEventTypeStringPresence
        case .newDevice: return kMXEventTypeStringNewDevice
        case .callInvite: return kMXEventTypeStringCallInvite
        case .callCandidates: return kMXEventTypeStringCallCandidates
        case .callAnswer: return kMXEventTypeStringCallAnswer
        case .callHangup: return kMXEventTypeStringCallHangup
        case .receipt: return kMXEventTypeStringReceipt
            
        // Swift converts any constant with the suffix "Notification" as the type `Notification.Name`
        // The original value can be reached using the `rawValue` property.
        case .typing: return NSNotification.Name.mxEventTypeStringTyping.rawValue
            
        case .custom(let string): return string
        }
    }
}

/// Types of messages
public enum MXMessageType {
    case text, emote, notice, image, audio, video, location, file
    
    var identifier: String {
        switch self {
        case .text: return kMXMessageTypeText
        case .emote: return kMXMessageTypeEmote
        case .notice: return kMXMessageTypeNotice
        case .image: return kMXMessageTypeImage
        case .audio: return kMXMessageTypeAudio
        case .video: return kMXMessageTypeVideo
        case .location: return kMXMessageTypeLocation
        case .file: return kMXMessageTypeFile
        }
    }
}



public enum MXRoomHistoryVisibility {
    case worldReadable, shared, invited, joined
    
    var identifier: String {
        switch self {
        case .worldReadable: return kMXRoomHistoryVisibilityWorldReadable
        case .shared: return kMXRoomHistoryVisibilityShared
        case .invited: return kMXRoomHistoryVisibilityInvited
        case .joined: return kMXRoomHistoryVisibilityJoined
        }
    }
    
    init?(identifier: String?) {
        let historyVisibilities: [MXRoomHistoryVisibility] = [.worldReadable, .shared, .invited, .joined]
        guard let value = historyVisibilities.first(where: {$0.identifier == identifier}) else { return nil }
        self = value
    }
}

/**
 Room join rule.
 
 The default homeserver value is invite.
 */
public enum MXRoomJoinRule {
    
    /// Anyone can join the room without any prior action
    case `public`
    
    /// A user who wishes to join the room must first receive an invite to the room from someone already inside of the room.
    case invite
    
    /// Reserved keyword which is not implemented by homeservers.
    case `private`, knock
    
    var identifier: String {
        switch self {
        case .public: return kMXRoomJoinRulePublic
        case .invite: return kMXRoomJoinRuleInvite
        case .private: return kMXRoomJoinRulePrivate
        case .knock: return kMXRoomJoinRuleKnock
        }
    }
    
    init?(identifier: String?) {
        let joinRules: [MXRoomJoinRule] = [.public, .invite, .private, .knock]
        guard let value = joinRules.first(where: { $0.identifier == identifier}) else { return nil }
        self = value
    }
}


/// Room guest access. The default homeserver value is forbidden.
public enum MXRoomGuestAccess {
    
    /// Guests can join the room
    case canJoin
    
    /// Guest access is forbidden
    case forbidden
    
    /// String identifier
    var identifier: String {
        switch self {
        case .canJoin: return kMXRoomGuestAccessCanJoin
        case .forbidden: return kMXRoomGuestAccessForbidden
        }
    }
    
    init?(identifier: String?) {
        let accessRules: [MXRoomGuestAccess] = [.canJoin, .forbidden]
        guard let value = accessRules.first(where: { $0.identifier == identifier}) else { return nil }
        self = value
    }
}



/**
 Room visibility in the current homeserver directory.
 The default homeserver value is private.
 */
public enum MXRoomDirectoryVisibility {
    
    /// The room is not listed in the homeserver directory
    case `private`
    
    /// The room is listed in the homeserver directory
    case `public`
    
    var identifier: String {
        switch self {
        case .private: return kMXRoomDirectoryVisibilityPrivate
        case .public: return kMXRoomDirectoryVisibilityPublic
        }
    }
    
    init?(identifier: String?) {
        let visibility: [MXRoomDirectoryVisibility] = [.public, .private]
        guard let value = visibility.first(where: { $0.identifier == identifier}) else { return nil }
        self = value
    }
}





/// Method of inviting a user to a room
public enum MXRoomInvitee {
    
    /// Invite a user by username
    case userId(String)
    
    /// Invite a user by email
    case email(String)
    
    /// Invite a user using a third-party mechanism.
    /// `method` is the method to use, eg. "email".
    /// `address` is the address of the user.
    case thirdPartyId(medium: String, address: String)
}




/// Room presets.
/// Define a set of state events applied during a new room creation.
public enum MXRoomPreset {
    
    /// join_rules is set to invite. history_visibility is set to shared.
    case privateChat
    
    /// join_rules is set to invite. history_visibility is set to shared. All invitees are given the same power level as the room creator.
    case trustedPrivateChat
    
    /// join_rules is set to public. history_visibility is set to shared.
    case publicChat
    
    
    var identifier: String {
        switch self {
        case .privateChat: return kMXRoomPresetPrivateChat
        case .trustedPrivateChat: return kMXRoomPresetTrustedPrivateChat
        case .publicChat: return kMXRoomPresetPublicChat
        }
    }
}


/// Types of third-party identifiers.
public enum MX3PIDMedium {
    case email
    case msisdn
    case other(String)
    
    var identifier: String {
        switch self {
        case .email: return kMX3PIDMediumEmail
        case .msisdn: return kMX3PIDMediumMSISDN
        case .other(let value): return value
        }
    }
}



/**
 Return a closure that accepts any object, converts it to a MXResponse value, and then 
 executes the provided completion block
 
 The `transform` parameter is helpful in cases where `T` and `U` are different types, 
 for instance when `U` is an enum, and `T` is it's identifier as a String.
 
 - parameters:
    - transform: A block that takes the output from the API and transforms it to the expected
        type. The default block returns the input as-is.
    - input: The value taken directly from the API call.
    - completion: A block that gets called with the manufactured `MXResponse` variable.
    - response: The API response wrapped in a `MXResponse` enum.
 
 - returns: a block that accepts an optional value from the API, wraps it in an `MXResponse`, and then passes it to `completion`

 
 ## Usage Example:
 
 ```
 func guestAccess(forRoom roomId: String, completion: @escaping (_ response: MXResponse<MXRoomGuestAccess>) -> Void) -> MXHTTPOperation? {
    return __guestAccess(ofRoom: roomId, success: success(transform: MXRoomGuestAccess.init, completion), failure: error(completion))
 }
 ```
 
 1. The `success:` block of the `__guestAccess` function passes in a `String?` type from the API.
 2. That value gets fed into the `transform:` block – in this case, an initializer for `MXRoomGuestAccess`.
 3. The `MXRoomGuestAccess` value returned from the  `transform:` block is wrapped in a `MXResponse` enum.
 4. The newly created `MXResponse` is passed to the completion block.
 
 */

fileprivate func success<T, U>(transform: @escaping (_ input: T) -> U? = { return $0 as? U },
                         _ completion: @escaping (_ response: MXResponse<U>) -> Void) -> (T) -> Void {
    return { completion(.fromOptional(value: transform($0))) }
}

/// Return a closure that accepts any error, converts it to a MXResponse value, and then executes the provded completion block
fileprivate func error<T>(_ completion: @escaping (MXResponse<T>) -> Void) -> (Error?) -> Void {
    return { completion(.fromOptional(error: $0)) }
}


public extension MXRestClient {
    
    
    // MARK: - Initialization
    
    /**
     Create an instance based on homeserver url.
     
     - parameters:
         - homeServer: The homeserver address.
         - handler: the block called to handle unrecognized certificate (`nil` if unrecognized certificates are ignored).
     
     - returns: a `MXRestClient` instance.
     */
    @nonobjc convenience init(homeServer: URL, unrecognizedCertificateHandler handler: MXHTTPClientOnUnrecognizedCertificate?) {
        self.init(__homeServer: homeServer.absoluteString, andOnUnrecognizedCertificateBlock: handler)
    }
    
    /**
     Create an instance based on existing user credentials.
     
     - parameters:
         - credentials: A set of existing user credentials.
         - handler: the block called to handle unrecognized certificate (`nil` if unrecognized certificates are ignored).
     
     - returns: a `MXRestClient` instance.
     */
    @nonobjc convenience init(credentials: MXCredentials, unrecognizedCertificateHandler handler: MXHTTPClientOnUnrecognizedCertificate?) {
        self.init(__credentials: credentials, andOnUnrecognizedCertificateBlock: handler)
    }

    
    
    
    // MARK: - Registration Operations
    
    /**
     Check whether a username is already in use.
     
     - parameters:
         - username: The user name to test.
         - completion: A block object called when the operation is completed.
         - inUse: Whether the username is in use
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func isUserNameInUse(_ username: String, completion: @escaping (_ inUse: Bool) -> Void) -> MXHTTPOperation? {
        return __isUserName(inUse: username, callback: completion)
    }
    
    /**
     Get the list of register flows supported by the home server.
     
     - parameters:
         - completion: A block object called when the operation is completed.
         - response: Provides the server response as an `MXAuthenticationSession` instance.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func getRegisterSession(completion: @escaping (_ response: MXResponse<MXAuthenticationSession>) -> Void) -> MXHTTPOperation? {
        return __getRegisterSession(success(completion), failure: error(completion))
    }

    
    /**
     Generic registration action request.
     
     As described in [the specification](http://matrix.org/docs/spec/client_server/r0.2.0.html#client-authentication),
     some registration flows require to complete several stages in order to complete user registration.
     This can lead to make several requests to the home server with different kinds of parameters.
     This generic method with open parameters and response exists to handle any kind of registration flow stage.
     
     At the end of the registration process, the SDK user should be able to construct a MXCredentials object
     from the response of the last registration action request.
     
     - parameters:
         - parameters: the parameters required for the current registration stage
         - completion: A block object called when the operation completes.
         - response: Provides the raw JSON response from the server.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func register(parameters: [String: Any], completion: @escaping (_ response: MXResponse<[String: Any]>) -> Void) -> MXHTTPOperation? {
        return __register(withParameters: parameters, success: success(completion), failure: error(completion))
    }
    
    
    
    /*
     TODO: This method accepts a nil username. Maybe this should be called "anonymous registration"? Would it make sense to have a separate API for that case?
     We could also create an enum called "MXRegistrationType" with associated values, e.g. `.username(String)` and `.anonymous`
     */
    /**
     Register a user.
     
     This method manages the full flow for simple login types and returns the credentials of the newly created matrix user.
     
     - parameters:
         - loginType: the login type. Only `MXLoginFlowType.password` and `MXLoginFlowType.dummy` (m.login.password and m.login.dummy) are supported.
         - username: the user id (ex: "@bob:matrix.org") or the user id localpart (ex: "bob") of the user to register. Can be nil.
         - password: the user's password.
         - completion: A block object called when the operation completes.
         - response: Provides credentials to use to create a `MXRestClient`.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func register(loginType: MXLoginFlowType = .password, username: String?, password: String, completion: @escaping (_ response: MXResponse<MXCredentials>) -> Void) -> MXHTTPOperation? {
        return __register(withLoginType: loginType.rawValue, username: username, password: password, success: success(completion), failure: error(completion))
    }
    
    
    /// The register fallback page to make registration via a web browser or a web view.
    var registerFallbackURL: URL {
        let fallbackString = __registerFallback()!
        return URL(string: fallbackString)!
    }
    
    
    
    
    
    
    // MARK: - Login Operation
    
    /**
     Get the list of login flows supported by the home server.
     
     - parameters:
         - completion: A block object called when the operation completes. 
         - response: Provides the server response as an MXAuthenticationSession instance.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func getLoginSession(completion: @escaping (_ response: MXResponse<MXAuthenticationSession>) -> Void) -> MXHTTPOperation? {
        return __getLoginSession(success(completion), failure: error(completion))
    }
    
    /**
     Generic login action request.
     
     As described in [the specification](http://matrix.org/docs/spec/client_server/r0.2.0.html#client-authentication),
     some login flows require to complete several stages in order to complete authentication.
     This can lead to make several requests to the home server with different kinds of parameters.
     This generic method with open parameters and response exists to handle any kind of authentication flow stage.
     
     At the end of the registration process, the SDK user should be able to construct a MXCredentials object
     from the response of the last authentication action request.
     
     - parameters:
         - parameters: the parameters required for the current login stage
         - completion: A block object called when the operation completes.
         - response: Provides the raw JSON response from the server.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func login(parameters: [String: Any], completion: @escaping (_ response: MXResponse<[String: Any]>) -> Void) -> MXHTTPOperation? {
        return __login(parameters, success: success(completion), failure: error(completion))
    }
    
    /**
     Log a user in.
     
     This method manages the full flow for simple login types and returns the credentials of the logged matrix user.
     
     - parameters:
         - type: the login type. Only `MXLoginFlowType.password` (m.login.password) is supported.
         - username: the user id (ex: "@bob:matrix.org") or the user id localpart (ex: "bob") of the user to authenticate.
         - password: the user's password.
         - completion: A block object called when the operation succeeds.
         - response: Provides credentials for this user on `success`
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func login(type loginType: MXLoginFlowType = .password, username: String, password: String, completion: @escaping (_ response: MXResponse<MXCredentials>) -> Void) -> MXHTTPOperation? {
        return __login(withLoginType: loginType.rawValue, username: username, password: password, success: success(completion), failure: error(completion))
    }
    
    
    /**
     Get the login fallback page to make login via a web browser or a web view.
     
     Presently only server auth v1 is supported.
     
     - returns: the fallback page URL.
     */
    var loginFallbackURL: URL {
        let fallbackString = __loginFallback()!
        return URL(string: fallbackString)!
    }

    
    /**
     Reset the account password.
     
     - parameters:
         - parameters: a set of parameters containing a threepid credentials and the new password.
         - completion: A block object called when the operation completes.
         - response: indicates whether the operation succeeded or not.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func resetPassword(parameters: [String: Any], completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __resetPassword(withParameters: parameters, success: success(completion), failure: error(completion))
    }
    
    
    /**
     Replace the account password.
     
     - parameters:
         - old: the current password to update.
         - new: the new password.
         - completion: A block object called when the operation completes
         - response: indicates whether the operation succeeded or not.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func changePassword(from old: String, to new: String, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __changePassword(old, with: new, success: success(completion), failure: error(completion))
    }
    
    
    /**
     Invalidate the access token, so that it can no longer be used for authorization.
     
     - parameters:
         - completion: A block object called when the operation completes.
         - response: Indicates whether the operation succeeded or not.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func logout(completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __logout(success(completion), failure: error(completion))
    }
    
    
    
    
    // MARK: - Account data
    
    /**
     Set some account_data for the client.
     
     - parameters:
         - data: the new data to set for this event type.
         - type: The event type of the account_data to set. Custom types should be namespaced to avoid clashes.
         - completion: A block object called when the operation completes
         - response: indicates whether the request succeeded or not
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func setAccountData(_ data: [String: Any], for type: MXAccountDataType, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __setAccountData(data, forType: type.rawValue, success: success(completion), failure: error(completion))
    }
    
    
    
    
    
    
    
    
    // MARK: - Push Notifications
    
    /**
     Update the pusher for this device on the Home Server.
     
     - parameters:
        - pushkey: The pushkey for this pusher. This should be the APNS token formatted as required for your push gateway (base64 is the recommended formatting).
        - kind: The kind of pusher your push gateway requires. Generally `.http`. Specify `.none` to disable the pusher.
        - appId: The app ID of this application as required by your push gateway.
        - appDisplayName: A human readable display name for this app.
        - deviceDisplayName: A human readable display name for this device.
        - profileTag: The profile tag for this device. Identifies this device in push rules.
        - lang: The user's preferred language for push, eg. 'en' or 'en-US'
        - data: Dictionary of data as required by your push gateway (generally the notification URI and aps-environment for APNS).
        - completion: A block object called when the operation succeeds.
        - response: indicates whether the request succeeded or not.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func setPusher(pushKey: String, kind: MXPusherKind, appId: String, appDisplayName: String, deviceDisplayName: String, profileTag: String, lang: String, data: [String: Any], append: Bool, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __setPusherWithPushkey(pushKey, kind: kind.objectValue, appId: appId, appDisplayName: appDisplayName, deviceDisplayName: deviceDisplayName, profileTag: profileTag, lang: lang, data: data, append: append, success: success(completion), failure: error(completion))
    }
    // TODO: setPusherWithPushKey - futher refinement
    /*
     This method is very long. Some of the parameters seem related,
     specifically: appId, appDisplayName, deviceDisplayName, and profileTag.
     Perhaps these parameters can be lifted out into a sparate struct?
     Something like "MXPusherDescriptor"?
     */
    
    
    /**
     Get all push notifications rules.
     
     - parameters:
        - completion: A block object called when the operation completes.
        - response: Provides the push rules on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func pushRules(completion: @escaping (_ response: MXResponse<MXPushRulesResponse>) -> Void) -> MXHTTPOperation? {
        return __pushRules(success(completion), failure: error(completion))
    }
    
    
    /*
     TODO: Consider refactoring. The following three methods all contain (ruleId:, scope:, kind:).
     
     Option 1: Encapsulate those parameters as a tuple or struct called `MXPushRuleDescriptor`
     This would be appropriate if these three parameters typically get passed around as a set,
     or if the rule is uniquely identified by this combination of parameters. (eg. one `ruleId`
     can have different settings for varying scopes and kinds).
     
     Option 2: Refactor all of these to a single function that takes a "MXPushRuleAction"
     as the fourth paramerer. This approach might look like this:
     
         enum MXPushRuleAction {
            case enable
            case disable
            case add(actions: [Any], pattern: String, conditions: [[String: Any]])
            case remove
         }
         
         func pushRule(ruleId: String, scope: MXPushRuleScope, kind: MXPushRuleKind, action: MXPushRuleAction, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation ? {
             switch action {
             case .enable:
                 // ... Call the `enablePushRule` method
             case .disable:
                 // ... Call the `enablePushRule` method
             case let .add(actions, pattern, conditions):
                 // ... Call the `addPushRule` method
             case let .remove:
                 // ... Call the `removePushRule` method
             }
         }
    
     Option 3: Leave these APIs as-is.
     */
    
    /**
     Enable/Disable a push notification rule.
     
     - parameters:
        - ruleId: The identifier for the rule.
        - scope: Either 'global' or 'device/<profile_tag>' to specify global rules or device rules for the given profile_tag.
        - kind: The kind of rule, ie. 'override', 'underride', 'sender', 'room', 'content' (see MXPushRuleKind).
        - enabled: YES to enable
        - completion: A block object called when the operation completes
        - response: Indiciates whether the operation was successful
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func setPushRuleEnabled(ruleId: String, scope: MXPushRuleScope, kind: MXPushRuleKind, enabled: Bool, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __enablePushRule(ruleId, scope: scope.identifier, kind: kind.objc, enable: enabled, success: success(completion), failure: error(completion))
    }
    
    
    /**
     Remove a push notification rule.
     
     - parameters:
        - ruleId: The identifier for the rule.
        - scope: Either `.global` or `.device(profileTag:)` to specify global rules or device rules for the given profile_tag.
        - kind: The kind of rule, ie. `.override`, `.underride`, `.sender`, `.room`, `.content`.
        - completion: A block object called when the operation completes.
        - response: Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func removePushRule(ruleId: String, scope: MXPushRuleScope, kind: MXPushRuleKind, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __removePushRule(ruleId, scope: scope.identifier, kind: kind.objc, success: success(completion), failure: error(completion))
    }
    
    /**
     Create a new push rule.
     
     - parameters:
        - ruleId: The identifier for the rule (it depends on rule kind: user id for sender rule, room id for room rule...).
        - scope: Either `.global` or `.device(profileTag:)` to specify global rules or device rules for the given profile_tag.
        - kind: The kind of rule, ie. `.override`, `.underride`, `.sender`, `.room`, `.content`.
        - actions: The rule actions: notify, don't notify, set tweak...
        - pattern: The pattern relevant for content rule.
        - conditions: The conditions relevant for override and underride rule.
        - completion: A block object called when the operation completes.
        - response: Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func addPushRule(ruleId: String, scope: MXPushRuleScope, kind: MXPushRuleKind, actions: [Any], pattern: String, conditions: [[String: Any]], completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __addPushRule(ruleId, scope: scope.identifier, kind: kind.objc, actions: actions, pattern: pattern, conditions: conditions, success: success(completion), failure: error(completion))
    }
    
    
    
    
    
    
    
    // MARK: - Room operations
    
    /**
     Send a generic non state event to a room.
     
     - parameters:
        - roomId: the id of the room.
        - eventType: the type of the event.
        - content: the content that will be sent to the server as a JSON object.
        - completion: A block object called when the operation completes.
        - response: Provides the event id of the event generated on the home server on success.
     
     - returns: a `MXHTTPOperation` instance.
     
     */
    @nonobjc @discardableResult func sendEvent(toRoom roomId: String, eventType: MXEventType, content: [String: Any], completion: @escaping (_ response: MXResponse<String>) -> Void) -> MXHTTPOperation? {
        return __sendEvent(toRoom: roomId, eventType: eventType.identifier, content: content, success: success(completion), failure: error(completion))
    }
    
    
    /**
     Send a generic state event to a room.
     
     - paramters:
        - roomId: the id of the room.
        - eventType: the type of the event. @see MXEventType.
        - content: the content that will be sent to the server as a JSON object.
        - completion: A block object called when the operation completes.
        - response: Provides the event id of the event generated on the home server on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func sendStateEvent(toRoom roomId: String, eventType: MXEventType, content: [String: Any], completion: @escaping (_ response: MXResponse<String>) -> Void) -> MXHTTPOperation? {
        return __sendStateEvent(toRoom: roomId, eventType: eventType.identifier, content: content, success: success(completion), failure: error(completion))
    }
    
    /**
     Send a message to a room
     
     - parameters:
        - roomId: the id of the room.
        - messageType: the type of the message.
        - content: the message content that will be sent to the server as a JSON object.
        - completion: A block object called when the operation completes. 
        - response: Provides the event id of the event generated on the home server on success.
     
     -returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func sendMessage(toRoom roomId: String, messageType: MXMessageType, content: [String: Any], completion: @escaping (_ response: MXResponse<String>) -> Void) -> MXHTTPOperation? {
        return __sendMessage(toRoom: roomId, msgType: messageType.identifier, content: content, success: success(completion), failure: error(completion))
    }
    
    
    /**
     Send a text message to a room
     
     - parameters:
        - roomId: the id of the room.
        - text: the text to send.
        - completion: A block object called when the operation completes.
        - response: Provides the event id of the event generated on the home server on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func sendTextMessage(toRoom roomId: String, text: String, completion: @escaping (_ response: MXResponse<String>) -> Void) -> MXHTTPOperation? {
        return __sendTextMessage(toRoom: roomId, text: text, success: success(completion), failure: error(completion))
    }
    
    
    
    /**
     Set the topic of a room.
     
     - parameters:
        - roomId: the id of the room.
        - topic: the topic to set.
        - completion: A block object called when the operation completes.
        - response: Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func setTopic(ofRoom roomId: String, topic: String, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __setRoomTopic(roomId, topic: topic, success: success(completion), failure: error(completion))
    }
    
    /**
     Get the topic of a room.
     
     - parameters:
        - roomId: the id of the room.
        - completion: A block object called when the operation completes.
        - response: Provides the topic of the room on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func topic(ofRoom roomId: String, completion: @escaping (_ response: MXResponse<String>) -> Void) -> MXHTTPOperation? {
        return __topic(ofRoom: roomId, success: success(completion), failure: error(completion))
    }
    
    
    
    /**
     Set the avatar of a room.
     
     - parameters:
        - roomId: the id of the room.
        - avatar: the avatar url to set.
        - completion: A block object called when the operation completes.
        - response: Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func setAvatar(ofRoom roomId: String, avatarUrl: URL, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __setRoomAvatar(roomId, avatar: avatarUrl.absoluteString, success: success(completion), failure: error(completion))
    }
    
    /**
     Get the avatar of a room.
     
     - parameters:
        - roomId: the id of the room.
        - completion: A block object called when the operation completes.
        - response: Provides the room avatar url on success.
     
     - returns: a MXHTTPOperation instance.
     */
    @nonobjc @discardableResult func avatar(ofRoom roomId: String, completion: @escaping (_ response: MXResponse<URL>) -> Void) -> MXHTTPOperation? {
        return __avatar(ofRoom: roomId, success: success(transform: {return URL(string: $0 ?? "")}, completion), failure: error(completion))
    }
    
    
    
    
    /**
     Set the name of a room.
     
     - parameters:
        - roomId: the id of the room.
        - name: the name to set.
        - completion: A block object called when the operation completes.
        - response: Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func setName(ofRoom roomId: String, name: String, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __setRoomName(roomId, name: name, success: success(completion), failure: error(completion))
    }
    
    /**
     Get the name of a room.
     
     - parameters:
        - roomId: the id of the room.
        - completion: A block object called when the operation completes.
        - response: Provides the room name on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func name(ofRoom roomId: String, completion: @escaping (_ response: MXResponse<String>) -> Void) -> MXHTTPOperation? {
        return __name(ofRoom: roomId, success: success(completion), failure: error(completion))
    }
    
    
    
    
    /**
     Set the history visibility of a room.
     
     - parameters:
        - roomId: the id of the room
        - historyVisibility: the visibily to set.
        - completion: A block object called when the operation completes.
        - response: Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func setHistoryVisibility(ofRoom roomId: String, historyVisibility: MXRoomHistoryVisibility, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __setRoomHistoryVisibility(roomId, historyVisibility: historyVisibility.identifier, success: success(completion), failure: error(completion))
    }
    
    /**
     Get the history visibility of a room.
     
     - parameters:
        - roomId: the id of the room.
        - completion: A block object called when the operation completes.
        - response: Provides the room history visibility on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func historyVisibility(ofRoom roomId: String, completion: @escaping (_ response: MXResponse<MXRoomHistoryVisibility>) -> Void) -> MXHTTPOperation? {
        return __historyVisibility(ofRoom: roomId, success: success(transform: MXRoomHistoryVisibility.init, completion), failure: error(completion))
    }
    
    
    
    
    
    
    
    /**
     Set the join rule of a room.
     
     - parameters:
        - roomId: the id of the room.
        - joinRule: the rule to set.
        - completion: A block object called when the operation completes.
        - response: Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func setJoinRule(ofRoom roomId: String, joinRule: MXRoomJoinRule, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __setRoomJoinRule(roomId, joinRule: joinRule.identifier, success: success(completion), failure: error(completion))
    }
    
    /**
     Get the join rule of a room.
     
     - parameters:
        - roomId: the id of the room.
        - completion: A block object called when the operation completes.
        - response: Provides the room join rule on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func joinRule(ofRoom roomId: String, completion: @escaping (_ response: MXResponse<MXRoomJoinRule>) -> Void) -> MXHTTPOperation? {
        return __joinRule(ofRoom: roomId, success: success(transform: MXRoomJoinRule.init, completion), failure: error(completion))
    }
    
    
    
    
    /**
     Set the guest access of a room.
     
     - parameters:
        - roomId: the id of the room.
        - guestAccess: the guest access to set.
        - completion: A block object called when the operation completes.
        - response: Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func setGuestAccess(forRoom roomId: String, guestAccess: MXRoomGuestAccess, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __setRoomGuestAccess(roomId, guestAccess: guestAccess.identifier, success: success(completion), failure: error(completion))
    }
    
    /**
     Get the guest access of a room.
     
     - parameters:
        - roomId the id of the room.
        - completion: A block object called when the operation completes.
        - response: Provides the room guest access on success.
     
     - return: a MXHTTPOperation instance.
     */
    @nonobjc @discardableResult func guestAccess(forRoom roomId: String, completion: @escaping (_ response: MXResponse<MXRoomGuestAccess>) -> Void) -> MXHTTPOperation? {
        return __guestAccess(ofRoom: roomId, success: success(transform: MXRoomGuestAccess.init, completion), failure: error(completion))
    }
    
    
    
    
    
    
    /**
     Set the directory visibility of a room on the current homeserver.
     
     - parameters:
        - roomId: the id of the room.
        - directoryVisibility: the directory visibility to set.
        - completion: A block object called when the operation completes.
        - response: Indicates whether the operation was successful.
     
     - returns: a MXHTTPOperation instance.
     */
    @nonobjc @discardableResult func setDirectoryVisibility(ofRoom roomId: String, directoryVisibility: MXRoomDirectoryVisibility, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __setRoomDirectoryVisibility(roomId, directoryVisibility: directoryVisibility.identifier, success: success(completion), failure: error(completion))
    }
    
    /**
     Get the visibility of a room in the current HS's room directory.
     
     - parameters:
        - roomId: the id of the room.
        - completion: A block object called when the operation completes.
        - response: Provides the room directory visibility on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func directoryVisibility(ofRoom roomId: String, completion: @escaping (_ response: MXResponse<MXRoomDirectoryVisibility>) -> Void) -> MXHTTPOperation? {
        return __directoryVisibility(ofRoom: roomId, success: success(transform: MXRoomDirectoryVisibility.init, completion), failure: error(completion))
    }
    
    
    
    
    
    /**
     Create a new mapping from room alias to room ID.
     
     - parameters:
        - roomId: the id of the room.
        - roomAlias: the alias to add.
        - completion: A block object called when the operation completes.
        - response: Indicates whether the operation was successful.
     
     - returns a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func addAlias(forRoom roomId: String, alias: String, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __addRoomAlias(roomId, alias: alias, success: success(completion), failure: error(completion))
    }
    
    /**
     Remove a mapping of room alias to room ID.
     
     - parameters:
        - roomAlias: the alias to remove.
        - completion: A block object called when the operation completes.
        - response: Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func removeRoomAlias(_ roomAlias: String, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __removeRoomAlias(roomAlias, success: success(completion), failure: error(completion))
    }
    
    
    
    
    /**
     Set the canonical alias of the room.
     
     - parameters:
        - roomId: the id of the room.
        - canonicalAlias: the canonical alias to set.
        - completion: A block object called when the operation completes.
        - response: Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func setCanonicalAlias(forRoom roomId: String, canonicalAlias: String, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __setRoomCanonicalAlias(roomId, canonicalAlias: canonicalAlias, success: success(completion), failure: error(completion));
    }
    
    /**
     Get the canonical alias.
     
     - parameters:
        - roomId: the id of the room.
        - completion: A block object called when the operation completes.
        - response: Provides the canonical alias on success
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func canonicalAlias(ofRoom roomId: String, completion: @escaping (_ response: MXResponse<String>) -> Void) -> MXHTTPOperation? {
        return __canonicalAlias(ofRoom: roomId, success: success(completion), failure: error(completion))
    }
    
    
    /**
     Join a room, optionally where the user has been invited by a 3PID invitation.
     
     - parameters:
        - roomIdOrAlias: The id or an alias of the room to join.
        - thirdPartySigned: The signed data obtained by the validation of the 3PID invitation, if 3PID validation is used. The validation is made by `self.signUrl()`.
        - completion: A block object called when the operation completes.
        - response: Provides the room id on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func joinRoom(_ roomIdOrAlias: String, withThirdPartySigned dictionary: [String: Any]? = nil, completion: @escaping (_ response: MXResponse<String>) -> Void) -> MXHTTPOperation? {
        if let dictionary = dictionary {
            return __joinRoom(roomIdOrAlias, withThirdPartySigned: dictionary, success: success(completion), failure: error(completion))
        } else {
            return __joinRoom(roomIdOrAlias, success: success(completion), failure: error(completion))
        }
    }

    /**
     Leave a room.
     
     - parameters:
        - roomId: the id of the room to leave.
        - completion: A block object called when the operation completes.
        - response: Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func leaveRoom(_ roomId: String, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __leaveRoom(roomId, success: success(completion), failure: error(completion))
    }
    
    
    
    
    /**
     Invite a user to a room.
     
     A user can be invited one of three ways:
     1. By their user ID
     2. By their email address
     3. By a third party
     
     The `invitation` parameter specifies how this user should be reached.
     
     - parameters:
        - invitation: the way to reach the user.
        - roomId: the id of the room.
        - completion: A block object called when the operation completes.
        - response: Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func invite(_ invitation: MXRoomInvitee, toRoom roomId: String, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        switch invitation {
        case .userId(let userId):
            return __inviteUser(userId, toRoom: roomId, success: success(completion), failure: error(completion))
        case .email(let emailAddress):
            return __inviteUser(byEmail: emailAddress, toRoom: roomId, success: success(completion), failure: error(completion))
        case .thirdPartyId(medium: let medium, address: let address):
            return __invite(byThreePid: medium, address: address, toRoom: roomId, success: success(completion), failure: error(completion))
        }
    }
    
    
    
    
    
    /**
     Kick a user from a room.
     
     - parameters:
        - userId: the user id.
        - roomId: the id of the room.
        - reason: the reason for being kicked
        - completion: A block object called when the operation completes.
        - response: Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func kickUser(_ userId: String, fromRoom roomId: String, reason: String, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __kickUser(userId, fromRoom: roomId, reason: reason, success: success(completion), failure: error(completion))
    }
    
    
    /**
     Ban a user in a room.
     
     - parameters:
         - userId: the user id.
         - roomId: the id of the room.
         - reason: the reason for being banned
         - completion: A block object called when the operation completes.
         - response: Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func banUser(_ userId: String, fromRoom roomId: String, reason: String, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __banUser(userId, inRoom: roomId, reason: reason, success: success(completion), failure: error(completion))
    }
    
    /**
     Unban a user in a room.
     
     - parameters:
         - userId: the user id.
         - roomId: the id of the room.
         - completion: A block object called when the operation completes.
         - response: Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func unbanUser(_ userId: String, fromRoom roomId: String, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __unbanUser(userId, inRoom: roomId, success: success(completion), failure: error(completion))
    }
    
    
    
    
    
    
    
    /**
     Create a room.
     
     - parameters:
        - name: The room name.
        - visibility: The visibility of the room in the current HS's room directory.
        - roomAlias: The room alias on the home server the room will be created.
        - topic: The room topic.
        - invite: A list of user IDs to invite to the room. This will tell the server to invite everyone in the list to the newly created room.
        - invite3PID: A list of objects representing third party IDs to invite into the room.
        - isDirect: This flag makes the server set the is_direct flag on the m.room.member events sent to the users in invite and invite_3pid.
        - preset: Convenience parameter for setting various default state events based on a preset.
     
        - completion: A block object called when the operation completes.
        - response: Provides a MXCreateRoomResponse object on success.
     
     - returns: a MXHTTPOperation instance.
     */
    @nonobjc @discardableResult func createRoom(name: String?,
                                                visibility: MXRoomDirectoryVisibility?,
                                                alias: String?,
                                                topic: String?,
                                                invite: [String]? = nil,
                                                invite3PID: [MXInvite3PID]? = nil,
                                                isDirect: Bool = false,
                                                preset: MXRoomPreset?,
                                                completion: @escaping (_ response: MXResponse<MXCreateRoomResponse>) -> Void) -> MXHTTPOperation? {
        
        return __createRoom(name, visibility: nil, roomAlias: alias, topic: topic,
                            invite: invite, invite3PID: invite3PID,
                            isDirect: isDirect, preset: preset?.identifier,
                            success: success(completion), failure: error(completion));
    }
    
    /**
     Create a room.
     
     - parameters:
        - parameters: The parameters. Refer to the matrix specification for details.
        - completion: A block object called when the operation completes.
        - response: Provides a MXCreateRoomResponse object on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func createRoom(parameters: [String: Any], completion: @escaping (_ response: MXResponse<MXCreateRoomResponse>) -> Void) -> MXHTTPOperation? {
        return __createRoom(parameters, success: success(completion), failure: error(completion))
    }
    
    
    
    
    /**
     Get a list of messages for this room.
     
     - parameters:
        - roomId: the id of the room.
        - from: the token to start getting results from.
        - direction: `MXTimelineDirectionForwards` or `MXTimelineDirectionBackwards`
        - limit: (optional, use -1 to not defined this value) the maximum nuber of messages to return.
        - filter: to filter returned events with.
        - completion: A block object called when the operation completes.
        - response: Provides a `MXPaginationResponse` object on success.
     
     - returns: a MXHTTPOperation instance.
     */
    @nonobjc @discardableResult func messages(forRoom roomId: String, from: String, direction: MXTimelineDirection, limit: UInt?, filter: MXRoomEventFilter, completion: @escaping (_ response: MXResponse<MXPaginationResponse>) -> Void) -> MXHTTPOperation? {
        
        // The `limit` variable should be set to -1 if it's not provided.
        let _limit: Int
        if let limit = limit {
            _limit = Int(limit)
        } else {
            _limit = -1;
        }
        return __messages(forRoom: roomId, from: from, direction: direction, limit: UInt(_limit), filter: filter, success: success(completion), failure: error(completion))
    }
    
    /**
     Get a list of members for this room.
     
     - parameters:
        - roomId: the id of the room.
        - completion: A block object called when the operation completes.
        - response: Provides an array of `MXEvent` objects that are the type `m.room.member` on success.
     
     - returns: a MXHTTPOperation instance.
     */
    @nonobjc @discardableResult func members(ofRoom roomId: String, completion: @escaping (_ response: MXResponse<[MXEvent]>) -> Void) -> MXHTTPOperation? {
        return __members(ofRoom: roomId, success: success(completion), failure: error(completion))
    }
    
    /**
     Get a list of all the current state events for this room.
     
     This is equivalent to the events returned under the 'state' key for this room in initialSyncOfRoom.
     
     See [the matrix documentation on state events](http://matrix.org/docs/api/client-server/#!/-rooms/get_state_events)
     for more detail.
     
     - parameters:
        - roomId: the id of the room.
        - completion: A block object called when the operation completes.
        - response: Provides the raw home server JSON response on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func state(ofRoom roomId: String, completion: @escaping (_ response: MXResponse<[String: Any]>) -> Void) -> MXHTTPOperation? {
        return __state(ofRoom: roomId, success: success(completion), failure: error(completion))
    }
    
    
    
    
    
    
    /**
     Inform the home server that the user is typing (or not) in this room.
     
     - parameters:
        - roomId: the id of the room.
        - typing: Use `true` if the user is currently typing.
        - timeout: the length of time until the user should be treated as no longer typing. Can be set to `nil` if they are no longer typing.
        - completion: A block object called when the operation completes.
        - response: Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func sendTypingNotification(inRoom roomId: String, typing: Bool, timeout: TimeInterval?, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        
        // The `timeout` variable should be set to -1 if it's not provided.
        let _timeout: Int
        if let timeout = timeout {
            // The `TimeInterval` type is a double value specified in seconds. Multiply by 1000 to get milliseconds.
            _timeout = Int(timeout * 1000 /* milliseconds */)
        } else {
            _timeout = -1;
        }
        
        return __sendTypingNotification(inRoom: roomId, typing: typing, timeout: UInt(_timeout), success: success(completion), failure: error(completion))
    }
    
    
    
    
    
    
    
    
    /**
     Redact an event in a room.
     
     - parameters:
        - eventId: the id of the redacted event.
        - roomId: the id of the room.
        - reason: the redaction reason.
        - completion: A block object called when the operation completes.
        - response: Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func redactEvent(_ eventId: String, inRoom roomId: String, reason: String?, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __redactEvent(eventId, inRoom: roomId, reason: reason, success: success(completion), failure: error(completion))
    }
    
    /**
     Report an event.
     
     - parameters:
        - eventId: the id of the event event.
        - roomId: the id of the room.
        - score: the metric to let the user rate the severity of the abuse. It ranges from -100 “most offensive” to 0 “inoffensive”.
        - reason: the redaction reason.
        - completion: A block object called when the operation completes.
        - response: Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func reportEvent(_ eventId: String, inRoom roomId: String, score: Int, reason: String?, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __reportEvent(eventId, inRoom: roomId, score: score, reason: reason, success: success(completion), failure: error(completion))
    }
    
    
    
    
    /**
     Get all the current information for this room, including messages and state events.
     
     See [the matrix documentation](http://matrix.org/docs/api/client-server/#!/-rooms/get_room_sync_data)
     for more detail.
     
     - parameters:
        - roomId: the id of the room.
        - limit: the maximum number of messages to return.
        - completion: A block object called when the operation completes.
        - response: Provides the model created from the homeserver JSON response on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func intialSync(ofRoom roomId: String, limit: UInt, completion: @escaping (_ response: MXResponse<MXRoomInitialSync>) -> Void) -> MXHTTPOperation? {
        return __initialSync(ofRoom: roomId, withLimit: Int(limit), success: success(completion), failure: error(completion))
    }
    
    
    /**
     Get the context surrounding an event.
     
     This API returns a number of events that happened just before and after the specified event.
     
     - parameters:
        - eventId: the id of the event to get context around.
        - roomId: the id of the room to get events from.
        - limit: the maximum number of messages to return.
        - completion: A block object called when the operation completes.
        - response: Provides the model created from the homeserver JSON response on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func context(ofEvent eventId: String, inRoom roomId: String, limit: UInt, completion: @escaping (_ response: MXResponse<MXEventContext>) -> Void) -> MXHTTPOperation? {
        return __context(ofEvent: eventId, inRoom: roomId, limit: limit, success: success(completion), failure: error(completion))
    }
    
    
    // MARK: - Room tags operations
    
    /**
     List the tags of a room.
     
     
     - parameters:
        - roomId: the id of the room.
        - completion: A block object called when the operation completes.
        - response: Provides an array of `MXRoomTag` objects on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func tags(ofRoom roomId: String, completion: @escaping (_ response: MXResponse<[MXRoomTag]>) -> Void) -> MXHTTPOperation? {
        return __tags(ofRoom: roomId, success: success(completion), failure: error(completion))
    }
    
    /**
     Add a tag to a room.
     
     Use this method to update the order of an existing tag.
     
     - parameters:
        - tag: the new tag to add to the room.
        - order: the order. @see MXRoomTag.order.
        - roomId: the id of the room.
        - completion: A block object called when the operation completes.
        - response: Provides an array of `MXRoomTag` objects on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func addTag(_ tag: String, withOrder order: String, toRoom roomId: String, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __addTag(tag, withOrder: order, toRoom: roomId, success: success(completion), failure: error(completion))
    }
    
    
    /**
     Remove a tag from a room.
     
     - parameters:
        - tag: the tag to remove.
        - roomId: the id of the room.
        - completion: A block object called when the operation completes.
        - response: Provides an array of `MXRoomTag` objects on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func removeTag(_ tag: String, fromRoom roomId: String, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __removeTag(tag, fromRoom: roomId, success: success(completion), failure: error(completion))
    }
    
    
    
    
    
    // MARK: - Profile operations
    
    /**
     Set the logged-in user display name.
     
     - parameters:
        - displayname: the new display name.
        - completion: A block object called when the operation completes.
        - response: Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func setDisplayName(_ displayName: String, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __setDisplayName(displayName, success: success(completion), failure: error(completion))
    }
    
    /**
     Get the display name of a user.
     
     - parameters:
        - userId: the user id to look up.
        - completion: A block object called when the operation completes.
        - response: Provides the display name on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func displayName(forUser userId: String, completion: @escaping (_ response: MXResponse<String>) -> Void) -> MXHTTPOperation? {
        return __displayName(forUser: userId, success: success(completion), failure: error(completion))
    }
    
    
    
    
    /**
     Set the logged-in user avatar url.
     
     - parameters:
        - urlString: The new avatar url.
        - completion: A block object called when the operation completes.
        - response: Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func setAvatarUrl(_ url: URL, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __setAvatarUrl(url.absoluteString, success: success(completion), failure: error(completion))
    }
    
    /**
     Get the avatar url of a user.
     
     - parameters:
        - userId: the user id to look up.
        - completion: A block object called when the operation completes.
        - response: Provides the avatar url on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func avatarUrl(forUser userId: String, completion: @escaping (_ response: MXResponse<URL>) -> Void) -> MXHTTPOperation? {
        return __avatarUrl(forUser: userId, success: success(transform: { return URL(string: $0 ?? "") }, completion), failure: error(completion))
    }
    
    
    /**
     Link an authenticated 3rd party id to the Matrix user.
     
     - parameters:
        - sid: the id provided during the 3PID validation session (MXRestClient.requestEmailValidation).
        - clientSecret: the same secret key used in the validation session.
        - bind: whether the homeserver should also bind this third party identifier to the account's Matrix ID with the identity server.
        - completion: A block object called when the operation completes.
        - response:  Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func addThirdPartyIdentifier(_ sid: String, clientSecret: String, bind: Bool, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __add3PID(sid, clientSecret: clientSecret, bind: bind, success: success(completion), failure: error(completion))
    }
    
    /**
     List all 3PIDs linked to the Matrix user account.
     
     - parameters:
        - completion: A block object called when the operation completes.
        - response: Provides the third-party identifiers on success
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func thirdPartyIdentifiers(_ completion: @escaping (_ response: MXResponse<[MXThirdPartyIdentifier]>) -> Void) -> MXHTTPOperation? {
        return __threePIDs(success(completion), failure: error(completion))
    }
    
    
    // MARK: - Presence operations
    
    
    // TODO: MXPresence could be refined to a Swift enum. presence+message could be combined in a struct, since they're closely related.
    /**
     Set the current user presence status.
    
     - parameters:
        - presence: the new presence status.
        - statusMessage: the new message status.
        - completion: A block object called when the operation completes.
        - response: Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func setPresence(_ presence: MXPresence, statusMessage: String, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __setPresence(presence, andStatusMessage: statusMessage, success: success(completion), failure: error(completion))
    }
    
    // TODO: MXPresenceResponse smells like a tuple (_ presence: MXPresence, timeActiveAgo: NSTimeInterval). Consider refining further.
    /**
     Get the presence status of a user.
     
     - parameters:
        - userId: the user id to look up.
        - completion: A block object called when the operation completes.
        - response: Provides the `MXPresenceResponse` on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func presence(forUser userId: String, completion: @escaping (_ response: MXResponse<MXPresenceResponse>) -> Void) -> MXHTTPOperation? {
        return __presence(userId, success: success(completion), failure: error(completion))
    }
    
    
    
    // MARK: - Sync
    
    
    /*
     TODO: This API could be further refined.
     
     `token` is an optional string, with nil meaning "initial sync".
     This could be expressed better as an enum: .initial or .fromToken(String)
     
     `presence` appears to support only two possible values: nil or "offline".
     This could be expressed better as an enum: .online, or .offline
     (are there any other valid values for this field? why would it be typed as a string?)
    */
    
    /**
     Synchronise the client's state and receive new messages.
     
     Synchronise the client's state with the latest state on the server.
     Client's use this API when they first log in to get an initial snapshot
     of the state on the server, and then continue to call this API to get
     incremental deltas to the state, and to receive new messages.
     
     - parameters:
        - token: the token to stream from (nil in case of initial sync).
        - serverTimeout: the maximum time in ms to wait for an event.
        - clientTimeout: the maximum time in ms the SDK must wait for the server response.
        - presence:  the optional parameter which controls whether the client is automatically marked as online by polling this API. If this parameter is omitted then the client is automatically marked as online when it uses this API. Otherwise if the parameter is set to "offline" then the client is not marked as being online when it uses this API.
        - filterId: the ID of a filter created using the filter API (optinal).
        - completion: A block object called when the operation completes.
        - response: Provides the `MXSyncResponse` on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func sync(fromToken token: String?, serverTimeout: UInt, clientTimeout: UInt, setPresence presence: String?, filterId: String? = nil, completion: @escaping (_ response: MXResponse<MXSyncResponse>) -> Void) -> MXHTTPOperation? {
        return __sync(fromToken: token, serverTimeout: serverTimeout, clientTimeout: clientTimeout, setPresence: presence, filter: filterId, success: success(completion), failure: error(completion))
    }
    

    // MARK: - Directory operations
    
    /**
     Get the list of public rooms hosted by the home server.
     
     - parameter completion: A block object called when the operation is complete.
     - parameter response: Provides an array of the public rooms on this server on `success`
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func publicRooms(completion: @escaping (_ response: MXResponse<[MXPublicRoom]>) -> Void) -> MXHTTPOperation? {
        return __publicRooms(success(completion), failure: error(completion))
    }
    
    /**
     Get the room ID corresponding to this room alias
     
     - parameters:
        - roomAlias: the alias of the room to look for.
        - completion: A block object called when the operation completes.
        - response: Provides the the ID of the room on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func roomId(forRoomAlias roomAlias: String, completion: @escaping (_ response: MXResponse<String>) -> Void) -> MXHTTPOperation? {
        return __roomID(forRoomAlias: roomAlias, success: success(completion), failure: error(completion))
    }
    
    // Mark: - Media Repository API
    
    /**
     Upload content to HomeServer
     
     - parameters:
        - data: the content to upload.
        - filename: optional filename
        - mimetype: the content type (image/jpeg, audio/aac...)
        - timeout: the maximum time the SDK must wait for the server response.
        - uploadProgress: A block object called multiple times as the upload progresses. It's also called once the upload is complete
        - progress: Provides the progress of the upload until it completes. This will provide the URL of the resource on successful completion, or an error message on unsuccessful completion.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func uploadContent(_ data: Data, filename: String? = nil, mimeType: String, timeout: TimeInterval, uploadProgress: @escaping (_ progress: MXProgress<URL>) -> Void) -> MXHTTPOperation? {
        return __uploadContent(data, filename: filename, mimeType: mimeType, timeout: timeout, success: { (urlString) in
            if let urlString = urlString, let url = URL(string: urlString) {
                uploadProgress(.success(url))
            } else {
                uploadProgress(.failure(_MXUnknownError()))
            }
        }, failure: { (error) in
            uploadProgress(.failure(error ?? _MXUnknownError()))
        }, uploadProgress: { (progress) in
            uploadProgress(.progress(progress!))
        })
    }
    
    
    // MARK: - Identity server API
    
    /**
     Retrieve a user matrix id from a 3rd party id.
     
     - parameters:
        - address: the id of the user in the 3rd party system.
        - medium: the 3rd party system.
        - completion: A block object called when the operation completes.
        - response: Provides the Matrix user id (or `nil` if the user is not found) on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func lookup3PID(_ address: String, for medium: MX3PIDMedium, completion: @escaping (_ response: MXResponse<String?>) -> Void) -> MXHTTPOperation? {
        return __lookup3pid(address, forMedium: medium.identifier, success: success(completion), failure: error(completion))
    }
    
    /**
     Retrieve user matrix ids from a list of 3rd party ids.
     
     - parameters:
        - threepids: the list of 3rd party ids: [[<(MX3PIDMedium)media1>, <(NSString*)address1>], [<(MX3PIDMedium)media2>, <(NSString*)address2>], ...].
        - completion: A block object called when the operation completes.
        - response: Provides the array of the discovered users returned by the identity server. [[<(MX3PIDMedium)media>, <(NSString*)address>, <(NSString*)userId>], ...].
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func lookup3PIDs(_ ids: [Any], completion: @escaping (_ response: MXResponse<[Any]>) -> Void) -> MXHTTPOperation? {
        return __lookup3pids(ids, success: success(completion), failure: error(completion))
    }
    
    
    
    /**
     Request the validation of an email address.
     
     The identity server will send an email to this address. The end user
     will have to click on the link it contains to validate the address.
     
     Use the returned sid to complete operations that require authenticated email
     like `MXRestClient.add3PID(_:)`.
     
     - parameters:
        - email: the email address to validate.
        - clientSecret: a secret key generated by the client. (`MXTools.generateSecret()` creates such key)
        - sendAttempt: the number of the attempt for the validation request. Increment this value to make the identity server resend the email. Keep it to retry the request in case the previous request failed.
        - nextLink: the link the validation page will automatically open. Can be nil
        - completion: A block object called when the operation completes.
        - response: Provides provides the id of the email validation session on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func requestEmailValidation(_ email: String, clientSecret: String, sendAttempt: UInt, nextLink: String?, completion: @escaping (_ response: MXResponse<String>) -> Void) -> MXHTTPOperation? {
        return __requestEmailValidation(email, clientSecret: clientSecret, sendAttempt: sendAttempt, nextLink: nextLink, success: success(completion), failure: error(completion))
    }
    
    
    
    /**
     Submit a token received by an email after the call of [self requestEmailValidation].
     
     In case of success, the email has been validated.
     
     - parameters:
        - token: the token received in the email.
        - clientSecret: the clientSecret in the email.
        - sid: the email validation session id in the email.
        - completion: A block object called when the operation completes.
        - response: Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func submitEmailValidationToken(_ token: String, clientSecret: String, sid: String, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __submitEmailValidationToken(token, clientSecret: clientSecret, sid: sid, success: success(completion), failure: error(completion))
    }
    
    
    /**
     Sign a 3PID URL.
     
     - parameters:
        - signUrl: the URL that will be called for signing.
        - completion: A block object called when the operation completes.
        - response: Provides the signed data on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func signUrl(_ signUrl: String, completion: @escaping (_ response: MXResponse<[String: Any]>) -> Void) -> MXHTTPOperation? {
        return __signUrl(signUrl, success: success(completion), failure: error(completion))
    }
    
    
    
    // MARK: - VoIP API
    
    /**
     Get the TURN server configuration advised by the homeserver.
     
     
     - parameters:
        - completion: A block object called when the operation completes.
        - response: Provides a `MXTurnServerResponse` object (or nil if the HS has TURN config) on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func turnServer(_ completion: @escaping (_ response: MXResponse<MXTurnServerResponse?>) -> Void) -> MXHTTPOperation? {
        return __turnServer(success(completion), failure: error(completion))
    }
    
    
    // MARK: - read receipts
    
    /**
     Send a read receipt.
     
     - parameters:
        - roomId: the id of the room.
        - eventId: the id of the event.
        - completion: A block object called when the operation completes.
        - response: Provides the event id of the event generated on the home server on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func sendReadReceipts(toRoom roomId: String, forEvent eventId: String, completion: @escaping (_ response: MXResponse<String>) -> Void) -> MXHTTPOperation? {
        return __sendReadReceipts(roomId, eventId: eventId, success: success(completion), failure: error(completion))
    }
    
    
    // MARK: - Search
    
    /**
     Search a text in room messages.
     
     - parameters:
        - textPattern: the text to search for in message body.
        - roomEventFilter: a nullable dictionary which defines the room event filtering during the search request.
        - beforeLimit: the number of events to get before the matching results.
        - afterLimit: the number of events to get after the matching results.
        - nextBatch: the token to pass for doing pagination from a previous response.
        - completion: A block object called when the operation completes.
        - response: Provides the search results on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func searchMessages(withPattern textPattern: String, roomEventFilter: MXRoomEventFilter? = nil, beforeLimit: UInt = 0, afterLimit: UInt = 0, nextBatch: String, completion: @escaping (_ response: MXResponse<MXSearchRoomEventResults>) -> Void) -> MXHTTPOperation? {
        return __searchMessages(withText: textPattern, roomEventFilter: roomEventFilter, beforeLimit: beforeLimit, afterLimit: afterLimit, nextBatch: nextBatch, success: success(completion), failure: error(completion))
    }
    
    /**
     Make a search.
     
     - parameters:
        - parameters: the search parameters as defined by the Matrix search spec (http://matrix.org/docs/api/client-server/#!/Search/post_search ).
        - nextBatch: the token to pass for doing pagination from a previous response.
        - completion: A block object called when the operation completes.
        - response: Provides the search results on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func search(withParameters parameters: [String: Any], nextBatch: String, completion: @escaping (_ response: MXResponse<MXSearchRoomEventResults>) -> Void) -> MXHTTPOperation? {
        return __search(parameters, nextBatch: nextBatch, success: success(completion), failure: error(completion))
    }
    
    
    
    // MARK: - Crypto
    
    /**
     Upload device and/or one-time keys.
     
     - parameters:
        - deviceKeys: the device keys to send.
        - oneTimeKeys: the one-time keys to send.
        - deviceId: the explicit device_id to use for upload (pass `nil` to use the same as that used during auth).
        - completion: A block object called when the operation completes.
        - response: Provides information about the keys on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func uploadKeys(_ deviceKeys: [String: Any], oneTimeKeys: [String: Any], forDevice deviceId: String? = nil, completion: @escaping (_ response: MXResponse<MXKeysUploadResponse>) -> Void) -> MXHTTPOperation? {
        return __uploadKeys(deviceKeys, oneTimeKeys: oneTimeKeys, forDevice: deviceId, success: success(completion), failure: error(completion))
    }
    
    /**
     Download device keys.
     
     - parameters:
        - userIds: list of users to get keys for.
        - completion: A block object called when the operation completes.
        - response: Provides information about the keys on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func downloadKeys(forUsers userIds: [String], completion: @escaping (_ response: MXResponse<MXKeysQueryResponse>) -> Void) -> MXHTTPOperation? {
        return __downloadKeys(forUsers: userIds, success: success(completion), failure: error(completion))
    }
    
    
    /**
     Claim one-time keys.
     
     - parameters:
        - usersDevices: a list of users, devices and key types to retrieve keys for.
        - completion: A block object called when the operation completes.
        - response: Provides information about the keys on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func claimOneTimeKeys(for usersDevices: MXUsersDevicesMap<NSString>, completion: @escaping (_ response: MXResponse<MXKeysClaimResponse>) -> Void) -> MXHTTPOperation? {
        return __claimOneTimeKeys(forUsersDevices: usersDevices, success: success(completion), failure: error(completion))
    }
    
    
    
    // MARK: - Direct-to-device messaging
    
    /**
     Send an event to a specific list of devices
     
     - paramaeters:
        - eventType: the type of event to send
        - contentMap: content to send. Map from user_id to device_id to content dictionary.
        - completion: A block object called when the operation completes.
        - response: Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func sendDirectToDevice(eventType: String, contentMap: MXUsersDevicesMap<NSDictionary>, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __send(toDevice: eventType, contentMap: contentMap, success: success(completion), failure: error(completion))
    }
    
    
    // MARK: - Device Management
    
    /**
     Get information about all devices for the current user.
     
     - parameters:
        - completion: A block object called when the operation completes.
        - response: Provides a list of devices on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func devices(completion: @escaping (_ response: MXResponse<[MXDevice]>) -> Void) -> MXHTTPOperation? {
        return __devices(success(completion), failure: error(completion))
    }
    
    /**
     Get information on a single device, by device id.
     
     - parameters:
        - deviceId: The device identifier.
        - completion: A block object called when the operation completes.
        - response: Provides the requested device on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func device(withId deviceId: String, completion: @escaping (_ response: MXResponse<MXDevice>) -> Void) -> MXHTTPOperation? {
        return __device(byDeviceId: deviceId, success: success(completion), failure: error(completion))
    }
    

    /**
     Update the display name of a given device.
     
     - parameters:
        - deviceName: The new device name. If not given, the display name is unchanged.
        - deviceId: The device identifier.
        - completion: A block object called when the operation completes.
        - response: Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func setDeviceName(_ deviceName: String, forDevice deviceId: String, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __setDeviceName(deviceName, forDeviceId: deviceId, success: success(completion), failure: error(completion))
    }
    
    /**
     Get an authentication session to delete a device.
     
     - parameters:
        - deviceId: The device identifier.
        - completion: A block object called when the operation completes.
        - response: Provides the server response.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func getSession(toDeleteDevice deviceId: String, completion: @escaping (_ response: MXResponse<MXAuthenticationSession>) -> Void) -> MXHTTPOperation? {
        return __getSessionToDeleteDevice(byDeviceId: deviceId, success: success(completion), failure: error(completion))
    }
    
    /**
     Delete the given device, and invalidates any access token associated with it.
     
     This API endpoint uses the User-Interactive Authentication API.
     
     - parameters:
        - deviceId: The device identifier.
        - authParameters: The additional authentication information for the user-interactive authentication API.
        - completion: A block object called when the operation completes.
        - response: Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func deleteDevice(_ deviceId: String, authParameters: [String: Any], completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation? {
        return __deleteDevice(byDeviceId: deviceId, authParams: authParameters, success: success(completion), failure: error(completion))
    }
    
}
