program QuickEditABC;

uses
  Vcl.Forms,
  QuickEdit in '..\QuickEdit\QuickEdit.pas' {QE},
  QEMain in 'QEMain.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TQE, QE);
  Application.Run;
end.
