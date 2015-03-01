/** 
 *  Copyright (c) 2014-present, Weibo, Corp.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree.
 */

(function (config) {

    config = config || {};

    (function (root, factory) {
        var interface = config["interface"];
        if (interface && !root[interface]) {
            root[interface] = factory();

            var eventName = config["readyEvent"];
            var document = root['document'];
            if (eventName && document) {
                var readyEvent = document.createEvent('Events');
                readyEvent.initEvent(eventName);
                document.dispatchEvent(readyEvent);
            }
        }
    } (this, function () {

        var _callbacks = [];
        var _callbackIndex = 1000;
        var _messageQueue = [];
        var _invokeScheme = config['invokeScheme'];

        var Weibo = {
            invoke: function (name, params, callback) {

                if (typeof name !== 'string') {
                    return;
                }

                if (!params) {
                    params = {};
                }

                var callbackID = (_callbackIndex++).toString();

                if (callback) {
                    _callbacks[callbackID] = callback;
                }

                var message = {
                    action: name,
                    params: params,
                    callback_id: callbackID
                }

                _messageQueue.push(message);
                location.href = _invokeScheme;
            },

            _messageQueue: function () {
                var ret = JSON.stringify(_messageQueue);
                _messageQueue = [];
                return ret;
            },

            _handleMessage: function (message) {
                if (!message) {
                    return;
                }
                var callbackID = message.callback_id;
                if (!callbackID) {
                    return;
                }

                var callback = _callbacks[callbackID];

                if (callback) {
                    var params = message.params;
                    var success = !message.failed;
                   
                    callback(params, success);
                }
            }
        };

        return Weibo;
    }));
})