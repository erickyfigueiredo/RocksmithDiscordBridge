#ifndef AppVersion
#define AppVersion "0.3.0"
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
english.ConnectionTitle=Connect your guitar
english.ConnectionDescription=Which audio setup do you use?
english.ConnectionPrompt=Your USB interface is selected inside its driver panel, after installation.
english.USBInterface=USB interface / not sure — use ASIO4ALL (download if needed)
english.Manufacturer=I have my interface manufacturer's ASIO driver — advanced
english.Advanced=Show advanced repairs
english.RepairsTitle=Advanced repairs
english.RepairsDescription=Only select these if a game or driver dependency needs repair.
english.USBPrompt=ASIO4ALL is selected. You will choose your USB interface in its panel after installation.
english.InvalidInput=Enter the physical input number, from 1 to 64.
brazilianportuguese.ConnectionTitle=Conectar a guitarra
brazilianportuguese.ConnectionDescription=Como você usa o áudio?
brazilianportuguese.ConnectionPrompt=A interface USB será escolhida no painel do driver, depois da instalação.
brazilianportuguese.USBInterface=Interface USB / não sei — usar ASIO4ALL (baixar se necessário)
brazilianportuguese.Manufacturer=Tenho o driver ASIO do fabricante da interface — avançado
brazilianportuguese.Advanced=Mostrar reparos avançados
brazilianportuguese.RepairsTitle=Reparos avançados
brazilianportuguese.RepairsDescription=Marque só se precisar reparar uma dependência do jogo ou driver.
brazilianportuguese.USBPrompt=ASIO4ALL selecionado. Depois de instalar, escolha sua interface USB no painel dele.
brazilianportuguese.InvalidInput=Digite o número da entrada da interface, de 1 a 64.
english.GameTitle=Rocksmith 2014 folder
english.GameDescription=Choose the folder containing Rocksmith2014.exe.
english.GamePrompt=Run the game once before installing. Its configuration file must exist.
english.PrereqTitle=Prepare audio
english.PrereqDescription=These are the components for your selected setup.
english.PrereqPrompt=Keep Steam and Discord installed. Python is already included.
english.BaseASIO=Game audio support (included)
english.ASIO4ALL=ASIO4ALL 2.22 (download and open its installer)
english.VCx86=Download Microsoft Visual C++ v14 x86 runtime (optional repair for game/driver dependencies)
english.VCx64=Download Microsoft Visual C++ v14 x64 runtime (optional repair; Python runtime is already included)
english.DriverTitle=Guitar input
english.DriverDescription=Which input on your interface is your guitar plugged into?
english.DriverPrompt=Select your manufacturer's ASIO driver. For a USB interface without one, go back and choose ASIO4ALL.
english.Channel=Guitar plugged into input:
english.Configure=Configure guitar, headphones and test audio
english.Finish=One more step: configure your guitar and headphones, then test the audio.
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
brazilianportuguese.PrereqTitle=Preparar áudio
brazilianportuguese.PrereqDescription=Estes são os componentes para a opção escolhida.
brazilianportuguese.PrereqPrompt=Mantenha Steam e Discord instalados. O Python já está incluído.
brazilianportuguese.BaseASIO=Suporte de áudio do jogo (incluído)
brazilianportuguese.ASIO4ALL=ASIO4ALL 2.22 (baixar e abrir o instalador dele)
brazilianportuguese.VCx86=Baixar runtime Microsoft Visual C++ v14 x86 (reparo opcional para dependências do jogo/driver)
brazilianportuguese.VCx64=Baixar runtime Microsoft Visual C++ v14 x64 (reparo opcional; runtime Python já incluído)
brazilianportuguese.DriverTitle=Entrada da guitarra
brazilianportuguese.DriverDescription=Em qual entrada da interface a guitarra está conectada?
brazilianportuguese.DriverPrompt=Escolha o driver ASIO do fabricante. Se a interface USB não tem um, volte e escolha ASIO4ALL.
brazilianportuguese.Channel=Guitarra conectada na entrada:
brazilianportuguese.Configure=Configurar guitarra, fone e testar áudio
brazilianportuguese.Finish=Falta um passo: configure a guitarra e o fone, depois teste o áudio.
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
Source: "..\DEPENDENCIES.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\PRIVACY.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\LICENSE"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\THIRD_PARTY_NOTICES.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\licenses\*"; DestDir: "{app}\licenses"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{cm:Configure}"; Filename: "{app}\player\RocksmithStreamBridge.exe"; Parameters: "--configure-output"
Name: "{group}\Rocksmith 2014"; Filename: "steam://rungameid/221680"
Name: "{group}\Uninstall"; Filename: "{uninstallexe}"

