library ShellHook64;

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  DDetours; // DDetours-Include library

const
  WM_MYFOCUSCHANGED = WM_USER + 1;
  MMFName: PChar = 'MMF';

type
  PHookRec = ^THookRec;
  THookRec = packed Record
    HookHandle: hhook;
    WindowHandle: hwnd;
  End;

type
  PGlobalDLLData = ^TGlobalDLLData;
  TGlobalDLLData = packed record
    HookWnd: HWND;
    Wnd: HWND;
  end;

var
  GlobalData: PGlobalDLLData;
  MapHandle: THandle;         // File Mapping Object
  IpHookRec: PHookRec;        // Pointer to hook record
  MMFHandle: THandle;
  MHSHELL_WINDOWACTIVATED: Cardinal;
  MHSHELL_WINDOWCREATED: Cardinal;
  MHSHELL_WINDOWDESTROYED: Cardinal;

var
  TrampolineMessageBoxW: function(hWnd: HWND; lpText, lpCaption: LPCWSTR; uType: UINT): Integer; stdcall = nil;

function ShellProc(Code: Integer; wParam: DWORD; lParam: DWORD): Longint; stdcall;
begin
  Result:= CallNextHookEx(GlobalData.HookWnd, Code, wParam, lParam);
  if (Code = HSHELL_WINDOWACTIVATED) then
    SendMessage(GlobalData.Wnd, MHSHELL_WINDOWACTIVATED, 0, Integer(wParam));
  if (Code = HSHELL_WINDOWCREATED) then
    SendMessage(GlobalData.Wnd, MHSHELL_WINDOWCREATED, 0, Integer(wParam));
  if (Code = HSHELL_WINDOWDESTROYED) then
    SendMessage(GlobalData.Wnd, MHSHELL_WINDOWDESTROYED, 0, Integer(wParam));
end;

function StartMouseHook64(State: Boolean; Wnd: HWND): Boolean; export; stdcall;
begin
  Result:= False;
  if State = True then
  begin
    GlobalData^.HookWnd:= SetWindowsHookEx(WH_SHELL, @ShellProc, hInstance, 0);
    GlobalData^.Wnd:= Wnd;
    if GlobalData^.HookWnd <> 0 then
      Result:= True;
  end
  else
  begin
    UnhookWindowsHookEx(GlobalData^.HookWnd);
    Result:= False;
  end;
end;

function StopMouseHook64(): Boolean; export; stdcall;
begin
  UnhookWindowsHookEx(GlobalData^.HookWnd);
  if GlobalData^.HookWnd = 0 then
    Result:= False
  else
    Result:= True;
end;

procedure MapFileMemory(dwAllocSize: DWORD);
begin
  {Create a process wide memory mapped variable}
  MapHandle := CreateFileMapping($FFFFFFFF, nil, PAGE_READWRITE, 0, dwAllocSize, 'HookRecMemBlock');
  if (MapHandle = 0) then
  begin
    MessageBox(0, 'Hook DLL', 'Could not create file map object', MB_OK);
    exit;
  end;

  {Get a pointer to our process wide memory mapped variable}
  ipHookRec := MapViewOfFile(MapHandle, FILE_MAP_WRITE, 0, 0, dwAllocSize);
  if (ipHookRec = nil) then
  begin
    CloseHandle(MapHandle);
    MessageBox(0, 'Hook DLL', 'Could not map file', MB_OK);
    exit;
  end;
end;

procedure UnMapFileMemory;
begin
  {Delete our process wide memory mapped variable}
  if (ipHookRec <> nil) then
  begin
    UnMapViewOfFile(ipHookRec);
    ipHookRec := nil;
  end;
  if (MapHandle > 0) then
  begin
    CloseHandle(MapHandle);
    MapHandle := 0;
  end;
end;

function GetHookRecPointer: pointer stdcall;
begin
  {Return a pointer to our process wide memory mapped variable}
  result := ipHookRec;
end;

function FocusHookProc(code: integer; wParam: wParam; lParam: lParam):     LResult; stdcall;
begin
 if (code < 0) then
  begin
    result := CallNextHookEx(ipHookRec^.HookHandle, code, wParam, lParam);
    exit;
  end;

  result := 0;

  if (code = HCBT_SETFOCUS) then
  begin
    if (ipHookRec^.WindowHandle <> INVALID_HANDLE_VALUE) then
      PostMessage(ipHookRec^.WindowHandle, WM_MYFOCUSCHANGED, wParam,     lParam);
    // wParam: Handle to the window gaining the keyboard focus

  end;
end;

procedure InstallHook(Hwnd: Cardinal); stdcall;
begin

  if ((ipHookRec <> nil) and (ipHookRec^.HookHandle = 0) and     (ipHookRec^.WindowHandle = 0)) then
  begin
    ipHookRec^.WindowHandle := Hwnd;   // handle to the application window
    ipHookRec^.HookHandle := SetWindowsHookEx(WH_CBT, @FocusHookProc,     Hinstance, 0);
  end;
end;

procedure UninstallHook; stdcall;
begin
   if ((ipHookRec <> nil) and (ipHookRec^.HookHandle <> 0)) then
  begin
    {Remove our hook and clear our hook handle}
    if (UnHookWindowsHookEx(ipHookRec^.HookHandle) <> FALSE) then
    begin
      ipHookRec^.HookHandle := 0;
      ipHookRec^.WindowHandle := 0;
    end;
  end;
end;

// Das ist unsere Hook-Funktion, die statt der originalen ausgeführt wird
function InterceptMessageBoxW(hWnd: HWND; lpText, lpCaption: LPCWSTR; uType: UINT): Integer; stdcall;
begin
  // Verhalten ändern oder Logik ausführen
  Result := TrampolineMessageBoxW(hWnd, 'Hooked Text!', lpCaption, uType);
end;

procedure DLLEntryPoint(dwReason: DWORD);
begin
  case dwReason of
    DLL_PROCESS_ATTACH:
    begin
      // Hook aktivieren beim Laden der DLL
      TrampolineMessageBoxW := InterceptCreate(@MessageBoxW, @InterceptMessageBoxW);
    end;
    DLL_PROCESS_DETACH:
    begin
      // Hook entfernen beim Entladen der DLL
      if Assigned(TrampolineMessageBoxW) then
        InterceptRemove(@TrampolineMessageBoxW);
    end;
  end;
end;

exports
  InstallHook name 'INSTALLHOOK',
  UninstallHook name 'UNINSTALLHOOK',
  GetHookRecPointer name 'GETHOOKRECPOINTER',
  StartMouseHook64 name 'StartMouseHook',
  StopMouseHook64 name 'StopMouseHook';

begin
  DllProc := @DLLEntryPoint;
  DLLEntryPoint(DLL_PROCESS_ATTACH);
end.