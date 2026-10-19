import 'package:flutter/material.dart';
import '../models/coupon.dart';

class CouponCard extends StatelessWidget {
  final Coupon coupon;
  final bool isExpiringSoon;

  /// ⭐ NEW: highlights best coupon
  final bool highlight;

  const CouponCard({
    super.key,
    required this.coupon,
    required this.isExpiringSoon,
    this.highlight = false, // 👈 default = safe
  });

  /* -------------------- BRAND CONFIG -------------------- */

  Color get brandColor {
    switch (coupon.brand.toLowerCase()) {
      case 'amazon':
        return Colors.orange;
      case 'flipkart':
        return Colors.blue;
      case 'zomato':
        return Colors.red;
      case 'swiggy':
        return Colors.deepOrange;
      case 'myntra':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  IconData get brandIcon {
    switch (coupon.category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'shopping':
        return Icons.shopping_bag;
      default:
        return Icons.local_offer;
    }
  }

  /* -------------------- EXPIRY HELPERS -------------------- */

  int get daysLeft {
    final parts = coupon.expiryDate.split('/');
    final expiry = DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
    return expiry.difference(DateTime.now()).inDays;
  }

  Color get expiryColor {
    if (daysLeft <= 1) return Colors.red;
    if (daysLeft <= 3) return Colors.orange;
    return Colors.green;
  }

  String get expiryText {
    if (daysLeft < 0) return "Expired";
    if (daysLeft == 0) return "Expires today";
    if (daysLeft == 1) return "Expires tomorrow";
    return "Expires in $daysLeft days";
  }

  /* -------------------- UI -------------------- */

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(
            color: brandColor,
            width: highlight ? 6 : 4,
          ),
        ),

        // ⭐ GLOW EFFECT
        boxShadow: highlight
            ? [
                BoxShadow(
                  color: brandColor.withOpacity(0.35),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: brandColor.withOpacity(0.15),
          child: Icon(brandIcon, color: brandColor),
        ),

        title: Text(
          coupon.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: highlight ? Colors.white : Colors.white70,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),

            Text(
              coupon.code,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _pill(
                  text: coupon.category,
                  color: brandColor,
                ),
                _pill(
                  text: expiryText,
                  color: expiryColor,
                  icon: Icons.timer,
                ),
              ],
            ),
          ],
        ),

        trailing: IconButton(
          icon: const Icon(Icons.copy, color: Colors.white70),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Coupon code copied")),
            );
          },
        ),
      ),
    );
  }

  /* -------------------- PILL WIDGET -------------------- */

  Widget _pill({
    required String text,
    required Color color,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}