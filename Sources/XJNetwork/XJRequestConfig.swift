//
//  XJRequestConfig.swift
//  XJNetWork
//
//  Created by liu on 2019/11/1.
//  Copyright © 2019 liuxiangjing. All rights reserved.
//

#if os(iOS)
import Foundation
import Alamofire
// MARK: - 请求方式列表
/// 请求方式
public enum RequestMethod :String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}
// MARK: - 网络环境列表
/// 网络请求环境，分开发环境以及线上环境
public enum XJServerPlat:Int {
    /// 开发环境
    case developer = 10
    /// 线上环境
    case release = 0
}

// MARK: - 网络请求默认配置
public struct XJRequestConfig {
    
    private init() { }
    
    public static var config = XJRequestConfig()
    
    public fileprivate(set) var host:String!
    
    public var hostDev:String? {
        didSet{
            updateServerPlatform()
        }
    }
    
    public var hostOnline:String! {
        didSet {
            updateServerPlatform()
        }
    }
    
    public var publicParameters:[String:Any]?
    
    public var httpHeader:[String:String]?
    
    fileprivate mutating func updateServerPlatform() {
        let platform = XJRequestConfig.serverPlatform
        switch platform {
        case .developer:
            host = hostDev != nil ? hostDev : hostOnline
            break
            
        case .release:
            host = hostOnline
        }
    }
}

// MARK: - 网络环境切换设置
fileprivate let environmentKey = "xj.net.platform"
extension XJRequestConfig {
    /// 当前环境
    public static fileprivate(set) var serverPlatform:XJServerPlat = {
        let platform = UserDefaults.standard.integer(forKey: environmentKey)
        return XJServerPlat(rawValue: platform) ?? .release
    }()
    /// 切换环境
    public static func changeServerPlatform(to platform:XJServerPlat) {
        UserDefaults.standard.set(platform.rawValue, forKey: environmentKey)
        UserDefaults.standard.synchronize()
        XJRequestConfig.config.updateServerPlatform()
    }
}
#endif
