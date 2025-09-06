import 'package:flutter/material.dart';

class Elevationbutton extends StatelessWidget {
  final String name, routePage;
  final double  fontsize, radius, padding;
  final int bgColor, textColor, iconcolor;
  final IconData icon;
  const Elevationbutton({super.key,
    required this.name,
    required this.bgColor,
    required this.textColor,
    required this.fontsize,
    required this.radius,
    required this.padding,
    required this.icon,
    required this.iconcolor,
    required this.routePage,
  });


  @override
  Widget build(BuildContext context) {
    final BgColor = Color(bgColor);
    final TextColor = Color(textColor);
    final IconColor = Color(iconcolor);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(onPressed: (){Navigator.of(context).pushNamed('$routePage');},
        style: ElevatedButton.styleFrom(
            backgroundColor: BgColor,
            side: BorderSide(
                color: Colors.black,
                width: 1
            ),
            padding: EdgeInsets.all(radius),//15
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(padding),//15
            )
        ),
        child:Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon as IconData?,color: IconColor),
            SizedBox(width: 8,),
            Text("$name",style: TextStyle(fontSize: fontsize,color: TextColor ),),
          ],
        ),

      ),
    );
  }
}
