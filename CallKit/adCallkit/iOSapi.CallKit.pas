{ *********************************************************** }
{ }
{ CodeGear Delphi Runtime Library }
{ }
{ Copyright(c) 2012-2014 Embarcadero Technologies, Inc. }
{ }
{ *********************************************************** }

//
// Delphi-Objective-C Bridge
// Interfaces for Cocoa framework CallKit
//

unit iOSapi.CallKit;

interface

uses
  Macapi.CoreFoundation,
  Macapi.CoreServices,
  Macapi.Dispatch,
  Macapi.Mach,
  Macapi.ObjCRuntime,
  Macapi.ObjectiveC,
  iOSapi.CocoaTypes,
  iOSapi.AVFoundation,
  iOSapi.Foundation;

const
  CXHandleTypeGeneric = 1;
  CXHandleTypePhoneNumber = 2;
  CXHandleTypeEmailAddress = 3;
  CXErrorCodeUnknownError = 0;
  CXErrorCodeIncomingCallErrorUnknown = 0;
  CXErrorCodeIncomingCallErrorUnentitled = 1;
  CXErrorCodeIncomingCallErrorCallUUIDAlreadyExists = 2;
  CXErrorCodeIncomingCallErrorFilteredByDoNotDisturb = 3;
  CXErrorCodeIncomingCallErrorFilteredByBlockList = 4;
  CXErrorCodeRequestTransactionErrorUnknown = 0;
  CXErrorCodeRequestTransactionErrorUnentitled = 1;
  CXErrorCodeRequestTransactionErrorUnknownCallProvider = 2;
  CXErrorCodeRequestTransactionErrorEmptyTransaction = 3;
  CXErrorCodeRequestTransactionErrorUnknownCallUUID = 4;
  CXErrorCodeRequestTransactionErrorCallUUIDAlreadyExists = 5;
  CXErrorCodeRequestTransactionErrorInvalidAction = 6;
  CXErrorCodeRequestTransactionErrorMaximumCallGroupsReached = 7;
  CXErrorCodeCallDirectoryManagerErrorUnknown = 0;
  CXErrorCodeCallDirectoryManagerErrorNoExtensionFound = 1;
  CXErrorCodeCallDirectoryManagerErrorLoadingInterrupted = 2;
  CXErrorCodeCallDirectoryManagerErrorEntriesOutOfOrder = 3;
  CXErrorCodeCallDirectoryManagerErrorDuplicateEntries = 4;
  CXErrorCodeCallDirectoryManagerErrorMaximumEntriesExceeded = 5;
  CXErrorCodeCallDirectoryManagerErrorExtensionDisabled = 6;
  CXErrorCodeCallDirectoryManagerErrorCurrentlyLoading = 7;
  CXErrorCodeCallDirectoryManagerErrorUnexpectedIncrementalRemoval = 8;
  CXPlayDTMFCallActionTypeSingleTone = 1;
  CXPlayDTMFCallActionTypeSoftPause = 2;
  CXPlayDTMFCallActionTypeHardPause = 3;
  CXCallEndedReasonFailed = 1;
  CXCallEndedReasonRemoteEnded = 2;
  CXCallEndedReasonUnanswered = 3;
  CXCallEndedReasonAnsweredElsewhere = 4;
  CXCallEndedReasonDeclinedElsewhere = 5;
  CXCallDirectoryEnabledStatusUnknown = 0;
  CXCallDirectoryEnabledStatusDisabled = 1;
  CXCallDirectoryEnabledStatusEnabled = 2;

