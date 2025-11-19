# firecamp
chat together, with AI

## Running locally

```
curl https://mise.jdx.dev/install.sh | sh
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
sudo apt-get install -y sqlite3 redis-server

cd /home/ubuntu/firecamp
mise install && bundle install
bin/rails db:prepare
bin/rails server -b 0.0.0.0 -p 1306

```

## AI assistant

1. Copy `.env.example` to `.env` and add your CloudRift API key plus any optional tuning parameters (model id, temperature, top-p, stop sequences, etc.).
2. Verify your credentials by running `ruby script/test_ai_client.rb "Hello"`—it loads `.env` and sends a request to CloudRift so you can confirm everything works before booting the app.
3. Start the server and mention **@Campfire AI** inside any room. The assistant receives the full conversation context and replies via the CloudRift model, and its Markdown output (lists, code blocks, bold text, etc.) is rendered inline in the chat.

If the credentials are missing, the assistant will remind you to fill out the `.env` file.
