```dart
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/sale.dart';

class ExcelService {
  static Future<void> exportSales(List<Sale> sales) async {
    if (sales.isEmpty) throw Exception('No sales data to export.');

    final excel = Excel.createExcel();
    excel.delete('Sheet1');
    final Sheet sheet = excel['Sales Report'];

    final headers = [
      'Date', 'Customer Name', 'Mushroom Type',
      'Quantity (kg)', 'Rate/kg (Rs)', 'Total (Rs)',
    ];

    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#4E7C59'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      horizontalAlign: HorizontalAlign.Center,
    );

    for (int col = 0; col < headers.length; col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0),
      );
      cell.value = TextCellValue(headers[col]);
      cell.cellStyle = headerStyle;
    }

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final altStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#F0F7F2'),
    );

    for (int i = 0; i < sales.length; i++) {
      final sale = sales[i];
      final rowData = [
        dateFormat.format(sale.date),
        sale.customerName,
        sale.mushroomType,
        sale.quantity.toStringAsFixed(2),
        sale.ratePerKg.toStringAsFixed(2),
        sale.totalPrice.toStringAsFixed(2),
      ];
      for (int col = 0; col < rowData.length; col++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: i + 1),
        );
        cell.value = TextCellValue(rowData[col]);
        if (i % 2 == 1) cell.cellStyle = altStyle;
      }
    }

    final totalRow = sales.length + 2;
    final grandTotal = sales.fold<double>(0.0, (sum, s) => sum + s.totalPrice);
    final totalStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#D4EDDA'),
    );

    final labelCell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: totalRow),
    );
    labelCell.value = const TextCellValue('GRAND TOTAL');
    labelCell.cellStyle = totalStyle;

    final totalCell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: totalRow),
    );
    totalCell.value = TextCellValue('Rs ${grandTotal.toStringAsFixed(2)}');
    totalCell.cellStyle = totalStyle;

    final bytes = excel.encode();
    if (bytes == null) throw Exception('Failed to encode Excel file.');

    final dir = await getTemporaryDirectory();
    final fileName =
        'MushroomSales_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Mushroom Sales Report',
      text: 'Sales report attached.',
    );
  }
}
```
