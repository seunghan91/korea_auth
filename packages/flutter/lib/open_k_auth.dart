/// # Open K-Auth
///
/// Flutter 카카오 로그인, 네이버 로그인, 구글 로그인, 애플 로그인 통합 SDK.
///
/// 한국 앱 개발자를 위한 소셜 로그인 통합 패키지입니다.
/// 카카오톡 로그인, 네이버 아이디 로그인, Google Sign-In, Apple Sign-In을
/// 하나의 통합된 API로 간편하게 구현할 수 있습니다.
///
/// ## 지원 상태 관리
///
/// Riverpod, Provider, BLoC, Cubit, GetX, MobX, Redux, Signals, Vanilla 등
/// 9가지 상태 관리 솔루션을 지원합니다.
///
/// ## 주요 기능
/// - **통합 API**: `signIn(provider)` 하나로 4개 소셜 로그인 처리
/// - **함수형 패턴**: `fold`, `when` 지원으로 깔끔한 에러 처리
/// - **상태 관리**: Riverpod 완벽 통합
/// - **자동 토큰 갱신**: 만료 전 자동 갱신 + 이벤트 스트림
/// - **서버 검증**: 백엔드 토큰 검증용 데이터 제공
/// - **테스트 지원**: MockAuthProvider로 쉬운 테스트
/// - **브랜드 버튼**: 각 플랫폼 디자인 가이드라인 준수
///
/// ## 빠른 시작
/// ```dart
/// import 'package:open_k_auth/open_k_auth.dart';
///
/// // Riverpod 사용
/// final user = await ref.read(authNotifierProvider.notifier).signIn(
///   KakaoAuthProvider(),
/// );
///
/// // 직접 사용
/// final repo = AuthRepository();
/// final user = await repo.signIn(GoogleAuthProvider());
///
/// // fold 패턴
/// result.fold(
///   onSuccess: (user) => print('환영합니다, ${user.displayName}!'),
///   onFailure: (error) => print('로그인 실패: $error'),
/// );
/// ```
library open_k_auth;

// Core
export 'src/core/auth_user.dart';
export 'src/core/auth_exception.dart';
export 'src/core/auth_provider.dart';
export 'src/core/auth_state.dart';
export 'src/core/auth_token.dart';
export 'src/core/auth_result.dart';
export 'src/core/auth_config.dart';
export 'src/core/token_manager.dart';
export 'src/core/server_verification.dart';
export 'src/core/session_storage.dart';

// Providers
export 'src/providers/google_auth_provider.dart';
export 'src/providers/kakao_auth_provider.dart';
export 'src/providers/naver_auth_provider.dart';
export 'src/providers/apple_auth_provider.dart';

// Repository
export 'src/repositories/auth_repository.dart';

// Integrations
export 'src/integrations/riverpod_auth.dart';

// Widgets
export 'src/widgets/auth_button.dart';
export 'src/widgets/login_button_group.dart';

// Utils
export 'src/utils/diagnostic.dart';
