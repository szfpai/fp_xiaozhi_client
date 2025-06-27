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
      if (response.statusCode == 200 && responseData['code'] == 0) {
        // 注册成功
        // _token = responseData['data']?['token'];
        // _currentUser = username;
        // await _secureStorage.write(key: 'token', value: _token);
        // await _secureStorage.write(key: 'username', value: username);
        print('注册成功: $responseData');
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
          'success': false,
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
    String? captcha,
    required String loginSuccess,
    required String networkError,
    required String loginFailedGeneric,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 构建请求体
      final Map<String, dynamic> requestBody = {
        'username': username,
        'password': password,
      };
      
      // 如果提供了验证码，添加到请求中
      if (captcha != null && captcha.isNotEmpty && _currentUuid != null) {
        requestBody['captcha'] = captcha;
        requestBody['captchaId'] = _currentUuid;
      }
      
      // 登录API调用
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/xiaozhi/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      ).timeout(AppConfig.apiTimeout);

      final responseData = json.decode(response.body);
      print('登录响应: $responseData');
      
      // 根据服务端返回的code字段判断成功或失败
      if (response.statusCode == 200 && responseData['code'] == 0) {
        // 登录成功
        final data = responseData['data'];
        _token = data?['token'];
        _currentUser = username;
        
        // 保存登录信息到本地存储
        await _secureStorage.write(key: 'token', value: _token);
        await _secureStorage.write(key: 'currentUser', value: _currentUser);
        
        // 保存过期时间（秒）
        if (data?['expire'] != null) {
          await _secureStorage.write(key: 'expire', value: data['expire'].toString());
        }
        
        // 保存客户端哈希
        if (data?['clientHash'] != null) {
          await _secureStorage.write(key: 'clientHash', value: data['clientHash']);
        }
        
        // 保存登录时间戳
        await _secureStorage.write(key: 'loginTime', value: DateTime.now().millisecondsSinceEpoch.toString());

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
    final currentUser = await _secureStorage.read(key: 'currentUser');
    final expire = await _secureStorage.read(key: 'expire');
    final loginTime = await _secureStorage.read(key: 'loginTime');
    
    if (token != null && currentUser != null) {
      // 检查token是否过期
      bool isExpired = false;
      
      if (expire != null && loginTime != null) {
        try {
          final expireSeconds = int.parse(expire);
          final loginTimestamp = int.parse(loginTime);
          final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
          final elapsedSeconds = (currentTimestamp - loginTimestamp) ~/ 1000;
          
          // 如果已经超过过期时间，则标记为过期
          if (elapsedSeconds >= expireSeconds) {
            isExpired = true;
            print('Token已过期，已过${elapsedSeconds}秒，过期时间${expireSeconds}秒');
          }
        } catch (e) {
          print('解析过期时间出错: $e');
          isExpired = true;
        }
      }
      
      if (!isExpired) {
        _token = token;
        _currentUser = currentUser;
        notifyListeners();
      } else {
        // Token过期，清除本地存储
        await logout();
      }
    }
  }

  // 获取token剩余有效时间（秒）
  Future<int?> getTokenRemainingTime() async {
    final expire = await _secureStorage.read(key: 'expire');
    final loginTime = await _secureStorage.read(key: 'loginTime');
    
    if (expire != null && loginTime != null) {
      try {
        final expireSeconds = int.parse(expire);
        final loginTimestamp = int.parse(loginTime);
        final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
        final elapsedSeconds = (currentTimestamp - loginTimestamp) ~/ 1000;
        
        final remainingSeconds = expireSeconds - elapsedSeconds;
        return remainingSeconds > 0 ? remainingSeconds : 0;
      } catch (e) {
        print('计算剩余时间出错: $e');
        return null;
      }
    }
    return null;
  }

  // 检查token是否即将过期（默认提前5分钟提醒）
  Future<bool> isTokenExpiringSoon({int warningMinutes = 5}) async {
    final remainingTime = await getTokenRemainingTime();
    if (remainingTime != null) {
      return remainingTime <= (warningMinutes * 60);
    }
    return false;
  }

  // 调试方法：打印当前缓存状态
  Future<void> debugPrintCacheStatus() async {
    final token = await _secureStorage.read(key: 'token');
    final currentUser = await _secureStorage.read(key: 'currentUser');
    final expire = await _secureStorage.read(key: 'expire');
    final loginTime = await _secureStorage.read(key: 'loginTime');
    final clientHash = await _secureStorage.read(key: 'clientHash');
    
    print('=== 缓存状态调试信息 ===');
    print('Token: ${token != null ? '已保存' : '未保存'}');
    print('当前用户: $currentUser');
    print('过期时间: $expire 秒');
    print('登录时间: $loginTime');
    print('客户端哈希: $clientHash');
    
    final remainingTime = await getTokenRemainingTime();
    if (remainingTime != null) {
      print('剩余有效时间: $remainingTime 秒');
      print('是否即将过期: ${await isTokenExpiringSoon()}');
    } else {
      print('无法计算剩余时间');
    }
    print('=======================');
  }
} 