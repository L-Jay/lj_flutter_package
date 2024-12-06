import 'package:flutter/material.dart';
import 'package:lj_flutter_package/ui_component/lj_dropdown_list.dart';

class DropdownPage extends StatefulWidget {
  const DropdownPage({super.key});

  @override
  State<DropdownPage> createState() => _DropdownPageState();
}

class _DropdownPageState extends State<DropdownPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [_buildDropdownList(child: false)],
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildDropdownList(child: true),
                _buildDropdownList(child: false),
                _buildDropdownList(
                  child: true,
                  width: 200,
                  position: LJDropdownPosition.middle,
                ),
                const SizedBox(height: 20),
                _buildDropdownList(
                  child: true,
                  width: 200,
                  position: LJDropdownPosition.right,
                ),
                const Spacer(),
                _buildDropdownList(child: true),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  LJDropdownList _buildDropdownList({
    required bool child,
    double? width,
    LJDropdownPosition? position,
  }) {
    return LJDropdownList(
      itemWidth: width,
      position: position,
      dotColor: Colors.orange,
      backgroundColor: child ? null : Colors.blue,
      elevation: child ? null : 0,
      borderRadius: child ? null : 0,
      borderWidth: child ? null : 2,
      borderColor: child ? null : Colors.yellow,
      targetWidget: child
          ? Container(
              width: 150,
              height: 44,
              color: Colors.orange,
              child: const Text('show'),
            )
          : null,
      length: 5,
      itemBuilder: (index) {
        return Text(index.toString());
      },
      onSelected: (int index) {},
    );
  }
}
