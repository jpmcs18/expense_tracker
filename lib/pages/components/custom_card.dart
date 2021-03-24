import 'package:expense_management/pages/styles/style.dart';
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final double radius = 10;
  final Widget child;

  const CustomCard({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10, left: 10, right: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(radius)), color: Theme.of(context).cardColor),
      child: ConstrainedBox(
        constraints: new BoxConstraints(
          minHeight: 100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 12, left: 15, right: 15, bottom: 5),
              child: Text(
                title,
                style: cardTitleStyle3,
              ),
            ),
            Divider(
              thickness: 1,
            ),
            Container(padding: EdgeInsets.all(10), child: child),
          ],
        ),
      ),
    );
  }
}
