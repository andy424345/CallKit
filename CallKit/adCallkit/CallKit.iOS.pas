unit CallKit.iOS;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Math, System.JSON, System.Generics.Collections,
  Macapi.ObjCRuntime,
  Macapi.ObjectiveC,
  Macapi.CoreFoundation,
  Macapi.Helpers,
  iOSapi.CocoaTypes,
  IOSapi.MediaPlayer,
  IOSapi.CoreMedia,
  IOSapi.AVFoundation,
  IOSapi.Foundation,
  IOSapi.CoreGraphics,
  IOSapi.UIKit,
  iOSapi.CoreAudio,
  FMX.Platform.iOS,
  iOSapi.PushKit,
  iOSapi.CallKit,
  iOSapi.Helpers, FMX.Dialogs,
  FMX.Platform, adCallKit, PushKit.iOS;

type

  TCXProviderDelegate = Class;

  TiOSCallKit
   = Class(TCallKit)
     Private
       FCallController: CXCallController;
       FProvider: CXProvider;
       FCXProviderDelegate: TCXProviderDelegate;
       Function CallUpdate(const JID, Alias: string; const HasVideo: Boolean): CXCallUpdate;
       Function GetConfiguration: CXProviderConfiguration;
       procedure SetConfigurationSupportedHandleTypes(config: CXProviderConfiguration);
       function GetResourceImage(const Key: string): UIImage;
       procedure OnCompletion(Error: NSError);
       procedure OnStartACallCompletion(Error: NSError);
       procedure OnEndACallCompletion(Error: NSError);
     Private
       FGUIDList: TStringList;
       procedure InternalReportNewIncomingCall(const JID, Sound, Alias, LGUID: string; const HasVideo: Boolean);
     Public
       Constructor Create;
       Destructor Destroy; override;
       procedure Initial; override;
       procedure ReceiveIncomingPushWithPayload(const Payload: string); override;
       procedure StartACall(const JID, Alias, UniqueID: string; const HasVideo: Boolean); override;
       procedure EndACall(const UniqueID: string); override;
       procedure CancelACall(const UniqueID: string); override;
       procedure ConnectACall(const UniqueID: string); override;
       procedure ReportNewIncomingCall(const JID, Sound, Alias, LGUID: string; const HasVideo: Boolean); override;
     End;

  TCXProviderDelegate
   = Class(TOCLocal, CXProviderDelegate)
     Private
        [weak]FCallKit: TiOSCallKit;
      Public
        constructor Create(ACallKit: TiOSCallKit);
     Public
       //當接收到調用重置時 調用的函數，這個函數必須被實現，其不需做任何邏輯，只用來重置狀態
       procedure providerDidReset(provider: CXProvider); cdecl;
       //調用開始時回調
       procedure providerDidBegin(provider: CXProvider); cdecl;
       //有事務被提交時調用
       //如果返回YES 則表示事務被捕獲處理 後面的回調都不會調用 如果返回NO 則表示事務不被捕獲，會回調後面的函數
       function provider(provider: CXProvider; executeTransaction: CXTransaction): Boolean; overload; cdecl;
       //點擊開始按鈕的回調
       procedure provider(provider: CXProvider; performStartCallAction: CXStartCallAction); overload; cdecl;
       //點擊接聽按鈕的回調
       procedure provider(provider: CXProvider; performAnswerCallAction: CXAnswerCallAction); overload; cdecl;
       //點擊結束按鈕的回調
       procedure provider(provider: CXProvider; performEndCallAction: CXEndCallAction); overload; cdecl;
       //點擊保持通話按鈕的回調
       procedure provider(provider: CXProvider; performSetHeldCallAction: CXSetHeldCallAction); overload; cdecl;
       //點擊靜音按鈕的回調
       procedure provider(provider: CXProvider; performSetMutedCallAction: CXSetMutedCallAction); overload; cdecl;
       //點擊組按鈕的回調
       procedure provider(provider: CXProvider; performSetGroupCallAction: CXSetGroupCallAction); overload; cdecl;
       //DTMF功能回調
       procedure provider(provider: CXProvider; performPlayDTMFCallAction: CXPlayDTMFCallAction); overload; cdecl;
       //行為超時的回調
       procedure provider(provider: CXProvider; timedOutPerformingAction: CXAction); overload; cdecl;
       //音頻會話激活狀態的回調
       procedure providerdidActivateAudioSession(provider: CXProvider; didActivateAudioSession: AVAudioSession); overload; cdecl;
       //音頻會話停用的回調
       procedure providerdidDeactivateAudioSession(provider: CXProvider; didDeactivateAudioSession: AVAudioSession); overload; cdecl;
     End;

