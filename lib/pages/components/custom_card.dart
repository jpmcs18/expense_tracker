import 'package:expense_management/pages/styles/style.dart';
import 'package:flutter/material.dart';

class CustomCard extends StatefulWidget {
  final String title;
  final Widget child;
  final bool isCollapsible;

  const CustomCard({required this.title, required this.child, this.isCollapsible = false});

  @override
  _CustomCardState createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  final double radius = 10;
  bool collapse = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(radius)), color: Theme.of(context).cardColor),
      child: ConstrainedBox(
        constraints: new BoxConstraints(
          minHeight: collapse ? 0 : 100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              child: Container(
                margin: EdgeInsets.only(top: 12, left: 15, right: 15, bottom: 12),
                child: Text(
                  widget.title,
                  style: cardTitleStyle3,
                ),
              ),
              onTap: widget.isCollapsible
                  ? () {
                      setState(() {
                        collapse = !collapse;
                      });
                    }
                  : null,
            ),
            ...(collapse
                ? []
                : [
                    Divider(
                      thickness: 1,
                      height: 0,
                    ),
                    Container(padding: EdgeInsets.all(10), child: widget.child)
                  ])
          ],
        ),
      ),
    );
  }
}
