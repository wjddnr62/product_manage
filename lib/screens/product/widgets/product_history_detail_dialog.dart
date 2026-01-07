import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rehabiltiation/models/product_model.dart';

class ProductHistoryDetailDialog extends StatelessWidget {
  const ProductHistoryDetailDialog({
    super.key,
    required this.product,
    required this.userMap,
  });

  final Product product;
  final Map<String, String> userMap;

  String _getStatusText(Product product) {
    if (product.status == 'rented' && product.returnDate != null && product.returnDate!.isBefore(DateTime.now())) {
      return '연체중';
    }
    switch (product.status) {
      case 'available':
        return '재고있음';
      case 'rented':
        return '대여중';
      case 'sold':
        return '판매완료';
      default:
        return product.status;
    }
  }

  int _calculateOverdueDays(DateTime returnDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final returnDay = DateTime(returnDate.year, returnDate.month, returnDate.day);
    if (today.isBefore(returnDay)) return 0;
    return today.difference(returnDay).inDays;
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('yyyy-MM-dd');
    final currencyFormatter = NumberFormat('#,###');
    final statusText = _getStatusText(product);
    final registeredByName = userMap[product.registeredBy] ?? '알 수 없음';

    return AlertDialog(
      title: Text(product.name),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('상태', statusText),
            _buildDetailRow('종류', '${product.type} / ${product.gender} / ${product.size}'),
            _buildDetailRow('가격', '${currencyFormatter.format(product.price)}원'),
            
            if (statusText == '연체중') ...[
              const Divider(),
              _buildDetailRow('대여자', product.rentedToName ?? '-'),
              _buildDetailRow('대여일', product.rentedDate != null ? formatter.format(product.rentedDate!.toLocal()) : '-'),
              _buildDetailRow('반납예정일', product.returnDate != null ? formatter.format(product.returnDate!.toLocal()) : '-'),
              _buildDetailRow('연체정보', '${_calculateOverdueDays(product.returnDate!)}일 / ${currencyFormatter.format(_calculateOverdueDays(product.returnDate!) * 10000)}원'),
            ] else if (product.status == 'rented') ...[
              const Divider(),
              _buildDetailRow('대여자', product.rentedToName ?? '-'),
              _buildDetailRow('대여일', product.rentedDate != null ? formatter.format(product.rentedDate!.toLocal()) : '-'),
              _buildDetailRow('반납예정일', product.returnDate != null ? formatter.format(product.returnDate!.toLocal()) : '-'),
            ],
            if (product.status == 'sold') ...[
              const Divider(),
              _buildDetailRow('구매자', product.soldToName ?? '-'),
              _buildDetailRow('판매일', product.soldDate != null ? formatter.format(product.soldDate!.toLocal()) : '-'),
            ],

            // 등록 정보는 대여/판매 상태일 때 하단으로 이동
            if (product.status != 'available') ...[
              const Divider(),
              _buildDetailRow('등록자', registeredByName),
              _buildDetailRow('등록일', formatter.format(product.createdAt.toLocal())),
            ] else ...[
              const Divider(),
              _buildDetailRow('등록자', registeredByName),
              _buildDetailRow('등록일', formatter.format(product.createdAt.toLocal())),
            ]
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('닫기'),
        ),
      ],
    );
  }
}
