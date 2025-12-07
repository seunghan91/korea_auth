/// 세션 저장소 인터페이스
///
/// 앱 재시작 시 자동 로그인을 위해 세션을 저장합니다.
///
/// 사용 예시:
/// ```dart
/// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
///
/// class SecureSessionStorage implements SessionStorage {
///   final _storage = FlutterSecureStorage();
///
///   @override
///   Future<void> save(String key, String value) async {
///     await _storage.write(key: key, value: value);
///   }
///
///   @override
///   Future<String?> read(String key) async {
///     return await _storage.read(key: key);
///   }
///
///   @override
///   Future<void> delete(String key) async {
///     await _storage.delete(key: key);
///   }
///
///   @override
///   Future<void> clear() async {
///     await _storage.deleteAll();
///   }
/// }
/// ```
abstract class SessionStorage {
  /// 값 저장
  Future<void> save(String key, String value);

  /// 값 읽기
  Future<String?> read(String key);

  /// 값 삭제
  Future<void> delete(String key);

  /// 모든 값 삭제
  Future<void> clear();
}

/// 메모리 기반 세션 저장소 (테스트/개발용)
///
/// 앱 재시작 시 데이터가 사라집니다.
class InMemorySessionStorage implements SessionStorage {
  final Map<String, String> _storage = {};

  @override
  Future<void> save(String key, String value) async {
    _storage[key] = value;
  }

  @override
  Future<String?> read(String key) async {
    return _storage[key];
  }

  @override
  Future<void> delete(String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> clear() async {
    _storage.clear();
  }
}

/// 세션 저장소 키
class SessionKeys {
  static const String provider = 'open_k_auth_provider';
  static const String userId = 'open_k_auth_user_id';
  static const String accessToken = 'open_k_auth_access_token';
  static const String refreshToken = 'open_k_auth_refresh_token';
  static const String idToken = 'open_k_auth_id_token';
  static const String expiresAt = 'open_k_auth_expires_at';
  static const String userData = 'open_k_auth_user_data';
}
