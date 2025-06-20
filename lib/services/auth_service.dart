import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';
/**
  1. 生成UUID
  2. 生成图片验证码
  3. 注册用户
  4. 登录用户
  5. 登出用户
  6. 检查登录状态
 */
class AuthService extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _isLoading = false;
  String? _currentUser;
  String? _token;
  String? _currentUuid;

  bool get isLoading => _isLoading;
  String? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoggedIn => _token != null;
  String? get currentUuid => _currentUuid;

  // 生成UUID
  String _generateUuid() {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(
      Iterable.generate(32, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  // 生成图片验证码
  Future<Uint8List> generateCaptcha({required String getCaptchaFailed}) async {
    _currentUuid = _generateUuid();
    _isLoading = true;
    notifyListeners();

    try {
      // 从服务端获取验证码图片
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/xiaozhi/user/captcha?uuid=$_currentUuid'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        _isLoading = false;
        notifyListeners();
        return response.bodyBytes;
      } else {
        throw Exception('$getCaptchaFailed: ${response.statusCode}');
      }
    } catch (e) {
      print('获取验证码错误: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // 客户端验证码格式检查（可选使用）
  bool validateCaptchaFormat(String input) {
    // 基本格式验证：非空且长度合理
    return input.isNotEmpty && input.length >= 4 && input.length <= 8;
  }

  // 用户注册
  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String captcha,
    required String pleaseGenerateCaptchaFirst,
    required String registrationSuccess,
    required String networkError,
    required String registrationFailedGeneric,
  }) async {
    if (_currentUuid == null) {
      return {
        'success': false,
        'message': pleaseGenerateCaptchaFirst,
      };
    }

    _isLoading = true;
    notifyListeners();

    try {
      // 注册时发送验证码和UUID到服务端进行校验
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/xiaozhi/user/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
          'captcha': captcha,
          'captchaId': _currentUuid,
        }),
      ).timeout(AppConfig.apiTimeout);
      
      final responseData = json.decode(response.body);
      print('注册响应: $responseData');
      
      // 根据服务端返回的code字段判断成功或失败
      if (response.statusCode == 200 && responseData['code'] == 200) {
        // 注册成功
        _token = responseData['data']?['token'];
        _currentUser = username;
        await _secureStorage.write(key: 'token', value: _token);
        await _secureStorage.write(key: 'username', value: username);
        _isLoading = false;
        notifyListeners();
        return {
          'success': true,
          'message': registrationSuccess,
        };
      } else {
        // 注册失败，返回服务端的错误信息
        final errorMessage = responseData['msg'] ?? registrationFailedGeneric;
        print('注册失败: $errorMessage');
        _isLoading = false;
        notifyListeners();
        return {
          'success': true,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print('注册错误: $e');
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': networkError,
      };
    }
  }

  // 用户登录
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
    required String loginSuccess,
    required String networkError,
    required String loginFailedGeneric,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 登录API调用
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/xiaozhi/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      ).timeout(AppConfig.apiTimeout);

      final responseData = json.decode(response.body);
      print('登录响应: $responseData');
      
      // 根据服务端返回的code字段判断成功或失败
      if (response.statusCode == 200 && responseData['code'] == 200) {
        // 登录成功
        _token = responseData['data']?['token'];
        _currentUser = username;
        await _secureStorage.write(key: 'token', value: _token);
        await _secureStorage.write(key: 'username', value: username);
        _isLoading = false;
        notifyListeners();
        return {
          'success': true,
          'message': loginSuccess,
        };
      } else {
        // 登录失败，返回服务端的错误信息
        final errorMessage = responseData['msg'] ?? loginFailedGeneric;
        print('登录失败: $errorMessage');
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print('登录错误: $e');
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': networkError,
      };
    }
  }

  // 用户登出
  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    await _secureStorage.deleteAll();
    notifyListeners();
  }

  // 检查登录状态
  Future<void> checkLoginStatus() async {
    final token = await _secureStorage.read(key: 'token');
    final username = await _secureStorage.read(key: 'username');
    if (token != null && username != null) {
      _token = token;
      _currentUser = username;
      notifyListeners();
    }
  }
} 