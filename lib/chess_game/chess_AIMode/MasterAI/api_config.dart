// API Configuration
// IMPORTANT: Never commit real API keys to git!
// Copy this file and add your real keys, then add the file to .gitignore

class APIConfig {
  // Groq API Configuration
  static const String groqKey = 'YOUR_GROQ_API_KEY_HERE';
  static const String groqEndpoint = 'https://api.groq.com/openai/v1/chat/completions';
  
  // OpenRouter API Configuration
  static const String openRouterKey = 'YOUR_OPENROUTER_API_KEY_HERE';
  static const String openRouterEndpoint = 'https://openrouter.ai/api/v1/chat/completions';
  
  // Perplexity API Configuration
  static const String perplexityKey = 'YOUR_PERPLEXITY_API_KEY_HERE';
  
  // Active provider: 'groq', 'openrouter', or 'perplexity'
  static const String activeProvider = 'groq';
}
