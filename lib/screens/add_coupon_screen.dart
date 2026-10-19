import 'package:flutter/material.dart';
import '../models/coupon.dart';

class AddCouponScreen extends StatefulWidget {
  const AddCouponScreen({super.key});

  @override
  State<AddCouponScreen> createState() => _AddCouponScreenState();
}

class _AddCouponScreenState extends State<AddCouponScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();

  String detectedBrand = 'Generic';
  String detectedCategory = 'Other';

  /* -------------------- AUTO DETECTION -------------------- */

  String detectBrand(String title, String code) {
    final text = (title + code).toLowerCase();

    if (text.contains('amazon')) return 'Amazon';
    if (text.contains('flipkart')) return 'Flipkart';
    if (text.contains('zomato')) return 'Zomato';
    if (text.contains('swiggy')) return 'Swiggy';
    if (text.contains('myntra')) return 'Myntra';

    return 'Generic';
  }

  String detectCategory(String brand) {
    switch (brand.toLowerCase()) {
      case 'amazon':
      case 'flipkart':
      case 'myntra':
        return 'Shopping';
      case 'zomato':
      case 'swiggy':
        return 'Food';
      default:
        return 'Other';
    }
  }

  void _updateDetection() {
    final brand =
        detectBrand(titleController.text, codeController.text);
    final category = detectCategory(brand);

    setState(() {
      detectedBrand = brand;
      detectedCategory = category;
    });
  }

  /* -------------------- UI -------------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Coupon")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Coupon Title",
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _updateDetection(),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: "Coupon Code",
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _updateDetection(),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: expiryController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Expiry Date",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate:
                      DateTime.now().add(const Duration(days: 365 * 5)),
                );

                if (pickedDate != null) {
                  expiryController.text =
                      "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                }
              },
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Chip(label: Text("Brand: $detectedBrand")),
                const SizedBox(width: 10),
                Chip(label: Text("Category: $detectedCategory")),
              ],
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (titleController.text.isEmpty ||
                      codeController.text.isEmpty ||
                      expiryController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please fill all fields"),
                      ),
                    );
                    return;
                  }

                  final coupon = Coupon(
                    title: titleController.text,
                    code: codeController.text,
                    expiryDate: expiryController.text,
                    brand: detectedBrand,
                    category: detectedCategory,
                  );

                  Navigator.pop(context, coupon);
                },
                child: const Text("Save Coupon"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}