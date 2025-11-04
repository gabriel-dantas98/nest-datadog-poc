# Configuração Datadog na Koyeb

Este guia explica como configurar o Datadog APM na Koyeb para este projeto.

## Por que não usar o Datadog Agent?

Na Koyeb (e outras plataformas PaaS/serverless), você **NÃO pode** rodar o Datadog Agent como container separado. Em vez disso, usamos a biblioteca `dd-trace` que envia dados **diretamente** para o Datadog via HTTPS (agentless mode).

## Configuração

### 1. Instalar Dependências

```bash
npm install
```

Isso instalará o `dd-trace` que já está no `package.json`.

### 2. Configurar Environment Variables na Koyeb

No painel da Koyeb, adicione estas variáveis de ambiente:

| Variable | Value | Description |
|----------|-------|-------------|
| `DD_API_KEY` | `c77d96e1f05c73e31727655e910de18c` | Sua chave de API do Datadog |
| `DD_SITE` | `us5.datadoghq.com` | Site do Datadog (região US5) |
| `DD_ENV` | `production` | Nome do ambiente |
| `DD_SERVICE` | `nest-datadog-poc` | Nome do serviço |
| `DD_VERSION` | `1.0.0` | Versão da aplicação |
| `DD_TRACE_AGENT_URL` | `https://trace.agent.us5.datadoghq.com` | Endpoint público do Datadog |
| `DD_LOGS_INJECTION` | `true` | Correlaciona logs com traces |

### 3. Deploy

O Dockerfile já está configurado para inicializar o tracer automaticamente:

```dockerfile
CMD ["node", "-r", "dd-trace/init", "dist/main"]
```

O `-r dd-trace/init` carrega o tracer antes da aplicação iniciar.

### 4. Verificar

Após o deploy, acesse o dashboard do Datadog:

1. Vá para **APM > Services**
2. Procure pelo serviço `nest-datadog-poc`
3. Você verá traces, métricas e performance

## O que foi instrumentado?

O `dd-trace` instrumenta automaticamente:

- ✅ HTTP requests (Express/NestJS)
- ✅ Database queries (se adicionar MongoDB, PostgreSQL, etc.)
- ✅ Redis, Elasticsearch, gRPC
- ✅ Runtime metrics (CPU, memória, GC)
- ✅ Profiling contínuo

## Troubleshooting

### Não vejo traces no Datadog

1. Verifique se a `DD_API_KEY` está correta
2. Verifique se `DD_TRACE_AGENT_URL` aponta para o site correto (`us5`)
3. Verifique os logs da aplicação para erros do tracer
4. Faça algumas requisições nos endpoints `/health` e `/info`

### Logs do tracer

O tracer imprime no console quando inicializado:

```
Datadog APM enabled
```

### Testar localmente

```bash
export DD_API_KEY=c77d96e1f05c73e31727655e910de18c
export DD_SITE=us5.datadoghq.com
export DD_ENV=development
export DD_SERVICE=nest-datadog-poc
export DD_VERSION=1.0.0

npm run start:dev
```

Faça requisições e verifique no Datadog.

## Referências

- [Datadog APM Node.js](https://docs.datadoghq.com/tracing/setup_overview/setup/nodejs/)
- [Datadog Agentless Mode](https://docs.datadoghq.com/agent/guide/how_remote_config_works/)
- [dd-trace NPM](https://www.npmjs.com/package/dd-trace)
