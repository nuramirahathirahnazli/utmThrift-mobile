// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utmthrift_mobile/views/order/order_history_details_page.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';

class OrderHistoryPage extends StatefulWidget {

  final bool refresh;
  final Map<String, dynamic>? paymentResult;

  const OrderHistoryPage({
    super.key,
    this.refresh = false,
    this.paymentResult
  });

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = OrderService.getBuyerOrders();
    _initializeOrders();
    _handleWebAuthToken();
   
  }

  Future<void> _handleWebAuthToken() async {
    final uri = Uri.base;
    final token = uri.queryParameters['token'];
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      print("Token saved to prefs: $token");
    }
  }

  void _confirmOrder(int orderId) async {
    final success = await OrderService.confirmOrder(orderId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meet Up confirmed!')),
      );
      setState(() {
        _ordersFuture = OrderService.getBuyerOrders();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to confirm order.')),
      );
    }
  }

  void _initializeOrders() {
    // If this page was navigated to with a request to refresh
    if (widget.refresh || widget.paymentResult != null) {
      print('Refreshing order list due to payment result');
      setState(() {
        _ordersFuture = OrderService.getBuyerOrders(); // fetch latest orders
      });
    } else {
      _ordersFuture = OrderService.getBuyerOrders(); // initial load
    }
  }

  Widget _buildOrderCard(Order order) {
    print('>> OrderHistoryPage: refresh=${widget.refresh}, paymentResult=${widget.paymentResult}');
    print('DEBUG >> Order item name: ${order.item?.name}');
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderHistoryDetailsPage(order: order),
        ),
      );
    },
    child: Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        title: Text(order.item?.name ?? 'Unnamed Item'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${order.status}'),
            Text('Payment: ${order.paymentMethod}'),
            if (order.paymentMethod == 'Meet Up' && order.status.toLowerCase() == 'pending')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ElevatedButton(
                  onPressed: () => _confirmOrder(order.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Confirm Meet Up'),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found.'));
          } else {
            final orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) =>
                  _buildOrderCard(orders[index]),
            );
          }
        },
      ),
    );
  }
}
