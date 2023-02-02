import 'package:example/common/lj_colors.dart';
import 'package:flutter/material.dart';
import 'package:lj_flutter_package/lj_flutter_package.dart';

showAlert(
    BuildContext context, {
      String? title,
      String content = '',
      String cancelTitle = '取消',
      String submitTitle = '确定',
      VoidCallback? cancelCallBack,
      VoidCallback? submitCallBack,
    }) {
  showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
            contentPadding: EdgeInsets.zero,
            backgroundColor: Colors.white,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            children: <Widget>[
              if (title != null)
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEEEFF),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                  ),
                  padding: const EdgeInsets.fromLTRB(0, 18.5, 0, 16),
                  width: double.infinity,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22,
                        color: LJColor.mainColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 20, 40, 12.5),
                child: Text(
                  content,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 15,
                      color: LJColor.textColor,
                      fontWeight: FontWeight.w400),
                ),
              ),
              Container(
                height: 45,
                margin: const EdgeInsets.all(15),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            cancelCallBack?.call();
                          },
                          style: buttonStyle(
                            16,
                            LJColor.mainColor,
                            backgroundColor: const Color(0xFFEEEEFF),
                            borderColor: LJColor.mainColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: Text(cancelTitle),
                        ),
                      ),
                    ),
                    Container(
                      width: 10,
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            submitCallBack?.call();
                          },
                          style: buttonStyle(
                            16,
                            Colors.white,
                            backgroundColor: LJColor.mainColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: Text(submitTitle),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ]);
      });
}