import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _isLoading = false;
  String? _currentUser;
  String? _token;
  String? _captchaText;

  bool get isLoading => _isLoading;
  String? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoggedIn => _token != null;

  // 模拟API基础URL
  static const String baseUrl = 'https://api.xiaozhi.com';

  // 生成图片验证码
  Future<Uint8List> generateCaptcha() async {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random random = Random();
    _captchaText = String.fromCharCodes(
      Iterable.generate(4, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(120, 40);
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // 绘制背景
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // 绘制干扰线
    for (int i = 0; i < 5; i++) {
      final linePaint = Paint()
        ..color = Colors.grey[300]!
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        linePaint,
      );
    }

    // 绘制验证码文字
    final textPainter = TextPainter(
      text: TextSpan(
        text: _captchaText,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(120, 40);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  // 验证验证码
  bool verifyCaptcha(String input) {
    return _captchaText?.toUpperCase() == input.toUpperCase();
  }

  // 用户注册
  Future<bool> register({
    required String username,
    required String password,
    required String email,
    required String captcha,
  }) async {
    if (!verifyCaptcha(captcha)) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // 模拟API调用
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
          'email': email,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'];
        _currentUser = username;
        await _secureStorage.write(key: 'token', value: _token);
        await _secureStorage.write(key: 'username', value: username);
        _isLoading = false;
        notifyListeners();
        return true;
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
      // 模拟API调用
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'];
        _currentUser = username;
        await _secureStorage.write(key: 'token', value: _token);
        await _secureStorage.write(key: 'username', value: username);
        _isLoading = false;
        notifyListeners();
        return true;
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