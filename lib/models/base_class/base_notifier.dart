import 'package:flutter/foundation.dart';
import 'package:gts/models/base_class/base_response.dart';
import 'package:gts/utill/CP.dart';

import '../errors/app_exception.dart';

abstract class BaseNotifier extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDisposed = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get isDisposed => _isDisposed;

  /// Helper to update state safely and trigger listeners if not disposed
  void setState({bool? isLoading, String? errorMessage}) {
    if (_isDisposed) return;

    if (isLoading != null)
      _isLoading = isLoading; // Explicit loading state update
    if (errorMessage != null) _errorMessage = errorMessage;

    notifyListeners();
  }

  /// Explicit helper to toggle loading state
  void setLoading(bool loading) {
    if (_isDisposed) return;
    _isLoading = loading;
    notifyListeners();
  }

  /// Explicit helper to set error state
  void setError(String? message) {
    if (_isDisposed) return;
    _errorMessage = message;
    notifyListeners();
  }

  /// Clears any existing error state
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      if (!_isDisposed) notifyListeners();
    }
  }

  /// Wraps async operations with automated loading state, error handling,
  /// lifecycle callbacks (onLoading, onError, onComplete), and safety checks.
  Future<BaseResponse<T>?> runSafely<T>(
    Future<BaseResponse<T>> Function() action, {
    void Function()? onLoading,
    void Function(String)? onSuccess,
    void Function(AppException error)? onError,
    void Function()? onComplete,
    bool notify = false,
  }) async {
    if (_isDisposed) return null;
    // if (_isLoading) return null;

    _isLoading = true;
    _errorMessage = null;
    if (notify) notifyListeners();

    // Trigger optional loading callback
    if (onLoading != null) {
      onLoading();
    }

    try {
      final result = await action();

      if (!_isDisposed && notify) notifyListeners();
      if (onSuccess != null) onSuccess(result.message);
      return result;
    } on AppException catch (e) {
      _errorMessage = e.message;

      if (onError != null) {
        onError(e);
      }

      if (!_isDisposed && notify) notifyListeners();
      return null;
    } on Exception catch (e) {
      final exp = UnauthorizedException(e.toString());
      if (onError != null) {
        onError(exp);
      }

      CP.error(e);
    } finally {
      _isLoading = false;
      if (notify) notifyListeners();
      // Trigger optional completion callback regardless of success or error
      if (onComplete != null) {
        onComplete();
      }
    }
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
