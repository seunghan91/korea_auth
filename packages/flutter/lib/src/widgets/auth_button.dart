import 'package:flutter/material.dart';

/// 버튼 스타일
enum AuthButtonStyle {
  /// 아이콘만 표시
  icon,

  /// 전체 너비 블록 버튼
  block,

  /// 컴팩트 버튼
  compact,
}

/// 소셜 로그인 버튼 위젯
///
/// 각 플랫폼의 디자인 가이드라인을 준수합니다.
///
/// 사용 예시:
/// ```dart
/// AuthButton.kakao(
///   onPressed: () => ref.read(authNotifierProvider.notifier).signIn(KakaoAuthProvider()),
/// )
/// ```
class AuthButton extends StatelessWidget {
  final String text;
  final Widget? icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AuthButtonStyle style;
  final BorderSide? borderSide;
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const AuthButton({
    super.key,
    required this.text,
    this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
    this.isLoading = false,
    this.style = AuthButtonStyle.block,
    this.borderSide,
    this.width,
    this.height = 50,
    this.borderRadius,
  });

  /// 카카오 로그인 버튼
  ///
  /// 카카오 브랜드 가이드라인 준수:
  /// - 배경색: #FEE500
  /// - 텍스트색: #191919
  factory AuthButton.kakao({
    required VoidCallback? onPressed,
    bool isLoading = false,
    AuthButtonStyle style = AuthButtonStyle.block,
    String? text,
  }) {
    return AuthButton(
      text: text ?? '카카오 로그인',
      icon: _KakaoIcon(),
      backgroundColor: const Color(0xFFFEE500),
      foregroundColor: const Color(0xFF191919),
      onPressed: onPressed,
      isLoading: isLoading,
      style: style,
      borderRadius: BorderRadius.circular(12),
    );
  }

  /// 네이버 로그인 버튼
  ///
  /// 네이버 브랜드 가이드라인 준수:
  /// - 배경색: #03C75A
  /// - 텍스트색: #FFFFFF
  factory AuthButton.naver({
    required VoidCallback? onPressed,
    bool isLoading = false,
    AuthButtonStyle style = AuthButtonStyle.block,
    String? text,
  }) {
    return AuthButton(
      text: text ?? '네이버 로그인',
      icon: _NaverIcon(),
      backgroundColor: const Color(0xFF03C75A),
      foregroundColor: Colors.white,
      onPressed: onPressed,
      isLoading: isLoading,
      style: style,
      borderRadius: BorderRadius.circular(12),
    );
  }

  /// 구글 로그인 버튼
  ///
  /// 구글 브랜드 가이드라인 준수:
  /// - 배경색: #FFFFFF
  /// - 텍스트색: #757575
  /// - 테두리: #DADCE0
  factory AuthButton.google({
    required VoidCallback? onPressed,
    bool isLoading = false,
    AuthButtonStyle style = AuthButtonStyle.block,
    String? text,
  }) {
    return AuthButton(
      text: text ?? 'Google로 로그인',
      icon: _GoogleIcon(),
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF757575),
      onPressed: onPressed,
      isLoading: isLoading,
      style: style,
      borderSide: const BorderSide(color: Color(0xFFDADCE0)),
      borderRadius: BorderRadius.circular(4),
    );
  }

  /// 애플 로그인 버튼
  ///
  /// 애플 Human Interface Guidelines 준수:
  /// - 배경색: #000000
  /// - 텍스트색: #FFFFFF
  factory AuthButton.apple({
    required VoidCallback? onPressed,
    bool isLoading = false,
    AuthButtonStyle style = AuthButtonStyle.block,
    String? text,
  }) {
    return AuthButton(
      text: text ?? 'Apple로 로그인',
      icon: _AppleIcon(),
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      onPressed: onPressed,
      isLoading: isLoading,
      style: style,
      borderRadius: BorderRadius.circular(12),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case AuthButtonStyle.icon:
        return _buildIconButton();
      case AuthButtonStyle.compact:
        return _buildCompactButton();
      case AuthButtonStyle.block:
        return _buildBlockButton();
    }
  }

  Widget _buildIconButton() {
    return Material(
      color: backgroundColor,
      shape: CircleBorder(side: borderSide ?? BorderSide.none),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(foregroundColor),
                    ),
                  )
                : icon ?? const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactButton() {
    return Material(
      color: backgroundColor,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: borderSide != null
                ? Border.fromBorderSide(borderSide!)
                : null,
            borderRadius: borderRadius ?? BorderRadius.circular(8),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[icon!, const SizedBox(width: 8)],
                    Text(
                      text,
                      style: TextStyle(
                        color: foregroundColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildBlockButton() {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor.withOpacity(0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(6),
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
                  if (icon != null) ...[icon!, const SizedBox(width: 12)],
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

/// 카카오 아이콘 (말풍선)
class _KakaoIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(painter: _KakaoIconPainter()),
    );
  }
}

class _KakaoIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF191919)
      ..style = PaintingStyle.fill;

    // 말풍선 모양
    final path = Path();
    final w = size.width;
    final h = size.height;

    // 타원형 말풍선
    path.addOval(Rect.fromLTWH(w * 0.1, h * 0.15, w * 0.8, h * 0.55));

    // 꼬리
    path.moveTo(w * 0.35, h * 0.65);
    path.lineTo(w * 0.25, h * 0.85);
    path.lineTo(w * 0.45, h * 0.7);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 네이버 아이콘 (N)
class _NaverIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 24,
      height: 24,
      child: Center(
        child: Text(
          'N',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// 구글 아이콘 (G 로고)
class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(painter: _GoogleIconPainter()),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w * 0.4;

    // 파란색 (상단 우측)
    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.15
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.5,
      1.2,
      false,
      bluePaint,
    );

    // 초록색 (하단 우측)
    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.15
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0.7,
      1.0,
      false,
      greenPaint,
    );

    // 노란색 (하단 좌측)
    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.15
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      1.7,
      1.0,
      false,
      yellowPaint,
    );

    // 빨간색 (상단 좌측)
    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.15
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      2.7,
      0.9,
      false,
      redPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 애플 아이콘
class _AppleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.apple, color: Colors.white, size: 24);
  }
}
