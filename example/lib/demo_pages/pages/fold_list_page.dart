import 'package:flutter/material.dart';
import 'package:lj_flutter_package/ui_component/lj_expansion_widget.dart';

class FoldListPage extends StatefulWidget {
  const FoldListPage({Key? key}) : super(key: key);

  @override
  State<FoldListPage> createState() => _FoldListPageState();
}

class _FoldListPageState extends State<FoldListPage> {
  @override
  Widget build(BuildContext context) {

    List<Widget> children = [];
    for (int i = 0; i < 10; i++) {
      children.add(LJExpansionWidget(
        stickyHeader: true,
        headerBuilder: (context, isExpand) {
          return FoldListHeaderView(
            isExpand: isExpand,
            title: i.toString(),
          );
        },
        children: List.generate(
          10,
              (index) => Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            color: Colors.orange,
            alignment: Alignment.centerLeft,
            child: Text('Row——$index'),
          ),
        ),
      ));
      children.add(const SizedBox(height: 15));
    }

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: children,
          ),
        ),
      ),

      /// Tip:ListView会复用item，展开状态无法保存，需要用外部model保存展开状态
      // body: ListView.builder(
      //   itemCount: 10,
      //   itemBuilder: (context, index) {
      //     return LJExpansionWidget(
      //       stickyHeader: true,
      //       headerBuilder: (context, isExpand) {
      //         return FoldListHeaderView(
      //           isExpand: isExpand,
      //           title: index.toString(),
      //         );
      //       },
      //       children: List.generate(
      //         10,
      //         (index) => Container(
      //           height: 44,
      //           padding: const EdgeInsets.symmetric(horizontal: 15),
      //           color: Colors.orange,
      //           alignment: Alignment.centerLeft,
      //           child: Text('Row——$index'),
      //         ),
      //       ).toList(),
      //     );
      //   },
      // ),
    );
  }
}

class FoldListHeaderView extends StatefulWidget {
  const FoldListHeaderView({
    Key? key,
    required this.isExpand,
    required this.title,
  }) : super(key: key);

  final bool isExpand;
  final String title;

  @override
  State<FoldListHeaderView> createState() => _FoldListHeaderViewState();
}

class _FoldListHeaderViewState extends State<FoldListHeaderView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  late Animation<double> _animation;

  @override
  void initState() {
    _animationController =
        AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
    _animation = Tween(begin: .0, end: 0.5).animate(_animationController);

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5E5),
        borderRadius: widget.isExpand
            ? const BorderRadius.vertical(top: Radius.circular(7.5))
            : BorderRadius.circular(7.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Row(
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                color: Color(0xFF333333),
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            RotationTransition(
              turns: _animation,
              child: const Icon(Icons.keyboard_arrow_up_outlined),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant FoldListHeaderView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isExpand != widget.isExpand) {
      widget.isExpand
          ? _animationController.forward()
          : _animationController.reverse();
    }
  }
}
