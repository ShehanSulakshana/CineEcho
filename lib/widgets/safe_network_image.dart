import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cine_echo/providers/connectivity_provider.dart';

/// A wrapper widget for Image.network that automatically handles errors
class SafeNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Color? backgroundColor;

  const SafeNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholder,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isEmpty ||
        imageUrl.endsWith('/null') ||
        imageUrl.endsWith('null')) {
      return _buildPlaceholder();
    }

    return Image.network(
      imageUrl,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Image loading error for $imageUrl: $error');

        // Report to connectivity provider
        if (context.mounted && error.toString().contains('SocketException')) {
          try {
            context.read<ConnectivityProvider>().setNetworkError(
              'Failed to load image. Check your internet connection',
            );
          } catch (e) {
            debugPrint('Error reporting to connectivity provider: $e');
          }
        }

        return _buildPlaceholder();
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: backgroundColor ?? Colors.grey[800],
          ),
          child: const Center(
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: backgroundColor ?? Colors.grey[800],
      ),
      child:
          placeholder ??
          Center(
            child: Icon(
              Icons.broken_image_rounded,
              color: Colors.grey[600],
              size: 40,
            ),
          ),
    );
  }
}
