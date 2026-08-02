import 'package:flutter/material.dart';

class SearchEmpty extends StatelessWidget {
  const SearchEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: const [

            Icon(
              Icons.search_off,
              size: 90,
              color: Colors.grey,
            ),

            SizedBox(height: 20),

            Text(
              "No results found",
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            SizedBox(height: 8),

            Text(
              "Try another keyword.",
              textAlign:
                  TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}