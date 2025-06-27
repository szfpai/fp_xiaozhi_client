import 'package:flutter/material.dart';

class DeviceBindingScreen extends StatefulWidget {
  final String agentId;
  const DeviceBindingScreen({super.key, required this.agentId});

  @override
  State<DeviceBindingScreen> createState() => _DeviceBindingScreenState();
}

class _DeviceBindingScreenState extends State<DeviceBindingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onCancel() {
    Navigator.pop(context, false);
  }

  void _onConfirm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; });
    // TODO: 这里可以添加绑定设备的API调用逻辑，使用widget.agentId
    await Future.delayed(const Duration(seconds: 1)); // 模拟网络请求
    setState(() { _isLoading = false; });
    Navigator.pop(context, _codeController.text.trim()); // 返回验证码
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加设备'),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '验证码',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: const InputDecoration(
                          hintText: '请输入设备播报的6位数验证码',
                          border: OutlineInputBorder(),
                          counterText: '',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '请输入验证码';
                          }
                          if (!RegExp(r'^\d{6}').hasMatch(value.trim())) {
                            return '请输入6位数字验证码';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _isLoading ? null : _onCancel,
                            child: const Text('取消', style: TextStyle(fontSize: 16)),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 90,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _onConfirm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF764BA2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('确定', style: TextStyle(fontSize: 16, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 