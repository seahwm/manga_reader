import 'package:flutter/material.dart';

class Loading extends StatelessWidget{

  const Loading({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.3), // 半透明背景
      child: Center(
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Processing...',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}