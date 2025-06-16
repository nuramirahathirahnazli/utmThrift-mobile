// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:utmthrift_mobile/services/order_service.dart';
import 'package:utmthrift_mobile/views/order/order_history_page.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ToyyibPayScreen extends StatefulWidget {
  final String paymentUrl;
  final int orderId;

  final Function(Map<String, dynamic>)? onPaymentComplete;

  const ToyyibPayScreen({
    super.key,
    required this.paymentUrl,
    required this.orderId,
    this.onPaymentComplete,
  });

  @override
  State<ToyyibPayScreen> createState() => _ToyyibPayScreenState();
}

class _ToyyibPayScreenState extends State<ToyyibPayScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  Map<String, dynamic>? _paymentResult;
  bool _paymentHandled = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            return _handleNavigation(request);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  NavigationDecision _handleNavigation(NavigationRequest request) {
    if (_paymentHandled) return NavigationDecision.prevent;

    if (request.url.contains('status_id') ||
        request.url.contains('billcode') ||
        request.url.contains('payment-success') ||
        request.url.contains('payment-failure')) {
      final uri = Uri.parse(request.url);
      final params = uri.queryParameters;

      final result = {
        'status': params['status_id'] ?? '0',
        'billcode': params['billcode'] ?? '',
        'order_id': params['order_id'] ?? '',
        'message': params['msg'] ?? '',
        'redirect_url': request.url,
        if (params.containsKey('transaction_id')) 'transaction_id': params['transaction_id'],
      };

      _paymentHandled = true;
      widget.onPaymentComplete?.call(result);

      setState(() {
        _paymentResult = result;
      });

      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ToyyibPay Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _paymentResult != null
          ? _buildPaymentResultUI(_paymentResult!)
          : Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
    );
  }

  Widget _buildPaymentResultUI(Map<String, dynamic> result) {
    bool isSuccess = result['status'] == '1';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 8,
                  color: Colors.black12,
                )
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.cancel,
                  color: isSuccess ? Colors.green : Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  isSuccess ? 'Payment Successful' : 'Payment Failed',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isSuccess ? Colors.green[800] : Colors.red[800],
                  ),
                ),
                const SizedBox(height: 24),
                _buildDetailItem('Transaction ID', result['transaction_id'] ?? '-'),
                _buildDetailItem('Order ID', result['order_id'] ?? '-'),
                _buildDetailItem('Bill Code', result['billcode'] ?? '-'),
                _buildDetailItem('Status Message', result['message'] ?? '-'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: isSuccess ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isSuccess ? 'Paid' : 'Failed',
                    style: TextStyle(
                      color: isSuccess ? Colors.green[900] : Colors.red[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isSuccess
                      ? 'Thank you for shopping with UTMThrift!'
                      : 'Unfortunately, your payment failed. Please try again.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          if (!isSuccess)
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _paymentResult = null;
                  _paymentHandled = false;
                  _controller.loadRequest(Uri.parse(widget.paymentUrl));
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry Payment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

          ElevatedButton.icon(
            onPressed: () async {
            await OrderService.manualConfirmOrder(widget.orderId);

              if (!mounted) return;

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderHistoryPage(
                    refresh: true,
                    paymentResult: _paymentResult,
                  ),
                ),
              );
            },

            icon: const Icon(Icons.history),
            label: const Text('Back to Orders'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey[800],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }

}

