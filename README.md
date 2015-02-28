# WBWebViewConsole

WBWebViewConsole is an In-App debug console for your UIWebView && WKWebView

<img src="https://github.com/Naituw/WBWebViewConsole/blob/master/Assets/hero.png" alt="WBWebViewConsole" width="487"/>

## Installation

WBWebViewConsole is available on [CocoaPods](http://cocoapods.org). Just add the following to your project Podfile:

```
pod 'WBWebViewConsole', '~> 1.0' 
```

## Setup

- Make your own `UIWebView` or `WKWebView` subclass, and implements all methods in `WBWebView` protocol
- Setup `JSBridge` and `console` when WebView inits
- If you are using `UIWebView`, inject userScript as early as possible after page loading. Otherwise, just use `WKUserScript` to implement.
- In `UIWebView`'s `webView:shouldStartLoadWithRequest:navigationType` or `WKWebView`'s `webView:decidePolicyForNavigationAction:decisionHandler`
  - Pass the request to `-[JSBridge handleWebViewRequest:]` and use the return value to decide wether the navigation should start

## Usage

- Use `WBWebViewConsole` to manage all messages
  - `addMessage:type:level:source:`
 	- add message for specific type, level and source
  - `clearMessage`
    - empty all messages
  - `sendMessage`
    - input (eval) script
  - `storeCurrentSelectedElementToJavaScriptVariable:completion:`
    - save current selected element to a js variable
- Use `WBWebDebugConsoleViewController` to display a `WBWebViewConsole`
  - `initWithConsole:`
    - designated initializer for this class
  - `setInitialCommand:`
    - set the placeholder command

## License

WBWebViewConsole is BSD-licensed. see the `LICENSE` file.

The files in the `/Examples` directory are licensed under a separate license as specified in `Examples/README.md`.
