//
//  WBWebViewConsoleDefines.h
//  WBWebViewConsole
//
//  Created by 吴天 on 2/13/15.
//  Copyright (c) 2015 Sina. All rights reserved.
//

#ifndef WBWebViewConsole_WBWebViewConsoleDefines_h
#define WBWebViewConsole_WBWebViewConsoleDefines_h

inline static NSBundle * WBWebBrowserConsoleBundle()
{
    return [NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], @"WBWebBrowserConsole.bundle"]];
}

#endif
