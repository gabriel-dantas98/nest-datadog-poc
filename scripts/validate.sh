#!/bin/bash

echo "================================================"
echo "VALIDAÇÃO DA ESTRUTURA DO PROJETO"
echo "================================================"
echo ""

# Check required files
echo "✅ Verificando arquivos essenciais..."

files=(
    "package.json"
    "Dockerfile"
    ".nvmrc"
    "src/main.ts"
    "src/app.module.ts"
    "src/app.controller.ts"
    "test.sh"
    "README.md"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✓ $file"
    else
        echo "  ✗ $file (FALTANDO)"
        exit 1
    fi
done

echo ""
echo "✅ Verificando estrutura de diretórios..."

if [ -d "src" ]; then
    echo "  ✓ Diretório src/"
else
    echo "  ✗ Diretório src/ (FALTANDO)"
    exit 1
fi

echo ""
echo "✅ Verificando configuração do NVM..."

if [ -f ".nvmrc" ]; then
    NODE_VERSION=$(cat .nvmrc)
    echo "  ✓ Versão do Node.js especificada: $NODE_VERSION"
else
    echo "  ✗ Arquivo .nvmrc não encontrado"
    exit 1
fi

echo ""
echo "✅ Verificando Dockerfile..."

if grep -q "NVM" Dockerfile; then
    echo "  ✓ Dockerfile contém configuração do NVM"
else
    echo "  ⚠ Dockerfile pode não ter configuração do NVM"
fi

if grep -q "FROM.*AS.*production" Dockerfile; then
    echo "  ✓ Dockerfile usa multi-stage build"
else
    echo "  ⚠ Dockerfile pode não usar multi-stage build"
fi

echo ""
echo "✅ Verificando endpoints no controller..."

if grep -q "@Get('health')" src/app.controller.ts; then
    echo "  ✓ Endpoint /health encontrado"
else
    echo "  ✗ Endpoint /health não encontrado"
    exit 1
fi

if grep -q "@Get('info')" src/app.controller.ts; then
    echo "  ✓ Endpoint /info encontrado"
else
    echo "  ✗ Endpoint /info não encontrado"
    exit 1
fi

echo ""
echo "================================================"
echo "✅ VALIDAÇÃO CONCLUÍDA COM SUCESSO!"
echo "================================================"
echo ""
echo "Próximos passos:"
echo "  1. Certifique-se de que o Docker está instalado e rodando"
echo "  2. Execute: ./test.sh"
echo "  3. Verifique o arquivo evidencias.txt gerado"
echo ""
