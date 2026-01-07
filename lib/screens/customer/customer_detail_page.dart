import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rehabiltiation/models/customer_model.dart';
import 'package:rehabiltiation/widgets/reusable_expansion_tile_card.dart';

class CustomerDetailPage extends StatelessWidget {
  const CustomerDetailPage({super.key, required this.customer});

  final Customer customer;

  String _formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.length == 11) {
      return '${phoneNumber.substring(0, 3)}-${phoneNumber.substring(3, 7)}-${phoneNumber.substring(7)}';
    }
    return phoneNumber;
  }

  Widget _buildCustomerGradeChip(Customer customer) {
    final totalTransactions = customer.rentalCount + customer.purchaseCount;
    if (totalTransactions == 0) {
      return const Chip(
        label: Text('신규'),
        backgroundColor: Colors.blueAccent,
        labelStyle: TextStyle(color: Colors.white),
      );
    } else if (totalTransactions >= 5) {
      return const Chip(
        label: Text('단골'),
        backgroundColor: Colors.amber,
        labelStyle: TextStyle(color: Colors.white),
      );
    }
    return const SizedBox.shrink();
  }

  List<Widget> _buildListItems(BuildContext context, DateFormat formatter) {
    final List<Widget> items = [];

    // 1. 기본 정보 카드
    items.add(
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('고객 정보', style: Theme.of(context).textTheme.titleLarge),
                  _buildCustomerGradeChip(customer),
                ],
              ),
              const Divider(),
              Text('이름: ${customer.name}'),
              Text('나이: ${customer.age != null ? '${customer.age}세' : '정보 없음'}'),
              Text('성별: ${customer.gender}'),
              Text('연락처: ${_formatPhoneNumber(customer.phoneNumber)}'),
              Text('총 대여 횟수: ${customer.rentalCount}회'),
              Text('총 구매 횟수: ${customer.purchaseCount}회'),
            ],
          ),
        ),
      ),
    );

    items.add(const SizedBox(height: 20));

    // 2. 대여 내역
    if (customer.rentedProducts.isNotEmpty) {
      items.add(
        ReusableExpansionTileCard(
          pageStorageKey: 'rented_history',
          title: '대여 내역 (${customer.rentedProducts.length}건)',
          children: customer.rentedProducts.map((item) {
            final returnDate = (item['returnDate'] as Timestamp?)?.toDate();
            return ListTile(
              title: Text(item['productName'] ?? '이름 없는 상품'),
              subtitle: Text(
                '반납 예정일: ${returnDate != null ? formatter.format(returnDate) : '-'}',
              ),
            );
          }).toList(),
        ),
      );
    }

    items.add(const SizedBox(height: 10));

    // 3. 구매 내역
    if (customer.purchasedProducts.isNotEmpty) {
      items.add(
        ReusableExpansionTileCard(
          pageStorageKey: 'purchased_history',
          title: '구매 내역 (${customer.purchasedProducts.length}건)',
          children: customer.purchasedProducts.map((item) {
            final purchaseDate = (item['purchaseDate'] as Timestamp?)?.toDate();
            return ListTile(
              title: Text(item['productName'] ?? '이름 없는 상품'),
              subtitle: Text(
                '구매일: ${purchaseDate != null ? formatter.format(purchaseDate) : '-'}',
              ),
            );
          }).toList(),
        ),
      );
    }

    // 4. 내역 없음 메시지
    if (customer.rentedProducts.isEmpty && customer.purchasedProducts.isEmpty) {
      items.add(
        const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('대여 또는 구매 내역이 없습니다.'),
          ),
        ),
      );
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('yyyy-MM-dd');
    final List<Widget> listItems = _buildListItems(context, formatter);

    return Scaffold(
      appBar: AppBar(title: Text('${customer.name} 님의 상세 정보')),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: listItems.length,
          itemBuilder: (context, index) {
            return listItems[index]; // 수정된 부분
          },
        ),
      ),
    );
  }
}
