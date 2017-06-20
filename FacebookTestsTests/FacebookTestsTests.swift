//1
//  FacebookTestsTests.swift
//  FacebookTestsTests
//
//  Created by Admin on 03.05.17.
//  Copyright © 2017 grapes-studio. All rights reserved.
//

import XCTest
import Cuckoo
import FacebookCore
import FacebookLogin
@testable import FacebookTests

class FacebookTestsTests: XCTestCase {
    
    var mainController: ViewController!
    
    override func setUp() {
        super.setUp()
        mainController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! ViewController!
        mainController.lbStatus = UILabel()
    }
    
    override func tearDown() {
        mainController = nil
        super.tearDown()
    }
    
    
    /// Testing LoginResult, which is returned when facebook window is closed
    func test1LoginResult() {
        
        // Test class AccessTokenWrapper
        let tokenStr = "token"
        let accessToken = AccessTokenWrapper(authenticationToken: tokenStr)
        XCTAssertEqual(accessToken.authenticationToken, tokenStr)
        
        // Test enum LoginResultWrapper
        let grantedPermissions : Set<PermissionWrapper> = [PermissionWrapper.init(name: "public"), PermissionWrapper.init(name: "email")]
        let declinedPermissions: Set<PermissionWrapper> = []
        var loginResult = LoginResultWrapper.success(grantedPermissions: grantedPermissions, declinedPermissions: declinedPermissions, token: accessToken)
        
        //test loginresult cancelled
        XCTAssert((loginResult == .cancelled) == false)
        //test loginresultwith error
        let error = NSError(domain: "com.facebooktests.error", code: 1, userInfo: nil)
        XCTAssert((loginResult == .failed(error)) == false)
        //test loginresult success
        XCTAssert(loginResult == .success(grantedPermissions: [], declinedPermissions: [], token: accessToken))
        
        //test loginresult success content
        if case .success(let gp,let dp,let t) = loginResult {
            XCTAssertEqual(gp, grantedPermissions)
            XCTAssertEqual(dp, declinedPermissions)
            XCTAssertEqual(t.authenticationToken, accessToken.authenticationToken)
        } else {
            XCTFail("AccessTokenWrapper compare error")
        }
        
        //Test LoginResultWrapper init
        let fbAccessToken = AccessToken(authenticationToken: tokenStr)
        let fbLoginResult = LoginResult.success(grantedPermissions: [], declinedPermissions: [], token: fbAccessToken)
        loginResult = LoginResultWrapper(loginResult: fbLoginResult)
        
        XCTAssert(loginResult == .success(grantedPermissions: [], declinedPermissions: [], token: accessToken))
        
        //test token from loginresult
        if case .success(_,_,let t) = loginResult {
            XCTAssertEqual(t.authenticationToken, fbAccessToken.authenticationToken)
        } else {
            XCTFail("AccessTokenWrapper compare error")
        }
    }
    
    
    /// Test wrapper over Facebook API
    func test2FacebookAPIWrapper() {
        
        // make LoginResult for mock logIn
        let tokenStr = "token"

        let fbAccessToken = AccessToken(authenticationToken: tokenStr)
        let fbLoginResult = LoginResult.success(grantedPermissions: [], declinedPermissions: [], token: fbAccessToken)
        var loginResult = LoginResultWrapper(loginResult: fbLoginResult)
        
        //mock logIn in LoginManagerWrapper
        let mockLoginManager = MockLoginManagerWrapper()
        
        stub(mockLoginManager) { (mockLoginManager) in
            when(mockLoginManager.logIn(any(), viewController: any(), completion: anyClosure())).then({ permissions, viewController, callBack in
                guard let completion = callBack else {
                    print("callback is null")
                    return
                }
                completion(loginResult)
            })
        }
        
        // variable for test call of closure
        var called = false
        
        //test success facebook login
        let facebook = Facebook()
        facebook.loginManager = mockLoginManager
        facebook.getAuthToken { (token, error) in
            called = true
            XCTAssertEqual(token, tokenStr, "token is wrong")
        }
        XCTAssertTrue(called)
        
        //test facebook login with error
        called = false
        let err = NSError(domain: "com.facebooktests.error", code: 1, userInfo: nil)
        loginResult = LoginResultWrapper.failed(err)
        facebook.getAuthToken { (token, error) in
            called = true
            XCTAssertNil(token)
            XCTAssertNotNil(error)
        }
        XCTAssertTrue(called)
        
        //test cancelled facebook login
        called = false
        loginResult = LoginResultWrapper.cancelled
        facebook.getAuthToken { (token, error) in
            called = true
            XCTAssertNil(token)
            XCTAssertNotNil(error)
        }
        XCTAssertTrue(called)
    }
    
    //Testing opening facebook window by button with mocking facebook api
    func test3OpeningFacebook() {
        XCTAssertNotNil(mainController, "Controller not initialized")
        XCTAssertNotNil(mainController.lbStatus, "label not initialized")
        // init LoginResult for mock logIn
        let tokenStr = "token"
        let fbAccessToken = AccessToken(authenticationToken: tokenStr)
        let fbLoginResult = LoginResult.success(grantedPermissions: [], declinedPermissions: [], token: fbAccessToken)
        var loginResult = LoginResultWrapper(loginResult: fbLoginResult)
        
        //mock logIn in LoginManagerWrapper
        let mockLoginManager = MockLoginManagerWrapper()
        
        stub(mockLoginManager) { (mockLoginManager) in
            when(mockLoginManager.logIn(any(), viewController: any(), completion: anyClosure())).then({ permissions, viewController, callBack in
                guard let completion = callBack else {
                    print("callback is null")
                    return
                }
                completion(loginResult)
            })
        }
        
        //test success facebook login
        mainController.facebook.loginManager = mockLoginManager
        mainController.btLoginFBAction()
        XCTAssertEqual(mainController.lbStatus.text, "authorized", "Successful authorization test failed")
        
        //test facebook login with cancel
        //va err = NSError(domain: "com.facebooktests.error", code: 1, userInfo: nil)
        loginResult = LoginResultWrapper.cancelled
        mainController.btLoginFBAction()
        XCTAssertEqual(mainController.lbStatus.text, "cancelled", "Cancelled authorization test failed")
        
        //test facebook login with cancel
        //init custom error
        let userInfo: [AnyHashable : Any] =
            [
                NSLocalizedDescriptionKey :  "error",
        ]
        let err = NSError(domain: "com.facebooktests.error", code: 2, userInfo: userInfo)
        loginResult = LoginResultWrapper.failed(err)
        mainController.btLoginFBAction()
        XCTAssertEqual(mainController.lbStatus.text, "error", "Authorization with error test failed")
        
    }
    
}
