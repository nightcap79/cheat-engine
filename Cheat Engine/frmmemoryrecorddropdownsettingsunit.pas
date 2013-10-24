unit FrmMemoryRecordDropdownSettingsUnit;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, MemoryRecordUnit;

type

  { TFrmMemoryRecordDropdownSettings }

  TFrmMemoryRecordDropdownSettings = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    cbDisallowUserInput: TCheckBox;
    cbOnlyShowDescription: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    memoDropdownItems: TMemo;
    Panel1: TPanel;
    procedure btnOkClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    { private declarations }
    memrec: TMemoryrecord;
  public
    { public declarations }
    constructor create(memrec: TMemoryrecord);
  end;

implementation

{$R *.lfm}

{ TFrmMemoryRecordDropdownSettings }

procedure TFrmMemoryRecordDropdownSettings.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  CloseAction:=cafree;
end;

procedure TFrmMemoryRecordDropdownSettings.btnOkClick(Sender: TObject);
begin
  memrec.DropDownList.Assign(memoDropdownItems.Lines);
  memrec.DropDownReadOnly:=cbDisallowUserInput.checked;
  memrec.DropDownDescriptionOnly:=cbOnlyShowDescription.checked;

  modalresult:=mrok;
end;

constructor TFrmMemoryRecordDropdownSettings.create(memrec: TMemoryrecord);
begin
  inherited create(Application);

  self.memrec:=memrec;
  if memrec.DropDownList<>nil then
    memoDropdownItems.Lines.AddStrings(memrec.DropDownList);

  cbDisallowUserInput.checked:=memrec.DropDownReadOnly;
  cbOnlyShowDescription.checked:=memrec.DropDownDescriptionOnly;

  caption:='Dropdown options for '+memrec.description;
end;

end.

