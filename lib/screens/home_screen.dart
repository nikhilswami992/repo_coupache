import 'package:flutter/material.dart';

import '../models/coupon.dart';
import '../repositories/coupon_repository.dart';
import '../services/coupon_ranker.dart';
import '../services/notification_service.dart';
import '../context/app_launch_context.dart';
import '../widgets/coupon_card.dart';
import 'add_coupon_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Coupon> coupons = [];
  bool isLoading = true;

  String searchQuery = '';
  String selectedCategory = 'All';

  Coupon? bestPick; // ⭐ NEW

  /* -------------------- INIT -------------------- */

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    setState(() => isLoading = true);

    final loaded = await CouponRepository.getCoupons();

    setState(() {
      coupons = loaded;
      bestPick = CouponRanker.pickBest(
        coupons: loaded,
      );
      isLoading = false;

      // 🔥 Apply context if app opened via notification
      _applyLaunchContext();
    });
  }

  /* -------------------- CONTEXT HANDLING -------------------- */

  void _applyLaunchContext() {
    if (!AppLaunchContext.hasContext) return;

    final context = AppLaunchContext.get();
    debugPrint('🎯 Applying launch context: $context');

    if (context == 'shopping_amazon' ||
        context == 'shopping_flipkart') {
      selectedCategory = 'Shopping';
    } else if (context == 'food_ordering') {
      selectedCategory = 'Food';
    }

    if (context == 'shopping_amazon') {
      searchQuery = 'amazon';
    } else if (context == 'food_ordering') {
      searchQuery = 'zomato';
    }

    AppLaunchContext.clear();
  }

  /* -------------------- HELPERS -------------------- */

  int daysLeft(String expiryDate) {
    final parts = expiryDate.split('/');
    final expiry = DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
    return expiry.difference(DateTime.now()).inDays;
  }

  List<Coupon> get filteredCoupons {
    return coupons.where((coupon) {
      final q = searchQuery.toLowerCase();

      final matchesSearch =
          coupon.title.toLowerCase().contains(q) ||
          coupon.code.toLowerCase().contains(q) ||
          coupon.brand.toLowerCase().contains(q);

      final matchesCategory =
          selectedCategory == 'All' ||
          coupon.category == selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  Map<String, List<Coupon>> groupByCategory(List<Coupon> list) {
    final Map<String, List<Coupon>> grouped = {};

    for (final coupon in list) {
      // ⛔ avoid duplicate best pick
      if (bestPick != null && coupon == bestPick) continue;

      grouped.putIfAbsent(coupon.category, () => []);
      grouped[coupon.category]!.add(coupon);
    }

    for (final items in grouped.values) {
      items.sort(
        (a, b) =>
            daysLeft(a.expiryDate).compareTo(daysLeft(b.expiryDate)),
      );
    }

    return grouped;
  }

  /* -------------------- NOTIFICATIONS -------------------- */

  Future<void> scheduleCouponNotifications(
    Coupon coupon,
    int index,
  ) async {
    final parts = coupon.expiryDate.split('/');
    final expiry = DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );

    final reminders = [7, 3, 1];
    int offset = 0;

    for (final days in reminders) {
      final date = expiry.subtract(Duration(days: days));
      if (date.isAfter(DateTime.now())) {
        NotificationService.scheduleNotification(
          id: index * 10 + offset,
          title: 'Coupon expiring soon',
          body: '${coupon.title} expires in $days day(s)',
          scheduledDate: date,
        );
        offset++;
      }
    }
  }

  void cancelCouponNotifications(int index) {
    for (int i = 0; i < 3; i++) {
      NotificationService.cancel(index * 10 + i);
    }
  }

  /* -------------------- UI -------------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Coupons'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCoupons,
              child: ListView(
                children: [
                  _buildSearch(),
                  _buildFilters(),

                  if (bestPick != null)
                    _buildBestPick(bestPick!),

                  ..._buildGroupedCoupons(filteredCoupons),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final coupon = await Navigator.push<Coupon>(
            context,
            MaterialPageRoute(
              builder: (_) => AddCouponScreen(),
            ),
          );

          if (coupon != null) {
            final updated =
                await CouponRepository.addCoupon(
              coupons,
              coupon,
            );

            setState(() {
              coupons = updated;
              bestPick = CouponRanker.pickBest(
                coupons: updated,
              );
            });

            await scheduleCouponNotifications(
              coupon,
              coupons.length - 1,
            );
          }
        },
      ),
    );
  }

  /* -------------------- WIDGETS -------------------- */

  Widget _buildSearch() => Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search coupons...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (v) =>
              setState(() => searchQuery = v),
        ),
      );

  Widget _buildFilters() => SizedBox(
        height: 42,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding:
              const EdgeInsets.symmetric(horizontal: 16),
          children: ['All', 'Shopping', 'Food']
              .map(
                (cat) => Padding(
                  padding:
                      const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: selectedCategory == cat,
                    onSelected: (_) =>
                        setState(() => selectedCategory = cat),
                  ),
                ),
              )
              .toList(),
        ),
      );

  Widget _buildBestPick(Coupon coupon) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              '🔥 Best Pick for You',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          CouponCard(
            coupon: coupon,
            isExpiringSoon:
                daysLeft(coupon.expiryDate) <= 2,
            highlight: true, // ⭐ add glow in widget
          ),
        ],
      );

  List<Widget> _buildGroupedCoupons(List<Coupon> list) {
    final grouped = groupByCategory(list);

    return grouped.entries.map((entry) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              entry.key,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...entry.value.asMap().entries.map((e) {
            final index = e.key;
            final coupon = e.value;

            return Dismissible(
              key: Key(coupon.code),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) async {
                cancelCouponNotifications(index);
                final updated =
                    await CouponRepository.deleteCoupon(
                  coupons,
                  coupon,
                );
                setState(() => coupons = updated);
              },
              child: CouponCard(
                coupon: coupon,
                isExpiringSoon:
                    daysLeft(coupon.expiryDate) <= 2,
              ),
            );
          }),
        ],
      );
    }).toList();
  }
}