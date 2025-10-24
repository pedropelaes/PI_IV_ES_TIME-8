#!/bin/bash

# --- Configuracao de Variaveis ---
BUILD_DIR="out"
SRC_DIR="src"
LIBS_DIR="libs"

# --- Passo 1: Limpeza do Build Anterior ---
echo "Limpando build anterior..."
rm -rf "$BUILD_DIR"
echo "Criando diretorio de build..."
mkdir "$BUILD_DIR"

# --- Passo 2: Compilacao ---
echo "Compilando fontes para a pasta '$BUILD_DIR'..."

# Encontra todos os arquivos .java dentro da pasta 'src'
SOURCES=$(find "$SRC_DIR" -name "*.java")

# Compila os arquivos para o diretorio de build (-d)
# O separador de classpath no Linux e ':'
javac -d "$BUILD_DIR" -cp "$LIBS_DIR/*" -encoding UTF-8 $SOURCES

# Verifica se a compilacao falhou
if [ $? -ne 0 ]; then
    echo ""
    echo "ERRO: A compilacao falhou."
    exit 1
fi

# --- Passo 3: Copiando Arquivos de Recursos ---
echo "Copiando arquivos de configuracao..."
# Copia o simplelogger.properties para a raiz da pasta de build.
cp "$SRC_DIR/simplelogger.properties" "$BUILD_DIR/"

# --- Passo 4: Execucao ---
echo "Iniciando o servidor..."
# Usa o separador ':' para o classpath
# Adiciona seus parametros SSL
#
# ATENCAO: Baseado na sua estrutura de pastas (imagem), a classe principal e 'Servidor'
# (pois esta na raiz de 'src'). O 'src.Servidor' do seu script estava incorreto.
java -Djavax.net.ssl.trustStore=/usr/lib/jvm/temurin-17-jdk/lib/security/cacerts \
     -Djavax.net.ssl.trustStorePassword=changeit \
     -cp "$BUILD_DIR:$LIBS_DIR/*" \
     src.Servidor