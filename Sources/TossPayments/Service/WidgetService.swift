//
//  File.swift
//  
//
//  Created by 김진규 on 2022/12/21.
//

#if canImport(UIKit)
import UIKit
import WebKit

class WidgetService: NSObject, PaymentServiceProtocol {
    let htmlString: String
    let baseURL: URL
    init(
        htmlString: String,
        baseURL: URL
    ) {
        self.htmlString = htmlString
        self.baseURL = baseURL
    }
    
    var failURLHandler: ((URL) -> Void)?
    var successURLHandler: ((URL) -> Void)?
}

extension WidgetService: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        handleError(error)
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handleError(error)
    }
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        //  FailURL 혹은 SuccessURL 처리
        if handleResult(with: navigationAction) {
            decisionHandler(.cancel)
            return
        }
        
        // https 이외의 action 처리
        if handleActionExceptHTTP(with: navigationAction) {
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
    }
    
    func webView(
        _ webView: WKWebView,
        didFinish navigation: WKNavigation!
    ) {
    }
}

extension WidgetService {
    
    private func handleResult(with navigationAction: WKNavigationAction) -> Bool {
        guard let url = navigationAction.request.url else { return false }
        let urlString = url.absoluteString
        
        if urlString.hasPrefix(WebConstants.failURL) {
            failURLHandler?(url)
            return true
        } else if urlString.hasPrefix(WebConstants.successURL) {
            successURLHandler?(url)
            return true
        }
        
        return false
    }
    
    private func handleActionExceptHTTP(with navigationAction: WKNavigationAction) -> Bool {
        guard let url = navigationAction.request.url else { return false }
        guard !(url.scheme?.hasPrefix("http") ?? false) else { return false }
        guard url.scheme != "about" else { return false }
        UIApplication.shared.open(url)
        return true
    }
    
    private func handleError(_ error: Error) {
        let errorCode = (error as NSError).code
        let errorMessage = error.localizedDescription
        if let url = URL(string: "tosspayments://fail?errorCode=\(errorCode)&errorMessage=\(errorMessage)&orderId=unknown") {
            failURLHandler?(url)
        }
    }
}


#endif
