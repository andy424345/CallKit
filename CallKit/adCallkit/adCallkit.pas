unit adCallkit;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Math, System.JSON, System.Generics.Collections;

type
  TIncomingCall = Class;
  TOutGoingCall = Class;
  TCallBase     = Class;
  TCallList = Class;
  TOnNewIncomingCall = procedure (Sender: TObject; const IncomingCall: TIncomingCall; var CanReport: Boolean) of object;
  TOnAnswerCall = procedure (Sender: TObject; const IncomingCall: TIncomingCall) of object;
  TOnEndCall = procedure (Sender: TObject; const CallBase: TCallBase) of object;
  TOnIncomingCall = procedure (const JID, Alias, Sound: string; const HasVideo: Boolean) of object;
  TOnGetActive = procedure (var Active: Boolean) of object;

  TCallKit
   = Class
     Private
       FIncomingCallList: TCallList;
       FOutGoingCallList: TCallList;
     Private
       FOnNewIncomingCall: TOnNewIncomingCall;
       FOnIncomingCall: TOnIncomingCall;
       FOnAnswerCall: TOnAnswerCall;
       FOnEndCall: TOnEndCall;
       FOnGetActive: TOnGetActive;
       FResourceImage: string;
     Public
       Constructor Create;
       Destructor Destroy; override;
       Procedure Initial; virtual;
       procedure ReceiveIncomingPushWithPayload(const Payload: string); virtual;
       procedure StartACall(const JID, Alias, UniqueID: string; const HasVideo: Boolean); virtual;
       procedure EndACall(const UniqueID: string); virtual;
       procedure CancelACall(const UniqueID: string); virtual;
       procedure ConnectACall(const UniqueID: string); virtual;
       procedure ReportNewIncomingCall(const JID, Sound, Alias, LGUID: string; const HasVideo: Boolean); virtual;
       Property ResourceImage: string read FResourceImage write FResourceImage;
       Property OnNewIncomingCall: TOnNewIncomingCall read FOnNewIncomingCall write FOnNewIncomingCall;
       Property OnIncomingCall: TOnIncomingCall read FOnIncomingCall write FOnIncomingCall;
       Property OnAnswerCall: TOnAnswerCall read FOnAnswerCall write FOnAnswerCall;
       Property OnEndCall: TOnEndCall read FOnEndCall write FOnEndCall;
       Property IncomingCallList: TCallList read FIncomingCallList;
       Property OutGoingCallList: TCallList read FOutGoingCallList;
       Property OnGetActive: TOnGetActive read FOnGetActive write FOnGetActive;
     End;

  TCallBase
   = Class
     Private
       FUniqueID: string;
       FGUID: string;
       FJID: string;
       FAlias: string;
       FHasVideo: Boolean;
       FReportNotification: Boolean;
     Public
       Constructor Create;
       Destructor Destroy; override;
       Property JID: string read FJID write FJID;
       Property GUID: string read FGUID write FGUID;
       Property UniqueID: string read FUniqueID write FUniqueID;
       Property Alias: string read FAlias write FAlias;
       Property HasVideo: Boolean read FHasVideo write FHasVideo;
       Property ReportNotification: Boolean read FReportNotification write FReportNotification;
     End;

  TIncomingCall
   = Class(TCallBase)
     Private
       FSound: string;
       FReverseCall: Boolean;
       FReceiveDateTime: TDateTime;
     Public
       Constructor Create;
       Destructor Destroy; override;
       Property Sound: string read FSound write FSound;
       Property ReverseCall: Boolean read FReverseCall write FReverseCall;
       Property ReceiveDateTime: TDateTime read FReceiveDateTime write FReceiveDateTime;
     End;

  TOutGoingCall
   = Class(TCallBase)
     Private
       FConnecting: Boolean;
     Public
       Constructor Create;
       Property Connecting: Boolean read FConnecting write FConnecting;
     End;

  TCallList
   = Class(TObjectList<TCallBase>)
     Public
       Function GetByGUID(const GUID: string): TCallBase;
       Function GetByUniqueID(const UniqueID: string): TCallBase;
       Function DeleteItem(const Item: TCallBase): Boolean;
     End;

var
  ACallKit: TCallKit;

implementation
{$IFDEF IOS}
uses
  CallKit.iOS;
{$ENDIF}

{ TCallKit }

  constructor TCallKit.Create;
   begin
     inherited Create;
     FResourceImage := '';
     FIncomingCallList := TCallList.Create;
     FIncomingCallList.OwnsObjects := True;
     FOutGoingCallList := TCallList.Create;
     FOutGoingCallList.OwnsObjects := True;
   end;

  procedure TCallKit.CancelACall(const UniqueID: string);
   begin

   end;

  procedure TCallKit.ConnectACall(const UniqueID: string);
   begin

   end;

  procedure TCallKit.EndACall(const UniqueID: string);
   begin

   end;

  procedure TCallKit.Initial;
   begin

   end;

  procedure TCallKit.ReceiveIncomingPushWithPayload(const Payload: string);
   begin

   end;

  procedure TCallKit.ReportNewIncomingCall(const JID, Sound, Alias, LGUID: string; const HasVideo: Boolean);
   begin

   end;

  procedure TCallKit.StartACall(const JID, Alias, UniqueID: string; const HasVideo: Boolean);
   begin

   end;

  destructor TCallKit.Destroy;
   begin
     FIncomingCallList.DisposeOf; FIncomingCallList := nil;
     FOutGoingCallList.DisposeOf; FOutGoingCallList := nil;
     inherited;
   end;

{ TCallBase }

  constructor TCallBase.Create;
   begin
     inherited Create;
     FUniqueID := '';
     FGUID := '';
     FJID := '';
     FAlias := '';
     FHasVideo := False;
     FReportNotification := False;
   end;

  destructor TCallBase.Destroy;
   begin

     inherited;
   end;

{ TIncomingCall }

  constructor TIncomingCall.Create;
   begin
     inherited Create;
     FSound := '';
     FReverseCall := False;
     FReceiveDateTime := now;
   end;

  destructor TIncomingCall.Destroy;
   begin

     inherited;
   end;

{ TOutGoingCall }

  constructor TOutGoingCall.Create;
   begin
     inherited Create;
     FConnecting := True;
   end;

{ TCallList }

  function TCallList.GetByGUID(const GUID: string): TCallBase;
   var i: integer;
   begin
     Result := nil;
     for i := 0 to Count -1 do
       if Items[i].GUID = GUID then Exit(Items[i]);
   end;

  function TCallList.GetByUniqueID(const UniqueID: string): TCallBase;
   var i: integer;
   begin
     Result := nil;
     for i := 0 to Count -1 do
       if Items[i].UniqueID = UniqueID then Exit(Items[i]);
   end;

  Function TCallList.DeleteItem(const Item: TCallBase): Boolean;
   var i: integer;
   begin
     Result := False;
     if Item = nil then exit;
     i := Indexof(Item);
     if i <> -1 then begin Delete(i); Result := True; end;
   end;

initialization
{$IFDEF IOS}
  ACallKit := TiOSCallKit.Create;
{$ELSE}
  ACallKit := TCallKit.Create;
{$ENDIF}

finalization
  ACallKit.DisposeOf; ACallKit := nil;

end.
