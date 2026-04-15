```dart
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../models/sale.dart';

class WhatsAppService {
  static Future<void> sendBill({
    required Sale sale,
    String phoneNumber = '',
  }) async {
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(sale.date);

    final message = '🍄 *MUSHROOM BILL* 🍄\n'
        '━━━━━━━━━━━━━━━━━━━━━\n'
        '📅 Date: $dateStr\n\n'
        '👤 Customer: ${sale.customerName}\n'
        '🌿 Mushroom Type: ${sale.mushroomType}\n'
        '⚖️ Quantity: ${sale.quantity.toStringAsFixed(2)} kg\n'
        '💰 Rate: Rs ${sale.ratePerKg.toStringAsFixed(2)} / kg\n'
        '━━━━━━━━━━━━━━━━━━━━━\n'
        '💵 *TOTAL: Rs ${sale.totalPrice.toStringAsFixed(2)}*\n'
        '━━━━━━━━━━━━━━━━━━━━━\n'
        'Thank you for your purchase! 🙏';

    final encoded = Uri.encodeComponent(message);
    final urlString = phoneNumber.isEmpty
        ? 'https://wa.me/?text=$encoded'
        : 'https://wa.me/$phoneNumber?text=$encoded';

    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception(
        'Could not open WhatsApp. Make sure it is installed.',
      );
    }
  }
}
```
