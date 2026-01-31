import 'package:cine_echo/widgets/safe_network_image.dart';
import 'package:flutter/material.dart';

class ImageErrorListener {
  static void setupGlobalImageErrorListener(BuildContext context) {}

  static Widget buildNetworkImage({
    required String imageUrl,
    required BuildContext context,
    required BoxFit fit,
    Widget? placeholder,
    double? width,
    double? height,
    BorderRadius? borderRadius,
  }) {
    return SafeNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      borderRadius: borderRadius,
      placeholder:
          placeholder ??
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: Colors.grey[800],
            ),
            child: Center(
              child: Icon(Icons.broken_image_rounded, color: Colors.grey[600]),
            ),
          ),
    );
  }
}
