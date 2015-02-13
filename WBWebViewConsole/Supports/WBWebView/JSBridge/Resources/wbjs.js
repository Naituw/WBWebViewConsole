(function (root, factory) {
    root["WeiboJSBridge"] = factory();

    var document = root['document'];
    if (document) {
        var readyEvent = document.createEvent('Events');
        readyEvent.initEvent('WeiboJSBridgeReady');
        document.dispatchEvent(readyEvent);
    }
} (this, function () {

    var _callbacks = [];
    var _callbackIndex = 1000;
    var _messageQueue = [];

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
            location.href = 'wbjs://invoke';
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

            var params = message.params;
            var success = !message.failed;

            callback(params, success);
        }
    };

    return Weibo;
}));