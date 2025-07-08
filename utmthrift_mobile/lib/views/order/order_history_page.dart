// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utmthrift_mobile/views/order/order_history_details_page.dart';
import 'package:utmthrift_mobile/views/review/leave_review_page.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import 'package:utmthrift_mobile/main.dart';

class OrderHistoryPage extends StatefulWidget {
  final bool refresh;
  final Map<String, dynamic>? paymentResult;

  const OrderHistoryPage({
    super.key,
    this.refresh = false,
    this.paymentResult,
  });

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> with RouteAware {
  late Future<List<Order>> _ordersFuture;
  int _buyerId = 0;

  @override
  void initState() {
    super.initState();
    _initializeOrders();
    _prepareAsyncData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  void _prepareAsyncData() {
    _handleWebAuthToken();
    _loadBuyerId();
  }

  @override
  void didPopNext() {
    setState(() {
      _ordersFuture = OrderService.getBuyerOrders();
    });
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> _handleWebAuthToken() async {
    final uri = Uri.base;
    final token = uri.queryParameters['token'];
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
    }
  }

  void _confirmOrder(int orderId) async {
    final success = await OrderService.confirmOrder(orderId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meet Up confirmed!'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _ordersFuture = OrderService.getBuyerOrders();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to confirm order.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _initializeOrders() {
    if (widget.refresh || widget.paymentResult != null) {
      setState(() {
        _ordersFuture = OrderService.getBuyerOrders();
      });
    } else {
      _ordersFuture = OrderService.getBuyerOrders();
    }
  }

  Future<void> _loadBuyerId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _buyerId = prefs.getInt('user_id') ?? 0;
    });
  }

  Widget _buildOrderCard(Order order) {
    final statusColor = _getStatusColor(order.status);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderHistoryDetailsPage(order: order),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.item?.name ?? 'Unnamed Item',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    _getPaymentIcon(order.paymentMethod),
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    order.paymentMethod,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (order.paymentMethod == 'Meet Up' &&
                  order.status.toLowerCase() == 'pending')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _confirmOrder(order.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'CONFIRM MEET UP',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (order.status.toLowerCase() == 'completed')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: order.alreadyReviewed
                        ? null
                        : () {
                            final item = order.item!;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LeaveReviewPage(
                                  orderId: order.id,
                                  itemId: item.id,
                                  buyerId: _buyerId,
                                  sellerId: item.sellerId,
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: order.alreadyReviewed
                          ? Colors.grey
                          : Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      order.alreadyReviewed ? 'REVIEW SUBMITTED' : 'LEAVE REVIEW',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getPaymentIcon(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'credit card':
        return Icons.credit_card;
      case 'online banking':
        return Icons.account_balance;
      case 'meet up':
        return Icons.handshake;
      default:
        return Icons.payment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading orders',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _ordersFuture = OrderService.getBuyerOrders();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your order history will appear here',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          } else {
            final orders = snapshot.data!;
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _ordersFuture = OrderService.getBuyerOrders();
                });
              },
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: orders.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) => _buildOrderCard(orders[index]),
              ),
            );
          }
        },
      ),
    );
  }
}