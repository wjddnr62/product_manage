import 'package:flutter/material.dart';

class ReusableExpansionTileCard extends StatefulWidget {
  final Key? cardKey;
  final String title;
  final Widget? subtitle;
  final String pageStorageKey;
  final List<Widget> children;

  const ReusableExpansionTileCard({
    super.key,
    this.cardKey,
    required this.title,
    this.subtitle,
    required this.pageStorageKey,
    required this.children,
  });

  @override
  State<ReusableExpansionTileCard> createState() => _ReusableExpansionTileCardState();
}

class _ReusableExpansionTileCardState extends State<ReusableExpansionTileCard>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
      
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<Widget> _items = [];
  late AnimationController _controller;
  late Animation<double> _iconTurns;
  bool _isExpanded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _iconTurns = _controller.drive(Tween<double>(begin: 0.0, end: 0.5));

    // 애니메이션 완료 리스너 추가
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isExpanded) {
        _scrollToSelf();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final isExpandedFromStorage = PageStorage.of(context).readState(context, identifier: ValueKey(widget.pageStorageKey)) ?? false;
        if (isExpandedFromStorage) {
          setState(() {
            _isExpanded = true;
            _controller.value = 1.0;
            _items.addAll(widget.children);
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scrollToSelf() {
    // 위젯이 여전히 화면에 있는지 확인 후 스크롤 실행
    if (mounted) {
      Scrollable.ensureVisible(
        context,
        alignment: -0.1, // 화면 중앙보다 약간 위로 포커싱
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleTap() {
    if (_controller.isAnimating) return;

    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
        _insertAllItems();
      } else {
        _controller.reverse();
        _removeAllItems();
      }
      PageStorage.of(context).writeState(context, _isExpanded, identifier: ValueKey(widget.pageStorageKey));
    });
  }

  void _insertAllItems() {
    if (_listKey.currentState == null) return;
    for (int i = 0; i < widget.children.length; i++) {
      _items.insert(i, widget.children[i]);
      _listKey.currentState!.insertItem(i, duration: const Duration(milliseconds: 150));
    }
  }

  void _removeAllItems() {
    if (_listKey.currentState == null) return;
    for (int i = _items.length - 1; i >= 0; i--) {
      final removedItem = _items.removeAt(i);
      _listKey.currentState!.removeItem(
        i,
        (context, animation) => SizeTransition(sizeFactor: animation, child: removedItem),
        duration: const Duration(milliseconds: 100),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Card(
      key: widget.cardKey,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: widget.subtitle,
            onTap: _handleTap,
            trailing: RotationTransition(
              turns: _iconTurns,
              child: const Icon(Icons.expand_more),
            ),
          ),
          AnimatedList(
            key: _listKey,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            initialItemCount: _items.length,
            itemBuilder: (context, index, animation) {
              if (index >= _items.length) {
                return const SizedBox.shrink();
              }
              return SizeTransition(
                sizeFactor: animation,
                child: _items[index],
              );
            },
          ),
        ],
      ),
    );
  }
}
