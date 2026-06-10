#!/bin/bash
# =============================================
# entrypoint.sh for Go IDE Container with Ollama
# =============================================

set -e

echo "🚀 Starting Go IDE with Ollama..."

# Start Ollama in background
echo "Starting Ollama server..."
ollama serve > /var/log/ollama.log 2>&1 &
OLLAMA_PID=$!

# Wait for Ollama to be ready
echo "Waiting for Ollama to start..."
for i in {1..30}; do
    if curl -s http://localhost:11434/api/tags > /dev/null; then
        echo "✅ Ollama is ready!"
        break
    fi
    sleep 1
done

# Optional: Pull models if not present (uncomment if you want auto-pull)
echo "Pulling models (this may take time on first run)..."
ollama pull llama3.2:3b
ollama pull qwen2.5-coder:7b

# Source bashrc
source /root/.bashrc

echo "======================================"
echo "✅ IDE Ready! Emacs + Ollama + gopls"
echo "Ollama UI: http://localhost:11434"
echo "Connect Emacs: emacsclient -c -n"
echo "======================================"

# Start Emacs daemon
emacs --daemon

echo "Emacs daemon started. Connect with 'emacsclient -c'"

# Keep container running
tail -f /dev/null
