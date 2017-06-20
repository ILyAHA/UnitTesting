//
//  Facebook.swift
//  FacebookTests
//
//  Created by Admin on 03.05.17.
//  Copyright © 2017 grapes-studio. All rights reserved.
//

import Foundation
import UIKit
import FacebookLogin
import FacebookCore

/**
 Wrapper over facebook access token (AccessToken)
 authentication token of the current user
 */
public class AccessTokenWrapper {
    
    /**
     authentication token of the current user
     */
    public var authenticationToken: String = ""
    
    
    /// INitialize an instance of AccessTokenWrapper
    ///
    /// - Parameter token: token string
    public init(authenticationToken token: String) {
        self.authenticationToken = token
    }
}

/**
 Wrapper over facebook Permission
 */
public class PermissionWrapper: Hashable {
    public let name: String
    
    /**
     Create a permission with a string value.
     
     - parameter name: Name of the permission.
     */
    public init(name: String) {
        self.name = name
    }
    
    /// The hash value.
    public var hashValue: Int {
        return name.hashValue
    }
    
    /**
     Compare two `Permission`s for equality.
     
     - parameter lhs: The first permission to compare.
     - parameter rhs: The second permission to compare.
     
     - returns: Whether or not the permissions are equal.
     */
    public static func == (lhs: PermissionWrapper, rhs: PermissionWrapper) -> Bool {
        return lhs.name == rhs.name
    }
}

/**
 Wrapper over facebook LoginResult
 */
public enum LoginResultWrapper {
    /// User succesfully logged in. Contains granted, declined permissions and access token.
    case success(grantedPermissions: Set<PermissionWrapper>, declinedPermissions: Set<PermissionWrapper>, token: AccessTokenWrapper)
    /// Login attempt was cancelled by the user.
    case cancelled
    /// Login attempt failed.
    case failed(Error)
    
    
    /// Initialize an instance of LOGINResultWrapper
    ///
    /// - Parameter loginResult: Facebook LoginResult instance
    public init(loginResult: LoginResult) {
        
        switch loginResult {
        case .cancelled:
            self = .cancelled
            break
        case .failed(let error):
            self = .failed(error)
            break
        case .success(let grantedPermissions, let declinedPermissions, let token):
            let gp = Set(grantedPermissions.flatMap({ $0 as? String }).map({ PermissionWrapper(name: $0) }))
            let dp = Set(declinedPermissions.flatMap({ $0 as? String }).map({ PermissionWrapper(name: $0) }))
            self = .success(grantedPermissions: gp, declinedPermissions: dp, token: AccessTokenWrapper(authenticationToken: token.authenticationToken))
            break
        }
    }
    
    /**
     Compare two `LoginResultWrapper`s for equality.
     
     - parameter lhs: The first LoginResultWrapper to compare.
     - parameter rhs: The second LoginResultWrapper to compare.
     
     - returns: Whether or not the LoginResultWrapper are equal.
     */
    public static func ==(lhs: LoginResultWrapper, rhs: LoginResultWrapper) -> Bool {
        switch (lhs, rhs) {
        case (.cancelled, .cancelled):
            return true
        case (.failed, .failed):
            return true
        case (.success, .success):
            return true
        default: return false
        }
    }
    
}

/**
 Wrap Facebook API for Tests
 */
public class LoginManagerWrapper {
    
    // LoginManager instance
    private var loginManager: LoginManager = LoginManager();
    
    /**
     Wrap over facebook logIn method.
     Logs the user in or authorizes additional permissions.

     - parameter permissions: Array of read permissions. Default: `[.PublicProfile]`
     - parameter viewController: Optional view controller to present from. Default: topmost view controller.
     - parameter completion: Optional callback.
    */
    public func logIn(_ permissions: [ReadPermission] = [.publicProfile],
                      viewController: UIViewController? = nil,
                      completion: ((LoginResultWrapper) -> Void)? = nil) {
        self.loginManager.logIn([.publicProfile, .email], viewController: viewController) {( loginResult: LoginResult) in
            guard let completion = completion else {
                return
            }
            completion(LoginResultWrapper(loginResult: loginResult))
        }
    }
}

/**
 Provides methods for getting facebook access token and user data.
 */
public class Facebook{

    //LoginManager wrapper for facebook. This variable is public only for testing, because we should mock it for access to facebook api
    public var loginManager : LoginManagerWrapper = LoginManagerWrapper()
    
    /**
     Get facebook access token by opening a login window.
     
     - parameter callback:      Returns AccessToken as String or an Error.
     */
    public func getAuthToken(callback: @escaping (String?, Error?) -> Void) {
        // TODO(кандидат): определить метод. Функция, которая делает логин:
        // LoginManager().logIn([.publicProfile, .email], viewController: someViewController, someCallback)
        loginManager.logIn([.publicProfile, .email], viewController: nil) { (result) in
            //process result
            switch result {
            case .cancelled:
                //можно выделить в отдельную поименованную ошибку
                let err = NSError(domain: "com.facebooktests.error", code: 1, userInfo: nil)
                callback(nil, err)
                break;
            case .failed(let error):
                callback(nil, error)
                break;
            case .success(let _, let _, let token):
                callback(token.authenticationToken, nil)
                break;
            }
        }
    }
}