[Run]
Filename: "{app}\player\RocksmithStreamBridge.exe"; Parameters: "--configure-output"; Description: "{cm:Configure}"; Flags: postinstall runasoriginaluser skipifsilent; Check: ConfigureAudio

[Code]
var
  GamePage: TInputDirWizardPage;
  ConnectionPage: TInputOptionWizardPage;
  Dependencies: TInputOptionWizardPage;
  Repairs: TInputOptionWizardPage;
  Advanced: TNewCheckBox;
  DriverPage: TWizardPage;
  DriverPrompt: TNewStaticText;
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
  { Never silently choose an unrelated driver just because it was registered first. }
  if ConnectionPage.Values[0] then DriverList.ItemIndex := DriverList.Items.IndexOf('ASIO4ALL v2');
  if ExpandConstant('{param:ASIO_DRIVER|}') <> '' then
    DriverList.ItemIndex := DriverList.Items.IndexOf(ExpandConstant('{param:ASIO_DRIVER|}'));
end;

procedure InitializeWizard;
var LabelControl: TNewStaticText;
begin
  GamePage := CreateInputDirPage(wpSelectDir, CustomMessage('GameTitle'), CustomMessage('GameDescription'), CustomMessage('GamePrompt'), False, '');
  GamePage.Add('Rocksmith 2014:');
  GamePage.Values[0] := ExpandConstant('{param:GAME_DIR|}');
  if GamePage.Values[0] = '' then GamePage.Values[0] := DetectGame;
  ConnectionPage := CreateInputOptionPage(GamePage.ID, CustomMessage('ConnectionTitle'), CustomMessage('ConnectionDescription'), CustomMessage('ConnectionPrompt'), True, False);
  ConnectionPage.Add(CustomMessage('USBInterface'));
  ConnectionPage.Add(CustomMessage('Manufacturer'));
  ConnectionPage.SelectedValueIndex := 0;
  if ExpandConstant('{param:ASIO_DRIVER|}') <> '' then ConnectionPage.SelectedValueIndex := 1;
  Dependencies := CreateInputOptionPage(ConnectionPage.ID, CustomMessage('PrereqTitle'), CustomMessage('PrereqDescription'), CustomMessage('PrereqPrompt'), False, False);
  Dependencies.Add(CustomMessage('BaseASIO'));
  Dependencies.Add(CustomMessage('ASIO4ALL'));
  Dependencies.CheckListBox.Height := ScaleY(120);
  Advanced := TNewCheckBox.Create(Dependencies);
  Advanced.Parent := Dependencies.Surface;
  Advanced.SetBounds(0, ScaleY(190), Dependencies.SurfaceWidth, ScaleY(24));
  Advanced.Caption := CustomMessage('Advanced');
  Repairs := CreateInputOptionPage(Dependencies.ID, CustomMessage('RepairsTitle'), CustomMessage('RepairsDescription'), '', False, False);
  Repairs.Add(CustomMessage('VCx86'));
  Repairs.Add(CustomMessage('VCx64'));
  Dependencies.Values[0] := (not FileExists(GameDirectory + '\avrt.dll')) or (not FileExists(GameDirectory + '\RS_ASIO.ini'));
  if ExpandConstant('{param:INITIALIZE_ASIO|0}') = '1' then Dependencies.Values[0] := True;
  DriverPage := CreateCustomPage(Repairs.ID, CustomMessage('DriverTitle'), CustomMessage('DriverDescription'));
  DriverPrompt := TNewStaticText.Create(DriverPage);
  DriverPrompt.Parent := DriverPage.Surface;
  DriverPrompt.SetBounds(0, 0, DriverPage.SurfaceWidth, ScaleY(64));
  DriverPrompt.AutoSize := False; DriverPrompt.WordWrap := True;
  DriverPrompt.Caption := CustomMessage('DriverPrompt');
  DriverList := TNewComboBox.Create(DriverPage);
  DriverList.Parent := DriverPage.Surface;
  DriverList.SetBounds(0, ScaleY(78), DriverPage.SurfaceWidth, ScaleY(24));
  DriverList.Style := csDropDownList;
  LabelControl := TNewStaticText.Create(DriverPage);
  LabelControl.Parent := DriverPage.Surface;
  LabelControl.Top := ScaleY(120); LabelControl.Caption := CustomMessage('Channel');
  Channel := TNewEdit.Create(DriverPage);
  Channel.Parent := DriverPage.Surface;
  Channel.SetBounds(0, ScaleY(144), ScaleX(80), ScaleY(24)); Channel.Text := '1';
  RefreshDrivers;
  DownloadPage := CreateDownloadPage(CustomMessage('Downloads'), '', nil);
  WizardForm.FinishedLabel.Caption := CustomMessage('Finish');
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  Result := ((PageID = DriverPage.ID) or (PageID = ConnectionPage.ID)) and FileExists(GameDirectory + '\RS_ASIO.ini');
  if PageID = Repairs.ID then Result := not Advanced.Checked;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = DriverPage.ID then begin
    RefreshDrivers;
    DriverList.Visible := not ConnectionPage.Values[0];
    if ConnectionPage.Values[0] then DriverPrompt.Caption := CustomMessage('USBPrompt')
    else DriverPrompt.Caption := CustomMessage('DriverPrompt');
  end;
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
    if Result and ConnectionPage.Values[0] and (not FileExists(GameDirectory + '\RS_ASIO.ini')) then begin
      Result := Dependencies.Values[1] or RegKeyExists(HKLM32, 'SOFTWARE\ASIO\ASIO4ALL v2');
      if not Result then MsgBox(CustomMessage('MissingDriver'), mbError, MB_OK);
    end;
    RefreshDrivers;
  end;
  if CurPageID = ConnectionPage.ID then begin
    Dependencies.Values[1] := ConnectionPage.Values[0] and (not RegKeyExists(HKLM32, 'SOFTWARE\ASIO\ASIO4ALL v2'));
    RefreshDrivers;
  end;
  if (CurPageID = DriverPage.ID) and (not FileExists(GameDirectory + '\RS_ASIO.ini')) then begin
    Result := (DriverList.Text <> '') and (Pos('"', DriverList.Text) = 0);
    if not Result then MsgBox(CustomMessage('MissingDriver'), mbError, MB_OK);
    if Result then begin
      Result := (StrToIntDef(Channel.Text, -1) >= 1) and (StrToIntDef(Channel.Text, 65) <= 64);
      if not Result then MsgBox(CustomMessage('InvalidInput'), mbError, MB_OK);
    end;
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
    if Advanced.Checked and Repairs.Values[0] then InstallDependency('https://download.visualstudio.microsoft.com/download/pr/990c720a-46ce-4dc7-87b9-c2eb615d34b9/0C09F2611660441084CE0DF425C51C11E147E6447963C3690F97E0B25C55ED64/VC_redist.x86.exe', 'VCx86.exe', '0c09f2611660441084ce0df425c51c11e147e6447963c3690f97e0b25c55ed64', '/passive /norestart', SW_SHOWNORMAL);
    if Advanced.Checked and Repairs.Values[1] then InstallDependency('https://download.visualstudio.microsoft.com/download/pr/990c720a-46ce-4dc7-87b9-c2eb615d34b9/CC0FF0EB1DC3F5188AE6300FAEF32BF5BEEBA4BDD6E8E445A9184072096B713B/VC_redist.x64.exe', 'VCx64.exe', 'cc0ff0eb1dc3f5188ae6300faef32bf5beeba4bdd6e8e445a9184072096b713b', '/passive /norestart', SW_SHOWNORMAL);
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
    Args := Args + ' --driver ' + Q(DriverList.Text) + ' --input-channel ' + IntToStr(StrToIntDef(Channel.Text, 1)-1);
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
