import '../data/agent.dart';

List<Agent> getMockAgents() {
  return [
    Agent(
      id: 1, 
      userId: 1,
      agentName: '小智', 
      ttsVoice: '女神', 
      llmModel: 'openAI', 
      assistantName: '小助理', 
      userName: '天平', 
      character: '小河', 
      language: '中文',
      longMemorySwitch: 1,
      langCode: 'zh',
      ttsSpeechSpeed: 'normal',
      asrSpeed: 'normal',
      ttsPitch: 0,
      deviceCount: 1,
      createdAt: '2024-01-01',
      updatedAt: '2024-01-01',
    ),
    Agent(
      id: 2, 
      userId: 1,
      agentName: '小梦', 
      ttsVoice: '御姐', 
      llmModel: 'Kimi', 
      assistantName: '大助理', 
      userName: '小芳', 
      character: '小溪', 
      language: '英文',
      longMemorySwitch: 1,
      langCode: 'en',
      ttsSpeechSpeed: 'normal',
      asrSpeed: 'normal',
      ttsPitch: 0,
      deviceCount: 2,
      createdAt: '2024-01-01',
      updatedAt: '2024-01-01',
    ),
    Agent(
      id: 3, 
      userId: 1,
      agentName: '小慧', 
      ttsVoice: '萝莉', 
      llmModel: 'Gemini', 
      assistantName: '中助理', 
      userName: '小明', 
      character: '小江', 
      language: '日文',
      longMemorySwitch: 1,
      langCode: 'ja',
      ttsSpeechSpeed: 'normal',
      asrSpeed: 'normal',
      ttsPitch: 0,
      deviceCount: 3,
      createdAt: '2024-01-01',
      updatedAt: '2024-01-01',
    ),
  ];
}

Agent getMockAgent() {
  return Agent(
    id: 1, 
    userId: 1,
    agentName: '小智', 
    ttsVoice: '女神', 
    llmModel: 'openAI', 
    assistantName: '小助理', 
    userName: '天平', 
    character: '小河', 
    language: '中文',
    longMemorySwitch: 1,
    langCode: 'zh',
    ttsSpeechSpeed: 'normal',
    asrSpeed: 'normal',
    ttsPitch: 0,
    deviceCount: 1,
    createdAt: '2024-01-01',
    updatedAt: '2024-01-01',
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