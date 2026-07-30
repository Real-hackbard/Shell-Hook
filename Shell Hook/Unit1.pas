unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, Vcl.Shell.ShellCtrls, WinApi.ShlObj, WinApi.ActiveX,
  WinApi.ShellAPI, WinApi.PsAPI, ImgList, System.ImageList, Vcl.Menus,
  Vcl.StdCtrls, Vcl.ExtCtrls, WinApi.TlHelp32, ShellHook64;

type
  TForm1 = class(TForm)
    ListView1: TListView;
    ImageList1: TImageList;
    Panel1: TPanel;
    Label1: TLabel;
    StatusBar1: TStatusBar;
    PopupMenu1: TPopupMenu;
    Properties1: TMenuItem;
    Browse1: TMenuItem;
    Execute1: TMenuItem;
    N1: TMenuItem;
    Clear1: TMenuItem;
    ColorData1: TMenuItem;
    N2: TMenuItem;
    StartHook1: TMenuItem;
    StopHook1: TMenuItem;
    N3: TMenuItem;
    erminate1: TMenuItem;
    N4: TMenuItem;
    StayTop1: TMenuItem;
    Grid1: TMenuItem;
    View1: TMenuItem;
    Report1: TMenuItem;
    List1: TMenuItem;
    Label2: TLabel;
    Panel2: TPanel;
    ListBox1: TListBox;
    Panel3: TPanel;
    Timer1: TTimer;
    Button1: TButton;
    asklist1: TMenuItem;
    Label3: TLabel;
    procedure FormDestroy(Sender: TObject);
    procedure ListView1CustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure Properties1Click(Sender: TObject);
    procedure Browse1Click(Sender: TObject);
    procedure Execute1Click(Sender: TObject);
    procedure ListView1Change(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure Clear1Click(Sender: TObject);
    procedure StartHook1Click(Sender: TObject);
    procedure StopHook1Click(Sender: TObject);
    procedure erminate1Click(Sender: TObject);
    procedure StayTop1Click(Sender: TObject);
    procedure ListView1Click(Sender: TObject);
    procedure Grid1Click(Sender: TObject);
    procedure Report1Click(Sender: TObject);
    procedure List1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ListBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure asklist1Click(Sender: TObject);
  protected
    procedure WndProc(var Msg: TMessage); override;
  private
    { Private declarations }
    flbHorzScrollWidth: Integer; // horizontal scrollbar listbox
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  MHSHELL_WINDOWACTIVATED: Cardinal;
  MHSHELL_WINDOWCREATED: Cardinal;
  MHSHELL_WINDOWDESTROYED: Cardinal;
  HookEnable: Boolean = False;

function StartMouseHook(State: Boolean; Wnd: HWND): Boolean; stdcall; external 'SHELLHook.dll';
function StopMouseHook(): Boolean; stdcall; external 'SHELLHook.dll';

{ Use these functions when ShellHook64.dll is used.
  These two functions are retrieved from "ShellHook64.dll". }
//function StartMouseHook64(State: Boolean; Wnd: HWND): Boolean; stdcall; external 'SHELLHook64.dll';
//function StopMouseHook64(): Boolean; stdcall; external 'SHELLHook64.dll';

implementation

{$R *.dfm}
{ Driver injection for the 64-bit version.
  If the function fails, the project must be set to a 64-bit version in the IDE. }
{
procedure InjectDLL64(ProcessID: DWORD; const DLLPath: string);
var
  hProcess, hThread: THandle;
  pLibPath: Pointer;
  BytesWritten: NativeUInt;
begin
  hProcess := OpenProcess(PROCESS_ALL_ACCESS, False, ProcessID);
  if hProcess <> 0 then
  begin
    // Speicher im 64-Bit-Zielprozess reservieren
    pLibPath := VirtualAllocEx(hProcess, nil,
                               Length(DLLPath) * SizeOf(Char),
                               MEM_COMMIT, PAGE_READWRITE);

    // DLL-Pfad in den Speicher schreiben
    WriteProcessMemory(hProcess, pLibPath, PChar(DLLPath),
                       Length(DLLPath) * SizeOf(Char), BytesWritten);

    // LoadLibrary im Zielprozess aufrufen, um die Hook-DLL auszuführen
    hThread := CreateRemoteThread(hProcess, nil, 0,
               GetProcAddress(GetModuleHandle('kernel32.dll'),
               'LoadLibraryW'),
               pLibPath,
               0,
               BytesWritten);

    WaitForSingleObject(hThread, INFINITE);
    CloseHandle(hThread);
    CloseHandle(hProcess);
  end;
end;
 }

// Determine the memory usage of a running process.
function GetMemoryUsage(pid : cardinal) : DWORD;
var
  hdl : cardinal;
  // retrieve detailed memory statistics (like RAM usage and pagefile allocation)
  pcb : PROCESS_MEMORY_COUNTERS;
begin
  result := 0;
  // Open the process
  hdl := OpenProcess(PROCESS_QUERY_INFORMATION,false,pid);

  if hdl > 0 then
  begin
    // Get the memory information
    GetProcessMemoryInfo(hdl,@pcb,sizeof(pcb));
    result := pcb.WorkingSetSize;
  end;
end;

{ To get the full file name (executable path) of a parent process based
  on a target process ID (PID) }
function GetParentProcessFileName(PID : DWORD): String;
var
  HandleSnapShot      : THandle;
  EntryParentProc     : TProcessEntry32;
  HandleParentProc    : THandle;
  ParentPID           : DWORD;
  ParentProcessFound  : Boolean;
  ParentProcPath      : PChar;
begin
  ParentProcessFound := False;
  // Snapshot of currently running processes
  HandleSnapShot     := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  GetMem(ParentProcPath, MAX_PATH);
  try
    // check is handle exists
    if HandleSnapShot <> INVALID_HANDLE_VALUE then
    begin
      // extract details about a program's parent process
      EntryParentProc.dwSize := SizeOf(EntryParentProc);
      // to list all process names in a string list
      if Process32First(HandleSnapShot, EntryParentProc) then
      begin
        repeat
          { store the Process Identifier (PID) of a specific process
            iterated from a system snapshot }
          if EntryParentProc.th32ProcessID = PID then
          begin
            // if found pid..
            ParentPID  := EntryParentProc.th32ParentProcessID;
            // ..read information about them
            HandleParentProc  := OpenProcess(PROCESS_QUERY_INFORMATION or
                                             PROCESS_VM_READ, False, ParentPID);
            ParentProcessFound:= HandleParentProc <> 0;
            if ParentProcessFound then
            begin
              { retrieve the full file path of an executable file (.exe) or
                a DLL of another running process. }
                GetModuleFileNameEx(HandleParentProc, 0, PChar(ParentProcPath), MAX_PATH);
                { A secure process that prevents memory corruption or crashes
                  and needs to be replaced by a modern, secure approach. }
                ParentProcPath := PChar(ParentProcPath);
                // en the process
                CloseHandle(HandleParentProc);
            end;
            break;
          end;
        until not Process32Next(HandleSnapShot, EntryParentProc);
      end;
      CloseHandle(HandleSnapShot);
    end;

    // transferring information
    if ParentProcessFound then
      Result := ParentProcPath
    else
      Result := '';
  finally
      FreeMem(ParentProcPath);
  end;
end;

// To get a Process ID (PID) by its process name
function GetPIDbyProcessName(processName:String):integer;
var
  GotProcess: Boolean;
  tempHandle: tHandle;
  procE: TProcessEntry32;
begin
  // Snapshot of currently running processes
  tempHandle:=CreateToolHelp32SnapShot(TH32CS_SNAPALL, 0);
  //  evaluates storage size of a variable or data type in bytes at compile time.
  procE.dwSize:=SizeOf(procE);
  // retrieve information about the first process in a system snapshot.
  GotProcess:=Process32First(tempHandle, procE);
  {$B-}    //  compiler directive enables
    if GotProcess and not SameText(procE.szExeFile, processName) then
      repeat GotProcess := Process32Next(tempHandle, procE);
      until (not GotProcess) or SameText(procE.szExeFile,processName);
  {$B+}   //  disable directive enables

  if GotProcess then
    result := procE.th32ProcessID
  else
    result := 0; // process not found in running process list

  CloseHandle(tempHandle);
end;

// retrieve a list of running processes on Windows by using the TlHelp32 API
procedure GetProcessList(const aProcessList: TStrings);
var
  Snap: THandle;
  ProcessE: TProcessEntry32;
begin
  aProcessList.Clear;
  // Snapshot of currently running processes
  Snap := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  try
    // assign the size of a data structure or record
    ProcessE.dwSize := SizeOf(ProcessE);
    // retrieve the first process from a system snapshot list
    if Process32First(Snap, ProcessE) then
      Repeat
        // create list
        aProcessList.Add(ProcessE.szExeFile);
      Until not Process32Next(Snap, ProcessE)
    else
      RaiseLastOSError;
  finally
    CloseHandle(Snap);
  end;
end;

// get a file size
function Get_File_Size4(const S: string): Int64;
var
  FD: TWin32FindData;
  FH: THandle;
begin
  // Determine the file size
  FH := FindFirstFile(PChar(S), FD);
  if FH = INVALID_HANDLE_VALUE then Result := 0
  else
    try
      // determine a file's exact size
      Result := FD.nFileSizeHigh;
      // the shl 32 (Shift Left) operator shifts the bits of an integer by 32 positions
      Result := Result shl 32;
      Result := Result + FD.nFileSizeLow;
    finally
      //CloseHandle(FH);
    end;
end;

// Check if the program is 32-bit.
function IsExecutable32Bit(const lpExeFilename: String): Boolean;
const
  kb32 = 1024 * 32;
var
  Buffer : Array[0..kb32-1] of Byte; // warning: assuming both headers are in there!
  hFile : DWord;
  bRead : DWord;
  bToRead : DWord;
  pDos : PImageDosHeader;
  pNt : PImageNtHeaders;
begin
  // Determine whether the file is a 64-bit or 32-bit file.
  Result := False;
  // request read access to a file, directory, or device
  hFile := CreateFile(pChar(lpExeFilename), GENERIC_READ, FILE_SHARE_READ, NIL,
    OPEN_EXISTING, 0, 0);
  if hFile <> INVALID_HANDLE_VALUE then
    try
      // Determine the size.
      bToRead := GetFileSize(hFile, NIL);
      if bToRead > kb32 then bToRead := kb32;
      // Let go if the file is unreadable.
      if not ReadFile(hFile, Buffer, bToRead, bRead, NIL) then Exit;

      if bRead = bToRead then
      begin
        // yields the memory address of the first element from array
        pDos := @Buffer[0];
        // parsing Windows Portable Executable (PE) files
        if pDos.e_magic = IMAGE_DOS_SIGNATURE then
        begin
          pNt := PImageNtHeaders(LongInt(pDos) + pDos._lfanew);
          if pNt.Signature = IMAGE_NT_SIGNATURE then
            Result := pNt.FileHeader.Machine and IMAGE_FILE_32BIT_MACHINE > 0;
        end; {
        else
          raise Exception.Create('File is not a valid executable.');
        }
      end; {
        else
          raise Exception.Create('File is not an executable.');
        }
    finally
      CloseHandle(hFile);
    end;
end;

// check if a compiled file is 64-bit
function IsExecutable64Bit(const lpExeFilename: String): Boolean;
begin
  Result := not IsExecutable32Bit(lpExeFilename);
end;

{ opening the folder in Windows Explorer or showing a folder-selection
  dialog box to the user. }
procedure ShowFolder(strFolder: string);
begin
  ShellExecute(Application.Handle,
    PChar('explore'),
    PChar(strFolder),
    nil,
    nil,
    SW_SHOWNORMAL);
end;

{ display the standard Windows File Properties dialog for a specific
  file in Delphi, you need to use the Windows API function ShellExecuteEx
  with the properties verb. }
procedure PropertiesDialog(const aFilename: string);
var
  sei: ShellExecuteInfo;
begin
  // Execute File Properties Windows Dialog
  FillChar(sei, SizeOf(sei), 0);
  sei.cbSize := SizeOf(sei);
  sei.lpFile := PChar(aFilename);
  sei.lpVerb := 'properties';
  sei.fMask  := SEE_MASK_INVOKEIDLIST;
  ShellExecuteEx(@sei);
end;

// Determine the system icon for the files.
function GetIcon(const FileName: string):
  TIcon;
var
  FileInfo: TShFileInfo;
  ImageList: TImageList;
begin
  // instantiate an empty icon object
  Result := TIcon.Create;
  // creates an image list
  ImageList := TImageList.Create(nil);
  try
    FillChar(FileInfo, Sizeof(FileInfo), #0);
    ImageList.ShareImages := true;
    ImageList.Handle := SHGetFileInfo(PChar(FileName),SFGAO_SHARE,
              FileInfo,SizeOf(FileInfo),SHGFI_SMALLICON or SHGFI_SYSICONINDEX);
    // pass the icon
    ImageList.GetIcon(FileInfo.iIcon, Result);
  finally
    ImageList.Free;
  end;
end;

// retrieve a window's class name by its handle (HWND)
function GetWndClassName(Wnd: HWND): String;
var
  WndClassName: array[0..256] of Char;
begin
  // Determine the Windows Class Name
  if GetClassName(Wnd, WndClassName, 256) <> 0 then
    Result:= WndClassName
  else
    Result:= '';
end;

// Determine the exact path of an external process.
function GetWndExePath(Wnd: HWND): String;
var
  ProcessHandle: THANDLE;
  ProcessId: DWORD;
  ExePath: array[0..256] of Char;
begin
  // Determine the path of the window.
  GetWindowThreadProcessId(Wnd, ProcessId);
  // Windows API access right
  ProcessHandle:= OpenProcess(PROCESS_QUERY_INFORMATION or
                              PROCESS_VM_READ, False, ProcessId);
  // determines the full path of the module of an external process
  if GetModuleFileNameEx(ProcessHandle, 0, ExePath, 256) <> 0 then
    Result:= ExePath
  else
    Result:= '';
end;

{ central method through which a control or window receives all
  Windows messages (such as clicks, keystrokes, or drawing commands). }
procedure TForm1.WndProc(var Msg: TMessage);
var
  i : Cardinal;
begin
  (* In Delphi, WndProc (Window Procedure) is a virtual method in VCL
     controls (such as TControl, TWinControl and TForm) that is
     responsible for processing all Windows messages sent to the
     associated window handle.*)

  inherited; // to call the constructor of the base class (parent class)

   // when a Windows window is being built
  if (Msg.Msg = MHSHELL_WINDOWCREATED) then
  begin
    // Retrieve the handle icon
    ImageList1.AddIcon(GetIcon(GetWndExePath(Msg.LParam)));

    // Populate the ListView with the handle's information.
    with ListView1.Items.Insert(0) do
    begin
      Caption:= 'Created..';
      SubItems.Add(ExtractFileName(GetWndExePath(Msg.LParam)));
      SubItems.Add(GetWndExePath(Msg.LParam));
      SubItems.Add(IntToStr(Msg.LParam));
      SubItems.Add(GetWndClassName(Msg.LParam));
      SubItems.Add(IntToStr(GetPIDbyProcessName(ExtractFileName(GetWndExePath(Msg.LParam)))));
      SubItems.Add(IntToStr(GetMemoryUsage(GetPIDbyProcessName(ExtractFileName(GetWndExePath(Msg.LParam)))) div 1000) + ' Kb');
      ImageIndex:= ImageList1.Count - 1;
      Data:= Pointer(clLime);
    end;

    //  update tasklist
    if asklist1.Checked = true then Button1.Click;
  end;

  // when a window is closed or destroyed
  if (Msg.Msg = MHSHELL_WINDOWDESTROYED) then
  begin
    // Retrieve the handle icon
    ImageList1.AddIcon(GetIcon(GetWndExePath(Msg.LParam)));
    // Populate the ListView with the handle's information.
    with ListView1.Items.Insert(0) do
    begin
      Caption:= 'Destroyed..';
      SubItems.Add(ExtractFileName(GetWndExePath(Msg.LParam)));
      SubItems.Add(GetWndExePath(Msg.LParam));
      SubItems.Add(IntToStr(Msg.LParam));
      SubItems.Add(GetWndClassName(Msg.LParam));
      SubItems.Add(IntToStr(GetPIDbyProcessName(ExtractFileName(GetWndExePath(Msg.LParam)))));
      SubItems.Add(IntToStr(GetMemoryUsage(GetPIDbyProcessName(ExtractFileName(GetWndExePath(Msg.LParam)))) div 1000) + ' Kb');
      ImageIndex:= ImageList1.Count - 1;
      Data:= Pointer(clRed);
    end;
  end;

  // when a window is clicked or focused by another process
  if (Msg.Msg = MHSHELL_WINDOWACTIVATED) then
  begin
    // Retrieve the handle icon
    ImageList1.AddIcon(GetIcon(GetWndExePath(Msg.LParam)));
    // Populate the ListView with the handle's information.
    with ListView1.Items.Insert(0) do
    begin
      Caption:= 'Activated..';
      SubItems.Add(ExtractFileName(GetWndExePath(Msg.LParam)));
      SubItems.Add(GetWndExePath(Msg.LParam));
      SubItems.Add(IntToStr(Msg.LParam));
      SubItems.Add(GetWndClassName(Msg.LParam));
      SubItems.Add(IntToStr(GetPIDbyProcessName(ExtractFileName(GetWndExePath(Msg.LParam)))));
      SubItems.Add(IntToStr(GetMemoryUsage(GetPIDbyProcessName(ExtractFileName(GetWndExePath(Msg.LParam)))) div 1000) + ' Kb');
      ImageIndex:= ImageList1.Count - 1;
      Data:= Pointer(RGB(230, 230, 230));
    end;
  end;
end;

procedure TForm1.asklist1Click(Sender: TObject);
begin
  Panel2.Visible := asklist1.Checked;
  Button1.Visible := asklist1.Checked;
end;

procedure TForm1.Browse1Click(Sender: TObject);
var
  strFolder : string;
begin
  if ListView1.Items.Count = 0 then Exit;
  ShowFolder(ExtractFileDir(ListView1.Selected.SubItems[1]));
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if HookEnable <> False then
    StopMouseHook;
end;

procedure TForm1.Grid1Click(Sender: TObject);
begin
  if Grid1.Checked = true then
  ListView1.GridLines := true
  else
  ListView1.GridLines := false;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Listbox1.Perform(LB_SetHorizontalExtent, 1000, Longint(0));
  Form1.DoubleBuffered := true;
  GetProcessList(ListBox1.Items);
end;

// update tasklist
procedure TForm1.Button1Click(Sender: TObject);
var
  search: string;
begin
  // Populate the list box with the task list.
  GetProcessList(listbox1.Items);
  if asklist1.Checked = true then
  begin
    // Find the string in the first sub-item of the ListView's first item.
    search := ListView1.Items[0].SubItems[0];
    // Pass the listbox string and select the item.
    if SendMessage(ListBox1.Handle, lb_selectstring, - 1,
       Longint(PChar(search))) <> LB_ERR then
      ListBox1.Update
    else
      ListBox1.Update;
  end;
  StatusBar1.SetFocus;
end;

procedure TForm1.Clear1Click(Sender: TObject);
begin
  ListView1.Clear;
  StatusBar1.Panels[3].Text := '';
  StatusBar1.Panels[5].Text := '0 Kb';
end;

procedure TForm1.erminate1Click(Sender: TObject);
begin
  HookEnable:= False;
  Application.Terminate;
end;

procedure TForm1.Execute1Click(Sender: TObject);
begin
  if ListView1.Items.Count = 0 then Exit;
  ShellExecute(Handle, 'open',
              PChar(ListView1.Selected.Subitems[1]), nil, nil, SW_SHOWNORMAL) ;
end;

procedure TForm1.List1Click(Sender: TObject);
begin
  ListView1.ViewStyle := vsSmallIcon;
end;

// Add the horizontal scrollbar for the listbox.
procedure TForm1.ListBox1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
 Len: Integer;
 NewText: String;
begin
  NewText:=Listbox1.Items[Index];

  with Listbox1.Canvas do
  begin
    FillRect(Rect);
    TextOut(Rect.Left + 1, Rect.Top, NewText);
    Len:=TextWidth(NewText) + Rect.Left + 10;
    if Len>flbHorzScrollWidth then
    begin
      flbHorzScrollWidth:=Len;
      Listbox1.Perform(LB_SETHORIZONTALEXTENT, flbHorzScrollWidth, 0 );
    end;
  end;
end;

// count the listview items
procedure TForm1.ListView1Change(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  StatusBar1.Panels[1].Text := IntToStr(ListView1.Items.Count);
end;

{ Check whether the target file (EXE) is a 32-bit or 64-bit file and
  write this to the status bar. }
procedure TForm1.ListView1Click(Sender: TObject);
begin
  If ListView1.ItemIndex <> -1 then
  begin
     if IsExecutable64Bit(ListView1.Selected.SubItems[1]) = true then
    begin
      StatusBar1.Panels[3].Text := ExtractFileName(ListView1.Selected.SubItems[1]) +
                                                ' (64 Bit)';
    end else begin
      StatusBar1.Panels[3].Text := ExtractFileName(ListView1.Selected.SubItems[1]) +
                                                ' (32 Bit)';
    end;

    StatusBar1.Panels[5].Text := IntToStr(Get_File_Size4(ListView1.Selected.SubItems[1])
                                          div 1000) + ' Kb';
    StatusBar1.Panels[7].Text := ListView1.Selected.Caption;
  end;
end;

// Color-code the respective activities in the report.
// green for created
// red for destroyed
// gray for activated
procedure TForm1.ListView1CustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if ColorData1.Checked = true then
  Sender.Canvas.Brush.Color := TColor(Item.Data);
end;

procedure TForm1.Properties1Click(Sender: TObject);
begin
  if ListView1.Items.Count = 0 then Exit;
  PropertiesDialog(ListView1.Selected.SubItems[1]);
end;

procedure TForm1.Report1Click(Sender: TObject);
begin
  ListView1.ViewStyle := vsReport;
end;

// start hook
procedure TForm1.StartHook1Click(Sender: TObject);
begin
  if StartMouseHook(True, Handle) = True then
  begin
    HookEnable:= True;
    StartHook1.Enabled:= False;
    StopHook1.Enabled:= True;
    Properties1.Enabled := false;
    Browse1.Enabled := false;
    Execute1.Enabled := false;
  end;
end;

// stop hook
procedure TForm1.StopHook1Click(Sender: TObject);
begin
  if StopMouseHook = True then
  begin
    HookEnable:= False;
    StartHook1.Enabled:= True;
    StopHook1.Enabled:= False;
    Properties1.Enabled := true;
    Browse1.Enabled := true;
    Execute1.Enabled := true;
  end;
end;

procedure TForm1.StayTop1Click(Sender: TObject);
begin
  if StayTop1.Checked = true then
    SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE)
  else
    SetWindowPos(Handle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE);
end;

{ primarily refers to the initialization block within a source unit,
  which executes startup code automatically before the main
  application runs. }
initialization
  MHSHELL_WINDOWACTIVATED:= RegisterWindowMessage('MHSHELL_WINDOWACTIVATED');
  MHSHELL_WINDOWCREATED:= RegisterWindowMessage('MHSHELL_WINDOWCREATED');
  MHSHELL_WINDOWDESTROYED:= RegisterWindowMessage('MHSHELL_WINDOWDESTROYED');
end.