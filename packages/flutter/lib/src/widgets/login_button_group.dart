import 'package:flutter/material.dart';
import 'auth_button.dart';

/// 로그인 버튼 그룹
///
/// 여러 소셜 로그인 버튼을 한 번에 표시합니다.
///
/// 사용 예시:
/// ```dart
/// LoginButtonGroup(
///   providers: [
///     AuthProviderType.kakao,
///     AuthProviderType.naver,
///     AuthProviderType.google,
///     AuthProviderType.apple,
///   ],
///   onPressed: (provider) async {
///     await authRepo.signIn(getProvider(provider));
///   },
/// )
/// ```
class LoginButtonGroup extends StatelessWidget {
  /// 표시할 Provider 목록
  final List<AuthProviderType> providers;

  /// 버튼 클릭 콜백
  final void Function(AuthProviderType provider) onPressed;

  /// 버튼 간 간격
  final double spacing;

  /// 버튼 스타일
  final AuthButtonStyle style;

  /// 로딩 중인 Provider (null이면 로딩 없음)
  final AuthProviderType? loadingProvider;

  /// 버튼 너비 (block 스타일에서만 적용)
  final double? buttonWidth;

  /// 가로 정렬 (icon 스타일에서만 적용)
  final MainAxisAlignment alignment;

  const LoginButtonGroup({
    super.key,
    required this.providers,
    required this.onPressed,
    this.spacing = 12,
    this.style = AuthButtonStyle.block,
    this.loadingProvider,
    this.buttonWidth,
    this.alignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    if (style == AuthButtonStyle.icon) {
      return Row(mainAxisAlignment: alignment, children: _buildButtons());
    }

    return Column(mainAxisSize: MainAxisSize.min, children: _buildButtons());
  }

  List<Widget> _buildButtons() {
    final buttons = <Widget>[];

    for (var i = 0; i < providers.length; i++) {
      final provider = providers[i];
      final isLoading = loadingProvider == provider;

      Widget button = _buildButton(provider, isLoading);

      if (buttonWidth != null && style == AuthButtonStyle.block) {
        button = SizedBox(width: buttonWidth, child: button);
      }

      buttons.add(button);

      if (i < providers.length - 1) {
        buttons.add(
          SizedBox(
            width: style == AuthButtonStyle.icon ? spacing : 0,
            height: style != AuthButtonStyle.icon ? spacing : 0,
          ),
        );
      }
    }

    return buttons;
  }

  Widget _buildButton(AuthProviderType provider, bool isLoading) {
    return switch (provider) {
      AuthProviderType.kakao => AuthButton.kakao(
        onPressed: isLoading ? null : () => onPressed(provider),
        isLoading: isLoading,
        style: style,
      ),
      AuthProviderType.naver => AuthButton.naver(
        onPressed: isLoading ? null : () => onPressed(provider),
        isLoading: isLoading,
        style: style,
      ),
      AuthProviderType.google => AuthButton.google(
        onPressed: isLoading ? null : () => onPressed(provider),
        isLoading: isLoading,
        style: style,
      ),
      AuthProviderType.apple => AuthButton.apple(
        onPressed: isLoading ? null : () => onPressed(provider),
        isLoading: isLoading,
        style: style,
      ),
    };
  }
}

/// Provider 타입 (버튼용)
enum AuthProviderType { kakao, naver, google, apple }
