// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PaymentService {
  late Razorpay _razorpay;
  BuildContext? _context;

  // Callbacks
  Function(String paymentId, String orderId, String signature)? onSuccess;
  Function(String message)? onError;

  void initialize(BuildContext context) {
    _context = context;
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> startPayment({
    required double amount,
    required String description,
    String? userEmail,
    String? userPhone,
  }) async {
    if (amount <= 0) {
      _showToast('Invalid amount');
      return;
    }

    var options = {
      'key': 'rzp_test_1DP5mmOlF5G5ag', // Replace with your Razorpay key
      'amount': (amount * 100).toInt(), // Amount in paise
      'currency': 'INR',
      'name': 'Tournament Entry',
      'description': description,
      'retry': {'enabled': true, 'max_count': 2},
      'prefill': {'contact': userPhone ?? '', 'email': userEmail ?? ''},
      'theme': {'color': '#2196F3'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('❌ Error: $e');
      _showToast('Error starting payment: $e');
      onError?.call('Error starting payment');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('✅ Payment Success!');
    debugPrint('Payment ID: ${response.paymentId}');
    debugPrint('Order ID: ${response.orderId}');
    debugPrint('Signature: ${response.signature}');

    _showToast('Payment Successful!');

    onSuccess?.call(
      response.paymentId ?? '',
      response.orderId ?? '',
      response.signature ?? '',
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('❌ Payment Error!');
    debugPrint('Code: ${response.code}');
    debugPrint('Message: ${response.message}');

    _showToast('Payment Failed: ${response.message ?? "Unknown error"}');
    onError?.call(response.message ?? 'Payment failed');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet Selected: ${response.walletName}');
    _showToast('External Wallet: ${response.walletName ?? "Unknown"}');
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void dispose() {
    _razorpay.clear();
  }
}
