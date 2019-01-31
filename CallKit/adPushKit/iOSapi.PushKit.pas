{ *********************************************************** }
{ }
{ CodeGear Delphi Runtime Library }
{ }
{ Copyright(c) 2012-2014 Embarcadero Technologies, Inc. }
{ }
{ *********************************************************** }

//
// Delphi-Objective-C Bridge
// Interfaces for Cocoa framework PushKit
//

unit iOSapi.PushKit;

interface

uses
  Macapi.CoreFoundation,
  Macapi.CoreServices,
  Macapi.Dispatch,
  Macapi.Mach,
  Macapi.ObjCRuntime,
  Macapi.ObjectiveC,
  iOSapi.CocoaTypes,
  iOSapi.Foundation;

type

  // ===== Forward declarations =====
{$M+}
  PKPushCredentials = interface;
  PKPushPayload = interface;
  PKPushRegistryDelegate = interface;
  PKPushRegistry = interface;

  // ===== Framework typedefs =====
{$M+}
  PKPushType = NSString;
  PPKPushType = ^PKPushType;
  dispatch_queue_t = Pointer;
  Pdispatch_queue_t = ^dispatch_queue_t;
  TPushKitWithCompletionHandler = procedure() of object;
  // ===== Interface declarations =====

  PKPushCredentialsClass = interface(NSObjectClass)
    ['{3CF98929-7334-4865-A88A-78438D46603A}']
  end;

  PKPushCredentials = interface(NSObject)
    ['{1AFB5721-ACB1-4D90-9257-DC4D849F7A2B}']
    function &type: PKPushType; cdecl;
    function token: NSData; cdecl;
  end;

  TPKPushCredentials = class(TOCGenericImport<PKPushCredentialsClass,
    PKPushCredentials>)
  end;

  PPKPushCredentials = Pointer;

  PKPushPayloadClass = interface(NSObjectClass)
    ['{C90ED1C0-6A39-46F5-82E8-2CC7C6C7E173}']
  end;

  PKPushPayload = interface(NSObject)
    ['{BB9F980B-05A5-45A6-A581-5981EB7AADE2}']
    function &type: PKPushType; cdecl;
    function dictionaryPayload: NSDictionary; cdecl;
  end;

  TPKPushPayload = class(TOCGenericImport<PKPushPayloadClass, PKPushPayload>)
  end;

  PPKPushPayload = Pointer;

  PKPushRegistryClass = interface(NSObjectClass)
    ['{09F1C1A1-777D-4858-B2DA-92201CFB675F}']
  end;

  PKPushRegistry = interface(NSObject)
    ['{39914121-DA59-4EF6-B320-8820AD9CD4E3}']
    procedure setDelegate(delegate: Pointer); cdecl;
    function delegate: Pointer; cdecl;
    procedure setDesiredPushTypes(desiredPushTypes: NSSet); cdecl;
    function desiredPushTypes: NSSet; cdecl;
    function pushTokenForType(&type: PKPushType): NSData; cdecl;
    function initWithQueue(queue: dispatch_queue_t)
      : Pointer { instancetype }; cdecl;
  end;

  TPKPushRegistry = class(TOCGenericImport<PKPushRegistryClass, PKPushRegistry>)
  end;

  PPKPushRegistry = Pointer;

  // ===== Protocol declarations =====

  PKPushRegistryDelegate = interface(IObjectiveC)
    ['{F271CC92-48E1-43EC-9534-8CCBB5F07F5A}']
    [MethodName('pushRegistry:didUpdatePushCredentials:forType:')]
    procedure pushRegistry(registry: PKPushRegistry; didUpdatePushCredentials: PKPushCredentials; forType: PKPushType); cdecl; overload;
    [MethodName('pushRegistry:didReceiveIncomingPushWithPayload:forType:')]
    procedure pushRegistry(registry: PKPushRegistry; didReceiveIncomingPushWithPayload: PKPushPayload; forType: PKPushType); cdecl; overload;
    [MethodName('pushRegistry:didInvalidatePushTokenForType:')]
    procedure pushRegistry(registry: PKPushRegistry; didInvalidatePushTokenForType: PKPushType); cdecl; overload;
  end;

  // ===== Exported string consts =====

function PKPushTypeVoIP: NSString;
function PKPushTypeComplication: Pointer;
function PKPushTypeFileProvider: Pointer;


// ===== External functions =====

const
  libPushKit = '/System/Library/Frameworks/PushKit.framework/PushKit';

implementation

uses
  Posix.Dlfcn;

var
  PushKitModule: THandle;

function PKPushTypeVoIP: NSString;
begin
  Result := CocoaNSStringConst(libPushKit, 'PKPushTypeVoIP');
end;

function PKPushTypeComplication: Pointer;
begin
  Result := CocoaPointerConst(libPushKit, 'PKPushTypeComplication');
end;

function PKPushTypeFileProvider: Pointer;
begin
  Result := CocoaPointerConst(libPushKit, 'PKPushTypeFileProvider');
end;

initialization
PushKitModule := dlopen(MarshaledAString(libPushKit), RTLD_LAZY);

finalization
dlclose(PushKitModule);

end.
