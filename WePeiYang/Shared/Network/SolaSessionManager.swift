//
//  SolaSessionManager.swift
//  WePeiYang
//
//  Created by Halcao on 2017/3/12.
//  Copyright © 2017年 twtstudio. All rights reserved.
//

import Foundation
import Alamofire

enum SessionType {
    case get
    case post
    case duo
}

let TWT_ROOT_URL = "https://open.twtstudio.com/api/v1"
let DEV_RECORD_SESSION_INFO = "DEV_RECORD_SESSION_INFO"

struct SolaSessionManager {
    
    /// A primary package of Alamofire, the foundation of network module of WePeiyang
    ///
    /// - Parameters:
    ///   - type: http method: get/post/duo, default value is get
    ///   - baseURL: baseww url of your request, default value is TWT_ROOT_URL
    ///   - url: url of your request
    ///   - token: default value is twt token
    ///   - parameters: http parameters
    ///   - success: callback if request succeeds
    ///   - failure: callback if request fails
    static func solaSession(type: SessionType = .get, baseURL: String = TWT_ROOT_URL, url: String, token: String? = nil, parameters: Dictionary<String, String>? = nil, success: ((Dictionary<String, AnyObject>)->())? = nil, failure: ((Error)->())? = nil) {
        
        let fullurl = baseURL + url
        let timeStamp = String(Int64(Date().timeIntervalSince1970))
        var para = parameters ?? Dictionary<String, String>()
        para["t"] = timeStamp
        var fooPara = para
        
        if type == .duo {
            if let twtToken = TwTUser.shared.token {
                // twt token
                fooPara["token"] = twtToken
            }
        }
        
        let keys = fooPara.keys.sorted()
        // encrypt with sha1
        var tmpSign = ""
        for key in keys {
            tmpSign += (key + fooPara[key]!)
        }

        let sign = (TwTKeychain.shared.appKey + tmpSign + TwTKeychain.shared.appSecret).sha1.uppercased()
        para["sign"] = sign
        para["app_key"] = TwTKeychain.shared.appKey
        
        var headers = HTTPHeaders()
        headers["User-Agent"] = DeviceStatus.userAgent
        
//        //增加的
//        headers["Accept"] = "application/json"
//        headers["Content-Type"] = "application/json"
        
        
        if let twtToken = TwTUser.shared.token {
            headers["Authorization"] = "Bearer {\(twtToken)}"
        } else {
            log.errorMessage("can't load twtToken")/
        }
        
        if type == .duo && token != nil{
            headers["Authorization"] = "Bearer {\(token)}"
        }
        
        var method: HTTPMethod!
        switch type {
        case .get:
            method = .get
        case .post:
            method = .post
        case .duo:
            method = .post
        }
        Alamofire.request(fullurl, method: method, parameters: para, headers: headers).responseJSON { response in
            switch response.result {
            case .success:
                if let data = response.result.value  {
                    if let dict = data as? Dictionary<String, AnyObject> {
                        success?(dict)
                    }
                }
            case .failure(let error):
                print(error)
                failure?(error)
                log.error(error)/
                if let data = response.result.value  {
                    if let dict = data as? Dictionary<String, AnyObject> {
                        log.errorMessage(dict["message"] as! String)/
                    }
                }
            }
            
        }
    }
    
