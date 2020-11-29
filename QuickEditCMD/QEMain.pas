unit QEMain;


interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.StdCtrls,StrUtils, shellapi;

type
  QEClass = class (TObject)
  private
    procedure FindExclude( workspace : string; i:integer; Shab: TStringList; iscl: string; FindFile: TSearchRec;FindAll: TSearchRec); //����� ����������
    procedure CreateD(dir: string); // �������� ����� ����� � �����������
    procedure FindFiles(workspace: string; dir: string; Rasch: TStringList; Folders: TStringList; Shab: TStringList;  iscl: string);   // ����� �����
    procedure Change(global: integer;workspace: string;i:integer; dir: string; Folders: TStringList; Shab: TStringList;  iscl: string;FindFile: TSearchRec;FindAll: TSearchRec);//�������� �����, ��� ��� ��������
//    procedure Create(); //�����������
  public
    procedure CreateResult(PathDirShab: string;PathDirSource:string;PathDirResult:string); // �����

  end;

//var
//var
 // //QE: T//QE;
  //workspace: string; //���� � ������
 // i,global: integer; //������� �������� ������ � global ��� ��������� �� ������
 // i:integer;
  //f,f2:TFileStream;  //����
  //FindFile: TSearchRec;//����� ������� �����
  //dir: string;// ����� �����
  //iscl: string ; //����������
 // Rasch: TStringList;// ������ � ������������
  //Folders: TStringList;// ������ � �������
  //FindAll: TSearchRec;//����� ���� �����
  //Shab: TStringList; //������

implementation
procedure QEClass.FindExclude(workspace: string;i:integer; Shab: TStringList; iscl: string; FindFile: TSearchRec; FindAll: TSearchRec); //����� ����������
var
  NewName: String;// ����� ��� �����
  text,iscl1,iscl2:string;
  buf:AnsiChar;
  endEx,startEx,k,kk:integer;
  Arr : array of Integer;
  f,f2:TFileStream;
