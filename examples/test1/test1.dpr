program test1;
{$ifdef fpc}
{$mode delphi}
{$endif}
{$apptype console}

uses {$ifdef Unix}cthreads,{$endif}
     SysUtils,
     Classes,
     SyncObjs,
     PasENet in '..\..\src\PasENet.pas',
     PasENetWinSock2 in '..\..\src\PasENetWinSock2.pas';

type TServer=class(TThread)
      protected
       procedure Execute; override;
     end;

     TClient=class(TThread)
      protected
       procedure Execute; override;
     end;

procedure TServer.Execute;
var address:TENetAddress;
    server,client:PENetHost;
    event:TENetEvent;
    packet:PENetPacket;
begin
 if ParamCount>0 then begin
  address.host:=ENET_HOST_ANY;
 end else begin
  enet_address_set_host(@address,PAnsiChar('127.0.0.1'));
 end;
 address.port:=64242;
 server:=enet_host_create(@address,32,2,0,0);
 if assigned(server) then begin
  try
   client:=nil;
   while (not Terminated) and (enet_host_service(server,@event,1000)>=0) do begin
    case event.type_ of
     ENET_EVENT_TYPE_NONE:begin
      //writeln('Server: Nothing');
     end;
     ENET_EVENT_TYPE_CONNECT:begin
      writeln('Server: A new client connected');
      packet:=enet_packet_create('Hello world!',ENET_PACKET_FLAG_RELIABLE);
      enet_peer_send(event.peer,0,packet);
      enet_host_flush(server);
     end;
     ENET_EVENT_TYPE_DISCONNECT:begin
      writeln('Server: A client disconnected');
     end;
     ENET_EVENT_TYPE_RECEIVE:begin
      writeln('Server: A packet received');
      enet_packet_destroy(event.packet);
     end;
    end;
   end;
  finally
   enet_host_destroy(server);
  end;
 end;
end;

procedure TClient.Execute;
var address:TENetAddress;
    server,client:PENetHost;
    event:TENetEvent;
    peer:PENetPeer;
    Disconnected:boolean;
begin
 client:=enet_host_create(nil,1,2,57600 shr 3,14400 shr 3);
 if assigned(client) then begin
  try
   if ParamCount>1 then begin
    enet_address_set_host(@address,PAnsiChar(AnsiString(ParamStr(2))));
   end else begin
    enet_address_set_host(@address,PAnsiChar('127.0.0.1'));
   end;
   address.port:=64242;
   peer:=enet_host_connect(client,@address,2,0);
   if assigned(peer) then begin
    try
     if (enet_host_service(client,@event,5000)>=0) and
        (event.type_=ENET_EVENT_TYPE_CONNECT) then begin
      writeln('Connected');
      Disconnected:=false;
      while (not Terminated) and (enet_host_service(client,@event,1000)>=0) do begin
       case event.type_ of
        ENET_EVENT_TYPE_NONE:begin
         //writeln('Client: Nothing');
        end;
        ENET_EVENT_TYPE_CONNECT:begin
         writeln('Client: Connected');
        end;
        ENET_EVENT_TYPE_DISCONNECT:begin
         writeln('Client: Disconnected');
         Disconnected:=true;
        end;
        ENET_EVENT_TYPE_RECEIVE:begin
         writeln('Client: A packet received');
         writeln(copy(event.packet^.data,0,event.packet^.datalength));
         enet_packet_destroy(event.packet);
        end;
       end;
      end;
      if not Disconnected then begin
       writeln('Client: Disconnecting');
       enet_peer_disconnect(peer,0);
       while enet_host_service(client,@event,3000)>=0 do begin
        case event.type_ of
         ENET_EVENT_TYPE_RECEIVE:begin
          enet_packet_destroy(event.packet);
         end;
         ENET_EVENT_TYPE_DISCONNECT:begin
          writeln('Client: Disconnected');
          break;
         end;
        end;
       end;
      end;
     end else begin
      writeln('Connection failed');
     end;
    finally
     enet_peer_reset(peer);
    end;
   end;
  finally
   enet_host_destroy(client);
  end;
 end;
end;

var Server:TServer;
    Client:TClient;
    s:string;
begin
 s:=ParamStr(1);
 if enet_initialize=0 then begin
  try
   if s='server' then begin
    Server:=TServer.Create(false);
    try
     readln;
    finally
     Server.Terminate;
     Server.WaitFor;
     Server.Free;
    end;
   end else if s='client' then begin
    Client:=TClient.Create(false);
    try
     readln;
    finally
     Client.Terminate;
     Client.WaitFor;
     Client.Free;
    end;
   end else begin
    Server:=TServer.Create(false);
    try
     Client:=TClient.Create(false);
     try
      readln;
     finally
      Client.Terminate;
      Client.WaitFor;
      Client.Free;
     end;
    finally
     Server.Terminate;
     Server.WaitFor;
     Server.Free;
    end;
   end;
  finally
   enet_deinitialize;
  end;
 end;
end.
