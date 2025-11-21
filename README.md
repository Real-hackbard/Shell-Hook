# Shell-Hook:

</br>

![Compiler](https://github.com/user-attachments/assets/a916143d-3f1b-4e1f-b1e0-1067ef9e0401) &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: ![10 Seattle](https://github.com/user-attachments/assets/c70b7f21-688a-4239-87c9-9a03a8ff25ab) ![10 1 Berlin](https://github.com/user-attachments/assets/bdcd48fc-9f09-4830-b82e-d38c20492362) ![10 2 Tokyo](https://github.com/user-attachments/assets/5bdb9f86-7f44-4f7e-aed2-dd08de170bd5) ![10 3 Rio](https://github.com/user-attachments/assets/e7d09817-54b6-4d71-a373-22ee179cd49c)   
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;![10 4 Sydney](https://github.com/user-attachments/assets/e75342ca-1e24-4a7e-8fe3-ce22f307d881) ![11 Alexandria](https://github.com/user-attachments/assets/64f150d0-286a-4edd-acab-9f77f92d68ad) ![12 Athens](https://github.com/user-attachments/assets/59700807-6abf-4e6d-9439-5dc70fc0ceca)  
![Components](https://github.com/user-attachments/assets/d6a7a7a4-f10e-4df1-9c4f-b4a1a8db7f0e) : ![None](https://github.com/user-attachments/assets/30ebe930-c928-4aaf-a8e1-5f68ec1ff349)  
![Discription](https://github.com/user-attachments/assets/4a778202-1072-463a-bfa3-842226e300af) &nbsp;&nbsp;: ![Shell Hook](https://github.com/user-attachments/assets/9f5066d3-f90e-4150-9c7f-b5c334d7f0da)  
![Last Update](https://github.com/user-attachments/assets/e1d05f21-2a01-4ecf-94f3-b7bdff4d44dd) &nbsp;: ![112025](https://github.com/user-attachments/assets/6c049038-ad2c-4fe3-9b7e-1ca8154910c2)  
![License](https://github.com/user-attachments/assets/ff71a38b-8813-4a79-8774-09a2f3893b48) &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: ![Freeware](https://github.com/user-attachments/assets/1fea2bbf-b296-4152-badd-e1cdae115c43)

</br>

In computer programming, hooking is a range of techniques used to alter or augment the behaviour of an operating system, of [applications](https://en.wikipedia.org/wiki/Application_software), or of other software components by intercepting [function calls](https://en.wikipedia.org/wiki/Function_(computer_programming)) or [messages](https://en.wikipedia.org/wiki/Message_passing) or 8events](https://en.wikipedia.org/wiki/Event_(computing)) passed between [software components](https://en.wikipedia.org/wiki/Modular_programming). Code that handles such intercepted function calls, events or messages is called a hook.

Hook methods are of particular importance in the [template method pattern](https://en.wikipedia.org/wiki/Template_method_pattern) where common code in an abstract class can be augmented by custom code in a subclass. In this case each hook method is defined in the [abstract class](https://en.wikipedia.org/wiki/Abstract_type) with an empty implementation which then allows a different implementation to be supplied in each concrete subclass.

</br>

### Run the ```SHELLHook.dproj``` file to build the ```ShellHook.dll```.

</br>

![Shell Hook](https://github.com/user-attachments/assets/e85c4700-6d63-45b0-af71-e24b4bc01ed2)

</br>

As with normal window messages, the second parameter of the window procedure identifies the message as WM_SHELLHOOKMESSAGE. However, for these shell hook messages, the message value is not a predefined constant like other message IDs such as [WM_COMMAND](https://learn.microsoft.com/de-de/windows/win32/menurc/wm-command). The value must be retrieved dynamically using a call to [RegisterWindowMessage](https://learn.microsoft.com/de-de/windows/win32/api/winuser/nf-winuser-registerwindowmessagea), as shown here:

```pascal
RegisterWindowMessage(TEXT("SHELLHOOK"));
```

The following table describes the wParam and lParam parameter values ​​that can be passed to the window procedure for the shell hook messages.

| wParam | lParam |
| :-----------  | :-----------  |
| HSHELL_GETMINRECT	| A pointer to a SHELLHOOKINFO structure. |
| HSHELL_WINDOWACTIVATED |	A handle for the activated window. |
| HSHELL_RUDEAPPACTIVATED |	A handle for the activated window. |
| HSHELL_WINDOWREPLACING |	A handle for the window that replaces the top-level window.. |
| HSHELL_WINDOWREPLACED |	A handle for the window to be replaced. |
| HSHELL_WINDOWCREATED |	A handle for the window to be created. |
| HSHELL_WINDOWDESTROYED |	A handle for the top-level window that will be destroyed. |
| HSHELL_ACTIVATESHELLWINDOW |	Not used. |
| HSHELL_TASKMAN |	Can be ignored. |
| HSHELL_REDRAW |	A handle for the window that needs to be redrawn.. |
| HSHELL_FLASH |	A handle for the window that needs to be flashed.. |
| HSHELL_ENDTASK |	A handle for the window that is to be forced to close.. |
| HSHELL_APPCOMMAND |	The APPCOMMAND parameter that has not been handled by the application or other hooks. For more information, [see WM_APPCOMMAND](https://learn.microsoft.com/de-de/windows/win32/inputdev/wm-appcommand) and use the [GET_APPCOMMAND_LPARAM macro](https://learn.microsoft.com/de-de/windows/win32/api/winuser/nf-winuser-get_appcommand_lparam) to retrieve this parameter.. |
| HSHELL_MONITORCHANGED |	A handle for the window that has been moved to another monitor.. |

</br>

### C++ Virtual method Sample Code:
```c++
#include <iostream>
#include "windows.h"
 
using namespace std;
 
class VirtualClass
{
public:
 
    int number;
 
    virtual void VirtualFn1() //This is the virtual function that will be hooked.
    {
        cout << "VirtualFn1 called " << number++ << "\n\n";
    }
};
 
using VirtualFn1_t = void(__thiscall*)(void* thisptr); 
VirtualFn1_t orig_VirtualFn1;

void __fastcall hkVirtualFn1(void* thisptr, int edx) //This is our hook function which we will cause the program to call instead of the original VirtualFn1 function after hooking is done.
{
    cout << "Hook function called" << "\n";
 
    orig_VirtualFn1(thisptr); //Call the original function.
}
 

int main()
{
    VirtualClass* myClass = new VirtualClass(); //Create a pointer to a dynamically allocated instance of VirtualClass.
 
    void** vTablePtr = *reinterpret_cast<void***>(myClass); //Find the address that points to the base of VirtualClass' VMT (which then points to VirtualFn1) and store it in vTablePtr.
 
    DWORD oldProtection;
    VirtualProtect(vTablePtr, 4, PAGE_EXECUTE_READWRITE, &oldProtection); //Removes page protection at the start of the VMT so we can overwrite its first pointer.
 
    orig_VirtualFn1 = reinterpret_cast<VirtualFn1_t>(*vTablePtr); //Stores the pointer to VirtualFn1 from the VMT in a global variable so that it can be accessed again later after its entry in the VMT has been 
                                                                  //overwritten with our hook function.
 
    *vTablePtr = &hkVirtualFn1; //Overwrite the pointer to VirtualFn1 within the virtual table to a pointer to our hook function (hkVirtualFn1).
 
    VirtualProtect(vTablePtr, 4, oldProtection, 0); //Restore old page protection.
 
    myClass->VirtualFn1(); //Call the virtual function from our class instance. Because it is now hooked, this will actually call our hook function (hkVirtualFn1).
    myClass->VirtualFn1();
    myClass->VirtualFn1();
 
    delete myClass;
 
    return 0;
}
```
</br>

### C# keyboard event hook:
The following example will hook into keyboard events in Microsoft Windows using the Microsoft .NET Framework.

```c#
using System.Runtime.InteropServices;

namespace Hooks;

public class KeyHook
{
    /* Member variables */
    protected static int Hook;
    protected static LowLevelKeyboardDelegate Delegate;
    protected static readonly object Lock = new object();
    protected static bool IsRegistered = false;

    /* DLL imports */
    [DllImport("user32")]
    private static extern int SetWindowsHookEx(int idHook, LowLevelKeyboardDelegate lpfn,
        int hmod, int dwThreadId);

    [DllImport("user32")]
    private static extern int CallNextHookEx(int hHook, int nCode, int wParam, KBDLLHOOKSTRUCT lParam);

    [DllImport("user32")]
    private static extern int UnhookWindowsHookEx(int hHook);

    /* Types & constants */
    protected delegate int LowLevelKeyboardDelegate(int nCode, int wParam, ref KBDLLHOOKSTRUCT lParam);
    private const int HC_ACTION = 0;
    private const int WM_KEYDOWN = 0x0100;
    private const int WM_KEYUP = 0x0101;
    private const int WH_KEYBOARD_LL = 13;

    [StructLayout(LayoutKind.Sequential)]
    public struct KBDLLHOOKSTRUCT
    {
        public int vkCode;
        public int scanCode;
        public int flags;
        public int time;
        public int dwExtraInfo;
    }

    /* Methods */
    static private int LowLevelKeyboardHandler(int nCode, int wParam, ref KBDLLHOOKSTRUCT lParam)
    {
        if (nCode == HC_ACTION)
        {
            if (wParam == WM_KEYDOWN)
                System.Console.Out.WriteLine("Key Down: " + lParam.vkCode);
            else if (wParam == WM_KEYUP)
                System.Console.Out.WriteLine("Key Up: " + lParam.vkCode);
        }
        return CallNextHookEx(Hook, nCode, wParam, lParam);
    }

    public static bool RegisterHook()
    {
        lock (Lock)
        {
            if (IsRegistered)
                return true;
            Delegate = LowLevelKeyboardHandler;
            Hook = SetWindowsHookEx(
                WH_KEYBOARD_LL, Delegate,
                Marshal.GetHINSTANCE(
                    System.Reflection.Assembly.GetExecutingAssembly().GetModules()[0]
                ).ToInt32(), 0
            );

            if (Hook != 0)
                return IsRegistered = true;
            Delegate = null;
            return false;
        }
    }

    public static bool UnregisterHook()
    {
        lock (Lock)
        {
            return IsRegistered = (UnhookWindowsHookEx(Hook) != 0);
        }
    }
}
```

</br>

### API/function hooking method:
The following source code is an example of an API/function hooking method which hooks by overwriting the first six bytes of a destination function with a [JMP](https://en.wikipedia.org/wiki/JMP_(x86_instruction)) instruction to a new function. The code is compiled into a DLL file then loaded into the target process using any method of [DLL injection](https://en.wikipedia.org/wiki/DLL_injection). Using a backup of the original function one might then restore the first six bytes again so the call will not be interrupted. In this example the [win32 API](https://en.wikipedia.org/wiki/Win32_API) function MessageBoxW is hooked.

```c++
#include <windows.h>  
#define SIZE 6

 typedef int (WINAPI *pMessageBoxW)(HWND, LPCWSTR, LPCWSTR, UINT);  // Messagebox prototype
 int WINAPI MyMessageBoxW(HWND, LPCWSTR, LPCWSTR, UINT);            // Our detour

 void BeginRedirect(LPVOID);                                        
 pMessageBoxW pOrigMBAddress = NULL;                                // address of original
 BYTE oldBytes[SIZE] = {0};                                         // backup
 BYTE JMP[SIZE] = {0};                                              // 6 byte JMP instruction
 DWORD oldProtect, myProtect = PAGE_EXECUTE_READWRITE;

 INT APIENTRY DllMain(HMODULE hDLL, DWORD Reason, LPVOID Reserved)  
 {  
   switch (Reason)  
   {  
   case DLL_PROCESS_ATTACH:                                        // if attached
     pOrigMBAddress = (pMessageBoxW)                      
       GetProcAddress(GetModuleHandleA("user32.dll"),              // get address of original 
               "MessageBoxW");  
     if (pOrigMBAddress != NULL)  
       BeginRedirect(MyMessageBoxW);                               // start detouring
     break;

   case DLL_PROCESS_DETACH:  
     VirtualProtect((LPVOID)pOrigMBAddress, SIZE, myProtect, &oldProtect);   // assign read write protection
     memcpy(pOrigMBAddress, oldBytes, SIZE);                                 // restore backup
     VirtualProtect((LPVOID)pOrigMBAddress, SIZE, oldProtect, &myProtect);   // reset protection

   case DLL_THREAD_ATTACH:  
   case DLL_THREAD_DETACH:  
     break;  
   }  
   return TRUE;  
 }

 void BeginRedirect(LPVOID newFunction)  
 {  
   BYTE tempJMP[SIZE] = {0xE9, 0x90, 0x90, 0x90, 0x90, 0xC3};              // 0xE9 = JMP 0x90 = NOP 0xC3 = RET
   memcpy(JMP, tempJMP, SIZE);                                             // store jmp instruction to JMP
   DWORD JMPSize = ((DWORD)newFunction - (DWORD)pOrigMBAddress - 5);       // calculate jump distance
   VirtualProtect((LPVOID)pOrigMBAddress, SIZE,                            // assign read write protection
           PAGE_EXECUTE_READWRITE, &oldProtect);  
   memcpy(oldBytes, pOrigMBAddress, SIZE);                                 // make backup
   memcpy(&JMP[1], &JMPSize, 4);                                           // fill the nop's with the jump distance (JMP,distance(4bytes),RET)
   memcpy(pOrigMBAddress, JMP, SIZE);                                      // set jump instruction at the beginning of the original function
   VirtualProtect((LPVOID)pOrigMBAddress, SIZE, oldProtect, &myProtect);   // reset protection
 }

 int WINAPI MyMessageBoxW(HWND hWnd, LPCWSTR lpText, LPCWSTR lpCaption, UINT uiType)  
 {  
   VirtualProtect((LPVOID)pOrigMBAddress, SIZE, myProtect, &oldProtect);   // assign read write protection
   memcpy(pOrigMBAddress, oldBytes, SIZE);                                 // restore backup
   int retValue = MessageBoxW(hWnd, lpText, lpCaption, uiType);            // get return value of original function
   memcpy(pOrigMBAddress, JMP, SIZE);                                      // set the jump instruction again
   VirtualProtect((LPVOID)pOrigMBAddress, SIZE, oldProtect, &myProtect);   // reset protection
   return retValue;                                                        // return original return value
 }
```

</br>

### Netfilter hook:
This example shows how to use hooking to alter network traffic in the Linux kernel using [Netfilter](https://en.wikipedia.org/wiki/Netfilter).

```C++
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/skbuff.h>

#include <linux/ip.h>
#include <linux/tcp.h>
#include <linux/in.h>
#include <linux/netfilter.h>
#include <linux/netfilter_ipv4.h>

/* Port we want to drop packets on */
static const uint16_t port = 25;

/* This is the hook function itself */
static unsigned int hook_func(unsigned int hooknum,
                       struct sk_buff **pskb,
                       const struct net_device *in,
                       const struct net_device *out,
                       int (*okfn)(struct sk_buff *))
{
        struct iphdr *iph = ip_hdr(*pskb);
        struct tcphdr *tcph, tcpbuf;

        if (iph->protocol != IPPROTO_TCP)
                return NF_ACCEPT;

        tcph = skb_header_pointer(*pskb, ip_hdrlen(*pskb), sizeof(*tcph), &tcpbuf);
        if (tcph == NULL)
                return NF_ACCEPT;

        return (tcph->dest == port) ? NF_DROP : NF_ACCEPT;
}

/* Used to register our hook function */
static struct nf_hook_ops nfho = {
        .hook     = hook_func,
        .hooknum  = NF_IP_PRE_ROUTING,
        .pf       = NFPROTO_IPV4,
        .priority = NF_IP_PRI_FIRST,
};

static __init int my_init(void)
{
        return nf_register_hook(&nfho);
}

static __exit void my_exit(void)
{
    nf_unregister_hook(&nfho);
}

module_init(my_init);
module_exit(my_exit);
```

</br>

### Internal IAT hooking:
The following code demonstrates how to hook functions that are imported from another module. This can be used to hook functions in a different process from the calling process. For this the code must be compiled into a DLL file then loaded into the target process using any method of DLL injection. The advantage of this method is that it is less detectable by antivirus software and/or [anti-cheat](https://en.wikipedia.org/wiki/Cheating_in_online_games#Anti-cheating_methods_and_limitations) software, one might make this into an external hook that doesn't make use of any malicious calls. The [Portable Executable](https://en.wikipedia.org/wiki/Portable_Executable) header contains the Import Address Table (IAT), which can be manipulated as shown in the source below. The source below runs under Microsoft Windows.

```C++
#include <windows.h>

typedef int(__stdcall *pMessageBoxA) (HWND hWnd, LPCSTR lpText, LPCSTR lpCaption, UINT uType); //This is the 'type' of the MessageBoxA call.
pMessageBoxA RealMessageBoxA; //This will store a pointer to the original function.

void DetourIATptr(const char* function, void* newfunction, HMODULE module);

int __stdcall NewMessageBoxA(HWND hWnd, LPCSTR lpText, LPCSTR lpCaption, UINT uType) { //Our fake function
    printf("The String Sent to MessageBoxA Was : %s\n", lpText);
    return RealMessageBoxA(hWnd, lpText, lpCaption, uType); //Call the real function
}

int main(int argc, CHAR *argv[]) {
   DetourIATptr("MessageBoxA",(void*)NewMessageBoxA,0); //Hook the function
   MessageBoxA(NULL, "Just A MessageBox", "Just A MessageBox", 0); //Call the function -- this will invoke our fake hook.
   return 0;
}

void **IATfind(const char *function, HMODULE module) { //Find the IAT (Import Address Table) entry specific to the given function.
	int ip = 0;
	if (module == 0)
		module = GetModuleHandle(0);
	PIMAGE_DOS_HEADER pImgDosHeaders = (PIMAGE_DOS_HEADER)module;
	PIMAGE_NT_HEADERS pImgNTHeaders = (PIMAGE_NT_HEADERS)((LPBYTE)pImgDosHeaders + pImgDosHeaders->e_lfanew);
	PIMAGE_IMPORT_DESCRIPTOR pImgImportDesc = (PIMAGE_IMPORT_DESCRIPTOR)((LPBYTE)pImgDosHeaders + pImgNTHeaders->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress);

	if (pImgDosHeaders->e_magic != IMAGE_DOS_SIGNATURE)
		printf("libPE Error : e_magic is no valid DOS signature\n");

	for (IMAGE_IMPORT_DESCRIPTOR *iid = pImgImportDesc; iid->Name != NULL; iid++) {
		for (int funcIdx = 0; *(funcIdx + (LPVOID*)(iid->FirstThunk + (SIZE_T)module)) != NULL; funcIdx++) {
			char *modFuncName = (char*)(*(funcIdx + (SIZE_T*)(iid->OriginalFirstThunk + (SIZE_T)module)) + (SIZE_T)module + 2);
			const uintptr_t nModFuncName = (uintptr_t)modFuncName;
			bool isString = !(nModFuncName & (sizeof(nModFuncName) == 4 ? 0x80000000 : 0x8000000000000000));
			if (isString) {
				if (!_stricmp(function, modFuncName))
					return funcIdx + (LPVOID*)(iid->FirstThunk + (SIZE_T)module);
			}
		}
	}
	return 0;
}

void DetourIATptr(const char *function, void *newfunction, HMODULE module) {
	void **funcptr = IATfind(function, module);
	if (*funcptr == newfunction)
		 return;

	DWORD oldrights, newrights = PAGE_READWRITE;
	//Update the protection to READWRITE
	VirtualProtect(funcptr, sizeof(LPVOID), newrights, &oldrights);

	RealMessageBoxA = (pMessageBoxA)*funcptr; //Some compilers require the cast (like "MinGW"), not sure about MSVC though
	*funcptr = newfunction;

	//Restore the old memory protection flags.
	VirtualProtect(funcptr, sizeof(LPVOID), oldrights, &newrights);
}
```









