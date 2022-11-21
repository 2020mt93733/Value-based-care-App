import 'package:valuebasedcare/interface/themeDialog.dart';
import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget child;
  const Background({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      color: Color(0xFF339CEE),
      height: size.height,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: 330,
            left: 140,
            child: Image.asset(
              "assets/vaccine.png",
              width: size.width * 0.3,
            ),
          ),
          child,
        ],
      ),
    );
  }
}