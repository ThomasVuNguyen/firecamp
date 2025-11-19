# Feature 1
Goal:
An AI always present in every chat session. 
I can always tag the AI to activate it, it will get the entire conversation context and answer.

Execution:
Place a .env file with your CloudRift API key, using their chat completions endpoint:

```bash
curl -X POST https://inference.cloudrift.ai/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_RIFT_API_KEY" \
  -d '{ 
    "model": "deepseek-ai/DeepSeek-R1-0528",
    "messages": [
      {"role": "user", "content": "What is the meaning of life?"}
    ],
    "stream": true
  }'
```
