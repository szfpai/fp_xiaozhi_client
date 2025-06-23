import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../data/agent.dart';
import '../services/auth_service.dart';
import '../services/home_service.dart';

class CharacterConfigScreen extends StatefulWidget {
  final int agentId;

  const CharacterConfigScreen({Key? key, required this.agentId}) : super(key: key);

  @override
  State<CharacterConfigScreen> createState() => _CharacterConfigScreenState();
}

class _CharacterConfigScreenState extends State<CharacterConfigScreen> {
  Agent? _agent;
  bool _isLoading = true;
  String? _error;

  // Form Controllers
  final _assistantNameController = TextEditingController();
  final _characterIntroController = TextEditingController();
  final _memoryController = TextEditingController();

  // State variables
  String? _selectedTemplate;
  String? _selectedLanguage;
  String? _selectedVoice;

  @override
  void initState() {
    super.initState();
    _fetchAgentDetails();
  }

  @override
  void dispose() {
    _assistantNameController.dispose();
    _characterIntroController.dispose();
    _memoryController.dispose();
    super.dispose();
  }

  Future<void> _fetchAgentDetails() async {
    try {
      final authService = context.read<AuthService>();
      final homeService = HomeService(authService: authService);
      final agent = await homeService.getAgentDetails(widget.agentId);
      if (mounted && agent != null) {
        setState(() {
          _agent = agent;
          _assistantNameController.text = agent.assistantName;
          _characterIntroController.text = agent.character;
          _selectedLanguage = _mapAgentLanguageToDropdown(agent.language);
          _selectedVoice = agent.ttsVoice;   // Assuming ttsVoice matches one of the dropdown items
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '加载数据失败: $e';
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _saveChanges() async {
    if (_agent == null) return;

    setState(() { _isLoading = true; });

    final updatedAgent = Agent(
      id: _agent!.id,
      userId: _agent!.userId,
      agentName: _agent!.agentName,
      assistantName: _assistantNameController.text,
      character: _characterIntroController.text,
      language: _selectedLanguage ?? _agent!.language,
      ttsVoice: _selectedVoice ?? _agent!.ttsVoice,
      llmModel: _agent!.llmModel,
      userName: _agent!.userName,
      memory: _agent!.memory,
      longMemorySwitch: _agent!.longMemorySwitch,
      langCode: _agent!.langCode,
      ttsSpeechSpeed: _agent!.ttsSpeechSpeed,
      asrSpeed: _agent!.asrSpeed,
      ttsPitch: _agent!.ttsPitch,
      deviceCount: _agent!.deviceCount,
      createdAt: _agent!.createdAt,
      updatedAt: _agent!.updatedAt,
    );

    final authService = context.read<AuthService>();
    final homeService = HomeService(authService: authService);
    final result = await homeService.updateAgent(updatedAgent);

    if(mounted) {
      setState(() { _isLoading = false; });
      Fluttertoast.showToast(
        msg: result['message'],
        backgroundColor: result['success'] ? Colors.green : Colors.red,
      );
      if (result['success']) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_agent != null ? '配置角色: ${_agent!.agentName}' : '配置角色'),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
        actions: [
          _isLoading 
            ? const Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2,)))
            : IconButton(icon: const Icon(Icons.save), onPressed: _saveChanges),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _agent == null 
                  ? const Center(child: Text('未找到智能体数据'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('角色模板'),
                          _buildCharacterTemplates(),
                          const SizedBox(height: 24),

                          _buildSectionTitle('助手昵称'),
                          _buildTextField(_assistantNameController),
                          const SizedBox(height: 24),
                          
                          Row(
                            children: [
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildSectionTitle('对话语言'), _buildLanguageDropdown()],)),
                              const SizedBox(width: 16),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildSectionTitle('角色音色'), _buildVoiceDropdown()],)),
                            ],
                          ),
                          const SizedBox(height: 24),

                          _buildSectionTitle('角色介绍'),
                          _buildCharacterIntroductionField(),
                          const SizedBox(height: 24),

                          _buildSectionTitle('记忆体', actionWidget: TextButton(onPressed: (){}, child: const Text('清除记忆'))),
                          _buildTextField(_memoryController, hint: '我还没有记忆。', enabled: false),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildSectionTitle(String title, {Widget? actionWidget}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (actionWidget != null) actionWidget,
        ],
      ),
    );
  }

  Widget _buildCharacterTemplates() {
    final templates = ['台湾女友', '土豆子', 'English Tutor', '好奇小男孩', '汪汪队队长'];
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: templates.map((template) {
        return ChoiceChip(
          label: Text(template),
          selected: _selectedTemplate == template,
          onSelected: (selected) {
            setState(() {
              _selectedTemplate = selected ? template : null;
              // TODO: Apply template logic
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildTextField(TextEditingController controller, {String? hint, bool enabled = true}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hint,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    // Mock data
    final languages = ['普通话', 'English', '日本語'];
    return DropdownButtonFormField<String>(
      value: _selectedLanguage,
      items: languages.map((lang) => DropdownMenuItem(value: lang, child: Text(lang))).toList(),
      onChanged: (value) => setState(() => _selectedLanguage = value),
      decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12)),
    );
  }

  Widget _buildVoiceDropdown() {
    // Mock data
    final voices = ['湾湾小何', '标准女声', '标准男声'];
     return DropdownButtonFormField<String>(
      value: _selectedVoice,
      items: voices.map((voice) => DropdownMenuItem(value: voice, child: Text(voice))).toList(),
      onChanged: (value) => setState(() => _selectedVoice = value),
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        suffixIcon: IconButton(icon: const Icon(Icons.volume_up_outlined), onPressed: () { /* TODO: Play voice */ }),
      ),
    );
  }

  Widget _buildCharacterIntroductionField() {
    return TextField(
      controller: _characterIntroController,
      maxLines: 5,
      maxLength: 2000,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: '详细描述角色的背景、性格、说话风格等...',
      ),
    );
  }

  String _mapAgentLanguageToDropdown(String agentLanguage) {
    switch (agentLanguage) {
      case '中文':
      case '普通话':
        return '普通话';
      case '英文':
      case 'English':
        return 'English';
      case '日文':
      case '日本語':
        return '日本語';
      default:
        return '普通话'; // 默认
    }
  }
} 