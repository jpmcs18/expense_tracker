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
          color: Theme.of(context).primaryColor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...(icon == null
                ? [SizedBox()]
                : [
                    Icon(
                      icon!,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 10.0,
                    )
                  ]),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
