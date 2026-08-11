import 'package:flutter/material.dart';
import 'package:restauran_app/core/theme/app_colors.dart';
import 'package:restauran_app/core/services/language_service.dart';
import 'package:restauran_app/core/widgets/animated_touchable.dart';

class VoucherItem {
  final String code;
  final String title;
  final String description;
  final String discountType; // 'percent' or 'fixed'
  final double discountValue; // e.g. 10 for 10%, 20000 for Rp 20.000

  VoucherItem({
    required this.code,
    required this.title,
    required this.description,
    required this.discountType,
    required this.discountValue,
  });

  double calculateDiscount(double subtotal) {
    if (discountType == 'percent') {
      return (subtotal * (discountValue / 100)).clamp(0, subtotal);
    } else {
      return discountValue.clamp(0, subtotal);
    }
  }
}

class VoucherBottomSheet extends StatefulWidget {
  final double currentSubtotal;
  final String? appliedVoucherCode;

  const VoucherBottomSheet({
    Key? key,
    required this.currentSubtotal,
    this.appliedVoucherCode,
  }) : super(key: key);

  @override
  State<VoucherBottomSheet> createState() => _VoucherBottomSheetState();
}

class _VoucherBottomSheetState extends State<VoucherBottomSheet> {
  final _codeController = TextEditingController();
  String? _errorMsg;

  final List<VoucherItem> _availableVouchers = [
    VoucherItem(
      code: 'DISCOUNT10',
      title: 'Diskon 10% Semua Menu',
      description: 'Potongan 10% tanpa minimal belanja',
      discountType: 'percent',
      discountValue: 10,
    ),
    VoucherItem(
      code: 'MAGICFOOD20K',
      title: 'Potongan Rp 20.000',
      description: 'Hemat 20rb khusus pesanan spesial',
      discountType: 'fixed',
      discountValue: 20000,
    ),
    VoucherItem(
      code: 'FREESHIP',
      title: 'Gratis Ongkir Rp 10.000',
      description: 'Potongan ongkos kirim Rp 10.000',
      discountType: 'fixed',
      discountValue: 10000,
    ),
  ];

  void _applyCode(String inputCode) {
    final codeClean = inputCode.trim().toUpperCase();
    final match = _availableVouchers.firstWhere(
      (v) => v.code == codeClean,
      orElse: () => VoucherItem(code: '', title: '', description: '', discountType: 'fixed', discountValue: 0),
    );

    if (match.code.isNotEmpty) {
      Navigator.pop(context, match);
    } else {
      setState(() {
        _errorMsg = LanguageService.instance.tr('voucher_invalid');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.instance;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 20,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lang.tr('voucher_promo'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 12),

            // Input field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: lang.tr('enter_voucher_code'),
                      filled: true,
                      fillColor: Colors.grey[100],
                      errorText: _errorMsg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedTouchable(
                  onTap: () => _applyCode(_codeController.text),
                  child: ElevatedButton(
                    onPressed: () => _applyCode(_codeController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                    child: Text(
                      lang.tr('apply'),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              'Voucher Tersedia',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _availableVouchers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final v = _availableVouchers[index];
                  final isSelected = widget.appliedVoucherCode == v.code;
                  final discountCalc = v.calculateDiscount(widget.currentSubtotal);

                  return AnimatedTouchable(
                    onTap: () => Navigator.pop(context, v),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withOpacity(0.06) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.grey[300]!,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.confirmation_number_outlined, color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  v.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  v.description,
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '-Rp ${discountCalc.toInt()}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: 14,
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
