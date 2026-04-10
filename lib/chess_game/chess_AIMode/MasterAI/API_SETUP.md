# API Configuration Setup

## Important Security Notice
**NEVER commit real API keys to git!** This can expose your keys and lead to unauthorized usage.

## Setup Instructions

1. Open `lib/chess_AIMode/MasterAI/api_config.dart`
2. Replace the placeholder values with your actual API keys:
   - `YOUR_GROQ_API_KEY_HERE` → Your Groq API key
   - `YOUR_OPENROUTER_API_KEY_HERE` → Your OpenRouter API key
   - `YOUR_PERPLEXITY_API_KEY_HERE` → Your Perplexity API key

3. **DO NOT commit this file with real keys!**

## Getting API Keys

### Groq API
1. Visit https://console.groq.com/
2. Sign up or log in
3. Navigate to API Keys section
4. Create a new API key

### OpenRouter API
1. Visit https://openrouter.ai/
2. Sign up or log in
3. Go to Keys section
4. Generate a new API key

### Perplexity API
1. Visit https://www.perplexity.ai/
2. Sign up for API access
3. Generate your API key

## Alternative: Use Environment Variables (Recommended for Production)

For better security, consider using environment variables or a secure key management system instead of hardcoding keys in the source code.
