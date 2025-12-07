
import 'package:flutter/material.dart';

enum AuthButtonStyle {
  icon,
  block,
}

class AuthButton extends StatelessWidget {
  final String text;
  final Widget? icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AuthButtonStyle style;
  final BorderSide? borderSide;

  const AuthButton({
    Key? key,
    required this.text,
    this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
    this.isLoading = false,
    this.style = AuthButtonStyle.block,
    this.borderSide,
  }) : super(key: key);

  factory AuthButton.google({
    required VoidCallback? onPressed,
    bool isLoading = false,
    AuthButtonStyle style = AuthButtonStyle.block,
  }) {
    return AuthButton(
      text: 'Sign in with Google',
      icon: Image.asset('assets/google_logo.png', package: 'open_k_auth', height: 24), // Placeholder for asset
      backgroundColor: Colors.white,
      foregroundColor: Colors.black54,
      onPressed: onPressed,
      isLoading: isLoading,
      style: style,
      borderSide: const BorderSide(color: Colors.black12),
    );
  }

  factory AuthButton.kakao({
    required VoidCallback? onPressed,
    bool isLoading = false,
    AuthButtonStyle style = AuthButtonStyle.block,
  }) {
    return AuthButton(
      text: 'Sign in with Kakao',
      icon: Icon(Icons.chat_bubble, color: Colors.black87, size: 24), // Placeholder
      backgroundColor: const Color(0xFFFEE500),
      foregroundColor: const Color(0xFF191919),
      onPressed: onPressed,
      isLoading: isLoading,
      style: style,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (style == AuthButtonStyle.icon) {
      return _buildIconButton();
    }
    return _buildBlockButton();
  }

  Widget _buildIconButton() {
    return Ink(
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: CircleBorder(side: borderSide ?? BorderSide.none),
      ),
      child: IconButton(
        icon: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(foregroundColor),
                ),
              )
            : (icon ?? const SizedBox.shrink()),
        onPressed: onPressed,
        color: foregroundColor,
      ),
    );
  }

  Widget _buildBlockButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: borderSide ?? BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(foregroundColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 12),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
