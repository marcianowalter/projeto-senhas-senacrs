from flask import Flask, render_template, request
import redis
import string
import random
import os
from prometheus_client import Counter, start_http_server, generate_latest

app = Flask(__name__)

# Configurações do Redis via variáveis de ambiente
redis_host = os.environ.get('REDIS_HOST', 'redis')
redis_port = int(os.environ.get('REDIS_PORT', 6379))
redis_password = os.environ.get('REDIS_PASSWORD', '')

# Conexão com Redis
r = redis.StrictRedis(
    host=redis_host,
    port=redis_port,
    password=redis_password,
    decode_responses=True
)

# Métrica Prometheus
senha_gerada_counter = Counter('senha_gerada', 'Contador de senhas geradas')

# Função para criar senha
def criar_senha(tamanho, incluir_numeros, incluir_caracteres_especiais):
    caracteres = string.ascii_letters
    if incluir_numeros:
        caracteres += string.digits
    if incluir_caracteres_especiais:
        caracteres += string.punctuation
    return ''.join(random.choices(caracteres, k=tamanho))

# Rota principal
@app.route('/', methods=['GET', 'POST'])
def index():
    senha = None
    if request.method == 'POST':
        tamanho = int(request.form.get('tamanho', 8))
        incluir_numeros = request.form.get('incluir_numeros') == 'on'
        incluir_caracteres_especiais = request.form.get('incluir_caracteres_especiais') == 'on'
        senha = criar_senha(tamanho, incluir_numeros, incluir_caracteres_especiais)
        r.lpush("senhas", senha)
        senha_gerada_counter.inc()

    senhas_raw = r.lrange("senhas", 0, 9)
    senhas_geradas = [{"id": i + 1, "senha": s} for i, s in enumerate(senhas_raw)]

    return render_template("index.html", senha=senha, senhas_geradas=senhas_geradas)

# Rota de métricas Prometheus
@app.route('/metrics')
def metrics():
    return generate_latest(), 200, {'Content-Type': 'text/plain; charset=utf-8'}

# Inicialização
if __name__ == "__main__":
    start_http_server(8000)  # Porta Prometheus
    app.run(host="0.0.0.0", port=5000, debug=True)
