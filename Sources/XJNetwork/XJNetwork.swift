struct XJNetwork {
    var text = "Hello, World!"
}
/*
 Demo
 import Foundation
 import HandyJSON
 /// 初始化
 func configRequest() {
     XJRequestConfig.config.hostDev = "https://dev.baidu.com"
     XJRequestConfig.config.hostOnline = "https://baidu.com"
     XJRequestConfig.config.publicParameters = ["mac":"23:12"]
     XJRequestConfig.config.httpHeader = ["User-Agrent":"userAgent"]
     XJRequestConfig.changeServerPlatform(to: .release)
 }

 public class XJRequestDemo {
     
     public static func loadSimpleRequest()  {
        /// 最简单的网络请求，也不需要知道结果
         request(XJRequest("app/logout"))
         
     }
     
     
     public static func loadNoramalRequest()  {//普通网络请求，不需要映射
         let req = XJRequest("app/login")
         request(req) { (response) in
             if response.isSuccess {
                 print(String(describing: response.data))
             }else{
                 print(response.msg ?? "请求失败了")
             }
         }
     }
     public static func loadMapModelRequest() {
        //获取字典，并映射成Model
         let req = XJRequest("app/userInfo")
         requestMap(req, mapType: UserInfo.self) { (response) in
             if response.isSuccess {
                 let user = response.data as? UserInfo
                 print(user?.name ?? "")
             }else{
                 print(response.msg ?? "请求失败了")
             }
         }
     }
     public static func loadMapListRequest()  {
        //获取列表，并映射成数组
         let req = XJRequest("app/newsList")
         requestMap(req, mapType: News.self) { (response) in
             if response.isSuccess {
                 let newsArray = response.data as? [News]
                 print(newsArray?.first?.title ?? "")
             }else{
                 print(response.msg ?? "请求失败了")
             }
         }
     }
 }
 struct UserInfo:HandyJSON {
     var name :String?
 }
 struct News:HandyJSON {
     var title:String?
 }
 */
