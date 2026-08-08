import 'package:flutter/material.dart';
// Import halaman yang dituju
import '../../dashboard/presentation/pages/delivery_address_page.dart';
import '../../dashboard/presentation/pages/settings_page.dart';

class MenuSection extends StatelessWidget {
  final Function(int)? onSwitchTab;
  
  const MenuSection({Key? key, this.onSwitchTab}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MenuItem(
          icon: Icons.assignment_outlined, 
          title: 'Order History', 
          onTap: () {
            if (onSwitchTab != null) {
              onSwitchTab!(2); 
            }
          },
        ),
        _MenuItem(
          icon: Icons.location_on_outlined, 
          title: 'Delivery Addresses',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DeliveryAddressPage())),
        ),
        _MenuItem(
          icon: Icons.settings_outlined, 
          title: 'Settings',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({Key? key, required this.icon, required this.title, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: Colors.black54),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.black26),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}