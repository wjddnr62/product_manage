import 'package:flutter/material.dart';

// 데이터 상태를 나타내는 제네릭 enum
enum ViewState { loading, error, success }

class DataDrivenView<T> extends StatelessWidget {
  final ViewState viewState;
  final VoidCallback onRetry;
  final String? errorMessage;
  final Widget Function(T data) successBuilder;
  final T data;

  const DataDrivenView({
    super.key,
    required this.viewState,
    required this.onRetry,
    required this.successBuilder,
    required this.data,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    switch (viewState) {
      case ViewState.loading:
        return const Center(child: CircularProgressIndicator());
      case ViewState.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(errorMessage ?? '데이터를 불러오는데 실패했습니다.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        );
      case ViewState.success:
        return successBuilder(data);
    }
  }
}
