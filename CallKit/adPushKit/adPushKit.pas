unit adPushKit;

interface

uses
  System.SysUtils, System.Classes, System.Types;

type
  TOnReceiveDeviceToken = procedure (Sender: TObject; const ADeviceToken: string) of object;
  TOnReceiveIncomingPushWithPayload = procedure (const Payload: string) of object;

  TPushKit
   = Class
     Private
       FToken: string;
       FPushType: string;
       FOnReceiveIncomingPushWithPayload: TOnReceiveIncomingPushWithPayload;
       FOnReceiveDeviceToken: TOnReceiveDeviceToken;
     Public
       Constructor Create;
       Destructor Destroy; override;
       Property PushType: string read FPushType write FPushType;
       Property Token: string read FToken write FToken;
       Procedure RegisterPushToken; virtual;
       Property OnReceiveDeviceToken: TOnReceiveDeviceToken read FOnReceiveDeviceToken write FOnReceiveDeviceToken;
       Property OnReceiveIncomingPushWithPayload: TOnReceiveIncomingPushWithPayload read FOnReceiveIncomingPushWithPayload write FOnReceiveIncomingPushWithPayload;
     End;

var
  APushKit: TPushKit;

implementation

{$IFDEF IOS}
uses
  PushKit.iOS;
{$ENDIF}

{ TPushKit }

  constructor TPushKit.Create;
   begin
     inherited;
     FToken := '';
     FPushType := '';
   end;

  procedure TPushKit.RegisterPushToken;
   begin

   end;

  destructor TPushKit.Destroy;
   begin

     inherited;
   end;

initialization
{$IFDEF IOS}
  APushKit := TiOSPushKit.Create;
{$ELSE}
  APushKit := TPushKit.Create;
{$ENDIF}

finalization
  APushKit.DisposeOf; APushKit := nil;

end.
