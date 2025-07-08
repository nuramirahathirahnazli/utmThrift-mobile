// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utmthrift_mobile/views/order/order_history_details_page.dart';
import 'package:utmthrift_mobile/views/review/leave_review_page.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';
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
        SnackBar(
          content: const Text('Meet Up confirmed!'),
          backgroundColor: Colors.green[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      setState(() {
        _ordersFuture = OrderService.getBuyerOrders();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to confirm order.'),
          backgroundColor: Colors.red[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
    final isPendingMeetUp = order.paymentMethod == 'Meet Up' && 
                          order.status.toLowerCase() == 'pending';
    final isCompleted = order.status.toLowerCase() == 'completed';
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      color: AppColors.color11,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
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
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getPaymentIcon(order.paymentMethod),
                      size: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    order.paymentMethod,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (isPendingMeetUp || isCompleted)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: isPendingMeetUp
                        ? LinearGradient(colors: [Colors.green[600]!, Colors.green[800]!])
                        : (order.alreadyReviewed
                            ? LinearGradient(colors: [Colors.grey[600]!, Colors.grey[800]!])
                            : LinearGradient(colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).primaryColorDark,
                              ])),
                  ),
                  child: ElevatedButton(
                    onPressed: isPendingMeetUp
                        ? () => _confirmOrder(order.id)
                        : order.alreadyReviewed
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
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      isPendingMeetUp
                          ? 'CONFIRM MEET UP'
                          : order.alreadyReviewed
                              ? 'REVIEW SUBMITTED'
                              : 'LEAVE REVIEW',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
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
        return Colors.green[800]!;
      case 'pending':
        return Colors.orange[800]!;
      case 'cancelled':
        return Colors.red[800]!;
      default:
        return Colors.grey[800]!;
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
        title: const Text(
          'Order History',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: Colors.white
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.color2,
        foregroundColor: Colors.white,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      backgroundColor: AppColors.base,
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading your orders...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red[800],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Error loading orders',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _ordersFuture = OrderService.getBuyerOrders();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
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
                    size: 72,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No orders yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'Your completed orders will appear here',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            final orders = snapshot.data!;
            return RefreshIndicator(
              color: Colors.black87,
              backgroundColor: Colors.white,
              onRefresh: () async {
                setState(() {
                  _ordersFuture = OrderService.getBuyerOrders();
                });
              },
              child: ListView.separated(
                padding: const EdgeInsets.only(top: 16, bottom: 24),
                physics: const AlwaysScrollableScrollPhysics(),
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