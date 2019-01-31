unit PushKit.iOS;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Math, System.JSON, System.Generics.Collections,
  Macapi.ObjectiveC,
  Macapi.Helpers,
  IOSapi.AVFoundation,
  IOSapi.Foundation,
  iOSapi.PushKit,
  FMX.Platform;

type
  TiOSPushKit = Class;

  TPushRegistryDelegate
    = Class(TOCLocal, PKPushRegistryDelegate)
      Private
        [weak]FPushKit: TiOSPushKit;
      Public
        constructor Create(APushKit: TiOSPushKit);
      Public
        procedure pushRegistry(registry: PKPushRegistry; didUpdatePushCredentials: PKPushCredentials; forType: PKPushType); overload; cdecl;
        procedure pushRegistry(registry: PKPushRegistry; didReceiveIncomingPushWithPayload: PKPushPayload; forType: PKPushType); overload; cdecl;
        procedure pushRegistry(registry: PKPushRegistry; didInvalidatePushTokenForType: PKPushType); overload; cdecl;
      End;

  TOnReceiveToken = procedure (Sender: TObject; const AToken: string) of object;
  TOnReceiveIncomingPushWithPayload = procedure (const Payload: string) of object;
  TiOSPushKit
   = Class
     Private
       FToken: string;
       FPushType: string;
       FPushRegistryDelegate: TPushRegistryDelegate;
       FPushRegistry: PKPushRegistry;
       FOnReceiveIncomingPushWithPayload: TOnReceiveIncomingPushWithPayload;
       FOnReceiveToken: TOnReceiveToken;
       procedure ReceiveIncomingPushWithPayload(const Payload: string);
     Public
       Constructor Create;
       Destructor Destroy; override;
       Property PushType: string read FPushType;
       Property Token: string read FToken;
       Procedure RegisterPushToken;
       Property OnReceiveToken: TOnReceiveToken read FOnReceiveToken write FOnReceiveToken;
       Property OnReceiveIncomingPushWithPayload: TOnReceiveIncomingPushWithPayload read FOnReceiveIncomingPushWithPayload write FOnReceiveIncomingPushWithPayload;
     End;

implementation

  function NSDictionaryToJSON(const ADictionary: NSDictionary): string;
   var
     LData: NSData;
     LString: NSString;
     LError: NSError;
   begin
     Result := '';
     if ADictionary = nil then exit;
     LData := TNSJSONSerialization.OCClass.dataWithJSONObject((ADictionary as ILocalObject).GetObjectID, 0, Addr(LError));
     if (LData <> nil) and (LError = nil) then
     begin
       LString := TNSString.Wrap(TNSString.Alloc.initWithData(LData, NSUTF8StringEncoding));
       Result :=  NSStrToStr(LString);
     end
     else
       Result := string.Empty;
   end;

{ TPushRegistryDelegate }

  constructor TPushRegistryDelegate.Create(APushKit: TiOSPushKit);
   begin
     inherited Create;
     FPushKit := APushKit;
   end;

  procedure TPushRegistryDelegate.pushRegistry(registry: PKPushRegistry; didUpdatePushCredentials: PKPushCredentials; forType: PKPushType);
   var
     Token, PushType: string;
   begin
     Token := UTF8ToString(didUpdatePushCredentials.token.description.UTF8String);
     Token := Token.Replace('<', '');
     Token := Token.Replace('>', '');
     Token := Token.Replace(' ', '');
     PushType := UTF8ToString(forType.UTF8String);
     if not Assigned(FPushKit) then exit;
     FPushKit.FToken := Token;
     FPushKit.FPushType := PushType;
     if Assigned(FPushKit.OnReceiveToken)
       then FPushKit.OnReceiveToken(FPushKit, Token);
   end;

  procedure TPushRegistryDelegate.pushRegistry(registry: PKPushRegistry; didReceiveIncomingPushWithPayload: PKPushPayload; forType: PKPushType);
   var
     Payload: string;
   begin
     Payload := NSDictionaryToJSON(didReceiveIncomingPushWithPayload.dictionaryPayload);
     if not Assigned(FPushKit) then exit;
     FPushKit.ReceiveIncomingPushWithPayload(Payload);
   end;

  procedure TPushRegistryDelegate.pushRegistry(registry: PKPushRegistry; didInvalidatePushTokenForType: PKPushType);
   begin

   end;

{ TiOSPushKit }

  constructor TiOSPushKit.Create;
   begin
     inherited Create;
     FToken := '';
     FPushType := '';
     FPushRegistryDelegate := TPushRegistryDelegate.Create(self);
     FPushRegistry := nil;
   end;

  procedure TiOSPushKit.RegisterPushToken;
   var
     PushTypesSet: NSSet;
   begin
     FPushRegistry := TPKPushRegistry.Wrap(TPKPushRegistry.Alloc.initWithQueue(nil));
     FPushRegistry.setDelegate(FPushRegistryDelegate.GetObjectID);
     PushTypesSet := TNSSet.Wrap(TNSSet.OCClass.setWithObject((PKPushTypeVoIP as ILocalObject).GetObjectID));
     FPushRegistry.setDesiredPushTypes(PushTypesSet);
   end;

  procedure TiOSPushKit.ReceiveIncomingPushWithPayload(const Payload: string);
   begin
     if Assigned(FOnReceiveIncomingPushWithPayload)
       then FOnReceiveIncomingPushWithPayload(Payload);
   end;

  destructor TiOSPushKit.Destroy;
   begin
     FPushRegistryDelegate := nil;
     if Assigned(FPushRegistry) then FPushRegistry.release; FPushRegistry := nil;
     inherited;
   end;

end.
