program backend;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  System.SysUtils,
  System.JSON,
  Horse.Jhonson,
  Horse.Commons;

 var
    Users: TJsonArray;
    User: TJSONObject;

begin
    Users:= TJsonArray.Create;

    {Criando JSON Objeto}
    User := TJSONObject.Create;
    User.AddPair('Id', TJSONNumber.Create(1));
    User.AddPair('Nome', 'Caique');
    User.AddPair('Idade', TJSONNumber.Create(29));
    Users.AddElement(User);


    {Usando Midleware para utilização de JSON}
    THorse.Use(Jhonson());

    {End Point Ping}
   THorse.Get('/users',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      //Res.Send('Funcionado!!!');
      Res.Send<TJSONAncestor>(Users.Clone);
    end);

   THorse.Post('/users',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      {Recebendo TJSONObject}
      User := Req.Body<TJSONObject>.Clone as TJSONObject;
      Users.AddElement(User);
      Res.Send<TJSONAncestor>(User.Clone).Status(THTTPStatus.Created); {Retornando status de Criação}
    end);

    THorse.Delete('/users/:id',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
    id: Integer;
    begin
      {Recebendo Paramentro ID}
      ID := Req.Params.Items['id'].ToInteger;
      Users.Remove(ID).Free;
      Res.Send<TJSONAncestor>(Users.Clone).Status(THTTPStatus.NoContent); {Retornando status de Criação}
    end);

  THorse.Listen(9000,
    procedure(Horse: THorse)
    begin
      Writeln(Format('Server is runing on %s:%d', [Horse.Host, Horse.Port]));
    end);
end.
