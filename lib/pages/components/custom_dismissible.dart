import 'package:expense_management/pages/styles/style.dart';
import 'package:flutter/material.dart';

class CustomDismissible extends StatelessWidget {
  final String id;
  final String header;
  final Widget child;
  final Future<bool> Function() onDelete;
  final Future Function() onEdit;
  final bool isTop;
  final bool isBottom;
  final bool isNormal;
  const CustomDismissible(
      {required this.id,
      required this.child,
      required this.onDelete,
      required this.onEdit,
      this.isTop = false,
      this.isBottom = false,
      this.isNormal = false,
      this.header = ""});

  final double radius = 15;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        isTop && header.isNotEmpty
            ? Container(
                child: Text(
                  header,
                  style: headerStyle,
                ),
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(top: 10),
                padding: EdgeInsets.only(left: 20),
              )
            : SizedBox(),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isTop ? radius : 0),
                topRight: Radius.circular(isTop ? radius : 0),
                bottomLeft: Radius.circular(isBottom ? radius : 0),
                bottomRight: Radius.circular(isBottom ? radius : 0)),
          ),
          margin: EdgeInsets.only(
              top: isTop ? 10 : 0,
              bottom: isBottom ? 10 : 0,
              left: 10,
              right: 10),
          child: Column(
            children: [
              Dismissible(
                key: Key(id),
                child: Container(
                    decoration: BoxDecoration(color: Colors.transparent),
                    child: child),
                background: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(isTop ? radius : 0),
                          topRight: Radius.circular(isTop ? radius : 0),
                          bottomLeft: Radius.circular(isBottom ? radius : 0),
                          bottomRight: Radius.circular(isBottom ? radius : 0)),
                      color: Colors.green,
                    ),
                    padding: EdgeInsets.zero,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.fromLTRB(20, 5, 0, 5),
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                    )),
                secondaryBackground: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(isTop ? radius : 0),
                          topRight: Radius.circular(isTop ? radius : 0),
                          bottomLeft: Radius.circular(isBottom ? radius : 0),
                          bottomRight: Radius.circular(isBottom ? radius : 0)),
                      color: Colors.red,
                    ),
                    padding: EdgeInsets.zero,
                    child: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.fromLTRB(0, 5, 20, 5),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    )),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.endToStart) {
                    return await onDelete();
                  } else {
                    await onEdit();
                    return false;
                  }
                },
                onDismissed: (direction) {},
              ),
              isBottom || isNormal
                  ? SizedBox()
                  : Divider(
                      thickness: 1,
                      indent: 20,
                      endIndent: 20,
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
