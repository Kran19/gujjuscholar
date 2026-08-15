import 'web_payment_bridge_stub.dart'
    if (dart.library.js) 'web_payment_bridge_web.dart';

abstract class WebPaymentBridge {
  static void registerSuccessCallback(Function(String, String, String) callback) {
    registerWebSuccessCallback(callback);
  }

  static void unregisterSuccessCallback() {
    unregisterWebSuccessCallback();
  }

  static void openWebRazorpay(Map<String, dynamic> options) {
    openWebRazorpayInterop(options);
  }
}
