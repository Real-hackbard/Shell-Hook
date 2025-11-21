unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, ShlObj, ActiveX, ShellAPI,
  PsAPI, ImgList, System.ImageList, Vcl.Menus;

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
  protected
    procedure WndProc(var Msg: TMessage); override;
  private
    { Private declarations }
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

implementation

{$R *.dfm}

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
      Result := FD.nFileSizeHigh;
      Result := Result shl 32;
      Result := Result + FD.nFileSizeLow;
    finally
      //CloseHandle(FH);
    end;
end;

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
  hFile := CreateFile(pChar(lpExeFilename), GENERIC_READ, FILE_SHARE_READ, NIL,
    OPEN_EXISTING, 0, 0);
  if hFile <> INVALID_HANDLE_VALUE then
    try
      bToRead := GetFileSize(hFile, NIL);
      if bToRead > kb32 then bToRead := kb32;
      if not ReadFile(hFile, Buffer, bToRead, bRead, NIL) then Exit;
      if bRead = bToRead then
      begin
        pDos := @Buffer[0];
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

function IsExecutable64Bit(const lpExeFilename: String): Boolean;
// there only exist 32 and 64 bit executables,
// if its not the one, its assumably the other
begin
  Result := not IsExecutable32Bit(lpExeFilename);
end;

procedure ShowFolder(strFolder: string);
begin
  ShellExecute(Application.Handle,
    PChar('explore'),
    PChar(strFolder),
    nil,
    nil,
    SW_SHOWNORMAL);
end;

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

function GetIcon(const FileName: string):
  TIcon;
var
  FileInfo: TShFileInfo;
  ImageList: TImageList;
begin
  Result := TIcon.Create;
  ImageList := TImageList.Create(nil);
  FillChar(FileInfo, Sizeof(FileInfo), #0);
  ImageList.ShareImages := true;
  ImageList.Handle := SHGetFileInfo(
    PChar(FileName),
    SFGAO_SHARE,
    FileInfo,
    SizeOf(FileInfo),
    SHGFI_SMALLICON or SHGFI_SYSICONINDEX
    );
  ImageList.GetIcon(FileInfo.iIcon, Result);
  ImageList.Free;
end;

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

function GetWndExePath(Wnd: HWND): String;
var
  ProcessHandle: THANDLE;
  ProcessId: DWORD;
  ExePath: array[0..256] of Char;
begin
  // Determine the path of the window.
  GetWindowThreadProcessId(Wnd, ProcessId);
  ProcessHandle:= OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, ProcessId);
  if GetModuleFileNameEx(ProcessHandle, 0, ExePath, 256) <> 0 then
    Result:= ExePath
  else
    Result:= '';
end;

procedure TForm1.WndProc(var Msg: TMessage);
begin
  inherited;
  if (Msg.Msg = MHSHELL_WINDOWCREATED) then
  begin
  (* In Delphi, WndProc (Window Procedure) is a virtual method in VCL
     controls (such as TControl, TWinControl and TForm) that is
     responsible for processing all Windows messages sent to the
     associated window handle.*)
    ImageList1.AddIcon(GetIcon(GetWndExePath(Msg.LParam)));
    with ListView1.Items.Insert(0) do
    begin
      Caption:= 'HSHELL_WINDOWCREATED';
      SubItems.Add(GetWndClassName(Msg.LParam));
      SubItems.Add(GetWndExePath(Msg.LParam));
      SubItems.Add(IntToStr(Msg.LParam));
      ImageIndex:= ImageList1.Count - 1;
      Data:= Pointer(clLime);
    end;
  end;
  if (Msg.Msg = MHSHELL_WINDOWDESTROYED) then
  begin
    ImageList1.AddIcon(GetIcon(GetWndExePath(Msg.LParam)));
    with ListView1.Items.Insert(0) do
    begin
      Caption:= 'HSHELL_WINDOWDESTROYED';
      SubItems.Add(GetWndClassName(Msg.LParam));
      SubItems.Add(GetWndExePath(Msg.LParam));
      SubItems.Add(IntToStr(Msg.LParam));
      ImageIndex:= ImageList1.Count - 1;
      Data:= Pointer(clRed);
    end;
  end;
  if (Msg.Msg = MHSHELL_WINDOWACTIVATED) then
  begin
    ImageList1.AddIcon(GetIcon(GetWndExePath(Msg.LParam)));
    with ListView1.Items.Insert(0) do
    begin
      Caption:= 'HSHELL_WINDOWACTIVATED';
      SubItems.Add(GetWndClassName(Msg.LParam));
      SubItems.Add(GetWndExePath(Msg.LParam));
      SubItems.Add(IntToStr(Msg.LParam));
      ImageIndex:= ImageList1.Count - 1;
      Data:= Pointer(RGB(240, 240, 240));
    end;
  end;
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
  Form1.DoubleBuffered := true;
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

procedure TForm1.ListView1Change(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  StatusBar1.Panels[1].Text := IntToStr(ListView1.Items.Count);
end;

procedure TForm1.ListView1Click(Sender: TObject);
begin
  if ListView1.Items.Count = 0 then Exit;

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

initialization
  MHSHELL_WINDOWACTIVATED:= RegisterWindowMessage('MHSHELL_WINDOWACTIVATED');
  MHSHELL_WINDOWCREATED:= RegisterWindowMessage('MHSHELL_WINDOWCREATED');
  MHSHELL_WINDOWDESTROYED:= RegisterWindowMessage('MHSHELL_WINDOWDESTROYED');
end.