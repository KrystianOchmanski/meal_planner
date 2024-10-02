import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MealRow extends StatefulWidget {
  const MealRow({super.key, required this.title});

  final String title;

  @override
  State<MealRow> createState() => _MealRowState();
}

class _MealRowState extends State<MealRow> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 22),
              ),
              Text('Nie wybrano',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w300, color: Colors.black54))
            ],
          ),
        ),
        IconButton(onPressed: null, iconSize: 48, icon: Icon(Icons.add_circle))
      ],
    );
  }
}
