// replace console methods
(function (config) {

    if (window.__WeiboDebugConsole) return;

    function __stringifyObject(result) {
        try {
            var resultType = typeof result;
            if (resultType == 'string') {
                return '"' + result + '"';
            } else if (resultType == 'number' ||
                resultType == 'boolean') {
                return result;
            } else if (resultType == 'undefined') {
                return 'undefined';
            } else if (result == null) {
                return 'null';
            } else if (resultType == 'function') {
                return result.toString();
            } else if (resultType == 'object') {
                var cache = [];
                var json = JSON.stringify(result, function(key, value) {
                    if (typeof value === 'object' && value !== null) {
                        if (cache.indexOf(value) !== -1) {
                            // circular reference found, discard key
                            return;
                        }
                        // store value in our collection
                        cache.push(value);

                        if (value != result) {
                            // only print first level properties
                            // otherwise you will get huge return value, when you quering things like 'window'
                            return Object.prototype.toString.call(value);
                        }
                    }
                    return value;
                }, 4); // indented 4 spaces
                cache = null; // enable garbage collection
                return json;
            }
        } catch (error) {
            return result;
        }
        return result;
    }

    window.__WeiboDebugConsole = {
        stringifyObject: function(object) {
            return __stringifyObject(object);
        }
    };

    if (!window.console) return;
    function isNumber(n) {
        return !isNaN(parseFloat(n)) && isFinite(n);
    }
    function __logWithParams(params) {
        var interfaceName = (config && config['bridge']) || 'WeiboJSBridge';
        if (window[interfaceName]) {
            window[interfaceName].invoke('privateConsoleLog', params);
        }
    }
    function __updateParams(params, error) {
        var stack = error.stack;
        do {
            if (!stack.length) break;

            var caller = stack.split("\n")[1];

            if (!caller) break;

            var info = caller;

            var at_index = caller.indexOf("@");

            if (at_index < 0 || at_index + 1 >= caller.length) {
                info = caller;
            } else {
                info = caller.substring(at_index + 1, caller.length);
            }

            do {
                function getLastNumberAndTrimInfo() {
                    var colon_index = info.lastIndexOf(":");

                    if (colon_index < 0 || colon_index + 1 >= info.length) {
                        return -1;
                    }

                    var column = info.substring(colon_index + 1);

                    if (!isNumber(column)) {
                        return -1;
                    }

                    info = info.substring(0, colon_index);

                    return column;
                }

                // parse column no
                var colno = getLastNumberAndTrimInfo();
                if (colno == -1) break;
                params.colno = colno;

                // parse line no
                var lineno = getLastNumberAndTrimInfo();
                if (lineno == -1) break;
                params.lineno = lineno;

                // the rest is file
                params.file = info;
            } while (0);
        } while (0);

        if (!params.lineno && params.colno) {
            params.lineno = params.colno;
            delete params.colno;
        }
        return params;
    }
    function __stringifyArgs(args) {
        var result = [];
        var n = args.length;
        for (var i = 0; i < n; i++) {
            arg = args[i];
            result.push(__stringifyObject(arg));
        }
        return result;
    }
    for (var key in console) {
        (function (name) {
            var func = console[name];
            if (typeof func != 'function') return;
            console[name] = function () {
                var args = Array.prototype.slice.call(arguments, 0);
                func.apply(console, args);

                var params = {
                    'func': name,
                    'args': __stringifyArgs(args),
                };

                // retrive caller info
                try {
                    throw Error("");
                } catch (error) {
                    params = __updateParams(params, error);
                }
                __logWithParams(params);
            }
        }(key));
    }

    // catch errors
    (function () {

        window.addEventListener('error', function (event) {
            var params = {
                'func': 'error',
                'args': [event.message],
                'file': event.filename,
                'colno': event.colno,
                'lineno': event.lineno,
            };
            __logWithParams(params);
        });
    }());
})