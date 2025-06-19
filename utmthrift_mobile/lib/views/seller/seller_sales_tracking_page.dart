import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utmthrift_mobile/viewmodels/sellersale_viewmodel.dart';
import 'package:utmthrift_mobile/views/seller/seller_sales_details_track_page.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';

class SalesTrackingPage extends StatefulWidget {
  final int sellerId;

  const SalesTrackingPage({super.key, required this.sellerId});

  @override
  State<SalesTrackingPage> createState() => _SalesTrackingPageState();
}

class _SalesTrackingPageState extends State<SalesTrackingPage> {
  int? _selectedMonth;
  int? _selectedYear;
  
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
        title: const Text('Sales Tracking',
            style: TextStyle(color: AppColors.color10)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.color1, // Orange
        iconTheme: const IconThemeData(color: AppColors.color10), // Black icons
      ),
      body: Consumer<SellerSaleViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.color1), // Orange
              ),
            );
          }

          final summary = viewModel.summary;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Month Dropdown
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'Month',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedMonth,
                        items: List.generate(12, (index) {
                          return DropdownMenuItem(
                            value: index + 1,
                            child: Text('${index + 1}'.padLeft(2, '0')),
                          );
                        }),
                        onChanged: (value) {
                          setState(() => _selectedMonth = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Year Dropdown
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'Year',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedYear,
                        items: List.generate(5, (index) {
                          final year = 2025 + index;
                          return DropdownMenuItem(value: year, child: Text('$year'));
                        }),

                        onChanged: (value) {
                          setState(() => _selectedYear = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Filter Button
                    Column(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.color1, // Orange
                          ),
                          onPressed: () {
                            Provider.of<SellerSaleViewModel>(context, listen: false)
                                .fetchSales(widget.sellerId, month: _selectedMonth, year: _selectedYear);
                          },
                          child: const Text('Filter'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedMonth = null;
                              _selectedYear = null;
                            });
                            Provider.of<SellerSaleViewModel>(context, listen: false)
                                .fetchSales(widget.sellerId); // fetch all
                          },
                          child: const Text('Clear Filter'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Summary Card
              if (summary != null)
                Card(
                  margin: const EdgeInsets.all(16),
                  elevation: 2,
                  color: AppColors.color12, // Light Yellow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppColors.color3.withOpacity(0.3)), // Soft Pink border
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, 
                                color: AppColors.color2, size: 20), // Dark Pink
                            const SizedBox(width: 8),
                            Text(
                              summary['month'] ?? 'N/A',
                              style: const TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.color2), // Dark Pink
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.shopping_cart, 
                                color: AppColors.color7, size: 20), // Blue
                            const SizedBox(width: 8),
                            Text(
                              "Items Sold: ${summary['items_sold']}",
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.color10), // Black
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.attach_money, 
                                color: AppColors.color6, size: 20), // Green
                            const SizedBox(width: 8),
                            Text(
                              "Total Sales: RM ${summary['total_revenue']?.toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.color10), // Black
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              // Sales List
              Expanded(
                child: viewModel.sales.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long,
                                size: 60, color: AppColors.color3), // Soft Pink
                            SizedBox(height: 16),
                            Text(
                              "No sales found",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.color2), // Dark Pink
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: viewModel.sales.length,
                        itemBuilder: (context, index) {
                          final sale = viewModel.sales[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            elevation: 1,
                            color: AppColors.color11, // Light Pink
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: AppColors.color3.withOpacity(0.3)), // Soft Pink border
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SellerSaleDetailPage(sale: sale),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    // Item icon
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.color2.withOpacity(0.1), // Dark Pink
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.shopping_bag,
                                          color: AppColors.color2), // Dark Pink
                                    ),
                                    const SizedBox(width: 16),
                                    // Item details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            sale.itemName,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                color: AppColors.color10), // Black
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Payment: ${sale.paymentMethod}",
                                            style: const TextStyle(
                                                color: AppColors.color2), // Dark Pink
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Date: ${sale.createdAt.toLocal().toString().split(' ')[0]}",
                                            style: const TextStyle(
                                                color: AppColors.color2), // Dark Pink
                                          ),
                                          if (sale.paymentMethod == "qr_code" &&
                                              sale.receiptImage != null)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
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
                                    // Price
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "RM ${sale.price.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(153, 12, 138, 25), // Green
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Icon(Icons.chevron_right,
                                            color: AppColors.color2), // Dark Pink
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}