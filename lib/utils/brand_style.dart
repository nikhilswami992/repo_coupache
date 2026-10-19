import 'package:flutter/material.dart';
import '../models/coupon.dart';
import '../utils/brand_style.dart';

class CouponCard extends StatelessWidget {
  final Coupon coupon;
  final bool isExpiringSoon;

  const CouponCard({
    super.key,
    required this.coupon,
    required this.isExpiringSoon,
  });

  @override
  Widget build(BuildContext context) {
    final brandColor = BrandStyle.color(coupon.brand);

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: brandColor,
              width: 6,
            ),
          ),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: brandColor.withOpacity(0.15),
            child: Icon(
              BrandStyle.icon(coupon.brand),
              color: brandColor,
            ),
          ),
          title: Text(
            coupon.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(coupon.code),
              const SizedBox(height: 4),
              Text(
                isExpiringSoon
                    ? "⚠️ Expires soon"
                    : "Expires: ${coupon.expiryDate}",
                style: TextStyle(
                  color: isExpiringSoon
                      ? Colors.redAccent
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}