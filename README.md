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
