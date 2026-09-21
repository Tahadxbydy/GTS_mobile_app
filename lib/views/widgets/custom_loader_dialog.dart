import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../core/constants/assets.dart';

class CustomLoaderDialog extends StatelessWidget {
  final String message;

  const CustomLoaderDialog({super.key, this.message = 'Loading...'});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(height: 50, AppAssets.girigo),
            const SizedBox(width: 20),
            Flexible(
              child: Text(message, style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