type

  // ===== Forward declarations =====
{$M+}
  CXHandle = interface;
  CXCallUpdate = interface;
  CXAction = interface;
  CXCallAction = interface;
  CXStartCallAction = interface;
  CXAnswerCallAction = interface;
  CXEndCallAction = interface;
  CXSetHeldCallAction = interface;
  CXSetMutedCallAction = interface;
  CXSetGroupCallAction = interface;
  CXPlayDTMFCallAction = interface;
  CXTransaction = interface;
  CXProvider = interface;
  CXProviderConfiguration = interface;
  CXProviderDelegate = interface;
  CXCall = interface;
  CXCallObserver = interface;
  CXCallObserverDelegate = interface;
  CXCallController = interface;
  CXCallDirectoryManager = interface;
  CXCallDirectoryExtensionContext = interface;
  CXCallDirectoryProvider = interface;
  CXCallDirectoryExtensionContextDelegate = interface;

  // ===== Framework typedefs =====
{$M+}
  NSInteger = Integer;
  PNSInteger = ^NSInteger;

  CXHandleType = NSInteger;
  NSErrorDomain = NSString;
  PNSErrorDomain = ^NSErrorDomain;
  CXErrorCode = NSInteger;
  CXErrorCodeIncomingCallError = NSInteger;
  CXErrorCodeRequestTransactionError = NSInteger;
  CXErrorCodeCallDirectoryManagerError = NSInteger;
  CXPlayDTMFCallActionType = NSInteger;
  CXCallEndedReason = NSInteger;
  dispatch_queue_t = Pointer;
  Pdispatch_queue_t = ^dispatch_queue_t;
  TCallKitCompletion = procedure(param1: NSError) of object;
  NSUInteger = Cardinal;
  PNSUInteger = ^NSUInteger;

  CXCallDirectoryPhoneNumber = Int64;
  PCXCallDirectoryPhoneNumber = ^CXCallDirectoryPhoneNumber;
  CXCallDirectoryEnabledStatus = NSInteger;
  TCallKitCompletionHandler = procedure(param1: CXCallDirectoryEnabledStatus;
    param2: NSError) of object;
  TCallKitCompletion1 = procedure(param1: Boolean) of object;
  // ===== Interface declarations =====

  CXHandleClass = interface(NSObjectClass)
    ['{4DF29F2C-223A-46A3-B618-28BFC04CB120}']
  end;

  CXHandle = interface(NSObject)
    ['{17394CCD-EACD-4641-A8B3-A1726C36368D}']
    function &type: CXHandleType; cdecl;
    function value: NSString; cdecl;
    function initWithType(&type: CXHandleType; value: NSString)
      : Pointer { instancetype }; cdecl;
    function isEqualToHandle(handle: CXHandle): Boolean; cdecl;
  end;

  TCXHandle = class(TOCGenericImport<CXHandleClass, CXHandle>)
  end;

  PCXHandle = Pointer;

  CXCallUpdateClass = interface(NSObjectClass)
    ['{D71990FC-6E74-42CE-B42A-CA642785B479}']
  end;

  CXCallUpdate = interface(NSObject)
    ['{19ECE481-BA08-4186-AC45-E26A492FFC0C}']
    procedure setRemoteHandle(remoteHandle: CXHandle); cdecl;
    function remoteHandle: CXHandle; cdecl;
    procedure setLocalizedCallerName(localizedCallerName: NSString); cdecl;
    function localizedCallerName: NSString; cdecl;
    procedure setSupportsHolding(supportsHolding: Boolean); cdecl;
    function supportsHolding: Boolean; cdecl;
    procedure setSupportsGrouping(supportsGrouping: Boolean); cdecl;
    function supportsGrouping: Boolean; cdecl;
    procedure setSupportsUngrouping(supportsUngrouping: Boolean); cdecl;
    function supportsUngrouping: Boolean; cdecl;
    procedure setSupportsDTMF(supportsDTMF: Boolean); cdecl;
    function supportsDTMF: Boolean; cdecl;
    procedure setHasVideo(hasVideo: Boolean); cdecl;
    function hasVideo: Boolean; cdecl;
  end;

  TCXCallUpdate = class(TOCGenericImport<CXCallUpdateClass, CXCallUpdate>)
  end;

  PCXCallUpdate = Pointer;

  CXActionClass = interface(NSObjectClass)
    ['{07EA2A1A-4541-42AA-BE17-BC4D15A0268D}']
  end;

  CXAction = interface(NSObject)
    ['{AA7068F2-1FBB-48D4-A23E-DCCB163A08FB}']
    function UUID: NSUUID; cdecl;
    function isComplete: Boolean; cdecl;
    function timeoutDate: NSDate; cdecl;
    function init: Pointer { instancetype }; cdecl;
    function initWithCoder(aDecoder: NSCoder): Pointer { instancetype }; cdecl;
    procedure fulfill; cdecl;
    procedure fail; cdecl;
  end;

  TCXAction = class(TOCGenericImport<CXActionClass, CXAction>)
  end;

  PCXAction = Pointer;

  CXCallActionClass = interface(CXActionClass)
    ['{9F6E3940-05A4-4D0B-B45E-C4BC3EDB3730}']
  end;

  CXCallAction = interface(CXAction)
    ['{6588EF50-B5C5-4203-B0FF-7276B9DADEAB}']
    function callUUID: NSUUID; cdecl;
    function initWithCallUUID(callUUID: NSUUID)
      : Pointer { instancetype }; cdecl;
    function initWithCoder(aDecoder: NSCoder): Pointer { instancetype }; cdecl;
  end;

  TCXCallAction = class(TOCGenericImport<CXCallActionClass, CXCallAction>)
  end;

  PCXCallAction = Pointer;

  CXStartCallActionClass = interface(CXCallActionClass)
    ['{6F963DA1-5131-4E37-9EEA-5BD1D1DED89D}']
  end;

  CXStartCallAction = interface(CXCallAction)
    ['{74C8731B-35FC-4791-BBC5-EB8019A5685B}']
    function initWithCallUUID(callUUID: NSUUID; handle: CXHandle)
      : Pointer { instancetype }; cdecl;
    function initWithCoder(aDecoder: NSCoder): Pointer { instancetype }; cdecl;
    procedure setHandle(handle: CXHandle); cdecl;
    function handle: CXHandle; cdecl;
    procedure setContactIdentifier(contactIdentifier: NSString); cdecl;
    function contactIdentifier: NSString; cdecl;
    procedure setVideo(video: Boolean); cdecl;
    function isVideo: Boolean; cdecl;
    procedure fulfillWithDateStarted(dateStarted: NSDate); cdecl;
  end;

  TCXStartCallAction = class(TOCGenericImport<CXStartCallActionClass,
    CXStartCallAction>)
  end;

  PCXStartCallAction = Pointer;

  CXAnswerCallActionClass = interface(CXCallActionClass)
    ['{0D2E5C6F-BE6D-4863-BB03-A8542121DB12}']
  end;

  CXAnswerCallAction = interface(CXCallAction)
    ['{F3F8902F-510E-4CE6-BB83-79186B33111F}']
    procedure fulfillWithDateConnected(dateConnected: NSDate); cdecl;
  end;

  TCXAnswerCallAction = class(TOCGenericImport<CXAnswerCallActionClass,
    CXAnswerCallAction>)
  end;

  PCXAnswerCallAction = Pointer;

  CXEndCallActionClass = interface(CXCallActionClass)
    ['{ABE46BCC-BE93-4838-92B6-CF247D1400DC}']
  end;

  CXEndCallAction = interface(CXCallAction)
    ['{E516EE0C-551F-453B-84EF-D284F8268525}']
    procedure fulfillWithDateEnded(dateEnded: NSDate); cdecl;
  end;

  TCXEndCallAction = class(TOCGenericImport<CXEndCallActionClass,
    CXEndCallAction>)
  end;

  PCXEndCallAction = Pointer;

  CXSetHeldCallActionClass = interface(CXCallActionClass)
    ['{CF1571A1-4050-4CCF-8806-875DF281F692}']
  end;

  CXSetHeldCallAction = interface(CXCallAction)
    ['{0A261782-B4AC-4641-80E5-727645626C58}']
    function initWithCallUUID(callUUID: NSUUID; onHold: Boolean)
      : Pointer { instancetype }; cdecl;
    function initWithCoder(aDecoder: NSCoder): Pointer { instancetype }; cdecl;
    procedure setOnHold(onHold: Boolean); cdecl;
    function isOnHold: Boolean; cdecl;
  end;

  TCXSetHeldCallAction = class(TOCGenericImport<CXSetHeldCallActionClass,
    CXSetHeldCallAction>)
  end;

  PCXSetHeldCallAction = Pointer;

  CXSetMutedCallActionClass = interface(CXCallActionClass)
    ['{E13012CE-E419-4B0B-AB17-9822ED83DF97}']
  end;

  CXSetMutedCallAction = interface(CXCallAction)
    ['{591F6094-6A12-4F7D-8D1B-D573B454FC97}']
    function initWithCallUUID(callUUID: NSUUID; muted: Boolean)
      : Pointer { instancetype }; cdecl;
    function initWithCoder(aDecoder: NSCoder): Pointer { instancetype }; cdecl;
    procedure setMuted(muted: Boolean); cdecl;
    function isMuted: Boolean; cdecl;
  end;

  TCXSetMutedCallAction = class(TOCGenericImport<CXSetMutedCallActionClass,
    CXSetMutedCallAction>)
  end;

  PCXSetMutedCallAction = Pointer;

  CXSetGroupCallActionClass = interface(CXCallActionClass)
    ['{F022B5C7-B82C-4D95-A717-F675EAD1AB57}']
  end;

  CXSetGroupCallAction = interface(CXCallAction)
    ['{863D668B-788E-42EE-8ADC-59468C671959}']
    function initWithCallUUID(callUUID: NSUUID; callUUIDToGroupWith: NSUUID)
      : Pointer { instancetype }; cdecl;
    function initWithCoder(aDecoder: NSCoder): Pointer { instancetype }; cdecl;
    procedure setCallUUIDToGroupWith(callUUIDToGroupWith: NSUUID); cdecl;
    function callUUIDToGroupWith: NSUUID; cdecl;
  end;

  TCXSetGroupCallAction = class(TOCGenericImport<CXSetGroupCallActionClass,
    CXSetGroupCallAction>)
  end;

  PCXSetGroupCallAction = Pointer;

  CXPlayDTMFCallActionClass = interface(CXCallActionClass)
    ['{2ABE9998-A303-4007-9CA6-11D5094B2564}']
  end;

  CXPlayDTMFCallAction = interface(CXCallAction)
    ['{5662FB79-E1BF-43D8-810D-B8ED8FCE751D}']
    function initWithCallUUID(callUUID: NSUUID; digits: NSString;
      &type: CXPlayDTMFCallActionType): Pointer { instancetype }; cdecl;
    function initWithCoder(aDecoder: NSCoder): Pointer { instancetype }; cdecl;
    procedure setDigits(digits: NSString); cdecl;
    function digits: NSString; cdecl;
    procedure setType(&type: CXPlayDTMFCallActionType); cdecl;
    function &type: CXPlayDTMFCallActionType; cdecl;
  end;

  TCXPlayDTMFCallAction = class(TOCGenericImport<CXPlayDTMFCallActionClass,
    CXPlayDTMFCallAction>)
  end;

  PCXPlayDTMFCallAction = Pointer;

  CXTransactionClass = interface(NSObjectClass)
    ['{1D06317C-2E86-4E9D-82BF-16027EF37A81}']
  end;

  CXTransaction = interface(NSObject)
    ['{507242E3-C23F-46E8-AC18-824B4B250F52}']
    function UUID: NSUUID; cdecl;
    function isComplete: Boolean; cdecl;
    function actions: NSArray; cdecl;
    function initWithActions(actions: NSArray): Pointer { instancetype }; cdecl;
    function initWithAction(action: CXAction): Pointer { instancetype }; cdecl;
    procedure addAction(action: CXAction); cdecl;
  end;

  TCXTransaction = class(TOCGenericImport<CXTransactionClass, CXTransaction>)
  end;

  PCXTransaction = Pointer;

  CXProviderClass = interface(NSObjectClass)
    ['{1595A1C2-BEBF-428F-92A5-6275A74EE88D}']
  end;

  CXProvider = interface(NSObject)
    ['{457A0C60-C188-4937-BA29-00708082A8D8}']
    function initWithConfiguration(configuration: CXProviderConfiguration): Pointer { instancetype }; cdecl;
    procedure setDelegate(delegate: Pointer; queue: dispatch_queue_t); cdecl;
    procedure reportNewIncomingCallWithUUID(UUID: NSUUID; update: CXCallUpdate; completion: TCallKitCompletion); cdecl;
    [MethodName('reportCallWithUUID:updated:')]
    procedure reportCallWithUUIDUpdated(UUID: NSUUID; updated: CXCallUpdate); cdecl;
    [MethodName('reportCallWithUUID:endedAtDate:reason:')]
    procedure reportCallWithUUIDEndedAtDateReason(UUID: NSUUID; endedAtDate: NSDate; reason: CXCallEndedReason); cdecl;
    [MethodName('reportOutgoingCallWithUUID:startedConnectingAtDate:')]
    procedure reportOutgoingCallWithUUIDStartedConnectingAtDate(UUID: NSUUID; startedConnectingAtDate: NSDate); cdecl;
    [MethodName('reportOutgoingCallWithUUID:connectedAtDate:')]
    procedure reportOutgoingCallWithUUIDConnectedAtDate(UUID: NSUUID; connectedAtDate: NSDate); cdecl;
    procedure setConfiguration(configuration: CXProviderConfiguration); cdecl;
    function configuration: CXProviderConfiguration; cdecl;
    procedure invalidate; cdecl;
    function pendingTransactions: NSArray; cdecl;
    function pendingCallActionsOfClass(callActionClass: Pointer; withCallUUID: NSUUID): NSArray; cdecl;
  end;

  TCXProvider = class(TOCGenericImport<CXProviderClass, CXProvider>)
  end;

  PCXProvider = Pointer;

  CXProviderConfigurationClass = interface(NSObjectClass)
    ['{34EBEE65-5EB7-4A7A-8A8E-C966BBBDFDF0}']
  end;

  CXProviderConfiguration = interface(NSObject)
    ['{79918ABC-0C69-4787-B5E7-9BFCB6A31367}']
    function localizedName: NSString; cdecl;
    procedure setRingtoneSound(ringtoneSound: NSString); cdecl;
    function ringtoneSound: NSString; cdecl;
    procedure setIconTemplateImageData(iconTemplateImageData: NSData); cdecl;
    function iconTemplateImageData: NSData; cdecl;
    procedure setMaximumCallGroups(maximumCallGroups: NSUInteger); cdecl;
    function maximumCallGroups: NSUInteger; cdecl;
    procedure setMaximumCallsPerCallGroup(maximumCallsPerCallGroup
      : NSUInteger); cdecl;
    function maximumCallsPerCallGroup: NSUInteger; cdecl;
    procedure setIncludesCallsInRecents(includesCallsInRecents: Boolean); cdecl;
    function includesCallsInRecents: Boolean; cdecl;
    procedure setSupportsVideo(supportsVideo: Boolean); cdecl;
    function supportsVideo: Boolean; cdecl;
    procedure setSupportedHandleTypes(supportedHandleTypes: NSSet); cdecl;
    function supportedHandleTypes: NSSet; cdecl;
    function initWithLocalizedName(localizedName: NSString)
      : Pointer { instancetype }; cdecl;
  end;

  TCXProviderConfiguration = class
    (TOCGenericImport<CXProviderConfigurationClass, CXProviderConfiguration>)
  end;

  PCXProviderConfiguration = Pointer;

  CXCallClass = interface(NSObjectClass)
    ['{1DB01C24-D21F-41F6-BA40-3F032DDCAB1F}']
  end;

  CXCall = interface(NSObject)
    ['{0DDFC5CF-A397-498B-ABB4-F4972D4BD179}']
    function UUID: NSUUID; cdecl;
    function isOutgoing: Boolean; cdecl;
    function isOnHold: Boolean; cdecl;
    function hasConnected: Boolean; cdecl;
    function hasEnded: Boolean; cdecl;
    function isEqualToCall(call: CXCall): Boolean; cdecl;
  end;

  TCXCall = class(TOCGenericImport<CXCallClass, CXCall>)
  end;

  PCXCall = Pointer;

  CXCallObserverClass = interface(NSObjectClass)
    ['{91B1D9B3-C15B-4E9B-BCF7-4A9525E670E6}']
  end;

  CXCallObserver = interface(NSObject)
    ['{FE0A7472-4F5F-4F4B-839D-1DACE6DC1042}']
    function calls: NSArray; cdecl;
    procedure setDelegate(delegate: Pointer; queue: dispatch_queue_t); cdecl;
  end;

  TCXCallObserver = class(TOCGenericImport<CXCallObserverClass, CXCallObserver>)
  end;

  PCXCallObserver = Pointer;

  CXCallControllerClass = interface(NSObjectClass)
    ['{C2475D7D-527F-4D62-85C4-8866846C7D17}']
  end;

  CXCallController = interface(NSObject)
    ['{AF7ADE86-5147-4A00-8699-D69C27DEEFE3}']
    function init: Pointer { instancetype }; cdecl;
    function initWithQueue(queue: dispatch_queue_t)
      : Pointer { instancetype }; cdecl;
    function callObserver: CXCallObserver; cdecl;
    procedure requestTransaction(transaction: CXTransaction; completion: TCallKitCompletion); cdecl;
    procedure requestTransactionWithActions(actions: NSArray; completion: TCallKitCompletion); cdecl;
    procedure requestTransactionWithAction(action: CXAction; completion: TCallKitCompletion); cdecl;
  end;

  TCXCallController = class(TOCGenericImport<CXCallControllerClass,
    CXCallController>)
  end;

  PCXCallController = Pointer;

  CXCallDirectoryManagerClass = interface(NSObjectClass)
    ['{3E084352-BB5D-428C-9D11-5AAAAAFC081E}']
  end;

  CXCallDirectoryManager = interface(NSObject)
    ['{AC02E39D-A42F-47EB-91C1-43B3256FA0A3}']
    function sharedInstance: CXCallDirectoryManager; cdecl;
    procedure reloadExtensionWithIdentifier(identifier: NSString;
      completionHandler: TCallKitCompletion); cdecl;
    procedure getEnabledStatusForExtensionWithIdentifier(identifier: NSString;
      completionHandler: TCallKitCompletionHandler); cdecl;
  end;

  TCXCallDirectoryManager = class(TOCGenericImport<CXCallDirectoryManagerClass,
    CXCallDirectoryManager>)
  end;

  PCXCallDirectoryManager = Pointer;

  CXCallDirectoryExtensionContextClass = interface(NSExtensionContextClass)
    ['{95AF09A7-41BC-4D07-AA36-9D1CF3FA4882}']
  end;

  CXCallDirectoryExtensionContext = interface(NSExtensionContext)
    ['{F06E0B43-72B9-4E6F-B62D-6D1C5D0FB6B9}']
    procedure setDelegate(delegate: Pointer); cdecl;
    function delegate: Pointer; cdecl;
    function isIncremental: Boolean; cdecl;
    procedure addBlockingEntryWithNextSequentialPhoneNumber(phoneNumber: CXCallDirectoryPhoneNumber); cdecl;
    procedure removeBlockingEntryWithPhoneNumber(phoneNumber: CXCallDirectoryPhoneNumber); cdecl;
    procedure removeAllBlockingEntries; cdecl;
    procedure addIdentificationEntryWithNextSequentialPhoneNumber(phoneNumber: CXCallDirectoryPhoneNumber; &label: NSString); cdecl;
    procedure removeIdentificationEntryWithPhoneNumber(phoneNumber: CXCallDirectoryPhoneNumber); cdecl;
    procedure removeAllIdentificationEntries; cdecl;
    procedure completeRequestWithCompletionHandler(completion: TCallKitCompletion1); cdecl;
  end;

  TCXCallDirectoryExtensionContext = class
    (TOCGenericImport<CXCallDirectoryExtensionContextClass,
    CXCallDirectoryExtensionContext>)
  end;

  PCXCallDirectoryExtensionContext = Pointer;

  CXCallDirectoryProviderClass = interface(NSObjectClass)
    ['{CE04ADA9-3DD9-4FD0-AF31-BBB93E33BA3B}']
  end;

  CXCallDirectoryProvider = interface(NSObject)
    ['{58E7D9C5-5D0A-4BC1-BD7E-2CE8EDC697A7}']
    procedure beginRequestWithExtensionContext
      (context: CXCallDirectoryExtensionContext); cdecl;
  end;

  TCXCallDirectoryProvider = class
    (TOCGenericImport<CXCallDirectoryProviderClass, CXCallDirectoryProvider>)
  end;

  PCXCallDirectoryProvider = Pointer;

  // ===== Protocol declarations =====

  CXProviderDelegate = interface(IObjectiveC)
    ['{64B033CB-4CB1-45D9-A63B-B0FCBE48B8AF}']
    procedure providerDidReset(provider: CXProvider); cdecl;
    procedure providerDidBegin(provider: CXProvider); cdecl;
    [MethodName('provider:executeTransaction:')]
    function provider(provider: CXProvider; executeTransaction: CXTransaction): Boolean; cdecl; overload;
    [MethodName('provider:performStartCallAction:')]
    procedure provider(provider: CXProvider; performStartCallAction: CXStartCallAction); cdecl; overload;
    [MethodName('provider:performAnswerCallAction:')]
    procedure provider(provider: CXProvider; performAnswerCallAction: CXAnswerCallAction); cdecl; overload;
    [MethodName('provider:performEndCallAction:')]
    procedure provider(provider: CXProvider; performEndCallAction: CXEndCallAction); cdecl; overload;
    [MethodName('provider:performSetHeldCallAction:')]
    procedure provider(provider: CXProvider; performSetHeldCallAction: CXSetHeldCallAction); cdecl; overload;
    [MethodName('provider:performSetMutedCallAction:')]
    procedure provider(provider: CXProvider; performSetMutedCallAction: CXSetMutedCallAction); cdecl; overload;
    [MethodName('provider:performSetGroupCallAction:')]
    procedure provider(provider: CXProvider; performSetGroupCallAction: CXSetGroupCallAction); cdecl; overload;
    [MethodName('provider:performPlayDTMFCallAction:')]
    procedure provider(provider: CXProvider; performPlayDTMFCallAction: CXPlayDTMFCallAction); cdecl; overload;
    [MethodName('provider:timedOutPerformingAction:')]
    procedure provider(provider: CXProvider; timedOutPerformingAction: CXAction); cdecl; overload;
    [MethodName('provider:didActivateAudioSession:')]
    procedure providerdidActivateAudioSession(provider: CXProvider; didActivateAudioSession: AVAudioSession); cdecl; overload;
    [MethodName('provider:didDeactivateAudioSession:')]
    procedure providerdidDeactivateAudioSession(provider: CXProvider; didDeactivateAudioSession: AVAudioSession); cdecl; overload;
  end;

  CXCallObserverDelegate = interface(IObjectiveC)
    ['{650E0B41-3F2A-4DF9-A087-B878F1784FCB}']
    procedure callObserver(callObserver: CXCallObserver;
      callChanged: CXCall); cdecl;
  end;

  CXCallDirectoryExtensionContextDelegate = interface(IObjectiveC)
    ['{3CDB826F-F850-400B-A348-70A0F372BB1E}']
    procedure requestFailedForExtensionContext(extensionContext
      : CXCallDirectoryExtensionContext; withError: NSError); cdecl;
  end;

  // ===== Exported string consts =====

function CXErrorDomain: Pointer;
function CXErrorDomainIncomingCall: Pointer;
function CXErrorDomainRequestTransaction: Pointer;
function CXErrorDomainCallDirectoryManager: Pointer;


// ===== External functions =====

const
  libCallKit = '/System/Library/Frameworks/CallKit.framework/CallKit';

implementation

uses
  Posix.Dlfcn;

var
  CallKitModule: THandle;

function CXErrorDomain: Pointer;
begin
  Result := CocoaPointerConst(libCallKit, 'CXErrorDomain');
end;

function CXErrorDomainIncomingCall: Pointer;
begin
  Result := CocoaPointerConst(libCallKit, 'CXErrorDomainIncomingCall');
end;

function CXErrorDomainRequestTransaction: Pointer;
begin
  Result := CocoaPointerConst(libCallKit, 'CXErrorDomainRequestTransaction');
end;

function CXErrorDomainCallDirectoryManager: Pointer;
begin
  Result := CocoaPointerConst(libCallKit, 'CXErrorDomainCallDirectoryManager');
end;

initialization
CallKitModule := dlopen(MarshaledAString(libCallKit), RTLD_LAZY);

finalization
dlclose(CallKitModule);


end.
