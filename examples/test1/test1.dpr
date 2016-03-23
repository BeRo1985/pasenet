program test1;
{$ifdef fpc}
{$mode delphi}
{$endif}
{$apptype console}

uses {$ifdef Unix}cthreads,{$endif}SysUtils,Classes,SyncObjs,PasENet in '..\..\src\PasENet.pas',PasENetWinSock2 in '..\..\src\PasENetWinSock2.pas';

var address:TENetAddress;
    server,client:PENetHost;
    event:TENetEvent;
begin
 if enet_initialize=0 then begin
  try
   address.host:=ENET_HOST_ANY;
   address.port:=1234;
   server:=enet_host_create(@address,32,2,0,0);
   if assigned(server) then begin
    try
     client:=nil;
     while enet_host_service(server,@event,10000)>0 do begin
      case event.type_ of
       ENET_EVENT_TYPE_CONNECT:begin
        writeln('A new client connected');
       end;
       ENET_EVENT_TYPE_DISCONNECT:begin
        writeln('A client disconnected');
       end;
       ENET_EVENT_TYPE_RECEIVE:begin
        writeln('A packet received');
        enet_packet_destroy(event.packet);
       end;
      end;
     end;
    finally
     enet_host_destroy(server);
    end;
   end;
  finally
   enet_deinitialize;
  end;
 end;
 readln;
end.