    static func upload1(dictionay: [String : Any], url: String, method: HTTPMethod = .put, progressBlock: ((Progress)->())? = nil, failure: ((Error)->())? = nil, success: (([String : Any])->())?) {
        
        var dataDict = [String: Data]()
        var paraDict = [String: String]()
        for item in dictionay {
            if let value = item.value as? UIImage {
                let data = UIImageJPEGRepresentation(value, 1.0)!
                dataDict[item.key] = data
            } else if let value = item.value as? String {
                paraDict[item.key] = value
            }
        }
        
        let timeStamp = String(Int64(Date().timeIntervalSince1970))
        paraDict["t"] = timeStamp
        var fooPara = paraDict
        
        let keys = fooPara.keys.sorted()
        // encrypt with sha1
        var tmpSign = ""
        for key in keys {
            tmpSign += (key + fooPara[key]!)
        }
        
        let sign = (TwTKeychain.shared.appKey + tmpSign + TwTKeychain.shared.appSecret).sha1.uppercased()
        paraDict["sign"] = sign
        paraDict["app_key"] = TwTKeychain.shared.appKey
        
        var headers = HTTPHeaders()
        headers["User-Agent"] = DeviceStatus.userAgent
        
        if let twtToken = TwTUser.shared.token {
            headers["Authorization"] = "Bearer {\(twtToken)}"
            
        } else {
            log.errorMessage("can't load twtToken")/
        }
        
        let fullURL = TWT_ROOT_URL + url
        
        if method == .post {
            Alamofire.upload(multipartFormData: { formdata in
                for item in dataDict {
                    formdata.append(item.value, withName: item.key, fileName: "avatar.jpg", mimeType: "image/jpeg")
                }
                for item in paraDict {
                    formdata.append(item.value.data(using: .utf8)!, withName: item.key)
                }
            }, to: fullURL, method: .post, headers: headers, encodingCompletion: { response in
                switch response {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        //success?([:])
                        print("qqq")
                        print(response)
                        if let data = response.result.value  {
                            if let dict = data as? Dictionary<String, Any> {
                                success?(dict)
                            }
                        }
                    }
                    upload.uploadProgress { progress in
                        progressBlock?(progress)
                    }
                case .failure(let error):
                    print("ewww")
                    failure?(error)
                    print(error)
                }
            })
        }
    }
    
    
    
    
    static func upload(dictionay: [String : Any], url: String, method: HTTPMethod = .post, progressBlock: ((Progress)->())? = nil, failure: ((Error)->())? = nil, success: (([String : Any])->())?) {
        var dataDict = [String: Data]()
        var paraDict = [String: String]()
        for item in dictionay {
            if let value = item.value as? UIImage {
                let data = UIImageJPEGRepresentation(value, 1.0)!
                dataDict[item.key] = data
            } else if let value = item.value as? String {
                paraDict[item.key] = value
            }
        }
        
        let timeStamp = String(Int64(Date().timeIntervalSince1970))
        paraDict["t"] = timeStamp
        var fooPara = paraDict
        
        let keys = fooPara.keys.sorted()
        // encrypt with sha1
        var tmpSign = ""
        for key in keys {
            tmpSign += (key + fooPara[key]!)
        }
        
        let sign = (TwTKeychain.shared.appKey + tmpSign + TwTKeychain.shared.appSecret).sha1.uppercased()
        paraDict["sign"] = sign
        paraDict["app_key"] = TwTKeychain.shared.appKey
        
        var headers = HTTPHeaders()
        headers["User-Agent"] = DeviceStatus.userAgent
        
//        //增加的
//        headers["Accept"] = "application/json"
//        headers["Content-Type"] = "application/json"
//
        
        if let twtToken = TwTUser.shared.token {
            headers["Authorization"] = "Bearer {\(twtToken)}"
        } else {
            log.errorMessage("can't load twtToken")/
        }
        let fullURL = TWT_ROOT_URL + url
        
        if method == .post {
            Alamofire.upload(multipartFormData: { formdata in
                for item in dataDict {
                    formdata.append(item.value, withName: item.key, fileName: "avatar.jpg", mimeType: "image/jpeg")
                    //                    formdata.append(item.value, withName: item.key, mimeType: "image/jpg")
                }
                for item in paraDict {
                    formdata.append(item.value.data(using: .utf8)!, withName: item.key)
                }
            }, to: fullURL, method: .post, headers: headers, encodingCompletion: { response in
                switch response {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        if let data = response.result.value  {
                            if let dict = data as? Dictionary<String, Any>, dict["error_code"] as? Int == 0 {
                                success?(dict)
                            } else {
                                //                                HUD.hide()
                                //                                HUD.flash(.label((data as? [String: Any])?["data"] as? String), delay: 1.0)
                            }
                        }
                    }
                    upload.uploadProgress { progress in
                        progressBlock?(progress)
                    }
                    upload.response(completionHandler: { response in
                        //                        print(response)
                    })
                    
                case .failure(let error):
                    failure?(error)
                    print(error)
                }
            })
        }
    }
    
    
    
}
