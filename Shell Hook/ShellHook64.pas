unit ShellHook64;

interface

uses
  Winapi.Windows, System.SysUtils;

type
  // The absolute 64-bit jump structure (12 bytes total)
  TJumpTrampoline = packed record
    OpcodeMove: Word;       // $B848 -> MOV RAX, <64-bit Address>
    TargetAddress: UInt64;  // 8-byte destination address
    OpcodeJmp: Word;        // $FFE0 -> JMP RAX
  end;

function HookFunction64(TargetFunc, HookFunc: Pointer; out OriginalBytes: TJumpTrampoline): Boolean;
procedure UnhookFunction64(TargetFunc: Pointer; const OriginalBytes: TJumpTrampoline);

implementation

function HookFunction64(TargetFunc, HookFunc: Pointer; out OriginalBytes: TJumpTrampoline): Boolean;
var
  OldProtect: DWORD;
  NewJump: TJumpTrampoline;
  BytesWritten: NativeUInt;
begin
  Result := False;
  if (TargetFunc = nil) or (HookFunc = nil) then Exit;

  // Prepare the 64-bit assembly patch:
  // MOV RAX, HookFunc
  // JMP RAX
  NewJump.OpcodeMove := $B848; 
  NewJump.TargetAddress := UInt64(HookFunc);
  NewJump.OpcodeJmp := $E0FF;

  // 1. Change memory permission to writable
  if VirtualProtect(TargetFunc, SizeOf(TJumpTrampoline), PAGE_EXECUTE_READWRITE, OldProtect) then
  begin
    try
      // 2. Backup the original 12 bytes so we can restore later
      Move(TargetFunc^, OriginalBytes, SizeOf(TJumpTrampoline));
      
      // 3. Overwrite the start of target function with our jump
      Move(NewJump, TargetFunc^, SizeOf(TJumpTrampoline));
      
      // 4. Flush instruction cache to enforce execution of the new code
      FlushInstructionCache(GetCurrentProcess, TargetFunc, SizeOf(TJumpTrampoline));
      Result := True;
    finally
      // 5. Restore original memory protections
      VirtualProtect(TargetFunc, SizeOf(TJumpTrampoline), OldProtect, OldProtect);
    end;
  end;
end;

procedure UnhookFunction64(TargetFunc: Pointer; const OriginalBytes: TJumpTrampoline);
var
  OldProtect: DWORD;
begin
  if TargetFunc = nil then Exit;

  if VirtualProtect(TargetFunc, SizeOf(TJumpTrampoline), PAGE_EXECUTE_READWRITE, OldProtect) then
  begin
    try
      Move(OriginalBytes, TargetFunc^, SizeOf(TJumpTrampoline));
      FlushInstructionCache(GetCurrentProcess, TargetFunc, SizeOf(TJumpTrampoline));
    finally
      VirtualProtect(TargetFunc, SizeOf(TJumpTrampoline), OldProtect, OldProtect);
    end;
  end;
end;

end.