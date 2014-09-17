unit PointerscannerSettingsFrm;

{$MODE Delphi}

interface

uses
  windows, LCLIntf, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, LResources, EditBtn, Buttons, Contnrs,
  CEFuncProc, NewKernelHandler, symbolhandler, multilineinputqueryunit,
  registry, resolve, fgl, math;


type
  TPointerFileEntry=class(TCustomPanel)
  private
    fimagelist: Timagelist;
    ffilename: string;
    fOnDelete: TNotifyEvent;
    fOnSetfilename: TNotifyEvent;
    lblFilename: TLabel;
    btnSetFile: TSpeedButton;
    btnDelete: TSpeedButton;
    edtAddress: TEdit;
    procedure btnSetFileClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure setFileName(filename: string);
  public
    property filename: string read ffilename write setFileName;
    property OnDelete: TNotifyEvent read fOnDelete write fOnDelete;
    property OnSetFileName: TNotifyEvent read fOnSetFileName write fOnSetFileName;
    constructor create(imagelist: TImageList; AOwner: TComponent);
    destructor destroy; override;
  end;


type
  TPointerFileEntries = TFPGList<TPointerFileEntry>;

  TPointerFileList=class(TPanel)
  private
    lblFilenames: TLabel;
    lblAddress: TLabel;
    fimagelist: TImageList;
    fOnEmptyList: TNotifyEvent;
    Entries: TPointerFileEntries;

    function getCount: integer;
    function getFilename(index: integer): string;
    function getAddress(index: integer): ptruint;
    procedure DeleteEntry(sender: TObject);
    procedure FilenameUpdate(sender: TObject);
    function AddEntry: TPointerFileEntry;
    procedure Organize;
  public
    constructor create(imagelist: TImageList; AOwner: TComponent; w: integer);
    destructor destroy; override;

    property OnEmptyList: TNotifyEvent read fOnEmptyList write fOnEmptyList;
    property Count: integer read getCount;
    property filenames[index: integer]: string read getFilename;
    property addresses[index: integer]: ptruint read getAddress;
  end;

type tmoduledata = class
  public
    moduleaddress: dword;
    modulesize: dword;
  end;

type TOffsetEntry=class(Tedit)
  private
    function getOffset: dword;
    procedure setOffset(x: dword);
  protected
    procedure KeyPress(var Key: Char); override;
  public
    constructor create(AOwner: TComponent); override;
  published
    property offset: dword read getOffset write setOffset;
end;

