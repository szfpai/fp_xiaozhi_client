import '../data/agent.dart';

class HomeMock {
  static List<Agent> getAgents() {
    return [
      Agent(id: 1, agentName: '小智', ttsVoice: '女神', llmModel: 'openAI', assistantName: '小助理', userName: '天平', character: '小河', language: '中文', deviceCount: 1),
      Agent(id: 2, agentName: '小梦', ttsVoice: '御姐', llmModel: 'Kimi', assistantName: '大助理', userName: '小芳', character: '小溪', language: '英文', deviceCount: 2),
      Agent(id: 3, agentName: '小慧', ttsVoice: '萝莉', llmModel: 'Gemini', assistantName: '中助理', userName: '小明', character: '小江', language: '日文', deviceCount: 3),
    ];
  }
}