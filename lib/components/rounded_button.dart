import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {

  RoundedButton({required this.label,required this.onPressed,required this.color});

  final Color color;
  final String label;
  final Function onPressed ;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: color,
        borderRadius: BorderRadius.circular(30.0),
        child:MaterialButton(
          onPressed: (){
            onPressed();
          },
          height: 42.0,
          minWidth: 200.0,
          child:Text(
            label,
            style: const TextStyle(
              color: Colors.white
            ),
          ),
        ),
      ),
    );
  }
}