implementation

{ TiOSCallKit }

  constructor TiOSCallKit.Create;
   begin
     inherited Create;
     FGUIDList := TStringList.Create;
     FCXProviderDelegate := TCXProviderDelegate.Create(self);
     FProvider := TCXProvider.Wrap(TCXProvider.Alloc.initWithConfiguration(GetConfiguration));
     FProvider.setDelegate(FCXProviderDelegate.GetObjectID, nil);
     FProvider.retain;
     FCallController := TCXCallController.Wrap(TCXCallController.Alloc.init);
     FCallController.retain;
   end;

  function TiOSCallKit.GetResourceImage(const Key: string): UIImage;
   var
     RS: TResourceStream;
     Data: NSData;
   begin
     try
       try
         Result := nil;
         RS := TResourceStream.Create(hInstance, Key , RT_RCDATA);
         RS.Position := 0;
         Data := TNSData.Wrap(TNSData.alloc.initWithBytesNoCopy(RS.Memory, RS.Size, False));
         try
           if Data.length > 0
             then Result := TUIImage.Wrap(TUIImage.alloc.initWithData(Data));
         finally
           Data.release;
         end;
       except
         if Assigned(Result)
           then Result.release;
         Result := nil;
       end;
     finally
       RS.DisposeOf; RS := nil;
     end;
   end;

  function TiOSCallKit.CallUpdate(const JID, Alias: string; const HasVideo: Boolean): CXCallUpdate;
   var
     handle: CXHandle;
   begin
     handle := TCXHandle.Wrap(TCXHandle.Alloc.initWithType(CXHandleTypeGeneric, StrToNSStr(JID)));
     Result := TCXCallUpdate.Wrap(TCXCallUpdate.Alloc.init);
     Result.setSupportsGrouping(False);
     Result.setSupportsDTMF(False);
     Result.setSupportsHolding(False);
     Result.setRemoteHandle(handle);
     Result.setHasVideo(HasVideo);
     Result.setLocalizedCallerName(StrToNSStr(Alias));
   end;

  procedure TiOSCallKit.Initial;
   begin
     GetConfiguration;
   end;

  procedure TiOSCallKit.InternalReportNewIncomingCall(const JID, Sound, Alias, LGUID: string; const HasVideo: Boolean);
   var
     update: CXCallUpdate;
     DisplayName: NSString;
     config: CXProviderConfiguration;
     Image: UIImage;
     UUID: NSUUID;
     IsActive: Boolean;
   begin
     IsActive := False;
     if Assigned(OnGetActive) then OnGetActive(IsActive);
     if not IsActive then
       begin
         if Assigned(OnIncomingCall)
           then OnIncomingCall(JID, Alias, Sound, HasVideo);
         IncomingCallList.Clear;
         exit;
       end;

     DisplayName := TNSString.Wrap(iOSapi.Helpers.TiOSHelper.MainBundle.objectForInfoDictionaryKey(NSStr('CFBundleDisplayName')));
     config := GetConfiguration;
     config.setRingtoneSound(NSStr(Sound));

     Image := GetResourceImage(ResourceImage);
     if Assigned(Image) then
       begin
         config.setIconTemplateImageData(TNSData.Wrap(UIImagePNGRepresentation((Image as ILocalObject).GetObjectID)));
         Image.release;
         Image := nil;
       end;

     update := CallUpdate(JID, Alias, HasVideo);

     UUID := TNSUUID.Alloc.initWithUUIDString(NSStr(LGUID));

     FProvider.setConfiguration(config);
     FProvider.reportNewIncomingCallWithUUID(UUID, update, OnCompletion);
   end;

  procedure TiOSCallKit.OnCompletion(Error: NSError);
   begin

   end;

  procedure TiOSCallKit.StartACall(const JID, Alias, UniqueID: string; const HasVideo: Boolean);
   var
     action: CXStartCallAction;
     handle: CXHandle;
     transaction: CXTransaction;
     UUID: NSUUID;
     Item: TOutGoingCall;
   begin
     handle := TCXHandle.Wrap(TCXHandle.Alloc.initWithType(CXHandleTypeGeneric, StrToNSStr(Alias)));
     UUID := TNSUUID.Alloc.init;
     Item := TOutGoingCall.Create;
     Item.JID := JID;
     Item.Alias := Alias;
     Item.UniqueID := UniqueID;
     Item.HasVideo := HasVideo;
     Item.GUID := NSStrToStr(UUID.UUIDString);
     OutGoingCallList.Add(Item);
     action := TCXStartCallAction.Wrap(TCXStartCallAction.Alloc.initWithCallUUID(UUID, handle));
     action.setVideo(HasVideo);
     transaction := TCXTransaction.Wrap(TCXTransaction.Alloc.initWithAction(action));
     FCallController.requestTransaction(transaction, OnStartACallCompletion);
   end;

  procedure TiOSCallKit.OnStartACallCompletion(Error: NSError);
   var S: string;
   begin
     if Error = nil
       then S := 'Transaction request sent successfully.'
       else S := NSStrToStr(Error.localizedDescription);
   end;

  procedure TiOSCallKit.CancelACall(const UniqueID: string);
   var Item: TOutgoingCall;
   begin
     Item := TOutgoingCall(OutGoingCallList.GetByUniqueID(UniqueID));
     if Item = nil then exit;
   end;

  procedure TiOSCallKit.ConnectACall(const UniqueID: string);
   var
     Item: TOutgoingCall;
     UUID: NSUUID;
   begin
     Item := TOutgoingCall(OutGoingCallList.GetByUniqueID(UniqueID));
     if Item = nil then exit;
     Item.Connecting := False;
     UUID := TNSUUID.Alloc.initWithUUIDString(StrToNSStr(Item.GUID));
     FProvider.reportOutgoingCallWithUUIDConnectedAtDate(UUID, nil);
   end;

  procedure TiOSCallKit.EndACall(const UniqueID: string);
   var
     endaction: CXEndCallAction;
     transaction: CXTransaction;
     UUID: NSUUID;
     Item: TCallBase;
     GUID: string;
     config: CXProviderConfiguration;
     provider: CXProvider;
     DisplayName: NSString;
     Date: NSDate;
   begin
     Item := IncomingCallList.GetByUniqueID(UniqueID);
     if Item = nil then Item := OutGoingCallList.GetByUniqueID(UniqueID);
     if Item = nil then exit;
     GUID := Item.GUID;
     if not IncomingCallList.DeleteItem(Item)
       then OutGoingCallList.DeleteItem(Item);
     UUID := TNSUUID.Alloc.initWithUUIDString(StrToNSStr(GUID));
     endaction := TCXEndCallAction.Wrap(TCXEndCallAction.Alloc.initWithCallUUID(UUID));
     transaction := TCXTransaction.Wrap(TCXTransaction.Alloc.initWithAction(endaction));
     FCallController.requestTransaction(transaction, OnEndACallCompletion);
   end;

  procedure TiOSCallKit.OnEndACallCompletion(Error: NSError);
   var S: string;
   begin
     if Error = nil
       then S := 'Transaction request sent successfully.'
       else S := NSStrToStr(Error.localizedDescription);
   end;

  procedure TiOSCallKit.ReceiveIncomingPushWithPayload(const Payload: string);
   var
     JO: TJSONObject;
     APS, U17: TJSONObject;
     Sound, jid, Alias, UniqueID, CallMode, ReverseCall: string;
     IncomingCall: TIncomingCall;
     temp: TCallBase;
     CanReport: Boolean;
     GUID: TGUID;
     LGUID: string;
     i: integer;
   begin
     if not Assigned(OnNewIncomingCall) then exit;
     CanReport := False;
     JO := TJSONObject(TJSONObject.ParseJSONValue(Payload));
     if JO = nil then exit;
     try
       APS := TJSONObject(JO.GetValue('aps'));
       if APS = nil then exit;
       U17 := TJSONObject(JO.GetValue('u17'));
       if U17 = nil then exit;
       Sound       := APS.Values['sound'].Value;
       UniqueID    := U17.Values['uid'].Value;
       Alias       := U17.Values['alias'].Value;
       jid         := U17.Values['jid'].Value;
       CallMode    := U17.Values['cm'].Value;
       ReverseCall := U17.Values['rc'].Value;

       temp := IncomingCallList.GetByUniqueID(UniqueID);
       if Assigned(temp) then exit;

       System.SysUtils.CreateGUID(GUID);
       LGUID := GUID.ToString;
       LGUID := LGUID.Substring(1, LGUID.Length - 2);

       IncomingCall := TIncomingCall.Create;
       IncomingCall.JID := jid;
       IncomingCall.GUID := LGUID;
       IncomingCall.UniqueID := UniqueID;
       IncomingCall.Sound := Sound;
       IncomingCall.Alias := Alias;
       IncomingCall.HasVideo := (CallMode = '1');
       IncomingCall.ReverseCall := ReverseCall.ToInteger.ToBoolean;
       IncomingCall.ReceiveDateTime := now;
       IncomingCallList.Add(IncomingCall);

       OnNewIncomingCall(Self, IncomingCall, CanReport);

       if CanReport
         then InternalReportNewIncomingCall(JID, Sound, Alias, LGUID, IncomingCall.HasVideo);
     finally
       JO.DisposeOf; JO := nil;
     end;
   end;

  Function TiOSCallKit.GetConfiguration: CXProviderConfiguration;
   var
     DisplayName: NSString;
   begin
     DisplayName := TNSString.Wrap(iOSapi.Helpers.TiOSHelper.MainBundle.objectForInfoDictionaryKey(NSStr('CFBundleDisplayName')));
     Result := TCXProviderConfiguration.Wrap(TCXProviderConfiguration.Alloc.initWithLocalizedName(DisplayName));
     Result.setSupportsVideo(True);
     Result.setMaximumCallGroups(1);
     Result.setMaximumCallsPerCallGroup(1);
     SetConfigurationSupportedHandleTypes(Result);
   end;

  procedure TiOSCallKit.SetConfigurationSupportedHandleTypes(config: CXProviderConfiguration);
   var
     HandleTypesArray: NSMutableArray;
     HandleTypesSet: NSSet;
   begin
   //
     exit;
     if not Assigned(config) then exit;
     HandleTypesArray := TNSMutableArray.Create;
     HandleTypesArray.addObject((TNSNumber.Wrap(TNSNumber.Alloc.initWithInteger(CXHandleTypeGeneric)) as ILocalObject).GetObjectID);
     HandleTypesArray.addObject((TNSNumber.Wrap(TNSNumber.Alloc.initWithInteger(CXHandleTypePhoneNumber)) as ILocalObject).GetObjectID);
     HandleTypesArray.addObject((TNSNumber.Wrap(TNSNumber.Alloc.initWithInteger(CXHandleTypeEmailAddress)) as ILocalObject).GetObjectID);
     HandleTypesSet := TNSSet.Wrap(TNSSet.OCClass.setWithArray(HandleTypesArray));
     HandleTypesArray.release;
     config.setSupportedHandleTypes(HandleTypesSet);
   end;

  procedure TiOSCallKit.ReportNewIncomingCall(const JID, Sound, Alias, LGUID: string; const HasVideo: Boolean);
   begin
     InternalReportNewIncomingCall(JID, Sound, Alias, LGUID, HasVideo);
   end;

  destructor TiOSCallKit.Destroy;
   begin
     FGUIDList.DisposeOf; FGUIDList := nil;
     FProvider.setDelegate(nil, nil);
     FProvider.release;
     FProvider := nil;
     FCXProviderDelegate := nil;
     FCallController.release;
     FCallController := nil;
     inherited;
   end;

