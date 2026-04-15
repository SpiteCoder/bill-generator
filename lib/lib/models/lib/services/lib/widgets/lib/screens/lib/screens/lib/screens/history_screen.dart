```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sale.dart';
import '../services/sales_store.dart';
import '../services/excel_service.dart';
import '../widgets/app_widgets.dart';
import 'bill_preview_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isExporting = false;

  List<Sale> get _sales => SalesStore.instance.getAll();

  Future<void> _exportToExcel() async {
    final sales = _sales;
    if (sales.isEmpty) { showError(context, 'No sales to export yet.'); return; }
    setState(() => _isExporting = true);
    try {
      await ExcelService.exportSales(sales);
      if (mounted) showSuccess(context, 'Excel file ready to share!');
    } catch (e) {
      if (mounted) showError(context, 'Export failed: $e');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _confirmDelete(Sale sale) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Sale?'),
        content: Text('Delete bill for ${sale.customerName}?\nThis cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent,
                minimumSize: const Size(80, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      SalesStore.instance.delete(sale.id);
      if (mounted) { setState(() {}); showSuccess(context, 'Sale deleted.'); }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sales = _sales;
    final currFmt = NumberFormat.currency(symbol: 'Rs ', decimalDigits: 2);
    final dateFmt = DateFormat('dd MMM yyyy');
    final timeFmt = DateFormat('hh:mm a');

    return Scaffold(
      backgroundColor: const Color(0xFFF5FBF7),
      appBar: AppBar(title: const Text('Sales History')),
      body: sales.isEmpty
          ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('🍄', style: TextStyle(fontSize: 72)),
              SizedBox(height: 16),
              Text('No sales yet.', style: TextStyle(fontSize: 20,
                  fontWeight: FontWeight.w700, color: Color(0xFF4E7C59))),
              SizedBox(height: 8),
              Text('Create your first bill from the home screen.',
                  style: TextStyle(color: Color(0xFF6B9B7A), fontSize: 14),
                  textAlign: TextAlign.center),
            ]))
          : Column(children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4E7C59), Color(0xFF2D5016)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: const Color(0xFF4E7C59).withOpacity(0.3),
                      blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('TOTAL REVENUE', style: TextStyle(fontSize: 11,
                          fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      Text(currFmt.format(sales.fold<double>(0.0, (s, e) => s + e.totalPrice)),
                          style: const TextStyle(fontSize: 26,
                              fontWeight: FontWeight.w900, color: Colors.white)),
                    ]),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      const Text('TOTAL SALES', style: TextStyle(fontSize: 11,
                          fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      Text('${sales.length}', style: const TextStyle(fontSize: 26,
                          fontWeight: FontWeight.w900, color: Colors.white)),
                    ]),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ActionButton(
                  label: 'Export to Excel', icon: Icons.file_download_rounded,
                  color: const Color(0xFF217346),
                  onTap: _isExporting ? null : _exportToExcel, loading: _isExporting,
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Swipe left on a sale to delete it',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  itemCount: sales.length,
                  itemBuilder: (ctx, i) {
                    final sale = sales[i];
                    return Dismissible(
                      key: Key(sale.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(20)),
                        child: const Icon(Icons.delete_rounded, color: Colors.red, size: 28),
                      ),
                      confirmDismiss: (_) async { await _confirmDelete(sale); return false; },
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => BillPreviewScreen(sale: sale))),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white, borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(
                                color: const Color(0xFF4E7C59).withOpacity(0.07),
                                blurRadius: 12, offset: const Offset(0, 4))],
                          ),
                          child: Row(children: [
                            Container(
                              width: 50, height: 50,
                              decoration: BoxDecoration(color: const Color(0xFFF0F7F2),
                                  borderRadius: BorderRadius.circular(14)),
                              alignment: Alignment.center,
                              child: const Text('🍄', style: TextStyle(fontSize: 24)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(sale.customerName, style: const TextStyle(fontSize: 15,
                                    fontWeight: FontWeight.w700, color: Color(0xFF1B3A28))),
                                const SizedBox(height: 3),
                                Text('${sale.mushroomType}  •  ${sale.quantity.toStringAsFixed(1)} kg',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B9B7A))),
                                const SizedBox(height: 2),
                                Text('${dateFmt.format(sale.date)}  ${timeFmt.format(sale.date)}',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            )),
                            const SizedBox(width: 8),
                            Text(currFmt.format(sale.totalPrice), style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800,
                                color: Color(0xFF4E7C59))),
                            const Icon(Icons.chevron_right_rounded, color: Color(0xFFA8D5B5)),
                          ]),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ]),
    );
  }
}
```
