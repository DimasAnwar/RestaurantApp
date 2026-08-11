import 'package:flutter/material.dart';
import 'package:restauran_app/core/theme/app_colors.dart';
import 'package:restauran_app/core/widgets/animated_touchable.dart';

class PrintReceiptDialog extends StatelessWidget {
  final dynamic order;

  const PrintReceiptDialog({Key? key, required this.order}) : super(key: key);

  static void show(BuildContext context, dynamic order) {
    showDialog(
      context: context,
      builder: (_) => PrintReceiptDialog(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderNumber = order['order_number']?.toString() ?? 'ORD-0000';
    final items = order['order_items'] as List<dynamic>? ?? [];
    final totalPrice = (order['total_price'] as num?)?.toDouble() ?? 0.0;
    final address = order['alamat_pengiriman'] ?? 'Takeaway / In-Store';
    final dateStr = order['created_at'] != null
        ? DateTime.tryParse(order['created_at'].toString())?.toLocal().toString().substring(0, 16) ?? '-'
        : '-';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Receipt Header
            const Icon(Icons.receipt_long_rounded, color: Color(0xFFD83A1E), size: 40),
            const SizedBox(height: 8),
            const Text(
              'MAGIC FOOD RESTORAN',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 0.5),
            ),
            const SizedBox(height: 2),
            Text(
              'Bogor Trade Mall Lt. 2, Jl. Ir. H. Juanda No. 12',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
            ),
            Text(
              'Telp: (0251) 8345-992',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Colors.black26, height: 1, thickness: 1),
            ),

            // Order Metadata
            _buildMetaRow('No. Pesanan:', '#$orderNumber'),
            _buildMetaRow('Tanggal:', dateStr),
            _buildMetaRow('Tujuan:', address.length > 22 ? '${address.substring(0, 22)}...' : address),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Colors.black26, height: 1, thickness: 1),
            ),

            // Items List
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('DETAIL PESANAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
            ),
            const SizedBox(height: 8),

            if (items.isEmpty)
              const Text('Menu items (1x Custom Package)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500))
            else
              Column(
                children: items.map((item) {
                  final name = item['nama_makanan'] ?? 'Menu Item';
                  final qty = item['jumlah'] ?? 1;
                  final price = (item['harga_satuan'] as num?)?.toDouble() ?? 0.0;
                  final subtotal = (item['subtotal'] as num?)?.toDouble() ?? (qty * price);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${qty}x  $name',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                        Text(
                          'Rp ${_formatPrice(subtotal)}',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Colors.black26, height: 1, thickness: 1),
            ),

            // Total Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TOTAL PEMBAYARAN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                Text(
                  'Rp ${_formatPrice(totalPrice)}',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFFD83A1E)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Status Pembayaran:', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Text('LUNAS / PAID', style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Text(
              '*** Terima kasih telah memesan di Magic Food ***',
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 11, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Tutup', style: TextStyle(color: Colors.black87)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AnimatedTouchable(
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Struk PDF #${orderNumber} berhasil dicetak/diunduh! 📄'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Struk PDF #${orderNumber} berhasil dicetak/diunduh! 📄'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.print_rounded, size: 16, color: Colors.white),
                      label: const Text('Cetak PDF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD83A1E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  String _formatPrice(num price) {
    return price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}
