import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rehabiltiation/models/customer_model.dart';
import 'package:rehabiltiation/repositories/customer_repository.dart';
import 'package:rehabiltiation/screens/customer/cubit/customer_management_cubit.dart';
import 'package:rehabiltiation/screens/customer/cubit/customer_management_state.dart';
import 'package:rehabiltiation/screens/customer/widgets/add_customer_dialog.dart';

class CustomerManagementPage extends StatelessWidget {
  const CustomerManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CustomerManagementCubit(CustomerRepository())..loadCustomers(),
      child: const CustomerManagementView(),
    );
  }
}

class CustomerManagementView extends StatelessWidget {
  const CustomerManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('고객 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => BlocProvider.value(
                value: BlocProvider.of<CustomerManagementCubit>(context),
                child: const AddCustomerDialog(),
              ),
            ),
            tooltip: '고객 추가',
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<CustomerManagementCubit, CustomerManagementState>(
          listener: (context, state) {
            if (state is CustomerManagementError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          builder: (context, state) {
            if (state is CustomerManagementInitial || state is CustomerManagementLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is CustomerManagementLoaded) {
              if (state.customers.isEmpty) {
                return const Center(child: Text('고객을 추가해주세요'));
              }
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80), // 하단 여백 추가
                itemCount: state.customers.length,
                itemBuilder: (context, index) {
                  final Customer customer = state.customers[index];
                  return ListTile(
                    title: Text('${customer.name} (${customer.gender})'),
                    subtitle: Text(customer.age == null 
                        ? customer.phoneNumber 
                        : '${customer.phoneNumber} (만 ${customer.age}세)'),
                  );
                },
              );
            }
            return const Center(child: Text('알 수 없는 오류가 발생했습니다.'));
          },
        ),
      ),
    );
  }
}