begin
    try
        f:=TFileStream.Create(workspace +'\'+FindFile.Name, fmOpenRead);   // ���������� �����
     //   f2:=TFileStream.Create(dir +'\'+NewName, fmCreate);   // ���������� �����
    except
       // ShowMessage('������ � FindIscl '+inttostr(i)+' �����');
       // //QE.Log.Lines.Add ('������ � FindIscl '+ inttostr(i)+' �����');
    end;
    try
       k:=0;//�������
       f.Seek(0,soFromBeginning);
       repeat
         f.Read(buf,sizeof(buf));        //������
         text:=text+buf;
       until f.Position=f.Size ;
       endEx:=Pos('contains',text); //������� ��������� requires
       startEx:=Pos( 'requires',text);// � ��� ������
       if (Pos('requires',text)<>0)  then
       begin
           iscl1:= text;  // ����� ��� ����� �� requires
           Delete(iscl1,endEx,text.Length);
           Delete(iscl1,1,startEx+8);
           endEx:=0;
           startEx:=-1;
           while startEx<>0 do
           begin
             startEx:=PosEx(',',iscl1,startEx+2);  //������� ��� �������
             if startEx<>0 then
             begin
                 inc(endEx);
                 setlength(arr,endEx);
                 arr[endEx-1]:=startEx;
             end;
           end;
           startEx:=PosEx(';',iscl1,startEx+2);
           if startEx<>0 then
           begin
             inc(endEx);
             setlength(arr,endEx);
             arr[endEx-1]:=startEx;
           end;
           startEx:=-1;
           k:=0;
           while startEx<>0 do
           begin
             startEx:=PosEx(shab[0],iscl1,startEx+2);  //������� ��� �������
             if startEx<>0 then
             for k:=0 to endEx-1 do
             begin
               if (arr[k-1]<=startEx) and(arr[k]>=startEx) then
               iscl:=iscl+' '+copy(iscl1,arr[k-1],arr[k]-arr[k-1]+1);
             end;
           end;

       end;
       // //QE.Memo1.Lines.Add ('���������� '+iscl1);
      // //QE.Log.Lines.Add ('���������� '+iscl);
    except
       // ShowMessage('������ � ������ ���������� '+inttostr(i)+' �����');
      //  //QE.Log.Lines.Add ('������ � ������ ����������'+inttostr(i)+' �����');
    end;
    f.Free;
end;

procedure QEClass.Change(global: integer;workspace: string;i:integer; dir: string; Folders: TStringList; Shab: TStringList; iscl: string; FindFile: TSearchRec;FindAll: TSearchRec ); //������ � ��������� �����
var
NewName: String;// ����� ��� �����
text,iscl2:string;
buf:AnsiChar;
BeforeChange: TStringList; //��� ����������� ���������� �� �����
AfterChange: TStringList;
j,l,k,kk,ll:integer;
Arr : array of Integer;
Arr2 : array of Integer; //������� ����������
f,f2:TFileStream;

begin

    if (Pos(shab[0],FindFile.Name) <> 0 )then
    begin
      NewName:=FindFile.Name;
    //  //QE.Memo1.Lines.Add ('NewName �� ������  '+NewName);
      NewName:= StringReplace(NewName,shab[0],shab[1],  [rfReplaceAll, rfIgnoreCase]);
     // //QE.Log.Lines.Add ('NewName ����� ������  '+NewName);
    end else    NewName:=FindFile.Name;

    try
        f:=TFileStream.Create(workspace +Folders[global] +'\'+FindFile.Name, fmOpenRead);   // ���������� �����
        f2:=TFileStream.Create(dir+ Folders[global] + '\'+NewName, fmCreate);   // ���������� �����
    except
        //ShowMessage('������ � Change 2'+inttostr(i)+' �����');
        //QE.Log.Lines.Add ('������ � Change 2'+ inttostr(i)+' �����');
    end;
    try
        f.Seek(0,soFromBeginning);
        repeat
          f.Read(buf,sizeof(buf));        //������
          text:=text+buf;
        until f.Position=f.Size;
        text:= StringReplace(text,shab[0],shab[1],[rfReplaceAll,rfIgnoreCase]);    //������ �� �������
        BeforeChange:=TStringList.Create;
        AfterChange:=TStringList.Create;
        BeforeChange.Delimiter := ' ' ;
        AfterChange.Delimiter := ' ' ;
        BeforeChange.DelimitedText := iscl ;
        iscl:= StringReplace(iscl,shab[0],shab[1],[rfReplaceAll,rfIgnoreCase]);
        AfterChange.DelimitedText := iscl ;
        for j:=0 to AfterChange.Count-1 do
          text:= StringReplace(text,AfterChange[j],BeforeChange[j],[rfReplaceAll,rfIgnoreCase]);// ��������� ���������� �� �����
        //    showmessage (text);
        f2.Seek(0,soFromBeginning);
        for j :=0 to text.length do
          f2.Write(text[j],sizeof(ansichar))   ;
        //QE.Log.Lines.Add ('�������� ������ '+inttostr(i));

    except
       // ShowMessage('������ � ������ '+inttostr(i)+' �����');
        //QE.Log.Lines.Add ('������ � ������ '+inttostr(i)+' �����');

    end;
    f2.Free;
    f.Free;
end;

procedure  QEClass.CreateD(dir: string);   // �������� ����� ����� � ����������� �������
begin

    try
      if(CreateDir(dir)) then
      //QE.Log.Lines.Add ('���������� ������� '+ dir)
      else
      begin
         //QE.Log.Lines.Add ('������ � �������� ���������� '+ dir);
        // showmessage('������ � �������� ���������� '+ dir);
         abort;
      end;
    except
      //QE.Log.Lines.Add ('������ � �������� ���������� '+ dir);
     // showmessage('������ � �������� ���������� '+ dir);
      abort;
    end;

end;

 procedure QEClass.FindFiles(workspace: string;dir: string; Rasch: TStringList; Folders: TStringList; Shab: TStringList;  iscl: string);   // ����� �����
 var
 global, i, j,kk,l,ll: integer;
 FindFile: TSearchRec;
 FindAll: TSearchRec;
begin
    CreateD(dir);
    i:=0;
    l:=1;
    try           // ����� ��������
      FindFirst(workspace + '\*',faDirectory ,FindFile);
      if (FindFile.Attr and faDirectory) <> 0 then  // ���� ��������� ���� - �����
      begin
        if ((FindFile.Name <>ExtractFileName(dir)) and (FindFile.Name <>'QE') ) then
          if (FindFile.Name <> '.') and (FindFile.Name <> '..') then  // ������������ ��������� �����
          begin
            Folders.Add('\'+FindFile.Name);
            CreateDir(dir+'\'+FindFile.Name);
            inc(l);
          end;
      end;

      while FindNext(FindFile)=0 do
      begin
        if (FindFile.Attr and faDirectory) <> 0 then  // ���� ��������� ���� - �����
        begin
          if ((FindFile.Name <>ExtractFileName(dir)) and (FindFile.Name <>'QE') ) then
            if (FindFile.Name <> '.') and (FindFile.Name <> '..') then  // ������������ ��������� �����
            begin
              Folders.Add('\'+FindFile.Name);
              CreateDir(dir+'\'+FindFile.Name);
              inc(l);
            end;
        end;

      end;
      FindClose(FindFile);
    except
    //  ShowMessage('������ � ������ �����');
      //QE.Log.Lines.Add ('������ � ������ �����');
    end;
    FindClose(FindFile);
    ll:=0;
    for kk:=0 to Folders.Count-1 do
    begin
      try
        FindFirst(workspace + Folders[kk]+'\*',faAnyFile,FindAll);
        if (FindAll.Name <> '.') and (FindAll.Name <> '..') then
           for j:=0 to Rasch.Count-1 do // �� ���������� ����� � ������� ������������
           begin
              if ('*'+ExtractFileExt(workspace + Folders[kk]+FindAll.Name )= Rasch[j]) or (ExtractFileExt(workspace + Folders[kk]+FindAll.Name )='.dpk')  then
                inc(ll);
           end;
           if ll=0 then
             CopyFile(PWideChar(workspace+ Folders[kk] + '\'+ FindAll.Name), PWideChar(dir+Folders[kk] +'\'+FindAll.Name), false);
        ll:=0;
      // kk:=0;
      while FindNext(FindALL)=0 do
        begin
        // inc(kk);
          if (FindAll.Name <> '.') and (FindAll.Name <> '..') then
            for j:=0 to Rasch.Count-1 do // �� ���������� ����� � ������� ������������
            begin
              if ('*'+ExtractFileExt(workspace + Folders[kk]+FindAll.Name )= Rasch[j]) or (ExtractFileExt(workspace + Folders[kk]+FindAll.Name )='.dpk') then
                inc(ll);
            end;
          if ll=0 then
            CopyFile(PWideChar(workspace+ Folders[kk] + '\'+ FindAll.Name), PWideChar(dir+Folders[kk] +'\'+FindAll.Name), false);
          ll:=0;
        // CopyFile(PWideChar(workspace + Folders[kk]+'\'+ FindAll.Name), PWideChar(dir+Folders[kk] +'\'+FindAll.Name), false);
        end;
        //   end;
        FindClose(FindAll);
      except
          //QE.Log.Lines.Add ('������ �����������'+inttostr(i)+' '+FindFile.Name);
      end;
    end;
    try           // ����� ����������
      FindFirst(workspace + '\*.dpk',faAnyFile,FindFile);
      inc(i);
      if FindFile.Name = '' then
        begin
          //QE.Log.Lines.Add ('dpk �� ������ ');        //�������� �� ����� ��� �������
          iscl:='';
        end else
        begin
          //QE.Log.Lines.Add ('������ dpk #'+inttostr(i)+' '+FindFile.Name);
          FindExclude(workspace, i, Shab, iscl, FindFile, FindAll);
          FindFile.Name:='' ;
        end;
    except
      //ShowMessage('������ � ������ ������� �����');
      //QE.Log.Lines.Add ('������ � ������ ������� �����');
    end;
    for global:=0 to Folders.Count-1 do
      for j:=0 to Rasch.Count-1 do
      begin
        try
          FindFirst(workspace + Folders[global] +'\*'+Rasch[j],faAnyFile,FindFile);
          inc(i);
          if FindFile.Name = '' then
          begin
            //QE.Log.Lines.Add ('������ �� ������� ');        //�������� �� ����� ��� �������
            // exit;
          end else
          begin
          //QE.Log.Lines.Add ('������ ���� #'+inttostr(i)+' '+FindFile.Name);
            Change(global, workspace, i, dir, Folders, Shab, iscl, FindFile, FindAll);
          end;

        except
          //ShowMessage('������ � ������ ������� �����');
          //QE.Log.Lines.Add ('������ � ������ ������� �����');
        end;

        try
          while FindNext(FindFile)=0 do
          begin
            inc(i);
            //QE.Log.Lines.Add ('������ ���� #'+inttostr(i)+' '+FindFile.Name);
            Change(global, workspace, i, dir, Folders, Shab, iscl,  FindFile, FindAll);
          end;
        except
          //  ShowMessage('������ � ������ '+ inttostr(i) +' �����');
          //QE.Log.Lines.Add ('������ � ������ '+ inttostr(i) +' �����');
        end;
    end;
    //QE.Log.Lines.Add ('����� ������� ������ '+ inttostr(i)); //��������� �����, ������� �� ������ � ����� �����
    //for kk:=0 to Folders.Count-1 do
    //   begin
    FindClose(FindFile);
end;

procedure QEClass.CreateResult(PathDirShab: string;PathDirSource:string;PathDirResult:string);
var
text:string;
buf:AnsiChar;
workspace: string;
f:TFileStream;
dir: string;
Rasch: TStringList;
Folders: TStringList;
Shab: TStringList;
iscl: string;
begin
   workspace:=PathDirShab;
  // Create;
   Rasch:= TStringList.Create;
   Rasch.Add('*.pas');
   Rasch.Add('*.dcu');
   Rasch.Add('*.pas');
   Rasch.Add('*.dfm');
   Rasch.Add('*.dproj');
   Rasch.Add('*.lng');
   Rasch.Add('*.rc');
   Shab:= TStringList.Create;
   Shab.Delimiter := ' ' ;
   Folders:= TStringList.Create;
   Folders.Add('');
   try
        if DirectoryExists(workspace) then
        f:=TFileStream.Create(workspace +'\QE.txt', fmOpenRead)
        else
        begin
          // ShowMessage('������ � ���� � ������� ');
           //QE.Log.Lines.Add ('������ � ���� � �������');
           abort;
        end
   except
        //ShowMessage('������ � ������ ');
        //QE.Log.Lines.Add ('������ � ������ ');
   end;
   try
     f.Seek(0,soFromBeginning);
     repeat
       f.Read(buf,sizeof(buf));        //������
       text:=text+buf;
     until f.Position=f.Size ;
   except
     //QE.Log.Lines.Add ('������ � ������ ');
   end;
   workspace:=PathDirSource;
   if not DirectoryExists(workspace) then
   begin
     // ShowMessage('������ � ���� � ��������� ');
     //QE.Log.Lines.Add ('������ � ���� � ���������');
     abort;
   end ;
   shab.DelimitedText := text ;// ������
   f.Free;
   //  if PathDirResult.Text='' then
   // dir:=workspace+'\QE'
   //else
   dir:= PathDirResult ;
   FindFiles(workspace, dir, rasch, Folders, Shab, iscl);
   // OpenResult.Visible:=true;
   // OpenResult.Enabled:=true;
end;

//procedure  QEClass.Create();
//var
//workspace: string;
//text:string;
//buf:AnsiChar;

//begin
   //i:=0;
    //Log.Text:='';
  //Shab:= TStringList.Create;
  //Shab.Delimiter := ' ' ;

 // Folders:= TStringList.Create;
  //Folders.Add('');

   // if ParamStr(1)='/?' then showhelp;
   { If ParamStr(1) <> '' then
    begin

       workspace:=Paramstr(2);
       try
         if DirectoryExists(workspace) then
           f:=TFileStream.Create(workspace +'\//QE.txt', fmOpenRead)
         else
         begin
          // ShowMessage('������ � ���� � ������� ');
           ShowHelp;
         end
       except
         //ShowMessage('������ � ������ ');
         //QE.Log.Lines.Add ('������ � ������ ');
       end;
       try
         f.Seek(0,soFromBeginning);
         repeat
           f.Read(buf,sizeof(buf));        //������
           text:=text+buf;
         until f.Position=f.Size ;
       except
         //QE.Log.Lines.Add ('������ � ������ ');
       end;
       workspace:=Paramstr(1);
       if not DirectoryExists(workspace) then
       begin
          // ShowMessage('������ � ���� � ��������� ');
           Showhelp;
       end ;
       shab.DelimitedText := text ;// ������
       f.Free;
       dir:=ParamStr(3);
       FindFiles(workspace);

    end
    else
      //QE.Visible:=false    }

//end;

end.

