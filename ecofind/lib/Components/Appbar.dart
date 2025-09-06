import 'package:flutter/material.dart';

import 'Colors.dart';


class appbar extends StatelessWidget {
  const appbar({super.key, required this.appbar_title });
  final String appbar_title;

  double get myAppBarHeight => 60.0;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      toolbarHeight: 60,
      title:  Container(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(

              backgroundImage: AssetImage("assets/Logo.png"),
              radius: 30,
              backgroundColor: Colors.white,

            ),
            Text(appbar_title,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.black),),
            Row(
              children: [
                CircleAvatar(child: IconButton(onPressed: (){
                  Navigator.of(context).pushNamed("/profile");
                }, icon: Icon(Icons.person, color: Colors.white,)),
                  backgroundImage: AssetImage("assets/images/Logo.png"),
                  radius: 25,
                  backgroundColor: primaryColor,
                ),

              ],
            )
          ],
        ),
      ),
    );


  }
}
