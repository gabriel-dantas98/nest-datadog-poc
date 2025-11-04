# Scripts

Scripts auxiliares para desenvolvimento e testes.

## docker-test.sh

Script completo de teste que executa:
1. Build da imagem Docker
2. Verificação do arquivo de ambiente
3. Start do container
4. Aguarda a aplicação ficar pronta (timeout 30s)
5. Health check do endpoint
6. Exibe estatísticas do container

### Uso

```bash
# Roda os testes e mantém o container rodando
./scripts/docker-test.sh

# Roda os testes e limpa tudo ao final
./scripts/docker-test.sh --cleanup
```

### Logs

Build logs são salvos em `/tmp/docker-build.log` para troubleshooting.
