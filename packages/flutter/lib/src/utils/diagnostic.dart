import '../core/auth_config.dart';

/// 진단 결과 항목
class DiagnosticItem {
  final String provider;
  final DiagnosticLevel level;
  final String message;
  final String? hint;

  const DiagnosticItem({
    required this.provider,
    required this.level,
    required this.message,
    this.hint,
  });

  String get icon => switch (level) {
    DiagnosticLevel.error => '❌',
    DiagnosticLevel.warning => '⚠️',
    DiagnosticLevel.ok => '✅',
  };

  @override
  String toString() =>
      '$icon [$provider] $message${hint != null ? '\n   힌트: $hint' : ''}';
}

enum DiagnosticLevel { error, warning, ok }

/// 진단 결과
class DiagnosticResult {
  final List<DiagnosticItem> items;

  const DiagnosticResult(this.items);

  /// 에러가 있는지
  bool get hasErrors => items.any((i) => i.level == DiagnosticLevel.error);

  /// 경고가 있는지
  bool get hasWarnings => items.any((i) => i.level == DiagnosticLevel.warning);

  /// 모든 설정이 올바른지
  bool get isAllOk => !hasErrors && !hasWarnings;

  /// 에러 목록
  List<DiagnosticItem> get errors =>
      items.where((i) => i.level == DiagnosticLevel.error).toList();

  /// 경고 목록
  List<DiagnosticItem> get warnings =>
      items.where((i) => i.level == DiagnosticLevel.warning).toList();

  /// 보기 좋게 출력
  String prettyPrint() {
    if (items.isEmpty) {
      return '설정된 Provider가 없습니다.';
    }
    return items.map((i) => i.toString()).join('\n');
  }
}

/// 설정 진단 도구
///
/// 앱 설정이 올바른지 확인합니다. 개발 중 디버깅에 유용합니다.
///
/// 사용 예시:
/// ```dart
/// final result = AuthDiagnostic.run(config);
/// if (result.hasErrors) {
///   print(result.prettyPrint());
/// }
/// ```
class AuthDiagnostic {
  /// 전체 설정 진단
  static DiagnosticResult run(AuthConfig config) {
    final items = <DiagnosticItem>[];

    if (config.kakao != null) {
      items.addAll(_checkKakao(config.kakao!));
    }

    if (config.naver != null) {
      items.addAll(_checkNaver(config.naver!));
    }

    if (config.google != null) {
      items.addAll(_checkGoogle(config.google!));
    }

    if (config.apple != null) {
      items.addAll(_checkApple(config.apple!));
    }

    if (items.isEmpty) {
      items.add(
        const DiagnosticItem(
          provider: 'config',
          level: DiagnosticLevel.warning,
          message: '설정된 Provider가 없습니다.',
          hint: 'AuthConfig에 최소 하나의 Provider를 설정하세요.',
        ),
      );
    }

    return DiagnosticResult(items);
  }

  /// 카카오 설정 진단
  static List<DiagnosticItem> checkKakao(KakaoConfig config) {
    return _checkKakao(config);
  }

  static List<DiagnosticItem> _checkKakao(KakaoConfig config) {
    final items = <DiagnosticItem>[];

    if (config.appKey.isEmpty) {
      items.add(
        const DiagnosticItem(
          provider: 'kakao',
          level: DiagnosticLevel.error,
          message: '네이티브 앱 키가 설정되지 않았습니다.',
          hint: 'KakaoConfig(appKey: "YOUR_NATIVE_APP_KEY")로 설정하세요.',
        ),
      );
    } else if (config.appKey.startsWith('YOUR_') || config.appKey.length < 10) {
      items.add(
        const DiagnosticItem(
          provider: 'kakao',
          level: DiagnosticLevel.warning,
          message: '네이티브 앱 키가 올바르지 않을 수 있습니다.',
          hint: '카카오 개발자 콘솔에서 네이티브 앱 키를 확인하세요.',
        ),
      );
    } else {
      items.add(
        const DiagnosticItem(
          provider: 'kakao',
          level: DiagnosticLevel.ok,
          message: '설정이 올바릅니다.',
        ),
      );
    }

    return items;
  }

  /// 네이버 설정 진단
  static List<DiagnosticItem> checkNaver(NaverConfig config) {
    return _checkNaver(config);
  }

  static List<DiagnosticItem> _checkNaver(NaverConfig config) {
    final items = <DiagnosticItem>[];

    if (config.clientId.isEmpty) {
      items.add(
        const DiagnosticItem(
          provider: 'naver',
          level: DiagnosticLevel.error,
          message: 'Client ID가 설정되지 않았습니다.',
          hint: 'NaverConfig(clientId: "YOUR_CLIENT_ID", ...)로 설정하세요.',
        ),
      );
    }

    if (config.clientSecret.isEmpty) {
      items.add(
        const DiagnosticItem(
          provider: 'naver',
          level: DiagnosticLevel.error,
          message: 'Client Secret이 설정되지 않았습니다.',
          hint: 'NaverConfig(clientSecret: "YOUR_CLIENT_SECRET", ...)로 설정하세요.',
        ),
      );
    }

    if (config.appName.isEmpty) {
      items.add(
        const DiagnosticItem(
          provider: 'naver',
          level: DiagnosticLevel.error,
          message: '앱 이름이 설정되지 않았습니다.',
          hint: 'NaverConfig(appName: "Your App", ...)로 설정하세요.',
        ),
      );
    }

    if (items.isEmpty) {
      items.add(
        const DiagnosticItem(
          provider: 'naver',
          level: DiagnosticLevel.ok,
          message: '설정이 올바릅니다.',
        ),
      );
    }

    return items;
  }

  /// 구글 설정 진단
  static List<DiagnosticItem> checkGoogle(GoogleConfig config) {
    return _checkGoogle(config);
  }

  static List<DiagnosticItem> _checkGoogle(GoogleConfig config) {
    final items = <DiagnosticItem>[];

    if (config.iosClientId == null || config.iosClientId!.isEmpty) {
      items.add(
        const DiagnosticItem(
          provider: 'google',
          level: DiagnosticLevel.warning,
          message: 'iOS 클라이언트 ID가 없으면 iOS에서 로그인이 실패합니다.',
          hint: 'GoogleConfig(iosClientId: "YOUR_IOS_CLIENT_ID")로 설정하세요.',
        ),
      );
    } else {
      items.add(
        const DiagnosticItem(
          provider: 'google',
          level: DiagnosticLevel.ok,
          message: '설정이 올바릅니다.',
        ),
      );
    }

    return items;
  }

  /// 애플 설정 진단
  static List<DiagnosticItem> checkApple(AppleConfig config) {
    return _checkApple(config);
  }

  static List<DiagnosticItem> _checkApple(AppleConfig config) {
    // Apple은 별도 설정이 필요 없음 (Xcode에서 설정)
    return [
      const DiagnosticItem(
        provider: 'apple',
        level: DiagnosticLevel.ok,
        message: '설정이 올바릅니다.',
        hint: 'Xcode에서 Sign in with Apple capability가 추가되었는지 확인하세요.',
      ),
    ];
  }
}
