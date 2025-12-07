import 'dart:async';
import 'auth_token.dart';
import 'auth_exception.dart';

/// 토큰 이벤트 타입
enum TokenEventType {
  /// 토큰이 갱신됨
  refreshed,

  /// 토큰이 곧 만료됨
  expiringSoon,

  /// 토큰이 만료됨
  expired,

  /// 토큰 갱신 실패
  refreshFailed,
}

/// 토큰 관련 이벤트
class TokenEvent {
  final TokenEventType type;
  final AuthToken? token;
  final Object? error;
  final DateTime timestamp;

  TokenEvent({required this.type, this.token, this.error})
    : timestamp = DateTime.now();

  @override
  String toString() => 'TokenEvent($type, token: $token, error: $error)';
}

/// 토큰 갱신 콜백 타입
typedef TokenRefreshCallback = Future<AuthToken> Function();

/// 토큰 자동 갱신 및 관리를 담당하는 클래스
class TokenManager {
  AuthToken? _currentToken;
  Timer? _refreshTimer;
  Timer? _expiryCheckTimer;

  final _eventController = StreamController<TokenEvent>.broadcast();

  /// 자동 갱신 활성화 여부
  final bool autoRefresh;

  /// 만료 전 갱신 시작 시간
  final Duration refreshThreshold;

  /// 토큰 갱신 콜백
  TokenRefreshCallback? _refreshCallback;

  TokenManager({
    this.autoRefresh = true,
    this.refreshThreshold = const Duration(minutes: 5),
  });

  /// 토큰 이벤트 스트림
  Stream<TokenEvent> get tokenEvents => _eventController.stream;

  /// 현재 토큰
  AuthToken? get currentToken => _currentToken;

  /// 토큰이 유효한지 확인
  bool get hasValidToken => _currentToken?.isValid ?? false;

  /// 토큰 갱신 콜백 설정
  void setRefreshCallback(TokenRefreshCallback callback) {
    _refreshCallback = callback;
  }

  /// 토큰 설정
  void setToken(AuthToken token) {
    _currentToken = token;
    _scheduleRefresh();
    _startExpiryCheck();
  }

  /// 토큰 제거
  void clearToken() {
    _currentToken = null;
    _cancelTimers();
  }

  /// 수동 토큰 갱신
  Future<AuthToken> refresh() async {
    if (_refreshCallback == null) {
      throw const AuthException('no_refresh_callback', '토큰 갱신 콜백이 설정되지 않았습니다');
    }

    try {
      final newToken = await _refreshCallback!();
      _currentToken = newToken;
      _eventController.add(
        TokenEvent(type: TokenEventType.refreshed, token: newToken),
      );
      _scheduleRefresh();
      return newToken;
    } catch (e) {
      _eventController.add(
        TokenEvent(type: TokenEventType.refreshFailed, error: e),
      );
      rethrow;
    }
  }

  /// 자동 갱신 스케줄링
  void _scheduleRefresh() {
    if (!autoRefresh || _currentToken == null || _refreshCallback == null) {
      return;
    }

    _refreshTimer?.cancel();

    final expiresAt = _currentToken!.expiresAt;
    if (expiresAt == null) return;

    final refreshTime = expiresAt.subtract(refreshThreshold);
    final delay = refreshTime.difference(DateTime.now());

    if (delay.isNegative) {
      // 이미 갱신 시간이 지났으면 즉시 갱신
      if (!_currentToken!.isExpired) {
        refresh();
      }
      return;
    }

    _refreshTimer = Timer(delay, () async {
      try {
        await refresh();
      } catch (_) {
        // 에러는 이벤트로 전달됨
      }
    });
  }

  /// 만료 체크 타이머 시작
  void _startExpiryCheck() {
    _expiryCheckTimer?.cancel();

    // 1분마다 만료 체크
    _expiryCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_currentToken == null) return;

      if (_currentToken!.isExpired) {
        _eventController.add(TokenEvent(type: TokenEventType.expired));
        _cancelTimers();
      } else if (_currentToken!.isExpiringSoon(refreshThreshold)) {
        _eventController.add(
          TokenEvent(type: TokenEventType.expiringSoon, token: _currentToken),
        );
      }
    });
  }

  void _cancelTimers() {
    _refreshTimer?.cancel();
    _expiryCheckTimer?.cancel();
    _refreshTimer = null;
    _expiryCheckTimer = null;
  }

  void dispose() {
    _cancelTimers();
    _eventController.close();
  }
}
