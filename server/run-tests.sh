#!/bin/bash

# --- Configuracao de Variaveis ---
BUILD_DIR="out"
SRC_DIR="src"
TEST_DIR="test"
LIBS_DIR="libs"

# --- Passo 1: Limpeza do Build Anterior (apenas test) ---
if [ -d "$BUILD_DIR/test" ]; then
    echo "Limpando build anterior dos testes..."
    rm -rf "$BUILD_DIR/test"
fi

# --- Passo 2: Compilacao dos arquivos src (sempre compila para garantir) ---
echo "Compilando fontes do src para a pasta '$BUILD_DIR'..."
SOURCES=$(find "$SRC_DIR" -name "*.java")
javac -d "$BUILD_DIR" -cp "$LIBS_DIR/*" -encoding UTF-8 $SOURCES

if [ $? -ne 0 ]; then
    echo ""
    echo "ERRO: A compilacao do src falhou."
    exit 1
fi

# --- Passo 3: Compilacao do arquivo AllTests.java ---
echo "Compilando arquivo de teste AllTests.java para a pasta '$BUILD_DIR'..."

# Compila apenas o AllTests.java incluindo o classpath com src compilado e libs
javac -d "$BUILD_DIR" -cp "$BUILD_DIR:$LIBS_DIR/*" -encoding UTF-8 "$TEST_DIR/AllTests.java"

if [ $? -ne 0 ]; then
    echo ""
    echo "ERRO: A compilacao dos testes falhou."
    exit 1
fi

# --- Passo 4: Execucao dos testes ---
echo ""
echo "Executando todos os testes..."
echo ""
java -cp "$BUILD_DIR:$LIBS_DIR/*" test.AllTests

if [ $? -ne 0 ]; then
    echo ""
    echo "ERRO: A execucao dos testes falhou."
    exit 1
fi

echo ""
echo "Testes concluidos!"

