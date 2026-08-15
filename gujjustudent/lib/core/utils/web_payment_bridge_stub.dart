void registerWebSuccessCallback(Function(String, String, String) callback) {}

void unregisterWebSuccessCallback() {}

void openWebRazorpayInterop(Map<String, dynamic> options) {
  throw UnsupportedError('Web Razorpay is only supported on the Web platform.');
}
