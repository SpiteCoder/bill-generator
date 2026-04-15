```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sale.dart';
import '../services/whatsapp_service.dart';
import '../widgets/app_widgets.dart';

class BillPreviewScreen extends StatefulWidget {
  final Sale sale;
  const BillPreviewScreen({super.key, required this.sale});

  @override
  State<BillPreviewScreen> createState() => _BillPreviewScreenState();
}

class _BillPreviewScreenState extends State<BillPreviewScreen> {
  final _phoneCtrl = TextEditingController();

  Future<void> _sendWhatsApp() async {
    try {
      await WhatsAppService.sendBill(
        sale: widget.sale,
        phoneNumber: _phoneCtrl.text.trim(),
      );
    } catch (e) {
      if (mounted) showError(context, e.toString());
    }
  }

  @override
  void dispose() { _phoneCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final s = widget.sale;
    final dateStr = DateFormat('dd MMM yyyy  •  hh:mm a').format(s.date);
    final currFmt = NumberFormat.currency(symbol: 'Rs ', decimalDigits: 2);

    return Scaffold(
      backgroundColor: const Color(0xFFF5FBF7),
      appBar: AppBar(
        title: const Text('Bill Preview'),
        actions: [
          TextButton.icon(
            onPressed: _sendWhatsApp,
            icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            label: const Text('Send',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(
                  color: const Color(0xFF4E7C59).withOpacity(0.12),
                  blurRadius: 24, offset: const Offset(0, 8),
                )],
              ),
              child: Column(children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4E7C59), Color(0xFF2D5016)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(children: [
                    const Text('🍄', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 8),
                    const Text('MUSHROOM SELLER', style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w900,
                      color: Colors.white, letterSpacing: 2,
                    )),
                    const SizedBox(height: 4),
                    Text('RECEIPT', style: TextStyle(
                      fontSize: 12, color: Colors.white.withOpacity(0.75), letterSpacing: 3,
                    )),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(dateStr, style: const TextStyle(
                        fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600,
                      )),
                    ),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(children: [
                    _BillRow(label: 'Customer', value: s.customerName, icon: Icons.person_rounded),
                    const Divider(color: Color(0xFFE0EDE5), thickness: 1, height: 24),
                    _BillRow(label: 'Mushroom Type', value: s.mushroomType, icon: Icons.eco_rounded),
                    const Divider(color: Color(0xFFE0EDE5), thickness: 1, height: 24),
                    _BillRow(label: 'Quantity', value: '${s.quantity.toStringAsFixed(2)} kg', icon: Icons.scale_rounded),
                    const Divider(color: Color(0xFFE0EDE5), thickness: 1, height: 24),
                    _BillRow(label: 'Rate / kg', value: currFmt.format(s.ratePerKg), icon: Icons.currency_rupee_rounded),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F7F2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFF4E7C59).withOpacity(0.3), width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('TOTAL', style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1B3A28),
                          )),
                          Text(currFmt.format(s.totalPrice), style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF4E7C59),
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('🙏  Thank you for your business!',
                        style: TextStyle(fontSize: 14, color: Color(0xFF4A7A5A),
                            fontStyle: FontStyle.italic)),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 28),
            const SectionHeading('SEND VIA WHATSAPP'),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                  color: Color(0xFF1B3A28)),
              decoration: InputDecoration(
                labelText: 'Phone Number (optional)',
                hintText: 'e.g. 919876543210',
                helperText: 'Country code + number, no + sign. Leave empty to pick from contacts.',
                helperMaxLines: 2,
                prefixIcon: const Icon(Icons.phone_rounded,
                    color: Color(0xFF4E7C59), size: 22),
                filled: true,
                fillColor: const Color(0xFFF0F7F2),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFA8D5B5), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF4E7C59), width: 2.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
            ),
            const SizedBox(height: 16),
            ActionButton(
              label: 'Send Bill on WhatsApp', icon: Icons.send_rounded,
              color: const Color(0xFF25D366), onTap: _sendWhatsApp,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _BillRow({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 19, color: const Color(0xFF4E7C59)),
      const SizedBox(width: 10),
      Expanded(child: Text(label, style: const TextStyle(
        fontSize: 14, color: Color(0xFF6B9B7A), fontWeight: FontWeight.w600,
      ))),
      Flexible(child: Text(value, textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
              color: Color(0xFF1B3A28)))),
    ]);
  }
}
```