type

  { TfrmPointerScannerSettings }

  TfrmPointerScannerSettings = class(TForm)
    btnNotifySpecificIPs: TButton;
    cbNoReadOnly: TCheckBox;
    cbClassPointersOnly: TCheckBox;
    cbNoLoop: TCheckBox;
    cbMaxOffsetsPerNode: TCheckBox;
    cbStackOnly: TCheckBox;
    cbUseLoadedPointermap: TCheckBox;
    cbDistributedScanning: TCheckBox;
    cbBroadcast: TCheckBox;
    cbMustStartWithBase: TCheckBox;
    cbAcceptNonModuleVtable: TCheckBox;
    cbCompressedPointerscanFile: TCheckBox;
    cbCompareToOtherPointermaps: TCheckBox;
    cbGeneratePointermapOnly: TCheckBox;
    edtDistributedPort: TEdit;
    edtThreadStacks: TEdit;
    edtStackSize: TEdit;
    il: TImageList;
    lblPort: TLabel;
    lblNumberOfStackThreads: TLabel;
    lblStackSize: TLabel;
    cbStaticStacks: TCheckBox;
    edtMaxOffsetsPerNode: TEdit;
    edtAddress: TEdit;
    odLoadPointermap: TOpenDialog;
    PSSettings: TPageControl;
    PSReverse: TTabSheet;
    CbAlligned: TCheckBox;
    edtReverseStop: TEdit;
    edtReverseStart: TEdit;
    Label10: TLabel;
    Label11: TLabel;
    Label13: TLabel;
    cbStaticOnly: TCheckBox;
    cbMustEndWithSpecificOffset: TCheckBox;
    Panel1: TPanel;
    Label3: TLabel;
    Label12: TLabel;
    Label9: TLabel;
    Button1: TButton;
    editStructsize: TEdit;
    editMaxLevel: TEdit;
    btnCancel: TButton;
    edtThreadcount: TEdit;
    ComboBox1: TComboBox;
    cbUseHeapData: TCheckBox;
    cbHeapOnly: TCheckBox;
    cbValueType: TComboBox;
    Panel2: TPanel;
    rbFindAddress: TRadioButton;
    rbFindValue: TRadioButton;
    cbOnlyOneStatic: TCheckBox;
    cbReusePointermap: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure btnNotifySpecificIPsClick(Sender: TObject);
    procedure canNotReuse(Sender: TObject);
    procedure cbMustStartWithBaseChange(Sender: TObject);
    procedure cbBroadcastChange(Sender: TObject);
    procedure cbDistributedScanningChange(Sender: TObject);
    procedure cbMaxOffsetsPerNodeChange(Sender: TObject);
    procedure cbMustEndWithSpecificOffsetChange(Sender: TObject);
    procedure cbReusePointermapChange(Sender: TObject);
    procedure cbStaticStacksChange(Sender: TObject);
    procedure cbUseLoadedPointermapChange(Sender: TObject);
    procedure cbCompareToOtherPointermapsChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbMustEndWithSpecificOffsetClick(Sender: TObject);
    procedure cbUseHeapDataClick(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
    procedure rbFindValueClick(Sender: TObject);
    procedure edtAddressChange(Sender: TObject);
    procedure cbHeapOnlyClick(Sender: TObject);
  private
    { Private declarations }
    iplist: tstringlist;
    firstshow: boolean;

    edtBaseFrom: TEdit;
    edtBaseTo: TEdit;
    lblBaseFrom: TLabel;
    lblBaseTo: TLabel;


    procedure btnAddClick(sender: TObject);
    procedure btnRemoveClick(sender: TObject);
    procedure updatepositions;
    procedure PointerFileListEmpty(sender: TObject);
    procedure PointerFileListResize(sender: TObject);
    procedure UpdateFindValueState;
  public
    { Public declarations }
    reverse: boolean; //indicates to use the reverse method
    start:ptrUint;
    stop: ptrUint;
    unalligned: boolean;
    automaticaddress: ptrUint;
    structsize: integer;
    maxOffsetsPerNode: integer;
    maxlevel: integer;
    codescan: boolean;
    threadcount: integer;


    baseAddressRange: TComponentList;

    offsetlist: TComponentList;
    btnAddOffset: TButton;
    btnRemoveOffset: TButton;
    lblInfoLastOffset: TLabel;

    threadstacks: integer;
    stacksize: integer;
    scannerpriority: TThreadPriority;
    distributedport: word;

    baseStart: ptruint;
    baseStop: ptruint;

    resolvediplist: array of THostAddr;

    pdatafilelist: TPointerFileList;
  end;

var frmpointerscannersettings: tfrmpointerscannersettings;

implementation

uses frmMemoryAllocHandlerUnit, MemoryBrowserFormUnit, ProcessHandlerUnit;



resourcestring
  rsAdd = 'Add';
  rsRemove = 'Remove';
  rsIdle = 'Idle';
  rsLowest = 'Lowest';
  rsLower = 'Lower';
  rsNormal = 'Normal';
  rsHigher = 'Higher';
  rsHighest = 'Highest';
  rsTimeCritical = 'TimeCritical';

  strMaxOffsetsIsStupid = 'Sorry, but the max offsets should be 1 or higher, or else disable the checkbox'; //'Are you a fucking retard?';
  rsUseLoadedPointermap = 'Use saved pointermap';






//-----------TPointerFileEntry--------------


constructor TPointerFileEntry.create(imagelist: TImageList; AOwner: TComponent);
var bm: tbitmap;
begin
  inherited create(Aowner);

  fimagelist:=imagelist;

  bevelouter:=bvNone;

  lblFileName:=TLabel.create(self);
  lblFileName.OnClick:=btnSetFileClick;
  lblFilename.Cursor:=crHandPoint;

  btnSetFile:=TSpeedButton.Create(self);
  btnSetFile.OnClick:=btnSetFileClick;

  btnDelete:=TSpeedButton.Create(self);
  btnDelete.OnClick:=btnDeleteClick;
  edtAddress:=TEdit.Create(self);
  edtAddress.Enabled:=false;

  btnDelete.Parent:=self;
  btnDelete.AnchorSideRight.Side:=asrRight;
  btnDelete.AnchorSideRight.Control:=self;
  btnDelete.Anchors:=[aktop, akRight];
  btnDelete.BorderSpacing.Right:=4;

  bm:=tbitmap.Create;
  imagelist.GetBitmap(0, bm);
  btnDelete.Glyph:=bm;
  bm.free;

  edtAddress.parent:=self;
  edtAddress.AnchorSideRight.Control:=btnDelete;
  edtAddress.AnchorSideRight.side:=asrLeft;
  edtAddress.clientwidth:=tcustomform(aowner).canvas.TextWidth('DDDDDDDDDDDD');
  edtAddress.anchors:=[aktop, akright];
  edtAddress.alignment:=tacenter;

  edtAddress.BorderSpacing.Right:=8;


  btnsetfile.parent:=self;
  btnSetFile.AnchorSideRight.control:=edtAddress;
  btnSetFile.AnchorSideRight.side:=asrLeft;
  btnSetFile.Anchors:=[aktop, akright];
  btnSetFile.BorderSpacing.Right:=8;

  bm:=tbitmap.Create;
  imagelist.GetBitmap(1, bm);
  btnSetFile.Glyph:=bm;

  bm.free;


  lblFilename.parent:=self;
  lblFilename.AutoSize:=false;
  lblFilename.AnchorSideRight.control:=btnsetfile;
  lblFilename.AnchorSideRight.side:=asrleft;
  lblFilename.AnchorSideLeft.control:=self;
  lblFilename.AnchorSideLeft.side:=asrleft;
  lblFilename.AnchorSideTop.Control:=btnSetFile;
  lblfilename.AnchorSideTop.Side:=asrCenter;

  lblFilename.BorderSpacing.Right:=8;
  lblFilename.BorderSpacing.Left:=4;


  lblfilename.anchors:=[aktop, akleft, akright];
  lblFilename.Caption:='  <Select a file>';

  height:=edtAddress.Height+2;


end;

destructor TPointerFileEntry.destroy;
begin
  inherited destroy;
end;

procedure TPointerFileEntry.btnSetFileClick(Sender: TObject);
var od: TOpenDialog;
begin
  od:=TOpenDialog.Create(self);
  od.DefaultExt:='.scandata';
  od.Filter:='All files (*.*)|*.*|Scandata (*.scandata)|*.scandata';
  od.FilterIndex:=2;
  od.filename:=filename;
  if od.execute then
  begin
    filename:=od.filename;
    edtAddress.Enabled:=true;
  end;

  od.free;
end;

procedure TPointerFileEntry.btnDeleteClick(Sender: TObject);
begin
  if assigned(OnDelete) then
    OnDelete(self);
end;

procedure TPointerFileEntry.setFileName(filename: string);
begin
  ffilename:=filename;
  lblfilename.caption:=extractfilename(filename);
  lblfilename.Hint:=filename;
  lblfilename.ShowHint:=true;

  if assigned(fonsetfilename) then
    fonSetFileName(self);
end;




procedure TPointerFileList.Organize;
var
  i: integer;
  t: integer;

begin
  //sort based on the order of the list
  t:=lblFilenames.top+lblFilenames.height;
  for i:=0 to entries.count-1 do
  begin
    entries[i].top:=t;
    t:=entries[i].top+entries[i].Height;
  end;



  //adjust the height
  if Entries.count>0 then
    height:=entries[entries.count-1].Top+entries[entries.count-1].Height
  else
    height:=0;

end;

procedure TPointerFileList.DeleteEntry(sender: TObject);
var
  e: TPointerFileEntry;
  i: integer;
begin

  e:=TPointerFileEntry(sender);
  i:=entries.IndexOf(e);

  if (i<>0) and (i=entries.count-1) and (entries[i].filename='') then exit; //don't delete the last one if there asre entries

  entries.Delete(i);
  e.Free;

  Organize;

  if entries.count=0 then
  begin
    if assigned(fOnEmptyList) then
      fOnEmptyList(self);
  end;
end;

procedure TPointerFileList.FilenameUpdate(sender: TObject);
var i: integer;
begin
  //check if there is a empty line, and if not, add a new one
  for i:=0 to entries.count-1 do
    if entries[i].filename='' then exit;

  //no empty line. Add a new one
  AddEntry;
end;

function TPointerFileList.addentry:TPointerFileEntry;
var e: TPointerFileEntry;
begin
  e:=TPointerFileEntry.create(fimagelist, self);
  e.parent:=self;
  if entries.Count=0 then
    e.top:=lblFilenames.Top+lblFilenames.height+2
  else
    e.top:=entries[entries.count-1].Top+entries[entries.count-1].Height;

  e.width:=ClientWidth;
  e.OnDelete:=DeleteEntry;
  e.OnSetFileName:=FilenameUpdate;

  entries.Add(e);
  result:=e;

  Organize;
end;

function TPointerFileList.getFilename(index: integer): string;
begin
  if (index>=0) and (index<count) then
    result:=entries[index].filename
  else
    result:='';
end;

function TPointerFileList.getAddress(index: integer): ptruint;
begin
  if filenames[index]<>'' then
  begin
    try
      result:=StrToQWord('$'+entries[index].edtAddress.Text);
    except
      raise exception.create(filenames[index]+' has not been given a valid address');
    end;
  end;
end;

function TPointerFileList.getCount: integer;
begin
  result:=entries.count;
end;

constructor TPointerFileList.create(imagelist: TImageList; AOwner: TComponent; w: integer);
var e: TPointerFileEntry;
begin
  fimagelist:=imagelist;
  inherited create(AOwner);

  if aowner is twincontrol then
  begin
    width:=w;
    parent:=twincontrol(aowner);
  end;

  bevelouter:=bvNone;


  entries:=TPointerFileEntries.create;
  lblFilenames:=TLabel.create(self);
  lblFilenames.caption:='Filename';
  lblFilenames.parent:=self;

  lblAddress:=TLabel.create(self);
  lblAddress.caption:='Address';
  lblAddress.parent:=self;

  lblAddress.top:=0;
  lblFilenames.top:=0;

  e:=AddEntry;

  lblFilenames.Left:=e.lblFilename.Left;
  lblAddress.left:=e.edtAddress.Left+(e.edtAddress.width div 2)-(lblAddress.width div 2);
end;

destructor TPointerFileList.destroy;
var i: integer;
begin
  for i:=0 to entries.count-1 do
    entries[i].Free;

  entries.free;

  inherited destroy;
end;

//------------TOffsetEntry-------------------

constructor TOffsetEntry.create(AOwner: TComponent);
begin
  inherited create(AOwner);
  text:='0';

  width:=50;
end;

procedure TOffsetEntry.KeyPress(var Key: Char);
begin
  if key in ['A'..'F', 'a'..'f','0'..'9','+','-',#0..#31] then
    inherited KeyPress(key)
  else
    key:=#0;
end;

function TOffsetEntry.getOffset: dword;
var o: integer;
begin
  if TryStrToInt('$'+text, o) then result:=o else result:=0;
end;

procedure TOffsetEntry.setOffset(x: dword);
begin
  text:=inttohex(x,1);
end;

procedure TfrmPointerScannerSettings.Button1Click(Sender: TObject);
var
  i: integer;
  r: THostResolver;
  p: ptruint;
begin
  if cbMaxOffsetsPerNode.checked then
  begin
    maxOffsetsPerNode:=strtoint(edtMaxOffsetsPerNode.text);
    if maxOffsetsPerNode<=0 then
    begin
      MessageDlg(strMaxOffsetsIsStupid, mtError, [mbok], 0);
      exit;
    end;
  end;

  if cbCompareToOtherPointermaps.checked then
  begin
    //check if the addresses are valid
    try
      for i:=0 to pdatafilelist.Count-1 do
      begin
        if pdatafilelist.filenames[i]<>'' then
          p:=pdatafilelist.addresses[i];
      end;
    except
      on e:exception do
      begin
        MessageDlg(e.Message, mtError, [mbok], 0);
        exit;
      end;
    end;
  end;

  start:=StrToQWordEx('$'+edtReverseStart.text);
  stop:=StrToQWordEx('$'+edtReverseStop.text);


  if cbMustStartWithBase.checked then
  begin
    baseStart:=symhandler.getAddressFromName(edtBaseFrom.text);
    baseStop:=symhandler.getAddressFromName(edtBaseTo.text);
  end;


  automaticaddress:=symhandler.getAddressFromName(edtAddress.text);

  unalligned:=not cballigned.checked;

  structsize:=strtoint(editstructsize.text);
  maxlevel:=strtoint(editMaxLevel.text)+1;

  codescan:=false;

  threadcount:=strtoint(edtthreadcount.text);
  case combobox1.itemindex of
    0: scannerpriority:=tpIdle;
    1: scannerpriority:=tpLowest;
    2: scannerpriority:=tpLower;
    3: scannerpriority:=tpNormal;
    4: scannerpriority:=tpHigher;
    5: scannerpriority:=tpHighest;
    6: scannerpriority:=tpTimeCritical;
  end;

  if cbStaticStacks.checked then
  begin
    threadstacks:=strtoint(edtThreadStacks.text);
    stacksize:=strtoint(edtStackSize.text);
  end;

  distributedport:=strtoint(edtDistributedPort.text);


  if cbBroadcast.checked then
  begin
    r:=THostResolver.create(nil);
    r.RaiseOnError:=false;

    for i:=0 to iplist.count-1 do
    begin
      r.NameLookup(iplist[i]);

      if r.HostAddress.s_addr<>0 then
      begin
        setlength(resolvediplist, length(resolvediplist)+1);
        resolvediplist[Length(resolvediplist)-1]:=r.HostAddress;
      end;
    end;

    r.free;
  end;
  modalresult:=mrok;
end;

procedure TfrmPointerScannerSettings.btnNotifySpecificIPsClick(Sender: TObject);
var
  reg: Tregistry;
begin
  reg:=TRegistry.create;
  try
    if MultilineInputQuery('IP List','Enter the IP addresses to notify explicitly', iplist) then  //save the new ip list
    begin
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey('\Software\Cheat Engine',true) then
        reg.WriteString('Worker IP List', iplist.text);
    end;

  finally
    reg.free;
  end;

end;

procedure TfrmPointerScannerSettings.canNotReuse(Sender: TObject);
begin
  cbReusePointermap.Enabled:=false;
  cbReusePointermap.Checked:=false;


  cbAcceptNonModuleVtable.enabled:=cbClassPointersOnly.checked;

end;

procedure TfrmPointerScannerSettings.cbMustStartWithBaseChange(Sender: TObject);
begin
  if cbMustStartWithBase.checked then
  begin
    //create a 2 text boxes and 2 labels (from - to)
    edtBaseFrom:=tedit.create(self);
    edtBaseFrom.Top:=cbMustStartWithBase.top+cbMustStartWithBase.height+3;
    edtBaseFrom.Left:=edtReverseStart.left;
    edtBaseFrom.Width:=cbMustStartWithBase.width;
    edtBaseFrom.parent:=self;


    edtBaseTo:=tedit.create(self);
    edtBaseTo.top:=edtBaseFrom.top+edtbasefrom.height+1;
    edtbaseto.left:=edtReverseStop.left;
    edtbaseto.width:=cbMustStartWithBase.width;
    edtbaseto.parent:=self;

    lblBaseFrom:=tlabel.create(self);
    lblBaseFrom.Parent:=self;
    lblbasefrom.Caption:='From';
    lblbasefrom.left:=0;
    lblbasefrom.top:=edtbasefrom.top+(edtbasefrom.height div 2) - (lblbasefrom.height div 2);

    lblBaseTo:=tlabel.create(self);
    lblBaseTo.Parent:=self;
    lblBaseTo.Caption:='To';
    lblBaseTo.left:=0;
    lblBaseTo.top:=edtbaseto.top+(edtbaseto.height div 2) - (lblBaseTo.height div 2);


    cbStaticOnly.checked:=true;
    cbStaticOnly.enabled:=false;
  end
  else
  begin
    //destroy the edit boxes and labels

    freeandnil(edtbasefrom);
    freeandnil(edtbaseto);
    freeandnil(lblbasefrom);
    freeandnil(lblbaseto);


    cbStaticOnly.enabled:=true;
  end;

  updatepositions;
end;

procedure TfrmPointerScannerSettings.cbBroadcastChange(Sender: TObject);
begin
  if cbBroadcast.checked then
    btnNotifySpecificIPs.enabled:=true;
end;

procedure TfrmPointerScannerSettings.cbDistributedScanningChange(Sender: TObject);
begin
  cbBroadcast.enabled:=cbDistributedScanning.checked;
end;

procedure TfrmPointerScannerSettings.cbMaxOffsetsPerNodeChange(Sender: TObject);
begin
  edtMaxOffsetsPerNode.enabled:=cbMaxOffsetsPerNode.checked;
end;

procedure TfrmPointerScannerSettings.cbMustEndWithSpecificOffsetChange(Sender: TObject);
var offsetentry: TOffsetEntry;
begin
  //create an offset entry
  if (sender as tcheckbox).Checked then //create the first one and the add button
  begin
    offsetentry:=TOffsetEntry.Create(self);

    offsetlist:=TComponentList.create;
    offsetlist.Add(offsetentry);


    with offsetentry do
    begin
      offsetentry.Name:='edtOffset'+inttostr(offsetlist.Count);
      top:=panel1.top;
      left:=cbMustEndWithSpecificOffset.left+15;
      self.Height:=self.Height+height+2;
      parent:=self;
    end;

    if lblInfoLastOffset=nil then
      lblInfoLastOffset:=TLabel.Create(self);

    with lblInfoLastOffset do
    begin
      caption:='Last offset';
      left:=offsetentry.Left+offsetentry.Width+5;
      parent:=self;
      visible:=false;
    end;

    if btnAddOffset=nil then
      btnAddOffset:=TButton.Create(self);

    with btnAddOffset do
    begin
      name:='btnAddOffset';
      caption:=rsAdd;
      left:=offsetentry.Left+offsetentry.Width+3;
      width:=60;
      height:=offsetentry.Height;
      top:=offsetentry.top;
      parent:=self;
      onclick:=btnAddClick;
      visible:=true;
    end;

    if btnRemoveOffset=nil then
      btnRemoveOffset:=TButton.Create(self);

    with btnRemoveOffset do
    begin
      name:='btnRemoveOffset';
      caption:=rsRemove;
      left:=btnAddOffset.Left+btnAddOffset.Width+3;
      width:=60;
      height:=offsetentry.Height;
      top:=offsetentry.top;
      parent:=self;
      onclick:=btnRemoveClick;
      visible:=true;
    end;




  end
  else
  begin
    //delete all the objects in the list
    clientheight:=cbMustEndWithSpecificOffset.top+cbMustEndWithSpecificOffset.Height+2+panel1.height;
    freeandnil(offsetlist); //deletes all the assigned objects
    btnAddOffset.Visible:=false;
    btnRemoveOffset.Visible:=false;
    lblInfoLastOffset.Visible:=false;
  end;

  updatepositions;

end;

procedure TfrmPointerScannerSettings.cbReusePointermapChange(Sender: TObject);
begin
  if cbReusePointermap.checked then
  begin
    cbUseLoadedPointermap.OnChange:=nil;
    cbUseLoadedPointermap.checked:=false;
    cbUseLoadedPointermap.enabled:=false;
    cbUseLoadedPointermap.OnChange:=cbUseLoadedPointermapChange;
  end
  else
    cbUseLoadedPointermap.enabled:=true;

  UpdateFindValueState;
end;

procedure TfrmPointerScannerSettings.cbUseLoadedPointermapChange(Sender: TObject);
begin
  if cbUseLoadedPointermap.checked then
  begin
    cbUseLoadedPointermap.OnChange:=nil;
    if odLoadPointermap.Execute then
    begin
      cbReusePointermap.OnChange:=nil;
      cbReusePointermap.checked:=false;
      cbReusePointermap.enabled:=false;
      cbReusePointermap.OnChange:=cbReusePointermapChange;

      cbUseLoadedPointermap.Caption:=rsUseLoadedPointermap+':'+ExtractFileName(odLoadPointermap.FileName);



    end
    else
      cbUseLoadedPointermap.checked:=false;

    cbUseLoadedPointermap.OnChange:=cbUseLoadedPointermapChange;
  end
  else
    cbUseLoadedPointermap.Caption:=rsUseLoadedPointermap;

  UpdateFindValueState;
end;

procedure TfrmPointerScannerSettings.PointerFileListEmpty(sender: TObject);
begin
  cbCompareToOtherPointermaps.checked:=false;
end;


procedure TfrmPointerScannerSettings.PointerFileListResize(sender: TObject);
begin
  updatepositions;
end;

procedure TfrmPointerScannerSettings.cbCompareToOtherPointermapsChange(Sender: TObject);
begin
  if cbCompareToOtherPointermaps.checked then
  begin
    pdatafilelist:=TPointerFileList.create(il, self, cbDistributedScanning.left-cbCompareToOtherPointermaps.left-8);
    pdatafilelist.top:=cbCompareToOtherPointermaps.top+cbCompareToOtherPointermaps.height;
    pdatafilelist.left:=cbCompareToOtherPointermaps.left;

    pdatafilelist.OnEmptyList:=PointerFileListEmpty;
    pdatafilelist.OnResize:=PointerFileListResize;
  end
  else
  begin
    pdatafilelist.OnResize:=nil;
    pdatafilelist.OnEmptyList:=nil;
    pdatafilelist.visible:=false;
    pdatafilelist.free;
    pdatafilelist:=nil;
  end;

  UpdateFindValueState;
  updatepositions;
end;

procedure TfrmPointerScannerSettings.FormDestroy(Sender: TObject);
begin
  if iplist<>nil then
    freeandnil(iplist);
end;

procedure TfrmPointerScannerSettings.cbStaticStacksChange(Sender: TObject);
begin
  lblNumberOfStackThreads.enabled:=cbStaticStacks.checked;
  edtThreadStacks.enabled:=cbStaticStacks.checked;

  lblStackSize.enabled:=cbStaticStacks.checked;
  edtStackSize.enabled:=cbStaticStacks.checked;
  cbStackOnly.enabled:=cbStaticStacks.checked;

end;



procedure TfrmPointerScannerSettings.FormShow(Sender: TObject);
var
  cpucount: integer;

begin
  cpucount:=GetCPUCount;

  //assumption: when a core with hyperthreading core is running at 100% it's hyperthreaded processor will be running at 90%
  //This means that 10 cores are needed to provide an equivalent for one extra core when hyperthreading is used
  //In short, leave the hyperhtreaded processors alone so the user can use that hardly useful processing power to surf the web or move the mouse...
  //(at most use one)
  if HasHyperthreading then
    cpucount:=ceil((cpucount / 2)+(cpucount / 4));


  rbFindValueClick(rbFindAddress);


  edtThreadcount.text:=inttostr(cpucount);


  //check what type of process it is
  if processhandler.is64Bit then
  begin
    edtReverseStart.Width:=160;
    edtReverseStart.maxlength:=16;
    edtReverseStop.MaxLength:=edtReverseStart.MaxLength;

    //if it's not edited by the user, then fill in the default ranges for 64-bit
    if edtReverseStart.text='00000000' then
      edtReverseStart.text:='0000000000000000';

    if (edtReverseStop.text='7FFFFFFF') or (edtReverseStop.text='FFFFFFFF') then
    begin
      edtReverseStop.text:='7FFFFFFFFFFFFFFF';
    end;
  end
  else
  begin
    edtReverseStart.Width:=80;



    //if it's not edited by the user, then fill in the default ranges for 32-bit
    if edtReverseStart.text='0000000000000000' then
      edtReverseStart.text:='00000000';

    if (edtReverseStop.text='7FFFFFFFFFFFFFFF') or (edtReverseStop.text='7FFFFFFF') then
    begin
      if Is64bitOS then
        edtReverseStop.text:='FFFFFFFF'
      else
        edtReverseStop.text:='7FFFFFFF';
    end;

    edtReverseStart.maxlength:=8;
    edtReverseStop.MaxLength:=edtReverseStart.MaxLength;
  end;


  edtReverseStop.Width:=edtReverseStart.width;


  if firstshow then
    updatepositions;

  firstshow:=false;

end;

procedure TfrmPointerScannerSettings.FormCreate(Sender: TObject);
var reg: tregistry;
begin
  ComboBox1.Items.Clear;
  with ComboBox1.items do
  begin
    add(rsIdle);
    add(rsLowest);
    add(rsLower);
    add(rsNormal);
    add(rsHigher);
    add(rsHighest);
    add(rsTimeCritical);
  end;

  ComboBox1.itemindex:=3;


  pssettings.ActivePage:=PSReverse;
  clientheight:=cbMustEndWithSpecificOffset.top+cbMustEndWithSpecificOffset.Height+2+panel1.height;

  iplist:=TStringList.create;
  //load the ip list (if there is one)

  reg:=tregistry.create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Cheat Engine',false) then
    begin
      if reg.ValueExists('Worker IP List') then
        iplist.Text:=reg.ReadString('Worker IP List');
    end;

  finally
    reg.free;
  end;

end;

procedure tfrmPointerScannerSettings.btnAddClick(sender: TObject);
var offsetentry: TOffsetEntry;
begin
  offsetentry:=TOffsetEntry.Create(self);
  offsetlist.Add(offsetentry);
    
  with offsetentry do
  begin
    offsetentry.Name:='edtOffset'+inttostr(offsetlist.Count);
    top:=panel1.top;
    left:=cbMustEndWithSpecificOffset.left+15;
    self.Height:=self.Height+height+2;
    parent:=self;
  end;

  if offsetlist.count=2 then
  begin
    lblInfoLastOffset.visible:=true;
    lblInfoLastOffset.top:=TOffsetEntry(offsetlist[0]).Top+4;
  end;

  btnAddOffset.top:=offsetentry.top;
  btnRemoveOffset.top:=btnAddOffset.top;
end;

procedure tfrmPointerScannerSettings.btnRemoveClick(sender: TObject);
begin
  offsetlist.delete(offsetlist.count-1);
  if offsetlist.count>0 then
  begin
    btnAddOffset.top:=TOffsetEntry(offsetlist[offsetlist.count-1]).top;
    btnRemoveOffset.top:=btnAddOffset.top;
    self.Height:=btnAddOffset.top+btnAddOffset.Height+2+panel1.height;

    if offsetlist.count=1 then lblInfoLastOffset.visible:=false;

  end
  else
  begin
    cbMustEndWithSpecificOffset.checked:=false;
  end;
end;


procedure TfrmPointerScannerSettings.cbMustEndWithSpecificOffsetClick(Sender: TObject);
begin

end;

procedure TfrmPointerScannerSettings.cbUseHeapDataClick(Sender: TObject);
begin
  cbHeapOnly.Enabled:=cbUseHeapData.Checked;
  if (frmMemoryAllocHandler<>nil) and (frmMemoryAllocHandler.hookedprocessid<>processid) then
    freeandnil(frmMemoryAllocHandler);

  frmMemoryAllocHandler:=TfrmMemoryAllocHandler.Create(memorybrowser);
  frmMemoryAllocHandler.WaitForInitializationToFinish;

  edtAddressChange(edtAddress);
end;

procedure TfrmPointerScannerSettings.Panel1Click(Sender: TObject);
begin

end;

procedure TfrmPointerScannerSettings.rbFindValueClick(Sender: TObject);
begin
  if rbFindAddress.Checked then
  begin
    edtAddress.Width:=cbValueType.Left+cbValueType.Width-edtAddress.Left;
    cbValueType.Visible:=false;

  end
  else
  begin
    edtAddress.Width:=cbValueType.left-edtAddress.Left-3;
    cbValueType.Visible:=true;

  end;
  edtAddress.SetFocus;
end;

procedure TfrmPointerScannerSettings.edtAddressChange(Sender: TObject);
var haserror: boolean;
begin
  automaticaddress:=symhandler.getAddressFromName(edtAddress.text, false,haserror); //ignore error


  if cbHeapOnly.Checked then
  begin
   if (frmMemoryAllocHandler.FindAddress(@frmMemoryAllocHandler.HeapBaselevel, automaticaddress)<>nil) then
     edtAddress.Font.Color:=clGreen
   else
     edtAddress.Font.Color:=clRed; //BAD
  end else edtAddress.Font.Color:=clWindowText;

end;

procedure TfrmPointerScannerSettings.cbHeapOnlyClick(Sender: TObject);
begin
  edtAddressChange(edtAddress);
end;

procedure TfrmPointerScannerSettings.UpdateFindValueState;
begin
  //make rbFindValue enabled or disabled based on the current settings

  rbFindValue.enabled:=not (cbReusePointermap.checked or cbUseLoadedPointermap.checked or cbCompareToOtherPointermaps.checked);

  if rbFindValue.enabled=false then
    rbFindAddress.Checked:=true;

end;

procedure TfrmPointerScannerSettings.updatepositions;
var
  i: integer;
  adjustment: integer;
begin
  if pdatafilelist<>nil then
    cbMustStartWithBase.top:=pdatafilelist.top+pdatafilelist.Height+2
  else
    cbMustStartWithBase.top:=cbCompareToOtherPointermaps.top+cbCompareToOtherPointermaps.height+3;

  if edtBaseFrom<>nil then
  begin
    edtBaseFrom.Top:=cbMustStartWithBase.top+cbMustStartWithBase.height+3;
    edtBaseTo.top:=edtBaseFrom.top+edtbasefrom.height+1;
    lblbasefrom.top:=edtbasefrom.top+(edtbasefrom.height div 2) - (lblbasefrom.height div 2);
    lblBaseTo.top:=edtbaseto.top+(edtbaseto.height div 2) - (lblBaseTo.height div 2);
  end;

  adjustment:=cbMustEndWithSpecificOffset.Top;
  if edtBaseFrom<>nil then
    cbMustEndWithSpecificOffset.Top:=edtBaseTo.top+edtBaseTo.Height+2
  else
    cbMustEndWithSpecificOffset.Top:=cbMustStartWithBase.top+cbMustStartWithBase.height+2; //(cbMustStartWithBase.top-cbCompareToOtherPointermaps.top); //same difference

  adjustment:=cbMustEndWithSpecificOffset.Top-adjustment;

  if adjustment<>0 then
  begin
    if offsetlist<>nil then
    begin
      //update the TOffsetEntry's
      if offsetlist.Count>0 then
      begin
        taborder:=cbMustEndWithSpecificOffset.TabOrder;
        for i:=0 to offsetlist.Count-1 do
        begin
          if (offsetlist[i] is TOffsetEntry) then //should be true
          begin
            TOffsetEntry(offsetlist[i]).Top:=TOffsetEntry(offsetlist[i]).Top+adjustment;
            TOffsetEntry(offsetlist[i]).TabOrder:=taborder;
          end;
        end;

        if offsetlist.count>1 then lblInfoLastOffset.top:=TOffsetEntry(offsetlist[0]).Top+4;

        btnAddOffset.top:=TOffsetEntry(offsetlist[offsetlist.Count-1]).Top;
        btnRemoveOffset.top:=btnAddOffset.top;
      end;

      clientheight:=btnAddOffset.top+btnAddOffset.Height+2+panel1.height;
    end
    else
      clientheight:=cbMustEndWithSpecificOffset.top+cbMustEndWithSpecificOffset.Height+2+panel1.height;

  end;
end;

initialization
  {$i PointerscannerSettingsFrm.lrs}

end.





