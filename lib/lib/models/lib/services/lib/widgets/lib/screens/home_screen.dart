```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/sale.dart';
import '../services/sales_store.dart';
import '../services/whatsapp_service.dart';
import '../widgets/app_widgets.dart';
import 'bill_preview_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _mushroomCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();

  double _totalPrice = 0.0;
  bool _isSaving = false;
  Sale? _lastSavedSale;
  String? _selectedMushroomType;

  final List<String> _mushroomTypes = [
    'Button Mushroom', 'Oyster Mushroom', 'Shiitake Mushroom',
    'Portobello Mushroom', 'Cremini Mushroom', 'Enoki Mushroom',
    'Chanterelle Mushroom',
  ];

  void _calculateTotal() {
    final qty = double.tryParse(_quantityCtrl.text) ?? 0.0;
    final rate = double.tryParse(_rateCtrl.text) ?? 0.0;
    setState(() => _totalPrice = qty * rate);
  }

  Future<Sale?> _saveSale() async {
    if (!_formKey.currentState!.validate()) return null;
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 400));
    final sale = Sale(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerName: _nameCtrl.text.trim(),
      mushroomType: _mushroomCtrl.text.trim(),
      quantity: double.parse(_quantityCtrl.text),
      ratePerKg: double.parse(_rateCtrl.text),
      totalPrice: _totalPrice,
      date: DateTime.now(),
    );
    SalesStore.instance.add(sale);
    if (mounted) setState(() => _isSaving = false);
    return sale;
  }

  Future<void> _onGenerateBill() async {
    final sale = await _saveSale();
    if (sale == null || !mounted) return;
    setState(() => _lastSavedSale = sale);
    showSuccess(context, 'Bill generated successfully!');
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => BillPreviewScreen(sale: sale)));
  }

  Future<void> _onSendWhatsApp() async {
    Sale? sale = _lastSavedSale;
    if (sale == null) {
      sale = await _saveSale();
      if (sale == null || !mounted) return;
      setState(() => _lastSavedSale = sale);
    }
    try {
      await WhatsAppService.sendBill(sale: sale);
    } catch (e) {
      if (mounted) showError(context, e.toString());
    }
  }

  void _clearForm() {
    _nameCtrl.clear();
    _mushroomCtrl.clear();
    _quantityCtrl.clear();
    _rateCtrl.clear();
    setState(() {
      _totalPrice = 0.0;
      _lastSavedSale = null;
      _selectedMushroomType = null;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mushroomCtrl.dispose();
    _quantityCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  static final _decimalFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'));

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(symbol: 'Rs ', decimalDigits: 2);

    return Scaffold(
      backgroundColor: const Color(0xFFF5FBF7),
      appBar: AppBar(
        title: const Text('🍄  Mushroom Seller'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Sales History',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const HistoryScreen())),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4E7C59).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFF4E7C59).withOpacity(0.3)),
                    ),
                    child: Text(
                      DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                      style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: Color(0xFF4E7C59),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const SectionHeading('CUSTOMER DETAILS'),
                BigTextField(
                  label: 'Customer Name', hint: 'e.g. Ramesh Kumar',
                  icon: Icons.person_rounded, controller: _nameCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter customer name' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedMushroomType,
                  decoration: InputDecoration(
                    labelText: 'Mushroom Type',
                    prefixIcon: const Icon(Icons.eco_rounded,
                        color: Color(0xFF4E7C59), size: 22),
                    filled: true,
                    fillColor: const Color(0xFFF0F7F2),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: Color(0xFFA8D5B5), width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: Color(0xFF4E7C59), width: 2.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: Colors.redAccent, width: 1.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: Colors.redAccent, width: 2.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 18),
                  ),
                  hint: const Text('Select mushroom type'),
                  isExpanded: true,
                  items: _mushroomTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (val) {
                    setState(() => _selectedMushroomType = val);
                    if (val != null) _mushroomCtrl.text = val;
                  },
                  validator: (_) => _mushroomCtrl.text.trim().isEmpty
                      ? 'Please select mushroom type' : null,
                ),
                const SizedBox(height: 10),
                BigTextField(
                  label: 'Or type a custom mushroom name',
                  hint: 'e.g. King Oyster',
                  icon: Icons.edit_rounded, controller: _mushroomCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter mushroom type' : null,
                ),
                const SizedBox(height: 28),
                const SectionHeading('PRICING'),
                Row(
                  children: [
                    Expanded(
                      child: BigTextField(
                        label: 'Quantity (kg)', hint: '0.00',
                        icon: Icons.scale_rounded, controller: _quantityCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [_decimalFormatter],
                        onChanged: (_) => _calculateTotal(),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          if ((double.tryParse(v) ?? 0) <= 0) return 'Enter valid qty';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BigTextField(
                        label: 'Rate / kg (Rs)', hint: '0.00',
                        icon: Icons.currency_rupee_rounded, controller: _rateCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [_decimalFormatter],
                        onChanged: (_) => _calculateTotal(),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          if ((double.tryParse(v) ?? 0) <= 0) return 'Enter valid rate';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4E7C59), Color(0xFF2D5016)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4E7C59).withOpacity(0.35),
                        blurRadius: 16, offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(children: [
                    const Text('TOTAL AMOUNT',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                            color: Colors.white70, letterSpacing: 1.5)),
                    const SizedBox(height: 8),
                    Text(currencyFmt.format(_totalPrice),
                        style: const TextStyle(fontSize: 38,
                            fontWeight: FontWeight.w900, color: Colors.white)),
                  ]),
                ),
                const SizedBox(height: 32),
                const SectionHeading('ACTIONS'),
                ActionButton(
                  label: 'Generate Bill', icon: Icons.receipt_long_rounded,
                  color: const Color(0xFF4E7C59),
                  onTap: _onGenerateBill, loading: _isSaving,
                ),
                const SizedBox(height: 12),
                ActionButton(
                  label: 'Send Bill on WhatsApp', icon: Icons.send_rounded,
                  color: const Color(0xFF25D366), onTap: _onSendWhatsApp,
                ),
                const SizedBox(height: 12),
                ActionButton(
                  label: 'Clear / New Sale', icon: Icons.refresh_rounded,
                  color: Colors.blueGrey, onTap: _clearForm,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 58, width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF4E7C59), width: 2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      foregroundColor: const Color(0xFF4E7C59),
                    ),
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const HistoryScreen())),
                    icon: const Icon(Icons.bar_chart_rounded, size: 22),
                    label: const Text('View Sales History',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```
