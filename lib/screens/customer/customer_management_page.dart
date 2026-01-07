import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rehabiltiation/models/customer_model.dart';
import 'package:rehabiltiation/repositories/customer_repository.dart';
import 'package:rehabiltiation/screens/customer/cubit/customer_management_cubit.dart';
import 'package:rehabiltiation/screens/customer/cubit/customer_management_state.dart';
import 'package:rehabiltiation/screens/customer/customer_detail_page.dart';
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
    final cubit = context.read<CustomerManagementCubit>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('고객 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => BlocProvider.value(
                value: cubit,
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
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: state.customers.length,
                itemBuilder: (context, index) {
                  final Customer customer = state.customers[index];
                  return ListTile(
                    title: Text('${customer.name} (${customer.gender})'),
                    subtitle: Text(customer.age == null 
                        ? customer.phoneNumber 
                        : '${customer.phoneNumber} (만 ${customer.age}세)'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CustomerDetailPage(customer: customer),
                        ),
                      );
                    },
                  );
                },
              );
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('데이터를 불러오는데 실패했습니다.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => cubit.loadCustomers(),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
