import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

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
  Future<Uint8List> generateCaptcha() async {
    _currentUuid = _generateUuid();
    _isLoading = true;
    notifyListeners();

    try {
      // 从服务端获取验证码图片
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/xiaozhi/user/captcha?uuid=$_currentUuid'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return response.bodyBytes;
      } else {
        throw Exception('获取验证码失败: ${response.statusCode}');
      }
    } catch (e) {
      print('获取验证码错误: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // 验证验证码（现在由服务端校验）
  bool verifyCaptcha(String input) {
    // 客户端不再进行验证码校验，由服务端处理
    return input.isNotEmpty;
  }

  // 用户注册
  Future<bool> register({
    required String username,
    required String password,
    required String email,
    required String captcha,
  }) async {
    if (_currentUuid == null) {
      print('请先生成验证码');
      return false;
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
          'email': email,
          'captcha': captcha,
          'uuid': _currentUuid,
        }),
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'];
        _currentUser = username;
        await _secureStorage.write(key: 'token', value: _token);
        await _secureStorage.write(key: 'username', value: username);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // 处理服务端返回的错误信息
        final errorData = json.decode(response.body);
        print('注册失败: ${errorData['message'] ?? '未知错误'}');
      }
    } catch (e) {
      print('注册错误: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // 用户登录
  Future<bool> login({
    required String username,
    required String password,
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

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'];
        _currentUser = username;
        await _secureStorage.write(key: 'token', value: _token);
        await _secureStorage.write(key: 'username', value: username);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // 处理服务端返回的错误信息
        final errorData = json.decode(response.body);
        print('登录失败: ${errorData['message'] ?? '未知错误'}');
      }
    } catch (e) {
      print('登录错误: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
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