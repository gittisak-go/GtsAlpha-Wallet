import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GridMenu extends StatelessWidget {
  final Function(String title) onItemTap;

  const GridMenu({
    super.key,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'สแกนบาร์\nโค้ด',
        'icon': Icons.view_column_rounded,
        'color': AppTheme.gridBlue,
        'iconColor': Colors.blue,
      },
      {
        'title': 'สแกน\nธนบัตร',
        'icon': Icons.account_balance_wallet_rounded,
        'color': AppTheme.gridGreen,
        'iconColor': Colors.green,
      },
      {
        'title': 'สแกน\nเหรียญ',
        'icon': Icons.monetization_on_rounded,
        'color': AppTheme.gridBrown,
        'iconColor': Colors.orange,
      },
      {
        'title': 'สแกน\nอาหาร',
        'icon': Icons.fastfood_rounded,
        'color': AppTheme.gridRed,
        'iconColor': Colors.redAccent,
      },
      {
        'title': 'สแกน\nเอกสาร',
        'icon': Icons.description_rounded,
        'color': AppTheme.gridOrange,
        'iconColor': Colors.orangeAccent,
      },
      {
        'title': 'นามบัตร',
        'icon': Icons.contact_page_rounded,
        'color': AppTheme.gridTeal,
        'iconColor': Colors.tealAccent,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return GestureDetector(
          onTap: () => onItemTap(item['title'].replaceAll('\n', ' ')),
          child: Container(
            decoration: BoxDecoration(
              color: item['color'],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item['icon'],
                  size: 32,
                  color: item['iconColor'],
                ),
                const SizedBox(height: 12),
                Text(
                  item['title'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