{ TCXProviderDelegate }

  constructor TCXProviderDelegate.Create(ACallKit: TiOSCallKit);
   begin
     inherited Create;
     FCallKit := ACallKit;
   end;

  procedure TCXProviderDelegate.providerDidBegin(provider: CXProvider);
   begin

   end;

  procedure TCXProviderDelegate.providerDidReset(provider: CXProvider);
   var i: integer;
   begin
     try
       for i := 0 to FCallKit.IncomingCallList.Count -1 do
         FCallKit.EndACall(FCallKit.IncomingCallList[i].UniqueID);
       FCallKit.IncomingCallList.Clear;
       for i := 0 to FCallKit.OutGoingCallList.Count -1 do
         FCallKit.EndACall(FCallKit.OutGoingCallList[i].UniqueID);
       FCallKit.OutGoingCallList.Clear;
     except
     end;
   end;

  procedure TCXProviderDelegate.provider(provider: CXProvider; performEndCallAction: CXEndCallAction);
   var
     CallBase: TCallBase;
     GUID: string;
   begin
     try
       if FCallKit = nil then exit;
       GUID := NSStrToStr(performEndCallAction.callUUID.UUIDString);
       CallBase := FCallKit.IncomingCallList.GetByGUID(GUID);
       if CallBase = nil then CallBase := FCallKit.OutGoingCallList.GetByGUID(GUID);
       if CallBase = nil then exit;

       if Assigned(FCallKit.OnEndCall) and not performEndCallAction.isComplete
         then FCallKit.OnEndCall(FCallKit, CallBase);

       if not FCallKit.IncomingCallList.DeleteItem(CallBase)
         then FCallKit.OutGoingCallList.DeleteItem(CallBase);
     finally
       performEndCallAction.fulfill;
     end;
   end;

  procedure TCXProviderDelegate.provider(provider: CXProvider; performSetHeldCallAction: CXSetHeldCallAction);
   begin
     performSetHeldCallAction.fulfill;
   end;

  procedure TCXProviderDelegate.provider(provider: CXProvider; performAnswerCallAction: CXAnswerCallAction);
   var
     IncomingCall: TIncomingCall;
     GUID: string;
   begin
     performAnswerCallAction.fulfill;
     if FCallKit = nil then exit;
     GUID := NSStrToStr(performAnswerCallAction.callUUID.UUIDString);
     IncomingCall := TIncomingCall(FCallKit.IncomingCallList.GetByGUID(GUID));
     if IncomingCall = nil then exit;
     if Assigned(FCallKit.OnAnswerCall)
       then FCallKit.OnAnswerCall(FCallKit, IncomingCall);
   end;

  procedure TCXProviderDelegate.provider(provider: CXProvider; performStartCallAction: CXStartCallAction);
   var
     update: CXCallUpdate;
     GUID: string;
     Item: TOutGoingCall;
   begin
     GUID := NSStrToStr(performStartCallAction.callUUID.UUIDString);
     Item := TOutGoingCall(FCallKit.OutGoingCallList.GetByGUID(GUID));
     try
       if Item = nil then exit;
       update := FCallKit.CallUpdate(Item.JID, Item.Alias, Item.HasVideo);
       provider.reportCallWithUUIDUpdated(performStartCallAction.callUUID, update);
       if Item.Connecting
         then provider.reportOutgoingCallWithUUIDStartedConnectingAtDate(performStartCallAction.callUUID, nil)
         else provider.reportOutgoingCallWithUUIDConnectedAtDate(performStartCallAction.callUUID, nil);

       performStartCallAction.fulfill;
     except
       performStartCallAction.fail;
     end;
   end;

  function TCXProviderDelegate.provider(provider: CXProvider; executeTransaction: CXTransaction): Boolean;
   begin

   end;

  procedure TCXProviderDelegate.providerdidActivateAudioSession(provider: CXProvider; didActivateAudioSession: AVAudioSession);
   begin

   end;

  procedure TCXProviderDelegate.providerdidDeactivateAudioSession(provider: CXProvider; didDeactivateAudioSession: AVAudioSession);
   begin

   end;

  procedure TCXProviderDelegate.provider(provider: CXProvider; timedOutPerformingAction: CXAction);
   begin
     timedOutPerformingAction.fulfill;
   end;

  procedure TCXProviderDelegate.provider(provider: CXProvider; performPlayDTMFCallAction: CXPlayDTMFCallAction);
   begin
     performPlayDTMFCallAction.fulfill;
   end;

  procedure TCXProviderDelegate.provider(provider: CXProvider; performSetMutedCallAction: CXSetMutedCallAction);
   begin
     performSetMutedCallAction.fulfill;
   end;

  procedure TCXProviderDelegate.provider(provider: CXProvider; performSetGroupCallAction: CXSetGroupCallAction);
   begin
     performSetGroupCallAction.fulfill;
   end;

end.
