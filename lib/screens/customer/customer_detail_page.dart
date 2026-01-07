import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rehabiltiation/models/customer_model.dart';

class CustomerDetailPage extends StatelessWidget {
  const CustomerDetailPage({super.key, required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(
        title: Text('${customer.name} 님의 상세 정보'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // 기본 정보 카드
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('고객 정보', style: Theme.of(context).textTheme.titleLarge),
                    const Divider(),
                    Text('이름: ${customer.name}'),
                    Text('나이: ${customer.age != null ? '${customer.age}세' : '정보 없음'}'),
                    Text('성별: ${customer.gender}'),
                    Text('연락처: ${customer.phoneNumber}'),
                     Text('총 대여 횟수: ${customer.rentalCount}회'),
                    Text('총 구매 횟수: ${customer.purchaseCount}회'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 대여 내역
            if (customer.rentedProducts.isNotEmpty)
              Card(
                child: ExpansionTile(
                  title: Text('대여 내역 (${customer.rentedProducts.length}건)'),
                  children: customer.rentedProducts.map((item) {
                    final returnDate = (item['returnDate'] as Timestamp?)?.toDate();
                    return ListTile(
                      title: Text(item['productName'] ?? '이름 없는 상품'),
                      subtitle: Text('반납 예정일: ${returnDate != null ? formatter.format(returnDate) : '-'}'),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 10),

            // 구매 내역
            if (customer.purchasedProducts.isNotEmpty)
              Card(
                child: ExpansionTile(
                  title: Text('구매 내역 (${customer.purchasedProducts.length}건)'),
                  children: customer.purchasedProducts.map((item) {
                    final purchaseDate = (item['purchaseDate'] as Timestamp?)?.toDate();
                    return ListTile(
                      title: Text(item['productName'] ?? '이름 없는 상품'),
                      subtitle: Text('구매일: ${purchaseDate != null ? formatter.format(purchaseDate) : '-'}'),
                    );
                  }).toList(),
                ),
              ),

            if (customer.rentedProducts.isEmpty && customer.purchasedProducts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('대여 또는 구매 내역이 없습니다.'),
                ),
              )
          ],
        ),
      ),
    );
  }
}
