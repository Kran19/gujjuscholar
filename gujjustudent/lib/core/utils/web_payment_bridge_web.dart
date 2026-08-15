// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js; // ignore: deprecated_member_use

void registerWebSuccessCallback(Function(String, String, String) callback) {
  // ignore: undefined_function
  js.context['handleRazorpaySuccess'] = js.allowInterop(
    (String paymentId, String orderId, String signature) {
      callback(paymentId, orderId, signature);
    },
  );
}

void unregisterWebSuccessCallback() {
  js.context['handleRazorpaySuccess'] = null;
}

void openWebRazorpayInterop(Map<String, dynamic> options) {
  final funcExists = js.context.hasProperty('RazorpayOpen');
  if (!funcExists) {
    throw 'JS Error: RazorpayOpen function not found in index.html. Please REFRESH the page (Ctrl+F5).';
  }
  js.context.callMethod('RazorpayOpen', [js.JsObject.jsify(options)]);
}
