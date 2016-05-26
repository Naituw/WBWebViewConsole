Pod::Spec.new do |s|
  s.name         = "WBWebViewConsole"
  s.platform     = :ios
  s.ios.deployment_target = "6.0"
  s.version      = "1.0.2"
  s.summary      = "In-App debug console for your UIWebView && WKWebView"
  s.homepage     = "https://github.com/Naituw/WBWebViewConsole"
  s.license      = "BSD"
  s.authors      = {"Naituw" => "naituw@gmail.com"}
  s.source       = {:git => "https://github.com/Naituw/WBWebViewConsole.git", :tag => '1.0.2'}
  s.source_files = 'WBWebViewConsole/**/*.{h,m}'
  s.requires_arc = true
  s.resources = ["WBWebViewConsole/Resources/*", "WBWebViewConsole/Supports/WBWebView/JSBridge/Resources/*"]
end