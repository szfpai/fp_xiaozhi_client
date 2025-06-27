import '../data/agent.dart';

List<Agent> getMockAgents() {
  return [
    Agent(
      id: '1', 
      agentName: '小智', 
      ttsModelName: 'Edge语音合成',
      ttsVoiceName: 'EdgeTTS女声-晓晓',
      llmModelName: '智谱AI',
      vllmModelName: '智谱视觉AI',
      memModelId: 'Memory_nomem',
      systemPrompt: '你是小智，一个友好的AI助手。',
      deviceCount: 1,
    ),
    Agent(
      id: '2', 
      agentName: '小梦', 
      ttsModelName: 'Edge语音合成',
      ttsVoiceName: 'EdgeTTS男声-云扬',
      llmModelName: '智谱AI',
      vllmModelName: '智谱视觉AI',
      memModelId: 'Memory_nomem',
      systemPrompt: '你是小梦，一个专业的AI助手。',
      deviceCount: 2,
    ),
    Agent(
      id: '3', 
      agentName: '小慧', 
      ttsModelName: 'Edge语音合成',
      ttsVoiceName: 'EdgeTTS女声-晓伊',
      llmModelName: '智谱AI',
      vllmModelName: '智谱视觉AI',
      memModelId: 'Memory_nomem',
      systemPrompt: '你是小慧，一个聪明的AI助手。',
      deviceCount: 3,
    ),
  ];
}

Agent getMockAgent() {
  return Agent(
    id: '1', 
    agentName: '小智', 
    ttsModelName: 'Edge语音合成',
    ttsVoiceName: 'EdgeTTS女声-晓晓',
    llmModelName: '智谱AI',
    vllmModelName: '智谱视觉AI',
    memModelId: 'Memory_nomem',
    systemPrompt: '你是小智，一个友好的AI助手。',
    deviceCount: 1,
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