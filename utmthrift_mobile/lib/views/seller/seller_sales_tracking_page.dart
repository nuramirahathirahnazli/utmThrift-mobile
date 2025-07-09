import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utmthrift_mobile/viewmodels/sellersale_viewmodel.dart';
import 'package:utmthrift_mobile/views/seller/seller_sales_details_track_page.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';

class SalesTrackingPage extends StatefulWidget {
  final int sellerId;
  final VoidCallback? onGoToProfile;

  const SalesTrackingPage({
    super.key, 
    required this.sellerId,
    this.onGoToProfile,
  });

  @override
  State<SalesTrackingPage> createState() => _SalesTrackingPageState();
}

class _SalesTrackingPageState extends State<SalesTrackingPage> {
  int? _selectedMonth;
  int? _selectedYear;
  final String userType = 'Seller';

  @override
  void initState() {
    super.initState();
    Provider.of<SellerSaleViewModel>(context, listen: false)
        .fetchSales(widget.sellerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Sales Tracking',
          style: TextStyle(
            color: AppColors.base,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.color2,
        iconTheme: const IconThemeData(color: AppColors.base),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pop(context); // close SalesTrackingPage
              widget.onGoToProfile?.call(); // Navigate to ProfilePage
            },
          ),
        ],
      ),
      body: Consumer<SellerSaleViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.color2,
              ),
            );
          }

          final summary = viewModel.summary;

          return Column(
            children: [
              // Filter Section
              _buildFilterSection(viewModel),
              
              // Summary Card
              if (summary != null) _buildSummaryCard(summary),

              const SizedBox(height: 16),

              // Sales List
              _buildSalesList(viewModel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterSection(SellerSaleViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          // Month Dropdown
          Flexible(
            flex: 1,
            child: DropdownButtonFormField<int>(
              isExpanded: true,
              decoration: appInputDecoration(
                labelText: 'Month',
                prefixIcon: Icons.calendar_today,
              ),
              value: _selectedMonth,
              items: List.generate(12, (index) {
                return DropdownMenuItem(
                  value: index + 1,
                  child: Text('${index + 1}'.padLeft(2, '0')),
                );
              }),
              onChanged: (value) => setState(() => _selectedMonth = value),
            ),
          ),

          // Year Dropdown (Updated!)
          Flexible(
            flex: 1,
            child: DropdownButtonFormField<int>(
              isExpanded: true,
              decoration: appInputDecoration(
                labelText: 'Year',
                prefixIcon: Icons.calendar_view_month,
              ),
              value: _selectedYear,
              items: List.generate(5, (index) {
                final year = 2025 + index;
                return DropdownMenuItem(value: year, child: Text('$year'));
              }),
              onChanged: (value) => setState(() => _selectedYear = value),
            ),
          ),

          // Filter Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.color13,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Provider.of<SellerSaleViewModel>(context, listen: false).fetchSales(
                widget.sellerId,
                month: _selectedMonth,
                year: _selectedYear,
              );
            },
            child: const Text(
              'Filter',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Clear Filter Button
          TextButton(
            onPressed: () {
              setState(() {
                _selectedMonth = null;
                _selectedYear = null;
              });
              Provider.of<SellerSaleViewModel>(context, listen: false)
                  .fetchSales(widget.sellerId);
            },
            child: const Text(
              'Clear Filter',
              style: TextStyle(color: AppColors.color13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> summary) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      color: AppColors.color12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.color2.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: AppColors.color2, size: 24),
                SizedBox(width: 12),
                Text(
                  'Monthly Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.color2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              Icons.shopping_cart,
              "Items Sold",
              "${summary['items_sold']}",
              AppColors.color7,
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              Icons.attach_money,
              "Total Sales",
              "RM ${summary['total_revenue']?.toStringAsFixed(2)}",
              AppColors.color13,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesList(SellerSaleViewModel viewModel) {
    return Expanded(
      child: viewModel.sales.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 60,
                    color: AppColors.color2.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No sales found",
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.color2,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: viewModel.sales.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final sale = viewModel.sales[index];
                return _buildSaleItemCard(sale);
              },
            ),
    );
  }

  Widget _buildSummaryRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.color10,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.color10,
          ),
        ),
      ],
    );
  }

  Widget _buildSaleItemCard(sale) {
    return Card(
      elevation: 0,
      color: AppColors.color11,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.color2.withOpacity(0.1)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SellerSaleDetailPage(sale: sale),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.color2.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.shopping_bag,
                      color: AppColors.color2,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sale.itemName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppColors.color10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Payment: ${sale.paymentMethod}",
                          style: const TextStyle(color: AppColors.color2),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "RM ${sale.price.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.color13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sale.createdAt.toLocal().toString().split(' ')[0],
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.color10.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (sale.paymentMethod == "qr_code" && sale.receiptImage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      sale.receiptImage!,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable components 
InputDecoration appInputDecoration({
  required String labelText,
  required IconData prefixIcon,
}) {
  return InputDecoration(
    labelText: labelText,
    labelStyle: TextStyle(color: AppColors.color10.withOpacity(0.8)),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.color2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.color2.withOpacity(0.5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.color2, width: 2),
    ),
    filled: true,
    fillColor: AppColors.base.withOpacity(0.05),
    prefixIcon: Icon(prefixIcon, color: AppColors.color2),
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
  );
}

ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: AppColors.color2,
  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
);