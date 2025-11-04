#!/bin/bash

set -e

OUTPUT_FILE="evidencias.txt"
CONTAINER_NAME="nest-datadog-poc-test"
IMAGE_NAME="nest-datadog-poc"

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker não está instalado ou não está no PATH"
    echo "Por favor, instale o Docker e tente novamente."
    exit 1
fi

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    echo "❌ Docker daemon não está rodando"
    echo "Por favor, inicie o Docker e tente novamente."
    exit 1
fi

echo "================================================" > $OUTPUT_FILE
echo "EVIDÊNCIAS DE EXECUÇÃO - NestJS API" >> $OUTPUT_FILE
echo "Data: $(date)" >> $OUTPUT_FILE
echo "================================================" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# Cleanup function
cleanup() {
    echo "Limpando containers existentes..." >> $OUTPUT_FILE
    docker stop $CONTAINER_NAME 2>/dev/null || true
    docker rm $CONTAINER_NAME 2>/dev/null || true
    echo "" >> $OUTPUT_FILE
}

cleanup

# 1. Build Docker Image
echo "## 1. BUILD DA IMAGEM DOCKER" >> $OUTPUT_FILE
echo "----------------------------------------" >> $OUTPUT_FILE
echo "Comando: docker build -t $IMAGE_NAME ." >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE
echo "Saída:" >> $OUTPUT_FILE
echo "---" >> $OUTPUT_FILE

if docker build -t $IMAGE_NAME . >> $OUTPUT_FILE 2>&1; then
    echo "✅ Build da imagem concluído com sucesso!" >> $OUTPUT_FILE
else
    echo "❌ Erro no build da imagem" >> $OUTPUT_FILE
    exit 1
fi

echo "" >> $OUTPUT_FILE
echo "---" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# 2. Run Docker Container
echo "## 2. EXECUÇÃO DO CONTAINER DOCKER" >> $OUTPUT_FILE
echo "----------------------------------------" >> $OUTPUT_FILE
echo "Comando: docker run -d -p 3000:3000 --name $CONTAINER_NAME $IMAGE_NAME" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE
echo "Saída:" >> $OUTPUT_FILE
echo "---" >> $OUTPUT_FILE

if docker run -d -p 3000:3000 --name $CONTAINER_NAME $IMAGE_NAME >> $OUTPUT_FILE 2>&1; then
    echo "✅ Container iniciado com sucesso!" >> $OUTPUT_FILE
else
    echo "❌ Erro ao iniciar container" >> $OUTPUT_FILE
    exit 1
fi

echo "" >> $OUTPUT_FILE
echo "---" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# Wait for application to start
echo "Aguardando aplicação iniciar..." >> $OUTPUT_FILE
sleep 5

# 3. Test Endpoints
echo "## 3. TESTE DOS ENDPOINTS" >> $OUTPUT_FILE
echo "----------------------------------------" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# Test /health endpoint
echo "### Endpoint: GET /health" >> $OUTPUT_FILE
echo "Comando: curl http://localhost:3000/health" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE
echo "Resposta:" >> $OUTPUT_FILE
echo "---" >> $OUTPUT_FILE
if curl -s http://localhost:3000/health >> $OUTPUT_FILE 2>&1; then
    echo "" >> $OUTPUT_FILE
    echo "✅ Endpoint /health respondeu com sucesso!" >> $OUTPUT_FILE
else
    echo "❌ Erro ao testar endpoint /health" >> $OUTPUT_FILE
fi
echo "---" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# Test /info endpoint
echo "### Endpoint: GET /info" >> $OUTPUT_FILE
echo "Comando: curl http://localhost:3000/info" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE
echo "Resposta:" >> $OUTPUT_FILE
echo "---" >> $OUTPUT_FILE
if curl -s http://localhost:3000/info >> $OUTPUT_FILE 2>&1; then
    echo "" >> $OUTPUT_FILE
    echo "✅ Endpoint /info respondeu com sucesso!" >> $OUTPUT_FILE
else
    echo "❌ Erro ao testar endpoint /info" >> $OUTPUT_FILE
fi
echo "---" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# 4. Container logs
echo "## 4. LOGS DO CONTAINER" >> $OUTPUT_FILE
echo "----------------------------------------" >> $OUTPUT_FILE
echo "Comando: docker logs $CONTAINER_NAME" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE
echo "Saída:" >> $OUTPUT_FILE
echo "---" >> $OUTPUT_FILE
docker logs $CONTAINER_NAME >> $OUTPUT_FILE 2>&1
echo "---" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# 5. Container status
echo "## 5. STATUS DO CONTAINER" >> $OUTPUT_FILE
echo "----------------------------------------" >> $OUTPUT_FILE
echo "Comando: docker ps --filter name=$CONTAINER_NAME" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE
echo "Saída:" >> $OUTPUT_FILE
echo "---" >> $OUTPUT_FILE
docker ps --filter name=$CONTAINER_NAME >> $OUTPUT_FILE 2>&1
echo "---" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

echo "================================================" >> $OUTPUT_FILE
echo "TESTES CONCLUÍDOS!" >> $OUTPUT_FILE
echo "================================================" >> $OUTPUT_FILE

# Cleanup
cleanup

echo ""
echo "✅ Todos os testes foram executados!"
echo "📄 Evidências salvas em: $OUTPUT_FILE"
echo ""
echo "Para ver os resultados:"
echo "  cat $OUTPUT_FILE"
echo ""
echo "Para limpar o container manualmente:"
echo "  docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME"
