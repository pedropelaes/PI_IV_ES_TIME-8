@echo off
setlocal enabledelayedexpansion

REM --- Configuracao de Variaveis ---
set "BUILD_DIR=out"
set "SRC_DIR=src"
set "LIBS_DIR=libs"

REM --- Passo 1: Limpeza do Build Anterior ---
if exist "%BUILD_DIR%" (
    echo Limpando build anterior...
    rmdir /s /q "%BUILD_DIR%"
)
echo Criando diretorio de build...
mkdir "%BUILD_DIR%"

REM --- Passo 2: Compilacao ---
echo Compilando fontes para a pasta '%BUILD_DIR%'...

set "SOURCE_FILES="
for /r %SRC_DIR% %%f in (*.java) do (
    set "SOURCE_FILES=!SOURCE_FILES! "%%f""
)

javac -d "%BUILD_DIR%" -cp "%LIBS_DIR%/*" -encoding UTF-8 %SOURCE_FILES%

if %errorlevel% neq 0 (
    echo.
    echo ERRO: A compilacao falhou.
    pause
    exit /b
)

REM --- Passo 3: Copiando Arquivos de Recursos ---
echo Copiando arquivos de configuracao...
REM Esta linha e crucial para resolver o problema dos logs.
copy "%SRC_DIR%\simplelogger.properties" "%BUILD_DIR%\"

REM --- Passo 4: Execucao ---
echo Iniciando o servidor...
REM O nome da classe principal e apenas "Servidor", pois esta na raiz.
java -cp "%BUILD_DIR%;%LIBS_DIR%/*" src.Servidor
