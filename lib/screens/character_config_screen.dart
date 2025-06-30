import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../data/agent.dart';
import '../services/auth_service.dart';
import '../services/home_service.dart';
import '../services/agent_service.dart';

class CharacterConfigScreen extends StatefulWidget {
  final String agentId;

  const CharacterConfigScreen({Key? key, required this.agentId}) : super(key: key);

  @override
  State<CharacterConfigScreen> createState() => _CharacterConfigScreenState();
}

class _CharacterConfigScreenState extends State<CharacterConfigScreen> {
  AgentDetail? _agent;
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
      final agentService = AgentService(authService: authService);
      final agent = await agentService.getAgentDetail(widget.agentId);
      if (mounted) {
        final voices = ['湾湾小何', '标准女声', '标准男声'];
        final uniqueVoices = voices.toSet().toList();
        String? initialVoice = agent.ttsVoice;
        if (!voices.contains(initialVoice)) {
          initialVoice = voices.isNotEmpty ? voices[0] : null;
        }
        setState(() {
          _agent = agent;
          _assistantNameController.text = agent.assistantName;
          _characterIntroController.text = agent.character;
          _selectedLanguage = _mapAgentLanguageToDropdown(agent.languageDisplay);
          _selectedVoice = initialVoice;
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
      agentName: _agent!.agentName,
      ttsModelName: _agent!.ttsModelId,
      ttsVoiceName: _selectedVoice ?? _agent!.ttsVoiceId,
      llmModelName: _agent!.llmModelId,
      vllmModelName: _agent!.vllmModelId,
      memModelId: _agent!.memModelId,
      systemPrompt: _characterIntroController.text,
      summaryMemory: _agent!.summaryMemory,
      deviceCount: 0
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
        ),
        child: _isLoading
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
                            _buildSectionTitle('助手昵称'),
                            _buildTextField(_assistantNameController),
                            const SizedBox(height: 24),

                            _buildSectionTitle('角色模板'),
                            _buildCharacterTemplates(),
                            const SizedBox(height: 24),

                            _buildSectionTitle('角色介绍'),
                            _buildCharacterIntroductionField(),
                            const SizedBox(height: 24),

                            _buildSectionTitle('记忆体', actionWidget: TextButton(onPressed: (){}, child: const Text('清除记忆'))),
                            _buildTextField(_memoryController, hint: '我还没有记忆。', enabled: false),
                            const SizedBox(height: 24),

                            _buildSectionTitle('模型配置'),
                            _buildModelConfigSection(_agent!),
                            const SizedBox(height: 24),

                            Row(
                              children: [
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildSectionTitle('对话语言'), _buildLanguageDropdown()],)),
                                const SizedBox(width: 16),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildSectionTitle('角色音色'), _buildVoiceDropdown()],)),
                              ],
                            ),
                          ],
                        ),
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
    final uniqueVoices = voices.toSet().toList();
     return DropdownButtonFormField<String>(
      value: _selectedVoice,
      items: uniqueVoices.map((voice) => DropdownMenuItem(value: voice, child: Text(voice))).toList(),
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

  Widget _buildModelConfigSection(AgentDetail agent) {
    // 这里用mock数据，实际可用接口数据
    final vadModels = [agent.vadModelId];
    final asrModels = [agent.asrModelId];
    final llmModels = [agent.llmModelId];
    final vllmModels = [agent.vllmModelId];
    final intentModels = [agent.intentModelId];
    final memoryModels = [agent.memModelId];
    final ttsModels = [agent.ttsModelId];
    final ttsVoices = [agent.ttsVoiceId];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // VAD + ASR
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('语音活动检测(VAD)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: agent.vadModelId,
                      items: vadModels.toSet().map((id) => DropdownMenuItem(value: id, child: Text(id))).toList(),
                      onChanged: (value) {},
                      decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('语音识别(ASR)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: agent.asrModelId,
                      items: asrModels.toSet().map((id) => DropdownMenuItem(value: id, child: Text(id))).toList(),
                      onChanged: (value) {},
                      decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // LLM
        const Text('大语言模型(LLM)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: agent.llmModelId,
            items: llmModels.toSet().map((id) => DropdownMenuItem(value: id, child: Text(id))).toList(),
            onChanged: (value) {},
            decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
          ),
        ),
        const SizedBox(height: 20),
        // VLLM
        const Text('视觉大模型(VLLM)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: agent.vllmModelId,
            items: vllmModels.toSet().map((id) => DropdownMenuItem(value: id, child: Text(id))).toList(),
            onChanged: (value) {},
            decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
          ),
        ),
        const SizedBox(height: 20),
        // Intent
        const Text('意图识别(Intent)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: agent.intentModelId,
            items: intentModels.toSet().map((id) => DropdownMenuItem(value: id, child: Text(id))).toList(),
            onChanged: (value) {},
            decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
          ),
        ),
        const SizedBox(height: 20),
        // Memory
        const Text('记忆(Memory)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: agent.memModelId,
            items: memoryModels.toSet().map((id) => DropdownMenuItem(value: id, child: Text(id))).toList(),
            onChanged: (value) {},
            decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
          ),
        ),
        const SizedBox(height: 20),
        // TTS
        const Text('语音合成(TTS)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: agent.ttsModelId,
            items: ttsModels.toSet().map((id) => DropdownMenuItem(value: id, child: Text(id))).toList(),
            onChanged: (value) {},
            decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
          ),
        ),
        const SizedBox(height: 20),
        // TTS Voice
        const Text('角色音色', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: agent.ttsVoiceId,
            items: ttsVoices.toSet().map((id) => DropdownMenuItem(value: id, child: Text(id))).toList(),
            onChanged: (value) {},
            decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
          ),
        ),
      ],
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