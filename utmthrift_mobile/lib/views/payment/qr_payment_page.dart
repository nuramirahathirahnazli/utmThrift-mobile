// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:utmthrift_mobile/viewmodels/qrpayment_viewmodel.dart';
import 'package:utmthrift_mobile/views/order/order_history_page.dart';

class QRPaymentPage extends StatefulWidget {
  final int orderId;
  final int sellerId;

  const QRPaymentPage({super.key, required this.orderId, required this.sellerId});

  @override
  State<QRPaymentPage> createState() => _QRPaymentPageState();
}

class _QRPaymentPageState extends State<QRPaymentPage> {
  File? _receiptFile;

  @override
  void initState() {
    super.initState();
    _loadQrCode(); // call async-safe method
  }

  void _loadQrCode() async {
    await Future.delayed(Duration.zero); // ensures context is ready
    print('[QRPaymentPage] Fetching QR for sellerId: ${widget.sellerId}');
    Provider.of<QRPaymentViewModel>(context, listen: false)
        .fetchQrCode(widget.sellerId);
  }

  Future<void> _pickReceipt() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _receiptFile = File(picked.path);
      });
    }
  }

  Future<void> _submitPayment() async {
    if (_receiptFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload receipt")),
      );
      return;
    }

    final vm = Provider.of<QRPaymentViewModel>(context, listen: false);
    final success = await vm.uploadReceipt(widget.orderId, _receiptFile!);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Receipt uploaded successfully")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OrderHistoryPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QRPaymentViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          appBar: AppBar(title: const Text("QR Payment")),
          body: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (vm.qrCodeImageUrl != null)
                        Image.network(vm.qrCodeImageUrl!)
                      else
                        const Text("QR Code not found"),

                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _pickReceipt,
                        child: const Text("Upload Receipt"),
                      ),
                      if (_receiptFile != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.file(_receiptFile!, height: 120),
                        ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: vm.isUploading ? null : _submitPayment,
                        child: vm.isUploading
                            ? const CircularProgressIndicator()
                            : const Text("Done Payment"),
                      ),
                    ],
                  ),
                ),
              ),
        );
      },
    );
  }
}
