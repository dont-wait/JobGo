import 'package:flutter/material.dart';

/// Widget hiển thị logo công ty
/// - Nếu có [imageUrl] → hiển thị ảnh từ Cloudinary
/// - Nếu không → hiển thị [fallbackText] trên nền [backgroundColor]
class CompanyLogo extends StatelessWidget {
  final String? imageUrl;
  final String fallbackText;
  final Color backgroundColor;
  final double width;
  final double height;
  final double borderRadius;
  final double fontSize;

  const CompanyLogo({
    super.key,
    this.imageUrl,
    required this.fallbackText,
    required this.backgroundColor,
    this.width = 48,
    this.height = 48,
    this.borderRadius = 12,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildFallback(),
            )
          : _buildFallback(),
    );
  }

  Widget _buildFallback() {
    return Center(
      child: Text(
        fallbackText,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
