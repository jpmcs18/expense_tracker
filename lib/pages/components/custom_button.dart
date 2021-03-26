import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Function()? onTap;

  const CustomButton({required this.title, this.icon, this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(top: 10, left: 20, bottom: 10, right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          color: Theme.of(context).buttonColor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...(icon == null
                ? [
                    SizedBox()
                  ]
                : [
                    Icon(
                      icon!,
                      color: Theme.of(context).accentColor,
                    ),
                    SizedBox(
                      width: 5.0,
                    )
                  ]),
            Text(
              title,
              style: TextStyle(color: Theme.of(context).accentColor),
            ),
          ],
        ),
      ),
    );
  }
}
