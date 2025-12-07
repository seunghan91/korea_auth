import 'auth_user.dart';
import 'auth_exception.dart';

/// 인증 결과를 나타내는 sealed class
///
/// 함수형 프로그래밍 스타일의 fold, when 패턴을 지원합니다.
///
/// 사용 예시:
/// ```dart
/// final result = await authRepo.signInWithResult(KakaoAuthProvider());
///
/// // fold 패턴
/// result.fold(
///   onSuccess: (user) => print('환영합니다, ${user.displayName}!'),
///   onFailure: (error) => print('로그인 실패: $error'),
/// );
///
/// // when 패턴
/// result.when(
///   success: (user) => navigateToHome(user),
///   cancelled: () => showToast('로그인이 취소되었습니다'),
///   failure: (code, message) => showError(message),
/// );
/// ```
sealed class AuthResult {
  const AuthResult();

  /// 성공 여부
  bool get isSuccess => this is AuthSuccess;

  /// 취소 여부
  bool get isCancelled => this is AuthCancelled;

  /// 실패 여부
  bool get isFailure => this is AuthFailure;

  /// 사용자 정보 (성공 시에만)
  AuthUser? get user => switch (this) {
    AuthSuccess(user: final u) => u,
    _ => null,
  };

  /// 에러 정보 (실패 시에만)
  AuthException? get error => switch (this) {
    AuthFailure(exception: final e) => e,
    _ => null,
  };

  /// fold 패턴: 성공/실패 분기
  T fold<T>({
    required T Function(AuthUser user) onSuccess,
    required T Function(AuthException error) onFailure,
  }) {
    return switch (this) {
      AuthSuccess(user: final u) => onSuccess(u),
      AuthCancelled() => onFailure(
        const AuthException('cancelled', '사용자가 로그인을 취소했습니다'),
      ),
      AuthFailure(exception: final e) => onFailure(e),
    };
  }

  /// when 패턴: 성공/취소/실패 세분화
  T when<T>({
    required T Function(AuthUser user) success,
    required T Function() cancelled,
    required T Function(String code, String message) failure,
  }) {
    return switch (this) {
      AuthSuccess(user: final u) => success(u),
      AuthCancelled() => cancelled(),
      AuthFailure(exception: final e) => failure(e.code, e.message),
    };
  }

  /// 성공 시 콜백 체이닝
  AuthResult onSuccess(void Function(AuthUser user) callback) {
    if (this case AuthSuccess(user: final u)) {
      callback(u);
    }
    return this;
  }

  /// 실패 시 콜백 체이닝
  AuthResult onFailure(void Function(String code, String message) callback) {
    if (this case AuthFailure(exception: final e)) {
      callback(e.code, e.message);
    }
    return this;
  }

  /// 취소 시 콜백 체이닝
  AuthResult onCancelled(void Function() callback) {
    if (this is AuthCancelled) {
      callback();
    }
    return this;
  }

  /// 사용자 정보 변환
  T? mapUser<T>(T Function(AuthUser user) mapper) {
    return switch (this) {
      AuthSuccess(user: final u) => mapper(u),
      _ => null,
    };
  }

  /// 사용자 정보 변환 (기본값 포함)
  T mapUserOr<T>(T Function(AuthUser user) mapper, T defaultValue) {
    return switch (this) {
      AuthSuccess(user: final u) => mapper(u),
      _ => defaultValue,
    };
  }
}

/// 로그인 성공
class AuthSuccess extends AuthResult {
  @override
  final AuthUser user;

  const AuthSuccess(this.user);

  @override
  String toString() => 'AuthSuccess(user: $user)';
}

/// 로그인 취소
class AuthCancelled extends AuthResult {
  const AuthCancelled();

  @override
  String toString() => 'AuthCancelled()';
}

/// 로그인 실패
class AuthFailure extends AuthResult {
  final AuthException exception;

  const AuthFailure(this.exception);

  String get code => exception.code;
  String get message => exception.message;

  @override
  String toString() => 'AuthFailure(code: $code, message: $message)';
}
