unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, System.Notification, FMX.Layouts, FMX.ScrollBox,
  FMX.Platform, System.StrUtils, System.JSON, System.DateUtils,
  adCallKit, adPushKit,
  FMX.Memo;

type
  TfrmMain = class(TForm)
    ed_DeviceToken: TEdit;
    lb_DeviceToken: TLabel;
    NotificationCenter: TNotificationCenter;
    Button1: TButton;
    Switch1: TSwitch;
    Label1: TLabel;
    ed_CallName: TEdit;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    FUniqueID: string;
    procedure DoGetActive(var Active: Boolean);
    procedure DoNewIncomingCall(Sender: TObject; const IncomingCall: TIncomingCall; var CanReport: Boolean);
    procedure DoIncomingCall(const JID, Alias, Sound: string; const HasVideo: Boolean);
    procedure DoAnswerCall(Sender: TObject; const IncomingCall: TIncomingCall);
    procedure DoEndCall(Sender: TObject; const CallBase: TCallBase);
  private
    procedure DoReceiveIncomingPushWithPayload(const Payload: string);
    procedure DoReceiveDeviceToken(Sender: TObject; const ADeviceToken: string);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

  procedure TfrmMain.FormCreate(Sender: TObject);
   begin
     ACallKit.OnNewIncomingCall := DoNewIncomingCall;
     ACallKit.OnIncomingCall    := DoIncomingCall;
     ACallKit.OnAnswerCall      := DoAnswerCall;
     ACallKit.OnEndCall         := DoEndCall;
     ACallKit.OnGetActive       := DoGetActive;
     ACallKit.ResourceImage     := 'QQ';
     APushKit.OnReceiveIncomingPushWithPayload := DoReceiveIncomingPushWithPayload;
     APushKit.OnReceiveDeviceToken := DoReceiveDeviceToken;

     ACallKit.Initial;
     APushKit.RegisterPushToken;
   end;

  procedure TfrmMain.DoReceiveDeviceToken(Sender: TObject; const ADeviceToken: string);
   begin
     ed_DeviceToken.Text := ADeviceToken;
   end;

  procedure TfrmMain.DoReceiveIncomingPushWithPayload(const Payload: string);
   begin
     ACallKit.ReceiveIncomingPushWithPayload(Payload);
   end;

  procedure TfrmMain.Button1Click(Sender: TObject);
   var
     APayLoad, Alert, APS, U17: TJSONObject;
   begin
     APayLoad := TJSONObject.Create;
     try
       Alert := TJSONObject.Create;
       Alert.AddPair('body', 'Calling');
       Alert.AddPair('title', 'Andy');
       APS := TJSONObject.Create;
       APS.AddPair('alert', Alert);
       APS.AddPair('badge', TJSONNumber.Create(87));
       APS.AddPair('sound', 'default');
       APayLoad.AddPair('aps', APS);
       U17 := TJSONObject.Create;
       U17.AddPair('uid', 'test123');
       U17.AddPair('jid', 'u76');
       if ed_CallName.Text = ''
         then U17.AddPair('alias', 'Unknown')
         else U17.AddPair('alias', ed_CallName.Text);
       U17.AddPair('cm', '1');
       U17.AddPair('rc', False.ToInteger.ToString);
       APayLoad.AddPair('u17', U17);
       ACallKit.ReceiveIncomingPushWithPayload(APayLoad.ToJSON);
     finally
       APayLoad.DisposeOf; APayLoad := nil;
     end;
   end;

  procedure TfrmMain.Button2Click(Sender: TObject);
   begin
     ACallKit.EndACall(FUniqueID);
   end;

  procedure TfrmMain.DoAnswerCall(Sender: TObject; const IncomingCall: TIncomingCall);
   begin
     FUniqueID := IncomingCall.UniqueID;
   end;

  procedure TfrmMain.DoEndCall(Sender: TObject; const CallBase: TCallBase);
   begin
     Showmessage('End call: ' + CallBase.Alias);
   end;

  procedure TfrmMain.DoGetActive(var Active: Boolean);
   begin
     Active := Switch1.IsChecked;
   end;

  procedure TfrmMain.DoIncomingCall(const JID, Alias, Sound: string; const HasVideo: Boolean);
   var
     Description: string;
     Notification: TNotification;
   begin
     Description := IfThen(HasVideo, '來自%s的視訊來電', '來自%s的語音來電');
     Notification := NotificationCenter.CreateNotification;
     try
       Notification.Name      := Alias;
       Notification.AlertBody := Format(Description, [Alias]);
       Notification.SoundName := Sound;
       Notification.FireDate  := Now + EncodeTime(0, 0, 5, 0);
       NotificationCenter.ScheduleNotification(Notification);
     finally
       Notification.DisposeOf; Notification := nil;
     end;
   end;

  procedure TfrmMain.DoNewIncomingCall(Sender: TObject; const IncomingCall: TIncomingCall; var CanReport: Boolean);
   begin
     CanReport := True;
   end;

end.
