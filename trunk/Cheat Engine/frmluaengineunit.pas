unit frmLuaEngineUnit;

{$mode delphi}

interface

uses
  windows, Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Menus, ExtCtrls, SynMemo, SynCompletion, SynEdit, lua,
  lauxlib, lualib, LuaSyntax, luahandler, cefuncproc, strutils;

type

  { TfrmLuaEngine }

  TfrmLuaEngine = class(TForm)
    btnExecute: TButton;
    GroupBox1: TGroupBox;
    MainMenu1: TMainMenu;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    miView: TMenuItem;
    cbShowOnPrint: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    mOutput: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    pmEditor: TPopupMenu;
    dlgReplace: TReplaceDialog;
    SaveDialog1: TSaveDialog;
    Splitter1: TSplitter;
    mScript: TSynEdit;
    procedure btnExecuteClick(Sender: TObject);
    procedure dlgReplaceFind(Sender: TObject);
    procedure dlgReplaceReplace(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem11Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
    procedure mScriptKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure Panel2Resize(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    synhighlighter: TSynLuaSyn;
  end; 

var
  frmLuaEngine: TfrmLuaEngine;

implementation

{ TfrmLuaEngine }

uses luaclass;


resourcestring
  rsError = 'Script Error';

procedure TfrmLuaEngine.Panel2Resize(Sender: TObject);
begin
  btnexecute.Height:=panel2.clientheight-(2*btnexecute.top);
end;

function onerror(L: PLua_State): integer; cdecl;
var ld: lua_Debug;
  frm: TfrmLuaEngine;
  r: integer;
  t: integer;
begin
  //todo: Try to get this to work (might be a lua bug)
  {

  result:=0;
  frm:=luaclass_getClassObject(L);


  t:=lua_gettop(L);

  ZeroMemory(@ld, sizeof(ld));


  r:=lua_getstack(L, 1, @ld);
  if r=1 then
  begin
    lua_getinfo(L, '>l', @ld);
    lua_pushstring(L, 'Error in line '+inttostr(ld.currentline));
  end
  else
    lua_pushstring(L, 'Undefined error');
             }
  result:=1;


end;

procedure TfrmLuaEngine.btnExecuteClick(Sender: TObject);
var pc: pchar;
  i,j: integer;

  oldprintoutput: Tstrings;
  c: tobject;

  err: integer;
begin
  luacs.Enter;
  oldprintoutput:=lua_oldprintoutput;
  try
    mOutput.lines.add(mscript.text);


    lua_setPrintOutput(mOutput.lines);

    i:=0;
{    luaclass_newClass(Luavm, self);
    lua_pushcclosure(Luavm, onerror,1);
    err:=lua_gettop(Luavm);

    if luaL_loadstring(Luavm, pchar(mScript.text))=0 then
      i := lua_pcall(Luavm, 0, LUA_MULTRET, err);

     lua_remove(luavm, err); }


    if lua_dostring(Luavm, pchar(mScript.text))=0 then
    begin


      j:=lua_gettop(luavm);
      if j>0 then
      begin
        for i:=-j to -1 do
        begin
          pc:=lua_tolstring(luavm, i,nil);
          if pc<>nil then
            mOutput.lines.add(':'+pc)
          else
          begin
            if lua_islightuserdata(luavm,i) then //shouldn't occur anymore
              moutput.lines.add(':p->'+inttohex(ptruint(lua_touserdata(luavm,i)),1))
            else
            if lua_isboolean(luavm,i) then
              moutput.lines.add(':(boolean)'+BoolToStr(lua_toboolean(Luavm, i),'true','false'))
            else
            if lua_isnil(luavm,i) then
              moutput.lines.add(':'+'nil')
            else
            if lua_istable(luavm, i) then
              moutput.lines.add(':'+'table')
            else
            if lua_isfunction(luavm,i) then
              moutput.lines.add(':'+'function')
            else
            if lua_isuserdata(luavm,i) then
            begin
              try
                c:=lua_ToCEUserData(luavm, i);
                moutput.lines.add(':'+'class object ('+c.ClassName+')')
              except
                moutput.lines.add(':'+'class object (corrupt)')
              end;
            end
            else
              moutput.lines.add(':'+'unknown')

          end;
        end;

        lua_pop(luavm, lua_gettop(luavm)); //balance the stack
      end;
    end
    else
    begin
      i:=lua_gettop(luavm);
      if i>0 then
      begin

        //is currently shown inside the pcall function
        pc:=lua_tolstring(luavm, -1,nil);
        if pc<>nil then
          mOutput.lines.add(rsError+':'+pc)
        else
          moutput.lines.add(rsError+':'+'nil');

        lua_pop(luavm, i);
      end else moutput.lines.add(rsError);

    end;
  finally
    lua_setPrintOutput(oldprintoutput);
    luacs.Leave;
  end;
end;

procedure TfrmLuaEngine.dlgReplaceFind(Sender: TObject);
var
  s: string;
  i: integer;
begin
  //find
  s:=dlgReplace.FindText;

  i:=PosEx(s, mscript.Text, mscript.selstart+1);

  if i>0 then
  begin
    mScript.SelStart:=i;
    mscript.SelEnd:=i+length(s);
  end
  else
    beep;//weeeeee
end;

procedure TfrmLuaEngine.dlgReplaceReplace(Sender: TObject);
var oldselstart: integer;
begin
  //replace
  repeat
    oldselstart:=mScript.SelStart;
    dlgReplaceFind(sender);
    if oldselstart=mScript.SelStart then break;  //nothing found


    if mscript.SelEnd>mscript.SelStart then
    begin
      oldselstart:=mScript.SelStart;
      mScript.SelText:=dlgReplace.ReplaceText;
      mscript.selstart:=oldselstart;
      mscript.SelEnd:=oldselstart+length(dlgreplace.replacetext);
    end
    else
      break;
  until (frReplaceAll in dlgReplace.Options=false);

end;

procedure TfrmLuaEngine.FormCreate(Sender: TObject);
var x: array of integer;
begin
  synhighlighter:=TSynLuaSyn.Create(self);
  mscript.Highlighter:=synhighlighter;

  setlength(x,1);
  if LoadFormPosition(self, x) then
    panel1.height:=x[0];
end;

procedure TfrmLuaEngine.FormDestroy(Sender: TObject);
begin
  SaveFormPosition(self, [panel1.height]);
end;

procedure TfrmLuaEngine.MenuItem10Click(Sender: TObject);
begin
  mscript.Undo;
end;

procedure TfrmLuaEngine.MenuItem11Click(Sender: TObject);
var f: TfrmLuaEngine;
begin
  f:=TfrmLuaEngine.create(application);
  f.miView.visible:=false;

  f.show;
end;

procedure TfrmLuaEngine.MenuItem2Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
    mscript.Lines.LoadFromFile(opendialog1.filename);

end;

procedure TfrmLuaEngine.MenuItem3Click(Sender: TObject);
begin
  if savedialog1.execute then
    mscript.lines.SaveToFile(savedialog1.filename);
end;

procedure TfrmLuaEngine.MenuItem5Click(Sender: TObject);
begin
  moutput.Clear;
end;

procedure TfrmLuaEngine.MenuItem6Click(Sender: TObject);
begin
  dlgReplace.Execute;
end;

procedure TfrmLuaEngine.MenuItem7Click(Sender: TObject);
begin
  mscript.CutToClipboard;
end;

procedure TfrmLuaEngine.MenuItem8Click(Sender: TObject);
begin
  mscript.CopyToClipboard;
end;

procedure TfrmLuaEngine.MenuItem9Click(Sender: TObject);
begin
  mscript.PasteFromClipboard;
end;

procedure TfrmLuaEngine.mScriptKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

  if (ssCtrl in shift) and (key=vk_return) then
  begin
    btnExecute.click;
    mScript.ClearAll;
  end;
end;


initialization
  {$I frmluaengineunit.lrs}

end.

