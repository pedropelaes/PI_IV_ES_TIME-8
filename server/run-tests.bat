@echo off
setlocal enabledelayedexpansion

REM --- Configuracao de Variaveis ---
set "BUILD_DIR=out"
set "SRC_DIR=src"
set "TEST_DIR=test"
set "LIBS_DIR=libs"

REM --- Passo 1: Limpeza do Build Anterior (apenas test) ---
if exist "%BUILD_DIR%\test" (
    echo Limpando build anterior dos testes...
    rmdir /s /q "%BUILD_DIR%\test"
)

REM --- Passo 2: Compilacao dos arquivos src (sempre compila para garantir) ---
echo Compilando fontes do src para a pasta '%BUILD_DIR%'...
set "SOURCE_FILES="
for /r %SRC_DIR% %%f in (*.java) do (
    set "SOURCE_FILES=!SOURCE_FILES! "%%f""
)
javac -d "%BUILD_DIR%" -cp "%LIBS_DIR%/*" -encoding UTF-8 %SOURCE_FILES%
if %errorlevel% neq 0 (
    echo.
    echo ERRO: A compilacao do src falhou.
    pause
    exit /b
)

REM --- Passo 3: Compilacao do arquivo AllTests.java ---
echo Compilando arquivo de teste AllTests.java para a pasta '%BUILD_DIR%'...

REM Compila apenas o AllTests.java incluindo o classpath com src compilado e libs
javac -d "%BUILD_DIR%" -cp "%BUILD_DIR%;%LIBS_DIR%/*" -encoding UTF-8 "%TEST_DIR%\AllTests.java"

if %errorlevel% neq 0 (
    echo.
    echo ERRO: A compilacao dos testes falhou.
    pause
    exit /b
)

REM --- Passo 4: Execucao dos testes ---
echo.
echo Executando todos os testes...
echo.
java -cp "%BUILD_DIR%;%LIBS_DIR%/*" test.AllTests

if %errorlevel% neq 0 (
    echo.
    echo ERRO: A execucao dos testes falhou.
    pause
    exit /b
)

echo.
echo Testes concluidos!
pause

