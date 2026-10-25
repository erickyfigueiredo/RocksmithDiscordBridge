$ErrorActionPreference = 'Stop'
$taskPython = Get-Command py -ErrorAction SilentlyContinue
if ($taskPython) {
    & py -3.12 -c "import sys,struct,tkinter; assert struct.calcsize('P')==8; print(sys.version)"
    if ($LASTEXITCODE -ne 0) { throw 'Instale Python 3.12 x64 completo com tkinter em python.org.' }
    & py -3.12 -m venv (Join-Path $PSScriptRoot '.venv')
} else {
    & python -c "import sys,struct,tkinter; assert sys.version_info >= (3,11) and struct.calcsize('P')==8; print(sys.version)"
    if ($LASTEXITCODE -ne 0) { throw 'Instale Python 3.12 x64 completo com tkinter em python.org.' }
    & python -m venv (Join-Path $PSScriptRoot '.venv')
}
if ($LASTEXITCODE -ne 0) { throw 'Não foi possível criar o ambiente Python.' }
$taskExe = Join-Path $PSScriptRoot '.venv\Scripts\python.exe'
& $taskExe -m pip install -r (Join-Path $PSScriptRoot 'requirements.txt')
if ($LASTEXITCODE -ne 0) { throw 'Falha ao instalar dependências Python.' }
Push-Location $PSScriptRoot
try { & $taskExe -m unittest discover -s tests -p 'test_*.py' -v; if ($LASTEXITCODE -ne 0) { throw 'Testes Python falharam.' } }
finally { Pop-Location }
