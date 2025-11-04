# NestJS API with Docker, NVM and Datadog APM

A simple NestJS API with 2 endpoints, configured with Docker, NVM support and Datadog Application Performance Monitoring (APM).

## Endpoints

- `GET /health` - Returns health status and timestamp
- `GET /info` - Returns API information

## Prerequisites

- Docker installed
- Or Node.js 20+ (managed via NVM)
- Datadog API Key (for APM monitoring)

## Datadog Configuration

This application uses Datadog APM for monitoring and tracing. The `dd-trace` library sends data directly to Datadog without requiring a local Agent.

### Environment Variables

Configure these environment variables in your deployment platform (Koyeb, Heroku, etc.):

```bash
DD_API_KEY=your_datadog_api_key_here
DD_SITE=us5.datadoghq.com
DD_ENV=production
DD_SERVICE=nest-datadog-poc
DD_VERSION=1.0.0
DD_TRACE_AGENT_URL=https://trace.agent.us5.datadoghq.com
DD_LOGS_INJECTION=true
```

See `env.example` for a complete list of environment variables.

## Running with Docker

```bash
# Build the image
docker build -t nest-datadog-poc .

# Run the container with Datadog env vars
docker run -p 3000:3000 \
  -e DD_API_KEY=your_api_key \
  -e DD_SITE=us5.datadoghq.com \
  -e DD_ENV=development \
  -e DD_SERVICE=nest-datadog-poc \
  -e DD_VERSION=1.0.0 \
  nest-datadog-poc
```

## Running locally with NVM

```bash
# Install Node.js version specified in .nvmrc
nvm install
nvm use

# Install dependencies
npm install

# Run in development mode
npm run start:dev

# Or build and run production
npm run build
npm run start:prod
```

## Testing

### Automated Testing Script

Execute o script de teste automatizado que irá:
1. Construir a imagem Docker
2. Executar o container
3. Testar ambos os endpoints
4. Gerar arquivo de evidências

```bash
./test.sh
```

Ou manualmente:

```bash
# Build image
docker build -t nest-datadog-poc .

# Run container
docker run -d -p 3000:3000 --name nest-api nest-datadog-poc

# Test endpoints
curl http://localhost:3000/health
curl http://localhost:3000/info

# Check logs
docker logs nest-api

# Stop and remove container
docker stop nest-api && docker rm nest-api
```

O script `test.sh` gera automaticamente um arquivo `evidencias.txt` com todos os resultados dos testes.

## Deploying to Koyeb

1. Install dependencies:
```bash
npm install
```

2. Set environment variables in Koyeb dashboard:
   - `DD_API_KEY` - Your Datadog API key
   - `DD_SITE` - Your Datadog site (e.g., `us5.datadoghq.com`)
   - `DD_ENV` - Environment name (e.g., `production`)
   - `DD_SERVICE` - Service name (e.g., `nest-datadog-poc`)
   - `DD_VERSION` - Version (e.g., `1.0.0`)
   - `DD_TRACE_AGENT_URL` - Datadog trace endpoint (e.g., `https://trace.agent.us5.datadoghq.com`)

3. Deploy from GitHub or Docker Hub

4. Check Datadog APM dashboard to see traces and metrics

## Datadog Features Enabled

- ✅ **APM Tracing**: Automatic instrumentation of HTTP requests, database queries, etc.
- ✅ **Runtime Metrics**: CPU, memory, and garbage collection metrics
- ✅ **Profiling**: Continuous profiling for performance optimization
- ✅ **Log Injection**: Correlate logs with traces using trace IDs

## Viewing Datadog Events and Traces

### Using Native Datadog Debug Logging

O Datadog fornece logging nativo através da variável de ambiente `DD_TRACE_DEBUG`. Quando habilitado, o `dd-trace` loga automaticamente todos os eventos, spans e traces no console.

**Para habilitar o debug logging:**

```bash
export DD_TRACE_DEBUG=true
npm run start:dev
```

Ou no Docker:

```bash
docker run -p 3000:3000 \
  -e DD_TRACE_DEBUG=true \
  -e DD_API_KEY=your_api_key \
  -e DD_SITE=us5.datadoghq.com \
  nest-datadog-poc
```

Com `DD_TRACE_DEBUG=true`, você verá no console:
- Criação de spans HTTP
- Finalização de spans
- Envio de traces para o Datadog
- Erros e avisos do tracer
- Informações de sampling e rate limiting

**Exemplo de output:**

```
[DD-TRACE DEBUG] Starting span http.request
[DD-TRACE DEBUG] Finishing span http.request (duration: 45ms)
[DD-TRACE DEBUG] Sending trace to agent
```

### Viewing Traces in Datadog Dashboard

Após enviar traces, visualize-os no dashboard do Datadog:

1. Acesse **APM > Services** no Datadog
2. Selecione o serviço `nest-datadog-poc`
3. Veja traces detalhados, spans, métricas e performance

### Additional Debug Options

Você também pode usar outras variáveis de ambiente nativas do Datadog:

- `DD_TRACE_SAMPLE_RATE` - Taxa de sampling (0.0 a 1.0)
- `DD_TRACE_STARTUP_LOGS` - Logs de inicialização (já habilitado por padrão)
- `DD_TRACE_AGENT_URL` - URL customizada do agent
