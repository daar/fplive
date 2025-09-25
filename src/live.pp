program live;

{$mode objfpc}{$H+}

uses
  Classes,
  DateUtils,
  Process,
  SysUtils;

type
  TFileWatcher = class
  private
    Files: TStringList;
    Stamps: array of TDateTime;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddPath(const APath: string);
    function HasChanged: boolean;
  end;

  constructor TFileWatcher.Create;
  begin
    Files := TStringList.Create;
    Files.Sorted := False;
  end;

  destructor TFileWatcher.Destroy;
  begin
    Files.Free;
    inherited;
  end;

  procedure TFileWatcher.AddPath(const APath: string);
  var
    SR: TSearchRec;
  begin
    if FindFirst(IncludeTrailingPathDelimiter(APath) + '*.pp', faAnyFile, SR) = 0 then
      repeat
        Files.Add(IncludeTrailingPathDelimiter(APath) + SR.name);
      until FindNext(SR) <> 0;
    FindClose(SR);

    if FindFirst(IncludeTrailingPathDelimiter(APath) + '*.pas', faAnyFile, SR) = 0 then
      repeat
        Files.Add(IncludeTrailingPathDelimiter(APath) + SR.name);
      until FindNext(SR) <> 0;
    FindClose(SR);

   if FindFirst(IncludeTrailingPathDelimiter(APath) + '*.inc', faAnyFile, SR) = 0 then
      repeat
        Files.Add(IncludeTrailingPathDelimiter(APath) + SR.name);
      until FindNext(SR) <> 0;
    FindClose(SR);

    SetLength(Stamps, Files.Count);
  end;

  function TFileWatcher.HasChanged: boolean;
  var
    i:      integer;
    FTime:  TDateTime;
    change: boolean = False;
  begin
    Result := False;
    for i := 0 to Files.Count - 1 do
      if FileExists(Files[i]) then
      begin
        FTime := FileDateToDateTime(FileAge(Files[i]));

        if FTime > Stamps[i] then
        begin
          Stamps[i] := FTime;
          change := True;
        end;
      end;

    exit(change);
  end;

var
  Watcher: TFileWatcher;
  i:    integer;
  SourceFile, ExeFile: string;
  Args: array of TProcessString;
  s:    string;
  success: Boolean;
begin
  if ParamCount < 1 then
  begin
    WriteLn('Usage: live <main.pp> [compiler options]');
    Halt(1);
  end;

  SourceFile := ParamStr(1);
  ExeFile := ChangeFileExt(SourceFile,
    {$IFDEF WINDOWS}
 '.exe'
    {$ELSE}
    ''
    {$ENDIF}
    );

  // Build argument array: first the source file, then the remaining params
  SetLength(Args, ParamCount);
  for i := 1 to ParamCount do
    Args[i - 1] := ParamStr(i);

  Watcher := TFileWatcher.Create;
  try
    // Monitor main file dir
    Watcher.AddPath(ExtractFilePath(SourceFile));

    // Monitor additional -Fu paths
    for i := 2 to ParamCount do
      if (Pos('-Fu', ParamStr(i)) = 1) or (Pos('-FU', ParamStr(i)) = 1) then
        Watcher.AddPath(Copy(ParamStr(i), 4, Length(ParamStr(i))));

    WriteLn('Live build started. Watching for changes... Press Ctrl+C to quit.');

    while True do
    begin
      if Watcher.HasChanged then
      begin
        WriteLn('--- Change detected. Rebuilding... ---');

        success := RunCommand('fpc', Args, s);
        writeln(s);

        if success and FileExists(ExeFile) then
        begin
          WriteLn('--- Running program ---');
          RunCommand(ExeFile, [], s);
          writeln(s);
        end;
      end;
      Sleep(500);
    end;

  finally
    Watcher.Free;
  end;
end.
