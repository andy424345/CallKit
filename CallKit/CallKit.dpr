program CallKit;



{$R *.dres}

uses
  System.StartUpCopy,
  FMX.Forms,
  uMain in 'uMain.pas' {frmMain},
  adCallkit in 'adCallKit\adCallkit.pas',
  adPushKit in 'adPushKit\adPushKit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
