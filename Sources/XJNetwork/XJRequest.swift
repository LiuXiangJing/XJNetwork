//
//  XJRequest.swift
//  XJNetWork
//
//  Created by liu on 2019/10/30.
//  Copyright © 2019 liuxiangjing. All rights reserved.
//

#if os(iOS)
import Foundation
import Alamofire
import HandyJSON
/// 请求方式转换
extension RequestMethod {
    var httpMethod :HTTPMethod {
        return HTTPMethod(rawValue: self.rawValue) 
    }
}

/// 一次网络请求基本设置
public struct XJRequest {
    /// 路径
    public private(set) var path:String!
    /// 请求方式
    public private(set) var method:RequestMethod = .get
    /// 请求参数
    public var parameters:[String:Any]?
    /// httpheader
    public var header:[String:String]?
    
    public init(_ path:String,_ method:RequestMethod = .get,_ parameters:[String:Any]? = nil,_ header:[String:String]? = nil) {
        self.path = path
        self.method = method
        self.parameters = parameters
        self.header = header
        
    }
}

/// 请求结果
/**
 result = {
 code:0
 msg:"操作成功"
 data:[] 或 {}
  }
 */
fileprivate let successCode = 0
public struct XJResponse {
    /// 默认code = 0 为成功
    public var isSuccess:Bool = false
    /// 服务器返回的json结果
    public var result:[String:Any]?
    /// 状态值
    public var code:Int = -1
    /// 描述信息
    public var msg:String?
    /// 映射结果
    public var data:Any?
    /// 网络请求
    public var request: URLRequest?
    
}

fileprivate let requestManager: Session = {
    AF.sessionConfiguration.timeoutIntervalForRequest = 20
    AF.sessionConfiguration.timeoutIntervalForResource = 40
    return AF
}()
// MARK: - 普通网路请求
/// 进行普通网络请求
public func request(_ request:XJRequest,completionHandler:((XJResponse) -> Void)? = nil) {
    
    let url = XJRequestConfig.config.host + request.path
    
    let method = request.method.httpMethod
    
    let paramrters = (XJRequestConfig.config.publicParameters ?? [:]) + (request.parameters ?? [:])
    
    var httpHeader:HTTPHeaders?
    if let headers = (XJRequestConfig.config.httpHeader ?? [:]) + (request.header ?? [:]) as? [String : String] {
        httpHeader = HTTPHeaders(headers)
    }
    
    let dataRequest = requestManager.request(url, method: method, parameters: paramrters, headers: httpHeader)
        
    if let handler = completionHandler {
        dataRequest.responseJSON { (response) in
            handleJsonResult(dataResponse: response, completionHandler: handler)
        }
    }
}
// MARK: - 普通网络请求 + HandyJson映射
/// 进行普通网络请求，并将结果进行Map映射
public func requestMap<T:HandyJSON>(_ request:XJRequest,mapType:T.Type,completionHandler:@escaping((XJResponse) -> Void)) {
    
    let url = XJRequestConfig.config.host + request.path
    
    let method = request.method.httpMethod
    
    let paramrters = (XJRequestConfig.config.publicParameters ?? [:]) + (request.parameters ?? [:])
    

    var httpHeader:HTTPHeaders?
    if let headers = (XJRequestConfig.config.httpHeader ?? [:]) + (request.header ?? [:]) as? [String : String] {
        httpHeader = HTTPHeaders(headers)
    }
    
    AF.request(url, method: method, parameters: paramrters, headers: httpHeader).responseMap(type: mapType, completionHandler: completionHandler)
    
}
// MARK: - 文件上传操作
/// 上传文件操作
public func uploadRequest(_ request:XJRequest,
                          multipartFormData formData: @escaping (MultipartFormData) -> Void,
                          progressHandler:@escaping((Float) -> Void),completionHandler:@escaping((XJResponse) -> Void)){
    
    let url = XJRequestConfig.config.host + request.path
              
    let paramrters = (XJRequestConfig.config.publicParameters ?? [:]) + (request.parameters ?? [:])
          
    var httpHeader:HTTPHeaders?
    if let headers = (XJRequestConfig.config.httpHeader ?? [:]) + (request.header ?? [:]) as? [String : String] {
        httpHeader = HTTPHeaders(headers)
    }
    requestManager.upload(multipartFormData: { (multipartFormData) in
        for (key, value) in paramrters {
            if let data = (value as! String).data(using: .utf8) {
                multipartFormData.append(data, withName: key)
            }
        }
        formData(multipartFormData)
        
    }, to: url,headers:httpHeader).uploadProgress(closure: { (progress) in
        let aValue :Double = Double(progress.completedUnitCount)/Double(progress.totalUnitCount)
        
        progressHandler(Float(aValue))
    }).responseJSON { (response) in
        handleJsonResult(dataResponse: response, completionHandler: completionHandler)
    }
}
// MARK: - 结果处理
/// 将结果处理，并返回XJResponse
fileprivate func handleJsonResult(dataResponse:AFDataResponse<Any>,completionHandler:@escaping((XJResponse) -> Void))  {
    
    var response = XJResponse()
    response.request = dataResponse.request
    switch dataResponse.result {
    case .success(let result):
        let resultDic = result as? Dictionary<String, Any>
        let code  = resultDic?["code"] as? Int
        let msg = resultDic?["msg"] as? String
        
        response.result = resultDic
        response.code = code ?? -1
        if code == successCode {
            response.isSuccess = true
        }
        response.msg = msg
        response.data = resultDic?["data"]
        break
    case .failure(let error):
        response.msg = error.localizedDescription
        response.code = -1
        break
    }
    completionHandler(response)
}

/// 将结果进行处理后，并进行HandJson转化 返回 XJResponse
extension DataRequest {
    @discardableResult public func responseMap<T:HandyJSON>(type:T.Type,completionHandler:@escaping((XJResponse) -> Void)) -> Self {
        return responseJSON { (dataResponse) in
            handleJsonResult(dataResponse: dataResponse) { (response) in
                var mapResponse = response
                if let data = mapResponse.data as? [String:Any]{
                    mapResponse.data = JSONDeserializer<T>.deserializeFrom(dict: data)
                }else if let data = mapResponse.data as? [Any] {
                    mapResponse.data = JSONDeserializer<T>.deserializeModelArrayFrom(array: data)
                }
                completionHandler(mapResponse)
            }
        }
    }
}

@inlinable public func + (lhs: Dictionary<String, Any>, rhs: Dictionary<String, Any>) -> Dictionary<String, Any> {
       var dic = lhs
       for (key,value) in rhs.reversed() {
           dic[key] = value
       }
       return dic
}

#endif
