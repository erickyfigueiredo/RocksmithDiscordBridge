#ifndef AppVersion
#define AppVersion "0.2.0"
#endif
[Setup]
AppId={{341F8138-1E9E-4EAD-8253-DC4628AFC65B}
AppName=Rocksmith Discord Bridge
AppVersion={#AppVersion}
AppPublisher=Rocksmith Discord Bridge contributors
AppPublisherURL=https://github.com/erickyfigueiredo/RocksmithDiscordBridge
DefaultDirName={autopf}\Rocksmith Discord Bridge
DefaultGroupName=Rocksmith Discord Bridge
OutputDir=..\release
OutputBaseFilename=RocksmithDiscordBridge-Setup-x64
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0
PrivilegesRequired=admin
WizardStyle=modern
Compression=lzma2
SolidCompression=yes
LicenseFile=..\LICENSE
SetupLogging=yes
CloseApplications=no
UninstallDisplayIcon={app}\player\RocksmithStreamBridge.exe

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[CustomMessages]
english.GameTitle=Rocksmith 2014 folder
english.GameDescription=Choose the folder containing Rocksmith2014.exe.
english.GamePrompt=Run the game once before installing. Its configuration file must exist.
english.PrereqTitle=Dependencies and optional installation
english.PrereqDescription=Review the requirements and choose what this wizard may install.
english.PrereqPrompt=Included: Python and app libraries. Required: Steam game, Discord desktop and a 32-bit ASIO driver. Prefer your interface manufacturer's driver. Additional downloads happen only for checked items.
english.BaseASIO=Install missing RS_ASIO 0.7.4 support files (included; existing configuration is preserved)
english.ASIO4ALL=Download and install ASIO4ALL 2.22 (optional fallback driver; its own setup/license will open)
english.VCx86=Download Microsoft Visual C++ v14 x86 runtime (optional repair for game/driver dependencies)
english.VCx64=Download Microsoft Visual C++ v14 x64 runtime (optional repair; Python runtime is already included)
english.DriverTitle=First-time ASIO configuration
english.DriverDescription=Choose the 32-bit ASIO driver for your guitar interface.
english.DriverPrompt=Use the manufacturer's ASIO driver when available. ASIO4ALL requires choosing the correct devices in its own control panel. Use 48 kHz. Existing RS_ASIO settings will be preserved.
english.Channel=Guitar input channel (zero-based):
english.Configure=Choose where to hear the copied game audio
english.Finish=Share ROCKSMITH 2014 itself with sound in Discord. Configure the audio output using the Start menu shortcut. First-time ASIO users must check their interface devices, channels and 48 kHz in the driver control panel.
english.InvalidGame=Select the game folder and run Rocksmith once first (Rocksmith2014.exe and Rocksmith.ini are required).
english.MissingBase=RS_ASIO is missing. Select installation of its included support files.
english.MissingDriver=Choose an existing 32-bit ASIO driver, or select ASIO4ALL installation. You can also install your manufacturer's driver separately and reopen this wizard.
english.CloseGame=Close Rocksmith 2014 before installing or uninstalling.
english.Downloads=Downloading selected dependencies
english.InstallFailure=Game integration could not be installed. The previous game files were restored. Details:
english.RestoreFailure=The game integration could not be restored. Uninstallation was stopped. Details:
brazilianportuguese.GameTitle=Pasta do Rocksmith 2014
brazilianportuguese.GameDescription=Escolha a pasta que contém Rocksmith2014.exe.
brazilianportuguese.GamePrompt=Abra o jogo uma vez antes de instalar. O arquivo de configuração precisa existir.
brazilianportuguese.PrereqTitle=Dependências e instalação opcional
brazilianportuguese.PrereqDescription=Confira os requisitos e escolha o que este assistente pode instalar.
brazilianportuguese.PrereqPrompt=Incluídos: Python e bibliotecas do aplicativo. Necessários: jogo Steam, Discord desktop e driver ASIO de 32 bits. Prefira o driver do fabricante da interface. Só haverá downloads dos itens marcados.
brazilianportuguese.BaseASIO=Instalar suporte RS_ASIO 0.7.4 que estiver faltando (incluído; preserva a configuração existente)
brazilianportuguese.ASIO4ALL=Baixar e instalar ASIO4ALL 2.22 (alternativa opcional; abre o instalador/licença próprio)
brazilianportuguese.VCx86=Baixar runtime Microsoft Visual C++ v14 x86 (reparo opcional para dependências do jogo/driver)
brazilianportuguese.VCx64=Baixar runtime Microsoft Visual C++ v14 x64 (reparo opcional; runtime Python já incluído)
brazilianportuguese.DriverTitle=Primeira configuração ASIO
brazilianportuguese.DriverDescription=Escolha o driver ASIO de 32 bits da interface da guitarra.
brazilianportuguese.DriverPrompt=Use o driver ASIO do fabricante quando disponível. No ASIO4ALL, escolha os dispositivos no painel dele. Use 48 kHz. Configurações RS_ASIO existentes serão preservadas.
brazilianportuguese.Channel=Canal da entrada da guitarra (começa em zero):
brazilianportuguese.Configure=Escolher onde ouvir a cópia do áudio do jogo
brazilianportuguese.Finish=Compartilhe o próprio ROCKSMITH 2014 com som no Discord. Configure a saída pelo atalho do menu Iniciar. Na primeira configuração ASIO, confira dispositivos, canais e 48 kHz no painel do driver.
brazilianportuguese.InvalidGame=Selecione a pasta do jogo e abra o Rocksmith uma vez antes (Rocksmith2014.exe e Rocksmith.ini são necessários).
brazilianportuguese.MissingBase=O RS_ASIO está ausente. Marque a instalação dos arquivos de suporte incluídos.
brazilianportuguese.MissingDriver=Escolha um driver ASIO de 32 bits existente ou marque a instalação do ASIO4ALL. Você também pode instalar o driver do fabricante e reabrir este assistente.
brazilianportuguese.CloseGame=Feche o Rocksmith 2014 antes de instalar ou desinstalar.
brazilianportuguese.Downloads=Baixando as dependências escolhidas
brazilianportuguese.InstallFailure=Não foi possível integrar ao jogo. Os arquivos anteriores foram restaurados. Detalhes:
brazilianportuguese.RestoreFailure=Não foi possível restaurar a integração. A desinstalação foi interrompida. Detalhes:

[Files]
Source: "..\dist\RocksmithStreamBridge\RocksmithStreamBridge.exe"; DestDir: "{app}\player"; Flags: ignoreversion
Source: "..\dist\RocksmithStreamBridge\_internal\*"; DestDir: "{app}\player\_internal"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\bin\RS_ASIO.dll"; DestDir: "{app}\bin"; Flags: ignoreversion
Source: "..\bin\avrt.dll"; DestDir: "{app}\bin"; Flags: ignoreversion
Source: "..\config\RS_ASIO.ini"; DestDir: "{app}\config"; Flags: ignoreversion
Source: "..\README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\README.pt-BR.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\PRIVACY.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\LICENSE"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\THIRD_PARTY_NOTICES.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\licenses\*"; DestDir: "{app}\licenses"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Configure audio"; Filename: "{app}\player\RocksmithStreamBridge.exe"; Parameters: "--configure-output"
Name: "{group}\Rocksmith 2014"; Filename: "steam://rungameid/221680"
Name: "{group}\Uninstall"; Filename: "{uninstallexe}"

[Run]
Filename: "{app}\player\RocksmithStreamBridge.exe"; Parameters: "--configure-output"; Description: "{cm:Configure}"; Flags: postinstall runasoriginaluser skipifsilent; Check: ConfigureAudio

[Code]
var
  GamePage: TInputDirWizardPage;
  Dependencies: TInputOptionWizardPage;
  DriverPage: TWizardPage;
  DriverList: TNewComboBox;
  Channel: TNewEdit;
  DownloadPage: TDownloadWizardPage;
  RestartRequired: Boolean;

function Q(const S: String): String;
begin
  Result := '"' + S + '"';
end;

function GameDirectory: String;
begin
  Result := RemoveBackslashUnlessRoot(GamePage.Values[0]);
end;

function IsGameClosed: Boolean;
var WMI, Rows: Variant;
begin
  Result := False;
  try
    WMI := CreateOleObject('WbemScripting.SWbemLocator');
    WMI := WMI.ConnectServer('', 'root\CIMV2');
    Rows := WMI.ExecQuery('SELECT ProcessId FROM Win32_Process WHERE Name="Rocksmith2014.exe"', 'WQL', 0);
    Result := Rows.Count = 0;
  except
    { The windowless integration helper performs its own Toolhelp process check. }
    Result := True;
  end;
end;

function DetectGame: String;
var Root, Text, LibraryPath: String; Lines: TArrayOfString; I, P: Integer;
begin
  Result := '';
  if not RegQueryStringValue(HKCU, 'Software\Valve\Steam', 'SteamPath', Root) then
    RegQueryStringValue(HKLM32, 'Software\Valve\Steam', 'InstallPath', Root);
  if Root = '' then Root := ExpandConstant('{pf32}\Steam');
  if FileExists(Root + '\steamapps\common\Rocksmith2014\Rocksmith2014.exe') then begin
    Result := Root + '\steamapps\common\Rocksmith2014'; Exit;
  end;
  if LoadStringsFromFile(Root + '\steamapps\libraryfolders.vdf', Lines) then
    for I := 0 to GetArrayLength(Lines)-1 do begin
      Text := Trim(Lines[I]);
      if Pos('"path"', Text) = 1 then begin
        Delete(Text, 1, 6); Text := Trim(Text);
        if Copy(Text, 1, 1) = '"' then Delete(Text, 1, 1);
        P := Pos('"', Text);
        if P > 0 then begin
          LibraryPath := Copy(Text, 1, P-1);
          StringChangeEx(LibraryPath, '\\', '\', True);
          if FileExists(LibraryPath + '\steamapps\common\Rocksmith2014\Rocksmith2014.exe') then begin
            Result := LibraryPath + '\steamapps\common\Rocksmith2014'; Exit;
          end;
        end;
      end;
    end;
end;

procedure RefreshDrivers;
var Drivers: TArrayOfString; I: Integer; Selected: String;
begin
  Selected := DriverList.Text;
  DriverList.Items.Clear;
  if RegGetSubkeyNames(HKLM32, 'SOFTWARE\ASIO', Drivers) then
    for I := 0 to GetArrayLength(Drivers)-1 do DriverList.Items.Add(Drivers[I]);
  if Dependencies.Values[1] and (DriverList.Items.IndexOf('ASIO4ALL v2') < 0) then DriverList.Items.Add('ASIO4ALL v2');
  if (ExpandConstant('{param:ASIO_DRIVER|}') <> '') and (DriverList.Items.IndexOf(ExpandConstant('{param:ASIO_DRIVER|}')) < 0) then DriverList.Items.Add(ExpandConstant('{param:ASIO_DRIVER|}'));
  DriverList.ItemIndex := DriverList.Items.IndexOf(Selected);
  if (DriverList.ItemIndex < 0) and (DriverList.Items.Count > 0) then DriverList.ItemIndex := 0;
end;

procedure InitializeWizard;
var LabelControl: TNewStaticText;
begin
  GamePage := CreateInputDirPage(wpSelectDir, CustomMessage('GameTitle'), CustomMessage('GameDescription'), CustomMessage('GamePrompt'), False, '');
  GamePage.Add('Rocksmith 2014:');
  GamePage.Values[0] := ExpandConstant('{param:GAME_DIR|}');
  if GamePage.Values[0] = '' then GamePage.Values[0] := DetectGame;
  Dependencies := CreateInputOptionPage(GamePage.ID, CustomMessage('PrereqTitle'), CustomMessage('PrereqDescription'), CustomMessage('PrereqPrompt'), False, False);
  Dependencies.Add(CustomMessage('BaseASIO'));
  Dependencies.Add(CustomMessage('ASIO4ALL'));
  Dependencies.Add(CustomMessage('VCx86'));
  Dependencies.Add(CustomMessage('VCx64'));
  Dependencies.Values[0] := (not FileExists(GameDirectory + '\avrt.dll')) or (not FileExists(GameDirectory + '\RS_ASIO.ini'));
  if ExpandConstant('{param:INITIALIZE_ASIO|0}') = '1' then Dependencies.Values[0] := True;
  DriverPage := CreateCustomPage(Dependencies.ID, CustomMessage('DriverTitle'), CustomMessage('DriverDescription'));
  LabelControl := TNewStaticText.Create(DriverPage);
  LabelControl.Parent := DriverPage.Surface;
  LabelControl.SetBounds(0, 0, DriverPage.SurfaceWidth, ScaleY(64));
  LabelControl.AutoSize := False; LabelControl.WordWrap := True;
  LabelControl.Caption := CustomMessage('DriverPrompt');
  DriverList := TNewComboBox.Create(DriverPage);
  DriverList.Parent := DriverPage.Surface;
  DriverList.SetBounds(0, ScaleY(78), DriverPage.SurfaceWidth, ScaleY(24));
  DriverList.Style := csDropDownList;
  LabelControl := TNewStaticText.Create(DriverPage);
  LabelControl.Parent := DriverPage.Surface;
  LabelControl.Top := ScaleY(120); LabelControl.Caption := CustomMessage('Channel');
  Channel := TNewEdit.Create(DriverPage);
  Channel.Parent := DriverPage.Surface;
  Channel.SetBounds(0, ScaleY(144), ScaleX(80), ScaleY(24)); Channel.Text := '0';
  RefreshDrivers;
  if ExpandConstant('{param:ASIO_DRIVER|}') <> '' then begin
    DriverList.Items.Add(ExpandConstant('{param:ASIO_DRIVER|}'));
    DriverList.ItemIndex := DriverList.Items.Count-1;
  end;
  DownloadPage := CreateDownloadPage(CustomMessage('Downloads'), '', nil);
  WizardForm.FinishedLabel.Caption := CustomMessage('Finish');
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  Result := (PageID = DriverPage.ID) and FileExists(GameDirectory + '\RS_ASIO.ini');
end;

procedure CurPageChanged(CurPageID: Integer);
var Drivers: TArrayOfString; Installed: Cardinal; X86State, X64State: String;
begin
  if CurPageID = Dependencies.ID then begin
    RegGetSubkeyNames(HKLM32, 'SOFTWARE\ASIO', Drivers);
    X86State := 'not detected'; X64State := 'not detected';
    if RegQueryDWordValue(HKLM32, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x86', 'Installed', Installed) then
      if Installed = 1 then X86State := 'installed';
    if RegQueryDWordValue(HKLM64, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64', 'Installed', Installed) then
      if Installed = 1 then X64State := 'installed';
    Dependencies.SubCaptionLabel.Caption := CustomMessage('PrereqPrompt') + #13#10 + 'ASIO 32-bit: ' + IntToStr(GetArrayLength(Drivers)) + ' | VC++ x86: ' + X86State + ' | VC++ x64: ' + X64State;
    Dependencies.SubCaptionLabel.Height := ScaleY(88);
    Dependencies.CheckListBox.Top := ScaleY(96);
    Dependencies.CheckListBox.Height := Dependencies.SurfaceHeight - ScaleY(96);
  end;
  if CurPageID = DriverPage.ID then RefreshDrivers;
  if CurPageID = wpFinished then WizardForm.FinishedLabel.Caption := CustomMessage('Finish');
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if CurPageID = GamePage.ID then begin
    Result := FileExists(GameDirectory + '\Rocksmith2014.exe') and FileExists(GameDirectory + '\Rocksmith.ini');
    if not Result then MsgBox(CustomMessage('InvalidGame'), mbError, MB_OK);
    Dependencies.Values[0] := (not FileExists(GameDirectory + '\avrt.dll')) or (not FileExists(GameDirectory + '\RS_ASIO.ini'));
  end;
  if CurPageID = Dependencies.ID then begin
    Result := Dependencies.Values[0] or (FileExists(GameDirectory + '\avrt.dll') and FileExists(GameDirectory + '\RS_ASIO.ini'));
    if not Result then MsgBox(CustomMessage('MissingBase'), mbError, MB_OK);
    RefreshDrivers;
  end;
  if (CurPageID = DriverPage.ID) and (not FileExists(GameDirectory + '\RS_ASIO.ini')) then begin
    Result := (DriverList.Text <> '') and (Pos('"', DriverList.Text) = 0) and (StrToIntDef(Channel.Text, -1) >= 0) and (StrToIntDef(Channel.Text, 64) < 64);
    if not Result then MsgBox(CustomMessage('MissingDriver'), mbError, MB_OK);
  end;
end;

procedure InstallDependency(const URL, Name, Hash, Args: String; Show: Integer);
var Code: Integer;
begin
  DownloadPage.Clear;
  DownloadPage.Add(URL, Name, Hash);
  DownloadPage.Show;
  try DownloadPage.Download; finally DownloadPage.Hide; end;
  if not Exec(ExpandConstant('{tmp}\') + Name, Args, '', Show, ewWaitUntilTerminated, Code) then RaiseException(SysErrorMessage(Code));
  if Code = 3010 then RestartRequired := True
  else if (Code <> 0) and (Code <> 1638) then RaiseException('Dependency setup did not complete. Exit code: ' + IntToStr(Code));
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  Result := '';
  if not IsGameClosed then begin Result := CustomMessage('CloseGame'); Exit; end;
  try
    if Dependencies.Values[1] then InstallDependency('https://asio4all.org/downloads/ASIO4ALL_2_22.exe', 'ASIO4ALL.exe', '0d4f0c63bf5df077e4c74f18372f72b8e875a9abea499fea78aaa9f56022ac7e', '', SW_SHOWNORMAL);
    if Dependencies.Values[2] then InstallDependency('https://download.visualstudio.microsoft.com/download/pr/990c720a-46ce-4dc7-87b9-c2eb615d34b9/0C09F2611660441084CE0DF425C51C11E147E6447963C3690F97E0B25C55ED64/VC_redist.x86.exe', 'VCx86.exe', '0c09f2611660441084ce0df425c51c11e147e6447963c3690f97e0b25c55ed64', '/passive /norestart', SW_SHOWNORMAL);
    if Dependencies.Values[3] then InstallDependency('https://download.visualstudio.microsoft.com/download/pr/990c720a-46ce-4dc7-87b9-c2eb615d34b9/CC0FF0EB1DC3F5188AE6300FAEF32BF5BEEBA4BDD6E8E445A9184072096B713B/VC_redist.x64.exe', 'VCx64.exe', 'cc0ff0eb1dc3f5188ae6300faef32bf5beeba4bdd6e8e445a9184072096b713b', '/passive /norestart', SW_SHOWNORMAL);
  except Result := GetExceptionMessage; end;
end;

function ReadReport(const Filename: String): String;
var Data: AnsiString;
begin
  Result := '';
  if LoadStringFromFile(Filename, Data) then Result := UTF8Decode(Data);
end;

procedure CurStepChanged(CurStep: TSetupStep);
var Args, ReportFile: String; Code: Integer;
begin
  if CurStep = ssPostInstall then begin
    ReportFile := ExpandConstant('{tmp}\integration-report.txt');
    Args := '--setup-install --game-directory ' + Q(GameDirectory) + ' --package ' + Q(ExpandConstant('{app}')) + ' --state-file ' + Q(ExpandConstant('{commonappdata}\RocksmithDiscordBridge\installation.json')) + ' --report ' + Q(ReportFile);
    if Dependencies.Values[0] then Args := Args + ' --initialize-asio';
    Args := Args + ' --driver ' + Q(DriverList.Text) + ' --input-channel ' + Channel.Text;
    if not Exec(ExpandConstant('{app}\player\RocksmithStreamBridge.exe'), Args, '', SW_HIDE, ewWaitUntilTerminated, Code) then RaiseException(SysErrorMessage(Code));
    if Code <> 0 then RaiseException(CustomMessage('InstallFailure') + #13#10 + ReadReport(ReportFile));
  end;
end;

function ConfigureAudio: Boolean;
begin
  Result := ExpandConstant('{param:SKIP_AUDIO|0}') <> '1';
end;

function NeedRestart: Boolean;
begin
  Result := RestartRequired;
end;

function InitializeUninstall: Boolean;
var Code: Integer; ReportFile: String;
begin
  Result := False;
  if not IsGameClosed then begin MsgBox(CustomMessage('CloseGame'), mbError, MB_OK); Exit; end;
  ReportFile := ExpandConstant('{tmp}\restore-report.txt');
  if Exec(ExpandConstant('{app}\player\RocksmithStreamBridge.exe'), '--setup-uninstall --state-file ' + Q(ExpandConstant('{commonappdata}\RocksmithDiscordBridge\installation.json')) + ' --report ' + Q(ReportFile), '', SW_HIDE, ewWaitUntilTerminated, Code) then begin
    Result := Code = 0;
    if Result and (not UninstallSilent) then MsgBox(ReadReport(ReportFile), mbInformation, MB_OK);
  end;
  if not Result then MsgBox(CustomMessage('RestoreFailure') + #13#10 + ReadReport(ReportFile), mbError, MB_OK);
end;
