(*
**
** Copyright (c) 2002-2016 Lee Salzman
** Copyright (c) 2013-2016 Benjamin 'BeRo' Rosseaux (Pascal port and IPv6)
**
** Permission is hereby granted, free of charge, to any person obtaining a
** copy of this software and associated documentation files (the "Software"),
** to deal in the Software without restriction, including without limitation
** the rights to use, copy, modify, merge, publish, distribute, sublicense,
** and/or sell copies of the Software, and to permit persons to whom the
** Software is furnished to do so, subject to the following conditions:
**
** The above copyright notice and this permission notice shall be included in
** all copies or substantial portions of the Software.
**
** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
** IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
** FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
** AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
** LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
** FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
** DEALINGS IN THE SOFTWARE.
**
*)
unit PasENet;
{$ifdef fpc}
 {$mode delphi}
{$else}
 {$IFDEF CONDITIONALEXPRESSIONS}
  {$IF CompilerVersion >= 23.0}
   {$WARN IMPLICIT_STRING_CAST_LOSS OFF}
   {$WARN IMPLICIT_STRING_CAST OFF}
   {$WARN SUSPICIOUS_TYPECAST OFF}
  {$ifend}
 {$endif}
{$endif}
{$j+}

interface

uses {$ifdef unix}BaseUnix,Unix,UnixType,Sockets,cnetdb,termio,{$else}Windows,PasENetWinSock2,MMSystem,{$endif}SysUtils,Classes,Math;

type TENETRawByteString={$if declared(RawByteString)}RawByteString{$else}AnsiString{$ifend};

{$ifdef fpc}
 {$undef OldDelphi}
type ENETptruint=ptruint;
     ENETptrint=ptrint;
{$else}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=23.0}
   {$undef OldDelphi}
type ENETqword=uint64;
     ENETptruint=NativeUInt;
     ENETptrint=NativeInt;
  {$else}
   {$define OldDelphi}
  {$ifend}
 {$else}
  {$define OldDelphi}
 {$endif}
{$endif}
{$ifdef OldDelphi}
type ENETqword=int64;
{$ifdef cpu64}
     ENETptruint=qword;
     ENETptrint=int64;
{$else}
    ENETptruint=longword;
    ENETptrint=longint;
{$endif}
{$endif}

const ENET_VERSION_MAJOR=1;
      ENET_VERSION_MINOR=3;
      ENET_VERSION_PATCH=13;

{$ifdef unix}
      INVALID_SOCKET=-1;
{$else}
      INVALID_SOCKET=TSocket(not(0));
{$endif}

      ENET_VERSION=(ENET_VERSION_MAJOR shl 16) or (ENET_VERSION_MINOR shl 8) or ENET_VERSION_PATCH;

      AI_ADDRCONFIG=$0400;

      ENET_PROTOCOL_MINIMUM_MTU=576;
      ENET_PROTOCOL_MAXIMUM_MTU=4096;
      ENET_PROTOCOL_MAXIMUM_PACKET_COMMANDS=32;
      ENET_PROTOCOL_MINIMUM_WINDOW_SIZE=4096;
      ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE=65536;
      ENET_PROTOCOL_MINIMUM_CHANNEL_COUNT=1;
      ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT=255;
      ENET_PROTOCOL_MAXIMUM_PEER_ID=$fff;
      ENET_PROTOCOL_MAXIMUM_PACKET_SIZE=1024*1024*1024;
      ENET_PROTOCOL_MAXIMUM_FRAGMENT_COUNT=1024*1024;

      ENET_BUFFER_MAXIMUM=1+(2*ENET_PROTOCOL_MAXIMUM_PACKET_COMMANDS);

      ENET_PROTOCOL_COMMAND_NONE=0;
      ENET_PROTOCOL_COMMAND_ACKNOWLEDGE=1;
      ENET_PROTOCOL_COMMAND_CONNECT=2;
      ENET_PROTOCOL_COMMAND_VERIFY_CONNECT=3;
      ENET_PROTOCOL_COMMAND_DISCONNECT=4;
      ENET_PROTOCOL_COMMAND_PING=5;
      ENET_PROTOCOL_COMMAND_SEND_RELIABLE=6;
      ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE=7;
      ENET_PROTOCOL_COMMAND_SEND_FRAGMENT=8;
      ENET_PROTOCOL_COMMAND_SEND_UNSEQUENCED=9;
      ENET_PROTOCOL_COMMAND_BANDWIDTH_LIMIT=10;
      ENET_PROTOCOL_COMMAND_THROTTLE_CONFIGURE=11;
      ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE_FRAGMENT=12;
      ENET_PROTOCOL_COMMAND_COUNT=13;
      ENET_PROTOCOL_COMMAND_MASK=$0F;

      ENET_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE=1 shl 7;
      ENET_PROTOCOL_COMMAND_FLAG_UNSEQUENCED=1 shl 6;
      ENET_PROTOCOL_HEADER_FLAG_COMPRESSED=1 shl 14;
      ENET_PROTOCOL_HEADER_FLAG_SENT_TIME=1 shl 15;
      ENET_PROTOCOL_HEADER_FLAG_MASK=ENET_PROTOCOL_HEADER_FLAG_COMPRESSED or ENET_PROTOCOL_HEADER_FLAG_SENT_TIME;
      ENET_PROTOCOL_HEADER_SESSION_MASK=3 shl 12;
      ENET_PROTOCOL_HEADER_SESSION_SHIFT=12;

      ENET_TIME_OVERFLOW=86400000;

      ENET_SOCKET_NULL={$ifdef unix}-1{$else}INVALID_SOCKET{$endif};

      ENET_SOCKET_TYPE_STREAM=1;
      ENET_SOCKET_TYPE_DATAGRAM=2;

      ENET_SOCKET_WAIT_NONE=0;
      ENET_SOCKET_WAIT_SEND=1 shl 0;
      ENET_SOCKET_WAIT_RECEIVE=1 shl 1;
      ENET_SOCKET_WAIT_INTERRUPT=1 shl 2;

      ENET_SOCKOPT_NONBLOCK=1;
      ENET_SOCKOPT_BROADCAST=2;
      ENET_SOCKOPT_RCVBUF=3;
      ENET_SOCKOPT_SNDBUF=4;
      ENET_SOCKOPT_REUSEADDR=5;
      ENET_SOCKOPT_RCVTIMEO=6;
      ENET_SOCKOPT_SNDTIMEO=7;
      ENET_SOCKOPT_ERROR=8;
      ENET_SOCKOPT_NODELAY=9;

      ENET_SOCKET_SHUTDOWN_READ=0;
      ENET_SOCKET_SHUTDOWN_WRITE=1;
      ENET_SOCKET_SHUTDOWN_READ_WRITE=2;

      ENET_IPV4MAPPED_PREFIX_LEN=12; // specifies the length of the IPv4-mapped IPv6 prefix

      ENET_PORT_ANY=0; // specifies that a port should be automatically chosen

      ENET_NO_ADDRESS_FAMILY=0;
      ENET_IPV4=1 shl 0;
      ENET_IPV6=1 shl 1;

      ENET_PACKET_FLAG_RELIABLE=1 shl 0;
      ENET_PACKET_FLAG_UNSEQUENCED=1 shl 1;
      ENET_PACKET_FLAG_NO_ALLOCATE=1 shl 2;
      ENET_PACKET_FLAG_UNRELIABLE_FRAGMENT=1 shl 3;
      ENET_PACKET_FLAG_SENT=1 shl 8;

      ENET_PEER_STATE_DISCONNECTED=0;
      ENET_PEER_STATE_CONNECTING=1;
      ENET_PEER_STATE_ACKNOWLEDGING_CONNECT=2;
      ENET_PEER_STATE_CONNECTION_PENDING=3;
      ENET_PEER_STATE_CONNECTION_SUCCEEDED=4;
      ENET_PEER_STATE_CONNECTED=5;
      ENET_PEER_STATE_DISCONNECT_LATER=6;
      ENET_PEER_STATE_DISCONNECTING=7;
      ENET_PEER_STATE_ACKNOWLEDGING_DISCONNECT=8;
      ENET_PEER_STATE_ZOMBIE=9;

      ENET_HOST_RECEIVE_BUFFER_SIZE=256*1024;
      ENET_HOST_SEND_BUFFER_SIZE=256*1024;
      ENET_HOST_BANDWIDTH_THROTTLE_INTERVAL=1000;
      ENET_HOST_DEFAULT_MTU=1400;
      ENET_HOST_DEFAULT_MAXIMUM_PACKET_SIZE=32*1024*1024;
      ENET_HOST_DEFAULT_MAXIMUM_WAITING_DATA=32*1024*1024;
      ENET_PEER_DEFAULT_ROUND_TRIP_TIME=500;
      ENET_PEER_DEFAULT_PACKET_THROTTLE=32;
      ENET_PEER_PACKET_THROTTLE_SCALE=32;
      ENET_PEER_PACKET_THROTTLE_COUNTER=7;
      ENET_PEER_PACKET_THROTTLE_ACCELERATION=2;
      ENET_PEER_PACKET_THROTTLE_DECELERATION=2;
      ENET_PEER_PACKET_THROTTLE_INTERVAL=5000;
      ENET_PEER_PACKET_LOSS_SCALE=1 shl 16;
      ENET_PEER_PACKET_LOSS_INTERVAL=10000;
      ENET_PEER_WINDOW_SIZE_SCALE=64*1024;
      ENET_PEER_TIMEOUT_LIMIT=32;
      ENET_PEER_TIMEOUT_MINIMUM=5000;
      ENET_PEER_TIMEOUT_MAXIMUM=30000;
      ENET_PEER_PING_INTERVAL_=500;
      ENET_PEER_UNSEQUENCED_WINDOWS=64;
      ENET_PEER_UNSEQUENCED_WINDOW_SIZE=1024;
      ENET_PEER_FREE_UNSEQUENCED_WINDOWS=32;
      ENET_PEER_RELIABLE_WINDOWS=16;
      ENET_PEER_RELIABLE_WINDOW_SIZE=$1000;
      ENET_PEER_FREE_RELIABLE_WINDOWS=8;

      ENET_EVENT_TYPE_NONE=0;
      ENET_EVENT_TYPE_CONNECT=1;
      ENET_EVENT_TYPE_DISCONNECT=2;
      ENET_EVENT_TYPE_RECEIVE=3;

type PENetVersion=^TENetVersion;
     TENetVersion=longword;

     PENetSocket=^TENetSocket;
     TENetSocket=TSocket;

     PENetSocketSet=^TENetSocketSet;
     TENetSocketSet=TFDSet;

     PENetProtocolCommand=^TENetProtocolCommand; 
     TENetProtocolCommand=byte;

     PENetProtocolFlag=^TENetProtocolFlag;
     TENetProtocolFlag=longint;

     PENetCallbacks=^TENetCallbacks;
     TENetCallbacks=record
      malloc:function(Size:longint):pointer;
      free:procedure(memory:pointer);
      no_memory:procedure;
     end;

     PENetListNode=^TENetListNode;
     TENetListNode=record
      Next:PENetListNode;
      Previous:PENetListNode;
     end;

     TENetListIterator=PENetListNode;
     
     PENetList=^TENetList;
     TENetList=record
      Sentinel:TENetListNode;
     end;

     PENetProtocolHeader=^TENetProtocolHeader;
     TENetProtocolHeader=packed record
      peerID:word;
      sentTime:word;
     end;

     PENetProtocolCommandHeader=^TENetProtocolCommandHeader;
     TENetProtocolCommandHeader=packed record
      command:byte;
      channelID:byte;
      reliableSequenceNumber:word;
     end;

     PENetProtocolAcknowledge=^TENetProtocolAcknowledge;
     TENetProtocolAcknowledge=packed record
      header:TENetProtocolCommandHeader;
      receivedReliableSequenceNumber:word;
      receivedSentTime:word;
     end;

     PENetProtocolConnect=^TENetProtocolConnect;
     TENetProtocolConnect=packed record
      header:TENetProtocolCommandHeader;
      outgoingPeerID:word;
      incomingSessionID:word;
      outgoingSessionID:word;
      mtu:longword;
      windowSize:longword;
      channelCount:longword;
      incomingBandwidth:longword;
      outgoingBandwidth:longword;
      packetThrottleInterval:longword;
      packetThrottleAcceleration:longword;
      packetThrottleDeceleration:longword;
      connectID:longword;
      data:longword;
     end;

     PENetProtocolVerifyConnect=^TENetProtocolVerifyConnect;
     TENetProtocolVerifyConnect=packed record
      header:TENetProtocolCommandHeader;
      outgoingPeerID:word;
      incomingSessionID:word;
      outgoingSessionID:word;
      mtu:longword;
      windowSize:longword;
      channelCount:longword;
      incomingBandwidth:longword;
      outgoingBandwidth:longword;
      packetThrottleInterval:longword;
      packetThrottleAcceleration:longword;
      packetThrottleDeceleration:longword;
      connectID:longword;
     end;

     PENetProtocolBandwidthLimit=^TENetProtocolBandwidthLimit;
     TENetProtocolBandwidthLimit=packed record
      header:TENetProtocolCommandHeader;
      incomingBandwidth:longword;
      outgoingBandwidth:longword;
     end;

     PENetProtocolThrottleConfigure=^TENetProtocolThrottleConfigure;
     TENetProtocolThrottleConfigure=packed record
      header:TENetProtocolCommandHeader;
      packetThrottleInterval:longword;
      packetThrottleAcceleration:longword;
      packetThrottleDeceleration:longword;
     end;

     PENetProtocolDisconnect=^TENetProtocolDisconnect;
     TENetProtocolDisconnect=packed record
      header:TENetProtocolCommandHeader;
      data:longword;
     end;

     PENetProtocolPing=^TENetProtocolPing;
     TENetProtocolPing=packed record
      header:TENetProtocolCommandHeader;
     end;

     PENetProtocolSendReliable=^TENetProtocolSendReliable;
     TENetProtocolSendReliable=packed record
      header:TENetProtocolCommandHeader;
      dataLength:word;
     end;

     PENetProtocolSendUnreliable=^TENetProtocolSendUnreliable;
     TENetProtocolSendUnreliable=packed record
      header:TENetProtocolCommandHeader;
      unreliableSequenceNumber:word;
      dataLength:word;
     end;

     PENetProtocolSendUnsequenced=^TENetProtocolSendUnsequenced;
     TENetProtocolSendUnsequenced=packed record
      header:TENetProtocolCommandHeader;
      unsequencedGroup:word;
      dataLength:word;
     end;

     PENetProtocolSendFragment=^TENetProtocolSendFragment;
     TENetProtocolSendFragment=packed record
      header:TENetProtocolCommandHeader;
      startSequenceNumber:word;
      dataLength:word;
      fragmentCount:longword;
      fragmentNumber:longword;
      totalLength:longword;
      fragmentOffset:longword;
     end;

     PENetProtocol=^TENetProtocol;
     TENetProtocol=packed record
      case TENetProtocolCommand of
       ENET_PROTOCOL_COMMAND_NONE:(
        header:TENetProtocolCommandHeader;
       );
       ENET_PROTOCOL_COMMAND_ACKNOWLEDGE:(
        acknowledge:TENetProtocolAcknowledge;
       );
       ENET_PROTOCOL_COMMAND_CONNECT:(
        connect:TENetProtocolConnect;
       );
       ENET_PROTOCOL_COMMAND_VERIFY_CONNECT:(
        verifyConnect:TENetProtocolVerifyConnect;
       );
       ENET_PROTOCOL_COMMAND_DISCONNECT:(
        disconnect:TENetProtocolDisconnect;
       );
       ENET_PROTOCOL_COMMAND_PING:(
        ping:TENetProtocolPing;
       );
       ENET_PROTOCOL_COMMAND_SEND_RELIABLE:(
        sendReliable:TENetProtocolSendReliable;
       );
       ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE:(
        sendUnreliable:TENetProtocolSendUnreliable;
       );
       ENET_PROTOCOL_COMMAND_SEND_FRAGMENT:(
        sendFragment:TENetProtocolSendFragment;
       );
       ENET_PROTOCOL_COMMAND_SEND_UNSEQUENCED:(
        sendUnsequenced:TENetProtocolSendUnsequenced;
       );
       ENET_PROTOCOL_COMMAND_BANDWIDTH_LIMIT:(
        bandwidthLimit:TENetProtocolBandwidthLimit;
       );
       ENET_PROTOCOL_COMMAND_THROTTLE_CONFIGURE:(
        throttleConfigure:TENetProtocolThrottleConfigure;
       );
     end;

     PENetBuffer=^TENetBuffer;
     TENetBuffer=record
{$ifdef unix}
      Data:pansichar;
      DataLength:longword;
{$else}
      DataLength:longword;
      Data:pansichar;
{$endif}
     end;

     PENetSocketType=^TENetSocketType;
     TENetSocketType=byte;

     PENetSocketWait=^TENetSocketWait;
     TENetSocketWait=byte;

     PENetSocketOption=^TENetSocketOption;
     TENetSocketOption=byte;

     PENetSocketShutdown=^TENetSocketShutdown;
     TENetSocketShutdown=byte;

     PENetHostAddress=^TENetHostAddress;
     TENetHostAddress=packed record
      case byte of
       0:(
        addr:packed array[0..15] of byte;
       );
       1:(
        addr16:packed array[0..7] of word;
       );
       2:(
        addr32:packed array[0..3] of longword;
       );
       3:(
        addr64:packed array[0..1] of int64;
       );
     end;

     PENetAddressFamily=^TENetAddressFamily;
     TENetAddressFamily=byte;

     PENetPacketFlag=^TENetPacketFlag;
     TENetPacketFlag=byte;

     PENetAddress=^TENetAddress;
     TENetAddress=record
      host:TENetHostAddress;
      scopeID:{$ifdef unix}longword{$else}int64{$endif};
      port:word;
     end;

const ENET_HOST_ANY_INIT:TENetHostAddress=(addr:(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));
      ENET_HOST_ANY:TENetHostAddress=(addr:(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));
      ENET_IPV4MAPPED_PREFIX_INIT:TENetHostAddress=(addr:(0,0,0,0,0,0,0,0,0,0,255,255,0,0,0,0));
      ENET_IPV4MAPPED_PREFIX:TENetHostAddress=(addr:(0,0,0,0,0,0,0,0,0,0,255,255,0,0,0,0));
      ENET_HOST_BROADCAST_INIT:TENetHostAddress=(addr:(0,0,0,0,0,0,0,0,0,0,255,255,255,255,255,255));
      ENET_HOST_BROADCAST_:TENetHostAddress=(addr:(0,0,0,0,0,0,0,0,0,0,255,255,255,255,255,255));

type PENetPacket=^TENetPacket;

     PLongwords=^TLongwords;
     TLongwords=array[0..0] of longword;

     TENetPacketFreeCallback=procedure(packet:PENetPacket);

     TENetPacket=record
      referenceCount:longword;
      flags:longword;
      data:PAnsiChar;
      dataLength:longword;
      freeCallback:TENetPacketFreeCallback;
      userData:pointer;
     end;

     PENetAcknowledgement=^TENetAcknowledgement;
     TENetAcknowledgement=record
      acknowledgementList:TENetListNode;
      sentTime:longword;
      command:TENetProtocol;
     end;

     PENetOutgoingCommand=^TENetOutgoingCommand;
     TENetOutgoingCommand=record
      outgoingCommandList:TENetListNode;
      reliableSequenceNumber:word;
      unreliableSequenceNumber:word;
      sentTime:longword;
      roundTripTimeout:longword;
      roundTripTimeoutLimit:longword;
      fragmentOffset:longword;
      fragmentLength:word;
      sendAttempts:word;
      command:TENetProtocol;
      packet:PENetPacket;
     end;

     PENetIncomingCommand=^TENetIncomingCommand;
     TENetIncomingCommand=record
      incomingCommandList:TENetListNode;
      reliableSequenceNumber:word;
      unreliableSequenceNumber:word;
      command:TENetProtocol;
      fragmentCount:longword;
      fragmentsRemaining:longword;
      fragments:plongwords;
      packet:PENetPacket;
     end;

     PENetPeerState=^TENetPeerState;
     TENetPeerState=byte;

     PENetChannel=^TENetChannel;
     TENetChannel=record
      outgoingReliableSequenceNumber:word;
      outgoingUnreliableSequenceNumber:word;
      usedReliableWindows:word;
      reliableWindows:array[0..ENET_PEER_RELIABLE_WINDOWS-1] of word;
      incomingReliableSequenceNumber:word;
      incomingUnreliableSequenceNumber:word;
      incomingReliableCommands:TENetList;
      incomingUnreliableCommands:TENetList;
     end;

     PENetChannels=^TENetChannels;
     TENetChannels=array[0..0] of TENetChannel;

     PENetHost=^TENetHost;

     PENetPeer=^TENetPeer;
     TENetPeer=record
      dispatchList:TENetListNode;
      host:PENetHost;
      outgoingPeerID:word;
      incomingPeerID:word;
      connectID:longword;
      outgoingSessionID:byte;
      incomingSessionID:byte;
      address:TENetAddress;
      data:pointer;
      state:TENetPeerState;
      channels:PENetChannels;
      channelCount:longword;
      incomingBandwidth:longword;
      outgoingBandwidth:longword;
      incomingBandwidthThrottleEpoch:longword;
      outgoingBandwidthThrottleEpoch:longword;
      incomingDataTotal:longword;
      outgoingDataTotal:longword;
      lastSendTime:longword;
      lastReceiveTime:longword;
      nextTimeout:longword;
      earliestTimeout:longword;
      packetLossEpoch:longword;
      packetsSent:longword;
      packetsLost:longword;
      packetLoss:longword;
      packetLossVariance:longword;
      packetThrottle:longword;
      packetThrottleLimit:longword;
      packetThrottleCounter:longword;
      packetThrottleEpoch:longword;
      packetThrottleAcceleration:longword;
      packetThrottleDeceleration:longword;
      packetThrottleInterval:longword;
      pingInterval:longword;
      timeoutLimit:longword;
      timeoutMinimum:longword;
      timeoutMaximum:longword;
      lastRoundTripTime:longword;
      lowestRoundTripTime:longword;
      lastRoundTripTimeVariance:longword;
      highestRoundTripTimeVariance:longword;
      roundTripTime:longword;
      roundTripTimeVariance:longword;
      mtu:longword;
      windowSize:longword;
      reliableDataInTransit:longword;
      outgoingReliableSequenceNumber:word;
      acknowledgements:TENetList;
      sentReliableCommands:TENetList;
      sentUnreliableCommands:TENetList;
      outgoingReliableCommands:TENetList;
      outgoingUnreliableCommands:TENetList;
      dispatchedCommands:TENetList;
      needsDispatch:longbool;
      incomingUnsequencedGroup:word;
      outgoingUnsequencedGroup:word;
      unsequencedWindow:array[0..((ENET_PEER_UNSEQUENCED_WINDOW_SIZE+31) shr 5)-1] of longword;
      eventData:longword;
      totalWaitingData:ENETptruint;
     end;

     PENetPeers=^TENetPeers;
     TENetPeers=array[0..0] of TENetPeer;

     PENetCompressor=^TENetCompressor;
     TENetCompressor=record
      context:pointer;
      compress:function(context:pointer;inBuffer:PENetBuffer;inBufferCount,inLimit:longint;outData:pointer;outLimit:longint):longint;
      decompress:function(context:pointer;inData:pointer;inLimit:longint;outData:pointer;outLimit:longint):longint;
      destroy:procedure(context:pointer);
     end;

     TENetChecksumCallback=function(buffers:PENetBuffer;bufferCount:longint):longword;

     PENetEvent=^TENetEvent;

     TENetInterceptCallback=function(host:PENetHost;event:PENetEvent):longint;

     TENetHost=record
      socket4:TENetSocket;
      socket6:TENetSocket;
      address:TENetAddress;
      incomingBandwidth:longword;
      outgoingBandwidth:longword;
      bandwidthThrottleEpoch:longword;
      mtu:longword;
      randomSeed:longword;
      recalculateBandwidthLimits:longint;
      peers:PENetPeers;
      peerCount:longint;
      channelLimit:longword;
      serviceTime:longword;
      dispatchQueue:TENetList;
      continueSending:longint;
      packetSize:longint;
      headerFlags:word;
      commands:array[0..ENET_PROTOCOL_MAXIMUM_PACKET_COMMANDS-1] of TENetProtocol;
      commandCount:longint;
      buffers:array[0..ENET_BUFFER_MAXIMUM-1] of TENetBuffer;
      bufferCount:longint;
      checksum:TENetChecksumCallback;
      compressor:TENetCompressor;
      packetData:array[0..1,0..ENET_PROTOCOL_MAXIMUM_MTU-1] of byte;
      receivedAddress:TENetAddress;
      receivedData:PAnsiChar;
      receivedDataLength:longint;
      totalSentData:longword;
      totalSentPackets:longword;
      totalReceivedData:longword;
      totalReceivedPackets:longword;
      intercept:TENetInterceptCallback;
      connectedPeers:ENETptruint;
      bandwidthLimitedPeers:ENETptruint;
      duplicatePeers:ENETptruint;
      maximumPacketSize:ENETptruint;
      maximumWaitingData:ENETptruint;
     end;

     PENetEventType=^TENetEventType;
     TENetEventType=byte;

     TENetEvent=record
      type_:TENetEventType;
      peer:PENetPeer;
      channelID:byte;
      data:longword;
      packet:PENetPacket;
     end;

function enet_list_begin(list:pointer):pointer;
function enet_list_end(list:pointer):pointer;
function enet_list_empty(list:pointer):boolean;
function enet_list_next(iterator:pointer):pointer;
function enet_list_previous(iterator:pointer):pointer;
function enet_list_front(list:pointer):pointer;
function enet_list_back(list:pointer):pointer;
procedure enet_list_clear(list:PENetList);
function enet_list_insert(position:TENetListIterator;data:pointer):TENetListIterator;
function enet_list_remove(position:TENetListIterator):pointer;
function enet_list_move(position:TENetListIterator;dataFirst,dataLast:pointer):TENetListIterator;
function enet_list_size(list:PENetList):longint;

function ENET_TIME_LESS(a,b:longword):boolean;
function ENET_TIME_GREATER(a,b:longword):boolean;
function ENET_TIME_LESS_EQUAL(a,b:longword):boolean;
function ENET_TIME_GREATER_EQUAL(a,b:longword):boolean;
function ENET_TIME_DIFFERENCE(a,b:longword):longint;

function ENET_HOST_TO_NET_16(value:word):word;
function ENET_HOST_TO_NET_32(value:longword):longword;
function ENET_NET_TO_HOST_16(value:word):word;
function ENET_NET_TO_HOST_32(value:longword):longword;

procedure ENET_SOCKETSET_EMPTY(var sockset:TFDSet);
procedure ENET_SOCKETSET_ADD(var sockset:TFDSet;socket:TSocket);
procedure ENET_SOCKETSET_REMOVE(var sockset:TFDSet;socket:TSocket);
function ENET_SOCKETSET_CHECK(var sockset:TFDSet;socket:TSocket):boolean;

function enet_address_map4(address:longword):TENetHostAddress;

function enet_compare_address(const a,b:TENetHostAddress):boolean;

function enet_get_address_family(address:PENetAddress):TENetAddressFamily;

function enet_initialize:longint;
procedure enet_deinitialize;
function enet_linked_version:TENetVersion;
function enet_host_random_seed:longword;
function enet_time_get:longword;
procedure enet_time_set(newTimeBase:longword);
function enet_af(family:TENetAddressFamily):word;
function enet_sa_size(family:TENetAddressFamily):longint;
function enet_address_set_address(address:PENetAddress;sin:pointer):TENetAddressFamily;
function enet_address_set_sin(sin:pointer;address:PENetAddress;family:TENetAddressFamily):longint;
function enet_address_set_host(address:PENetAddress;name:PAnsiChar):longint;
function enet_address_get_host_x(address:PENetAddress;name:PAnsiChar;nameLength:longint;flags:longint):longint;
function enet_address_get_host_ip(address:PENetAddress;name:PAnsiChar;nameLength:longint):longint;
function enet_address_get_host(address:PENetAddress;name:PAnsiChar;nameLength:longint):longint;
function enet_socket_bind(socket:TENetSocket;address:PENetAddress;family:TENetAddressFamily):longint;
function enet_socket_get_address(socket:TENetSocket;address:PENetAddress;family:TENetAddressFamily):longint;
function enet_socket_listen(socket:TENetSocket;backlog:longint):longint;
function enet_socket_create(type_:TENetSocketType;family:TENetAddressFamily):TENetSocket;
function enet_socket_set_option(socket:TENetSocket;option:TENetSocketOption;value:longint):longint;
function enet_socket_get_option(socket:TENetSocket;option:TENetSocketOption;var value:longint):longint;
function enet_socket_shutdown(socket:TENetSocket;how:TENetSocketShutdown):longint;
function enet_socket_connect(socket:TENetSocket;address:PENetAddress;family:TENetAddressFamily):longint;
function enet_socket_accept(socket:TENetSocket;address:PENetAddress;family:TENetAddressFamily):TENetSocket;
procedure enet_socket_destroy(socket:TENetSocket);
function enet_socket_send(socket:TENetSocket;address:PENetAddress;buffers:PENetBuffer;bufferCount:longword;family:TENetAddressFamily):longint;
function enet_socket_receive(socket:TENetSocket;address:PENetAddress;buffers:PENetBuffer;bufferCount:longword;family:TENetAddressFamily):longint;
function enet_socketset_select(maxSocket:TENetSocket;readSet,writeSet:PENetSocketSet;timeout:longword):longint;
function enet_socket_wait(socket4,socket6:TENetSocket;condition:pointer;timeout:longword):longint;

function enet_host_compress_with_range_coder(host:PENetHost):longint;

function enet_packet_create(data:pointer;dataLength:longint;flags:Longword):PENetPacket; overload;
function enet_packet_create(const data:TENETRawByteString;flags:Longword):PENetPacket; overload;
procedure enet_packet_destroy(packet:PENetPacket);
function enet_packet_resize(packet:PENetPacket;dataLength:longword):longint;

function enet_crc32(buffers:PENetBuffer;bufferCount:longint):longword;

procedure enet_peer_throttle_configure(peer:PENetPeer;interval,acceleration,deceleration:longword);
function enet_peer_throttle(peer:PENetPeer;rtt:longword):longint;
function enet_peer_send(peer:PENetPeer;channelID:byte;packet:PENetPacket):longint;
function enet_peer_receive(peer:PENetPeer;channelID:pbyte):PENetPacket;
procedure enet_peer_reset_outgoing_commands(queue:PENetList);
procedure enet_peer_remove_incoming_commands(queue:PENetList;startCommand,endCommand:TENetListIterator);
procedure enet_peer_reset_incoming_commands(queue:PENetList);
procedure enet_peer_reset_queues(peer:PENetPeer);
procedure enet_peer_reset(peer:PENetPeer);
procedure enet_peer_ping(peer:PENetPeer);
procedure enet_peer_ping_interval(peer:PENetPeer;pingInterval:longword);
procedure enet_peer_timeout(peer:PENetPeer;timeoutLimit,timeoutMinimum,timeoutMaximum:longword);
procedure enet_peer_disconnect_now(peer:PENetPeer;data:longword);
procedure enet_peer_disconnect(peer:PENetPeer;data:longword);
procedure enet_peer_disconnect_later(peer:PENetPeer;data:longword);
function enet_peer_queue_acknowledgement(peer:PENetPeer;command:PENetProtocol;sentTime:word):PENetAcknowledgement;
procedure enet_peer_setup_outgoing_command(peer:PENetPeer;outgoingCommand:PENetOutgoingCommand);
function enet_peer_queue_outgoing_command(peer:PENetPeer;command:PENetProtocol;packet:PENetPacket;offset:longword;length:word):PENetOutgoingCommand;
procedure enet_peer_dispatch_incoming_unreliable_commands(peer:PENetPeer;channel:PENetChannel);
procedure enet_peer_dispatch_incoming_reliable_commands(peer:PENetPeer;channel:PENetChannel);
function enet_peer_queue_incoming_command(peer:PENetPeer;command:PENetProtocol;data:pointer;dataLength:ENETptruint;flags:longword;fragmentCount:longword):PENetIncomingCommand;
procedure enet_peer_on_connect(peer:PENetPeer);
procedure enet_peer_on_disconnect(peer:PENetPeer);

function enet_socket_create_bind(address:PENetAddress;family:TENetAddressFamily):TENetSocket;

function enet_host_create(address:PENetAddress;peerCount,channelLimit,incomingBandwidth,outgoingBandwidth:longword):PENetHost;
procedure enet_host_destroy(host:PENetHost);
function enet_host_connect(host:PENetHost;address:PENetAddress;channelCount,data:longword):PENetPeer;
procedure enet_host_broadcast(host:PENetHost;channelID:byte;packet:PENetPacket);
procedure enet_host_compress(host:PENetHost;compressor:PENetCompressor);
procedure enet_host_channel_limit(host:PENetHost;channelLimit:longword);
procedure enet_host_bandwidth_limit(host:PENetHost;incomingBandwidth,outgoingBandwidth:longword);
procedure enet_host_bandwidth_throttle(host:PENetHost);

function enet_protocol_command_size(command:byte):longint;
procedure enet_protocol_change_state(host:PENetHost;peer:PENetPeer;state:TENetPeerState);
procedure enet_protocol_dispatch_state(host:PENetHost;peer:PENetPeer;state:TENetPeerState);
function enet_protocol_dispatch_incoming_commands(host:PENetHost;event:PENetEvent):longint;
procedure enet_protocol_notify_connect(host:PENetHost;peer:PENetPeer;event:PENetEvent);
procedure enet_protocol_notify_disconnect(host:PENetHost;peer:PENetPeer;event:PENetEvent);
procedure enet_protocol_remove_sent_unreliable_commands(peer:PENetPeer);
function enet_protocol_remove_sent_reliable_command(peer:PENetPeer;reliableSequenceNumber:word;channelID:byte):TENetProtocolCommand;
function enet_protocol_handle_connect(host:PENetHost;header:PENetProtocolHeader;command:PENetProtocol):PENetPeer;
function enet_protocol_handle_send_reliable(host:PENetHost;peer:PENetPeer;command:PENetProtocol;currentData:PPAnsiChar):longint;
function enet_protocol_handle_send_unsequenced(host:PENetHost;peer:PENetPeer;command:PENetProtocol;currentData:PPAnsiChar):longint;
function enet_protocol_handle_send_unreliable(host:PENetHost;peer:PENetPeer;command:PENetProtocol;currentData:PPAnsiChar):longint;
function enet_protocol_handle_send_fragment(host:PENetHost;peer:PENetPeer;command:PENetProtocol;currentData:PPAnsiChar):longint;
function enet_protocol_handle_send_unreliable_fragment(host:PENetHost;peer:PENetPeer;command:PENetProtocol;currentData:PPAnsiChar):longint;
function enet_protocol_handle_ping(host:PENetHost;peer:PENetPeer;command:PENetProtocol):longint;
function enet_protocol_handle_bandwidth_limit(host:PENetHost;peer:PENetPeer;command:PENetProtocol):longint;
function enet_protocol_handle_throttle_configure(host:PENetHost;peer:PENetPeer;command:PENetProtocol):longint;
function enet_protocol_handle_disconnect(host:PENetHost;peer:PENetPeer;command:PENetProtocol):longint;
function enet_protocol_handle_acknowledge(host:PENetHost;event:PENetEvent;peer:PENetPeer;command:PENetProtocol):longint;
function enet_protocol_handle_verify_connect(host:PENetHost;event:PENetEvent;peer:PENetPeer;command:PENetProtocol):longint;
function enet_protocol_handle_incoming_commands(host:PENetHost;event:PENetEvent):longint;
procedure enet_protocol_send_acknowledgements(host:PENetHost;peer:PENetPeer);
function enet_protocol_receive_incoming_commands(host:PENetHost;event:PENetEvent;family:TENetAddressFamily):longint;
procedure enet_protocol_send_unreliable_outgoing_commands(host:PENetHost;peer:PENetPeer);
function enet_protocol_check_timeouts(host:PENetHost;peer:PENetPeer;event:PENetEvent):longint;
function enet_protocol_send_reliable_outgoing_commands(host:PENetHost;peer:PENetPeer):longint;
function enet_protocol_send_outgoing_commands(host:PENetHost;event:PENetEvent;checkForTimeouts:longint):longint;
procedure enet_host_flush(host:PENetHost);
function enet_host_check_events(host:PENetHost;event:PENetEvent):longint;
function enet_host_service(host:PENetHost;event:PENetEvent;timeout:longword):longint;

implementation

{$ifdef fpc}
 {$undef OldDelphi}
{$else}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=23.0}
   {$undef OldDelphi}
type qword=uint64;
     ptruint=NativeUInt;
     ptrint=NativeInt;
  {$else}
   {$define OldDelphi}
  {$ifend}
 {$else}
  {$define OldDelphi}
 {$endif}
{$endif}
{$ifdef OldDelphi}
type qword=int64;
{$ifdef cpu64}
     ptruint=qword;
     ptrint=int64;
{$else}
     ptruint=longword;
     ptrint=longint;
{$endif}
{$endif}

function enet_list_begin(list:pointer):pointer;
begin
 result:=PENetList(list)^.Sentinel.Next;
end;

function enet_list_end(list:pointer):pointer;
begin
 result:=@PENetList(list)^.Sentinel;
end;

function enet_list_empty(list:pointer):boolean;
begin
 result:=PENetList(list)^.Sentinel.Next=@PENetList(list)^.Sentinel;
end;

function enet_list_next(iterator:pointer):pointer;
begin
 result:=PENetListNode(iterator)^.Next;
end;

function enet_list_previous(iterator:pointer):pointer;
begin
 result:=PENetListNode(iterator)^.Previous;
end;

function enet_list_front(list:pointer):pointer;
begin
 result:=PENetList(list)^.Sentinel.Next;
end;

function enet_list_back(list:pointer):pointer;
begin
 result:=PENetList(list)^.Sentinel.Previous;
end;

procedure enet_list_clear(list:PENetList);
begin
 list^.sentinel.next:=@list^.sentinel;
 list^.sentinel.previous:=@list^.sentinel;
end;

function enet_list_insert(position:TENetListIterator;data:pointer):TENetListIterator;
begin
 result:=data;
 result^.previous:=position^.previous;
 result^.next:=position;
 result^.previous^.next:=result;
 position^.previous:=result;
end;

function enet_list_remove(position:TENetListIterator):pointer;
begin
 position^.previous^.next:=position^.next;
 position^.next^.previous:=position^.previous;
 result:=position;
end;

function enet_list_move(position:TENetListIterator;dataFirst,dataLast:pointer):TENetListIterator;
var first,last:TENetListIterator;
begin
 first:=dataFirst;
 last:=dataLast;
 first^.previous^.next:=last^.next;
 last^.next^.previous:=first^.previous;
 first^.previous:=position^.previous;
 last^.next:=pointer(position);
 first^.previous^.next:=first;
 position^.previous:=last;
 result:=first;
end;

function enet_list_size(list:PENetList):longint;
var position:TENetListIterator;
begin
 result:=0;
 if assigned(list) then begin
  position:=enet_list_begin(list);
  while position<>enet_list_end(list) do begin
   inc(result);
   position:=enet_list_next(position);
  end;
 end;
end;

function ENET_TIME_LESS(a,b:longword):boolean;
begin
 result:=(a-b)>=ENET_TIME_OVERFLOW;
end;

function ENET_TIME_GREATER(a,b:longword):boolean;
begin
 result:=(b-a)>=ENET_TIME_OVERFLOW;
end;

function ENET_TIME_LESS_EQUAL(a,b:longword):boolean;
begin
 result:=not ((b-a)>=ENET_TIME_OVERFLOW);
end;

function ENET_TIME_GREATER_EQUAL(a,b:longword):boolean;
begin
 result:=not ((a-b)>=ENET_TIME_OVERFLOW);
end;

function ENET_TIME_DIFFERENCE(a,b:longword):longint;
begin
 if (a-b)>=ENET_TIME_OVERFLOW then begin
  result:=b-a;
 end else begin
  result:=a-b;
 end;
end;

function ENET_HOST_TO_NET_16(value:word):word;
begin
 result:=htons(value);
end;

function ENET_HOST_TO_NET_32(value:longword):longword;
begin
 result:=htonl(value);
end;

function ENET_NET_TO_HOST_16(value:word):word;
begin
 result:=ntohs(value);
end;

function ENET_NET_TO_HOST_32(value:longword):longword;
begin
 result:=ntohl(value);
end;

procedure ENET_SOCKETSET_EMPTY(var sockset:TFDSet);
begin
{$ifdef unix}
 fpFD_ZERO(sockset);
{$else}
 FD_ZERO(sockset);
{$endif}
end;

procedure ENET_SOCKETSET_ADD(var sockset:TFDSet;socket:TSocket);
begin
{$ifdef unix}
 fpFD_SET(socket,sockset);
{$else}
 FD_SET(socket,sockset);
{$endif}
end;

procedure ENET_SOCKETSET_REMOVE(var sockset:TFDSet;socket:TSocket);
begin
{$ifdef unix}
 fpFD_CLR(socket,sockset);
{$else}
 FD_CLR(socket,sockset);
{$endif}
end;

function ENET_SOCKETSET_CHECK(var sockset:TFDSet;socket:TSocket):boolean;
begin
{$ifdef unix}
 result:=fpFD_ISSET(socket,sockset)=1;
{$else}
 result:=FD_ISSET(socket,sockset);
{$endif}
end;

function enet_address_map4(address:longword):TENetHostAddress;
begin
 result:=ENET_IPV4MAPPED_PREFIX_INIT;
 longword(pointer(@result.addr[12])^):=address;
end;

function enet_compare_address(const a,b:TENetHostAddress):boolean;
begin
 result:=(a.addr64[0]=b.addr64[0]) and (a.addr64[1]=b.addr64[1]);
end;

function enet_get_address_family(address:PENetAddress):TENetAddressFamily;
begin
 if (address^.host.addr[0]=ENET_IPV4MAPPED_PREFIX.addr[0]) and
    (address^.host.addr[1]=ENET_IPV4MAPPED_PREFIX.addr[1]) and
    (address^.host.addr[2]=ENET_IPV4MAPPED_PREFIX.addr[2]) and
    (address^.host.addr[3]=ENET_IPV4MAPPED_PREFIX.addr[3]) and
    (address^.host.addr[4]=ENET_IPV4MAPPED_PREFIX.addr[4]) and
    (address^.host.addr[5]=ENET_IPV4MAPPED_PREFIX.addr[5]) and
    (address^.host.addr[6]=ENET_IPV4MAPPED_PREFIX.addr[6]) and
    (address^.host.addr[7]=ENET_IPV4MAPPED_PREFIX.addr[7]) and
    (address^.host.addr[8]=ENET_IPV4MAPPED_PREFIX.addr[8]) and
    (address^.host.addr[9]=ENET_IPV4MAPPED_PREFIX.addr[9]) and
    (address^.host.addr[10]=ENET_IPV4MAPPED_PREFIX.addr[10]) and
    (address^.host.addr[11]=ENET_IPV4MAPPED_PREFIX.addr[11]) then begin
  result:=ENET_IPV4;
 end else begin
  result:=ENET_IPV6;
 end;
end;

const timeBase:longword=0;

{$ifdef unix}
const SOCKET_ERROR=-1;

type PSockaddrStorage=^TSockaddrStorage;
     TSockaddrStorage=record
      ss_family:word;
      _ss_pad1:array[0..5] of byte;
      _ss_align:int64;
      _ss_pad2:array[0..119] of byte;
     end;

function enet_initialize:longint;
begin
 result:=0;
end;

procedure enet_deinitialize;
begin
end;

function enet_host_random_seed:longword;
var tv:TTimeVal;
begin
 fpgettimeofday(@tv,nil);
 result:=((tv.tv_sec*1000)+(tv.tv_usec div 1000))-timeBase;
end;

function enet_time_get:longword;
var tv:TTimeVal;
begin
 fpgettimeofday(@tv,nil);
 result:=((tv.tv_sec*1000)+(tv.tv_usec div 1000))-timeBase;
end;

procedure enet_time_set(newTimeBase:longword);
var tv:TTimeVal;
begin
 fpgettimeofday(@tv,nil);
 timeBase:=((tv.tv_sec*1000)+(tv.tv_usec div 1000))-newTimeBase;
end;

function enet_af(family:TENetAddressFamily):word;
begin
 case family of
  ENET_IPV4:begin
   result:=AF_INET;
  end;
  ENET_IPV6:begin
   result:=AF_INET6;
  end;
  else begin
   result:=0;
  end;
 end;
end;

function enet_sa_size(family:TENetAddressFamily):longint;
begin
 case family of
  ENET_IPV4:begin
   result:=sizeof(sockaddr_in);
  end;
  ENET_IPV6:begin
   result:=sizeof(sockaddr_in6);
  end;
  else begin
   result:=0;
  end;
 end;
end;

function enet_address_set_address(address:PENetAddress;sin:pointer):TENetAddressFamily;
begin
 FillChar(address^,SizeOf(TENetAddress),AnsiChar(#0));
 case Psockaddr_in(sin)^.sin_family of
  AF_INET:begin
   address^.host:=enet_address_map4(Psockaddr_in(sin)^.sin_addr.S_addr);
   address^.scopeID:=0;
   address^.port:=ENET_NET_TO_HOST_16(Psockaddr_in(sin)^.sin_port);
   result:=ENET_IPV4;
  end;
  AF_INET6:begin
   address^.host:=PENetHostAddress(pointer(@Psockaddr_in6(sin)^.sin6_addr))^;
   address^.scopeID:=Psockaddr_in6(sin)^.sin6_scope_id;
   address^.port:=ENET_NET_TO_HOST_16(Psockaddr_in6(sin)^.sin6_port);
   result:=ENET_IPV6;
  end;
  else begin
   result:=ENET_NO_ADDRESS_FAMILY;
  end;
 end;
end;

function enet_address_set_sin(sin:pointer;address:PENetAddress;family:TENetAddressFamily):longint;
begin
 FillChar(sin^,enet_sa_size(family),AnsiChar(#0));
 if (family=ENET_IPV4) and ((enet_get_address_family(address)=ENET_IPV4) or
     ((address^.host.addr[0]=ENET_HOST_ANY.addr[0]) and
      (address^.host.addr[1]=ENET_HOST_ANY.addr[1]) and
      (address^.host.addr[2]=ENET_HOST_ANY.addr[2]) and
      (address^.host.addr[3]=ENET_HOST_ANY.addr[3]) and
      (address^.host.addr[4]=ENET_HOST_ANY.addr[4]) and
      (address^.host.addr[5]=ENET_HOST_ANY.addr[5]) and
      (address^.host.addr[6]=ENET_HOST_ANY.addr[6]) and
      (address^.host.addr[7]=ENET_HOST_ANY.addr[7]) and
      (address^.host.addr[8]=ENET_HOST_ANY.addr[8]) and
      (address^.host.addr[9]=ENET_HOST_ANY.addr[9]) and
      (address^.host.addr[10]=ENET_HOST_ANY.addr[10]) and
      (address^.host.addr[11]=ENET_HOST_ANY.addr[11]) and
      (address^.host.addr[12]=ENET_HOST_ANY.addr[12]) and
      (address^.host.addr[13]=ENET_HOST_ANY.addr[13]) and
      (address^.host.addr[14]=ENET_HOST_ANY.addr[14]) and
      (address^.host.addr[15]=ENET_HOST_ANY.addr[15]))) then begin
  Psockaddr_in(sin)^.sin_family:=AF_INET;
  Psockaddr_in(sin)^.sin_addr.S_addr:=longword(pointer(@address^.host.addr[12])^);
  Psockaddr_in(sin)^.sin_port:=ENET_HOST_TO_NET_16(address^.port);
  result:=0;
 end else if family=ENET_IPV6 then begin
  Psockaddr_in6(sin)^.sin6_family:=AF_INET6;
  PENetHostAddress(pointer(@Psockaddr_in6(sin)^.sin6_addr))^:=address^.host;
  Psockaddr_in6(sin)^.sin6_scope_id:=address^.scopeID;
  Psockaddr_in6(sin)^.sin6_port:=ENET_HOST_TO_NET_16(address^.port);
  result:=0;
 end else begin
  result:=-1;
 end;
end;

function enet_address_set_host(address:PENetAddress;name:PAnsiChar):longint;
var port:word;
    Hints:TAddrInfo;
    r,res:PAddrInfo;
begin
 port:=address^.port;
 FillChar(Hints,SizeOf(TAddrInfo),AnsiChar(#0));
 hints.ai_flags:=AI_ADDRCONFIG;
 hints.ai_family:=AF_UNSPEC;
 if getaddrinfo(name,nil,@hints,@r)<>0 then begin
  result:=-1;
  exit;
 end;
 res:=r;
 while assigned(res) do begin
  if enet_address_set_address(address,res^.ai_addr)<>ENET_NO_ADDRESS_FAMILY then begin
   break;
  end;
  res:=res^.ai_next;
 end;
 address^.port:=port;
 freeaddrinfo(r);
 if not assigned(res) then begin
  result:=-1;
  exit;
 end;
 result:=0;
end;

function enet_address_get_host_x(address:PENetAddress;name:PAnsiChar;nameLength:longint;flags:longint):longint;
var sin:TSockaddrStorage;
begin
 enet_address_set_sin(@sin,address,ENET_IPV6);
 if getnameinfo(pointer(@sin),enet_sa_size(ENET_IPV6),name,nameLength,nil,0,flags)=0 then begin
  result:=-1;
  exit;
 end;
 result:=0;
end;

function enet_address_get_host_ip(address:PENetAddress;name:PAnsiChar;nameLength:longint):longint;
begin
 result:=enet_address_get_host_x(address,name,nameLength,NI_NUMERICHOST);
end;

function enet_address_get_host(address:PENetAddress;name:PAnsiChar;nameLength:longint):longint;
begin
 result:=enet_address_get_host_x(address,name,nameLength,0);
end;

function enet_socket_bind(socket:TENetSocket;address:PENetAddress;family:TENetAddressFamily):longint;
var sin:TSockaddrStorage;
    address_:TENetAddress;
begin
 if assigned(address) then begin
  enet_address_set_sin(pointer(@sin),address,family);
 end else begin
  address_.host:=ENET_HOST_ANY_INIT;
  address_.scopeID:=0;
  address_.port:=0;
  enet_address_set_sin(pointer(@sin),@address_,family);
 end;
 if fpbind(socket,pointer(@sin),enet_sa_size(family))=SOCKET_ERROR then begin
  result:=-1;
 end else begin
  result:=0;
 end;
end;

function enet_socket_get_address(socket:TENetSocket;address:PENetAddress;family:TENetAddressFamily):longint;
var sin:TSockaddrStorage;
    sinLength:socklen_t;
    addressTemp:TENetAddress;
begin
 sinLength:=enet_sa_size(family);
 if fpgetsockname(socket,pointer(@sin),@sinLength)=-1 then begin
  result:=-1;
 end else begin
  if enet_address_set_address(@addressTemp,pointer(@sin))=ENET_NO_ADDRESS_FAMILY then begin
   result:=-1;
  end else begin
   address^:=addressTemp;
   result:=0;
  end;
 end;
end;

function enet_socket_listen(socket:TENetSocket;backlog:longint):longint;
begin
 if backlog<0 then begin
  backlog:=SOMAXCONN;
 end;
 if fplisten(socket,backlog)=SOCKET_ERROR then begin
  result:=-1;
 end else begin
  result:=0;
 end;
end;

function enet_socket_create(type_:TENetSocketType;family:TENetAddressFamily):TENetSocket;
begin
 if type_=ENET_SOCKET_TYPE_DATAGRAM then begin
  result:=fpsocket(enet_af(family),SOCK_DGRAM,0);
 end else begin
  result:=fpsocket(enet_af(family),SOCK_STREAM,0);
 end;
end;

function enet_socket_set_option(socket:TENetSocket;option:TENetSocketOption;value:longint):longint;
var nonBlocking:longword;
    tv:TTimeVal;
begin
 result:=SOCKET_ERROR;
 case option of
  ENET_SOCKOPT_NONBLOCK:begin
   nonBlocking:=value;
   result:=fpioctl(socket,FIONBIO,pointer(@nonBlocking));
  end;
  ENET_SOCKOPT_BROADCAST:begin
   result:=fpsetsockopt(socket,SOL_SOCKET,SO_BROADCAST,pointer(@value),SizeOf(longint));
  end;
  ENET_SOCKOPT_REUSEADDR:begin
   result:=fpsetsockopt(socket,SOL_SOCKET,SO_REUSEADDR,pointer(@value),SizeOf(longint));
  end;
  ENET_SOCKOPT_RCVBUF:begin
   result:=fpsetsockopt(socket,SOL_SOCKET,SO_RCVBUF,pointer(@value),SizeOf(longint));
  end;
  ENET_SOCKOPT_SNDBUF:begin
   result:=fpsetsockopt(socket,SOL_SOCKET,SO_SNDBUF,pointer(@value),SizeOf(longint));
  end;
  ENET_SOCKOPT_RCVTIMEO:begin
   tv.tv_sec:=Value div 1000;
   tv.tv_usec:=(Value mod 1000)*1000;
   result:=fpsetsockopt(socket,SOL_SOCKET,SO_RCVTIMEO,pointer(@tv),SizeOf(TTimeVal));
  end;
  ENET_SOCKOPT_SNDTIMEO:begin
   tv.tv_sec:=Value div 1000;
   tv.tv_usec:=(Value mod 1000)*1000;
   result:=fpsetsockopt(socket,SOL_SOCKET,SO_SNDTIMEO,pointer(@tv),SizeOf(TTimeVal));
  end;
  ENET_SOCKOPT_NODELAY:begin
   result:=fpsetsockopt(socket,IPPROTO_TCP,TCP_NODELAY,pointer(@value),SizeOf(longint));
  end;
 end;
 if result=SOCKET_ERROR then begin
  result:=-1;
 end else begin
  result:=0;
 end;
end;

function enet_socket_get_option(socket:TENetSocket;option:TENetSocketOption;var value:longint):longint;
var nonBlocking:longword;
    SockLen:socklen_t;
begin
 result:=SOCKET_ERROR;
 case option of
  ENET_SOCKOPT_ERROR:begin
   SockLen:=sizeof(longint);
   result:=fpgetsockopt(socket,SOL_SOCKET,SO_ERROR,pointer(@value),@SockLen);
  end;
 end;
 if result=SOCKET_ERROR then begin
  result:=-1;
 end else begin
  result:=0;
 end;
end;

function enet_socket_shutdown(socket:TENetSocket;how:TENetSocketShutdown):longint;
begin
 result:=fpshutdown(socket,how);
end;

function enet_socket_connect(socket:TENetSocket;address:PENetAddress;family:TENetAddressFamily):longint;
var sin:TSockaddrStorage;
begin
 enet_address_set_sin(pointer(@sin),address,family);
 result:=fpconnect(socket,pointer(@sin),enet_sa_size(family));
 if (result=SOCKET_ERROR) and (fpgeterrno=ESysEINPROGRESS) then begin
  result:=0;
 end;
end;

function enet_socket_accept(socket:TENetSocket;address:PENetAddress;family:TENetAddressFamily):TENetSocket;
var sin:TSockaddrStorage;
    sinLength:socklen_t;
begin
 sinLength:=enet_sa_size(family);
 if assigned(address) then begin
  result:=fpaccept(socket,pointer(@sin),@sinLength);
 end else begin
  result:=fpaccept(socket,nil,nil);
 end;
 if result=INVALID_SOCKET then begin
  result:=ENET_SOCKET_NULL;
  exit;
 end;               
 if assigned(address) then begin
  enet_address_set_address(address,pointer(@sin));
 end;
end;

procedure enet_socket_destroy(socket:TENetSocket);
begin
 if socket<>INVALID_SOCKET then begin
  CloseSocket(socket);
 end;
end;

function enet_socket_send(socket:TENetSocket;address:PENetAddress;buffers:PENetBuffer;bufferCount:longword;family:TENetAddressFamily):longint;
var sin:TSockaddrStorage;
    sentLength:longint;
begin
 if assigned(address) then begin
  enet_address_set_sin(pointer(@sin),address,family);
  sentLength:=fpSendTo(socket,pointer(buffers),bufferCount,MSG_NOSIGNAL,pointer(@sin),enet_sa_size(family));
  if sentLength=SOCKET_ERROR then begin
   if socketerror=EsockEWOULDBLOCK then begin
    result:=0;
   end else begin
    result:=-1;
   end;
   exit;
  end;
 end else begin
  sentLength:=fpSendTo(socket,pointer(buffers),bufferCount,MSG_NOSIGNAL,nil,0);
  if sentLength=SOCKET_ERROR then begin
   if socketerror=EsockEWOULDBLOCK then begin
    result:=0;
   end else begin
    result:=-1;
   end;
   exit;
  end;
 end;
 result:=sentLength;
end;

function enet_socket_receive(socket:TENetSocket;address:PENetAddress;buffers:PENetBuffer;bufferCount:longword;family:TENetAddressFamily):longint;
var sin:TSockaddrStorage;
    sinLength,recvLength:longint;
begin
 sinLength:=enet_sa_size(family);
 recvLength:=0;
 if assigned(address) then begin
  recvLength:=fpRecvFrom(socket,pointer(buffers),bufferCount,MSG_NOSIGNAL,pointer(@sin),@sinLength);
  if recvLength=SOCKET_ERROR then begin
   case SocketError of
    EsockEWOULDBLOCK{,EsockECONNRESET}:begin
     result:=0;
    end;
    else begin
     result:=-1;
    end;
   end;
   exit;
  end;
 end else begin
  recvLength:=fpRecvFrom(socket,pointer(buffers),bufferCount,MSG_NOSIGNAL,nil,nil);
  if recvLength=SOCKET_ERROR then begin
   case SocketError of
    EsockEWOULDBLOCK{,EsockECONNRESET}:begin
     result:=0;
    end;
    else begin
     result:=-1;
    end;
   end;
   exit;
  end;
 end;
{if (flags and MSG_PARTIAL)<>0 then begin
  result:=-1;
  exit;
 end;}
 if assigned(address) then begin
  enet_address_set_address(address,pointer(@sin));
 end;
 result:=recvLength;
end;

function enet_socketset_select(maxSocket:TENetSocket;readSet,writeSet:PENetSocketSet;timeout:longword):longint;
var tv:TTimeVal;
begin
 tv.tv_sec:=timeout div 1000;
 tv.tv_usec:=(timeout mod 1000)*1000;
 result:=fpselect(maxSocket+1,@readSet,@writeSet,nil,@tv);
end;

function enet_socket_wait(socket4,socket6:TENetSocket;condition:pointer;timeout:longword):longint;
var readSet,writeSet:TFDSet;
    tv:TTimeVal;
    selectCount:longint;
    maxSocket:TENetSocket;
begin
 tv.tv_sec:=timeout div 1000;
 tv.tv_usec:=(timeout mod 1000)*1000;
{$ifdef unix}
 fpFD_ZERO(readSet);
 fpFD_ZERO(writeSet);
{$else}
 FD_ZERO(readSet);
 FD_ZERO(writeSet);
{$endif}
 if (longword(condition^) and ENET_SOCKET_WAIT_SEND)<>0 then begin
  if socket4<>ENET_SOCKET_NULL then begin
{$ifdef unix}
   fpFD_SET(socket4,writeSet);
{$else}
   FD_SET(socket4,writeSet);
{$endif}
  end;
  if socket6<>ENET_SOCKET_NULL then begin
{$ifdef unix}
   fpFD_SET(socket6,writeSet);
{$else}
   FD_SET(socket6,writeSet);
{$endif}
  end;
 end;
 if (longword(condition^) and ENET_SOCKET_WAIT_RECEIVE)<>0 then begin
  if socket4<>ENET_SOCKET_NULL then begin
{$ifdef unix}
   fpFD_SET(socket4,readSet);
{$else}
   FD_SET(socket4,readSet);
{$endif}
  end;
  if socket6<>ENET_SOCKET_NULL then begin
{$ifdef unix}
   fpFD_SET(socket6,readSet);
{$else}
   FD_SET(socket6,readSet);
{$endif}
  end;
 end;
 if socket4<>ENET_SOCKET_NULL then begin
  maxSocket:=socket4;
 end else begin
  maxSocket:=0;
 end;
 if (socket6<>ENET_SOCKET_NULL) and (maxSocket<socket6) then begin
  maxSocket:=socket6;
 end;
 selectCount:=fpselect(maxSocket+1,@readSet,@writeSet,nil,@tv);
 if selectCount<0 then begin
  if (errno=ESysEINTR) and ((longword(condition^) and ENET_SOCKET_WAIT_INTERRUPT)<>0) then begin
   longword(condition^):=ENET_SOCKET_WAIT_INTERRUPT;
   result:=0;
  end else begin
   result:=-1;
  end;
  exit;
 end;
 longword(condition^):=ENET_SOCKET_WAIT_NONE;
 if selectCount=0 then begin
  result:=0;
  exit;
 end;
 if ((socket4<>ENET_SOCKET_NULL) and (fpFD_ISSET(socket4,writeSet)=1)) or ((socket6<>ENET_SOCKET_NULL) and (fpFD_ISSET(socket6,writeSet)=1)) then begin
  longword(condition^):=longword(condition^) or ENET_SOCKET_WAIT_SEND;
 end;
 if ((socket4<>ENET_SOCKET_NULL) and (fpFD_ISSET(socket4,readSet)=1)) or ((socket6<>ENET_SOCKET_NULL) and (fpFD_ISSET(socket6,readSet)=1)) then begin
  longword(condition^):=longword(condition^) or ENET_SOCKET_WAIT_RECEIVE;
 end;
 result:=0;
end;

{$else}
const AF_UNSPEC=0;
      AF_INET=2;
      AF_INET6=23;
      AF_MAX=24;

      NI_NUMERICHOST=$2;

type TInAddr=packed record
      case longint of
       0:(
        S_bytes:packed array [0..3] of byte;
       );
       1:(
        S_addr:longword;
       );
     end;

     PSockAddrIn=^TSockAddrIn;
     TSockAddrIn=record
      case longint of
       0:(
        sin_family:word;
        sin_port:word;
        sin_addr:TInAddr;
        sin_zero:array[0..7] of byte;
       );
       1:(
        sa_family:word;
        sa_data:array[0..13] of byte;
       );
     end;

     PInAddr6=^TInAddr6;
     TInAddr6=packed record
      case integer of
       0:(
        S6_addr:packed array [0..15] of shortint;
       );
       1:(
        u6_addr8:packed array [0..15] of byte;
       );
       2:(
        u6_addr16:packed array [0..7] of word;
       );
       3:(
        u6_addr32:packed array [0..3] of longword;
       );
     end;

     PSockAddrIn6=^TSockAddrIn6;
     TSockAddrIn6=packed record
      sin6_family:word;
      sin6_port:word;
      sin6_flowinfo:longword;
      sin6_addr:TInAddr6;
      sin6_scope_id:longword;
     end;

     PPAddrInfo=^PAddrInfo;
     PAddrInfo=^TAddrInfo;
     TAddrInfo=packed record
      ai_flags:longint;
      ai_family:longint;
      ai_socktype:longint;
      ai_protocol:longint;
      ai_addrlen:longword;
      ai_canonname:PAnsiChar;
      ai_addr:PSockAddr;
      ai_next:PAddrInfo;
     end;

     PSockaddrStorage=^TSockaddrStorage;
     TSockaddrStorage=record
      ss_family:word;
      _ss_pad1:array[0..5] of byte;
      _ss_align:int64;
      _ss_pad2:array[0..119] of byte;
     end;

     TGetAddrInfo=function(NodeName:PAnsiChar;ServName:PAnsiChar;Hints:PAddrInfo;Addrinfo:PPAddrInfo):longint; stdcall;
     TFreeAddrInfo=procedure(ai:PAddrInfo); stdcall;
     TGetNameInfo=function(addr:PSockAddr;namelen:Integer;host:PAnsiChar;hostlen:longword;serv:PAnsiChar;servlen:longword;flags:longint):longint; stdcall;

const GetAddrInfo:TGetAddrInfo=nil;
      FreeAddrInfo:TFreeAddrInfo=nil;
      GetNameInfo:TGetNameInfo=nil;

      LibHandle:THandle=0;

function enet_initialize:longint;
var versionRequested:word;
    vWSAData:TWSAData;
begin
 LibHandle:=0;
 versionRequested:=MAKEWORD(2,2);
 if WSAStartup(versionRequested,vWSAData)<>0 then begin
  result:=-1;
  exit;
 end;
 LibHandle:=LoadLibrary(PChar('ws2_32.dll'));
 if (LibHandle=0) or ((LOBYTE(vWSAData.wVersion)<>2) or (HIBYTE(vWSAData.wVersion)<>2)) then begin
  WSACleanup;
  result:=-1;
  exit;
 end;
 GetAddrInfo:=GetProcAddress(LibHandle,PAnsiChar(AnsiString('getaddrinfo')));
 FreeAddrInfo:=GetProcAddress(LibHandle,PAnsiChar(AnsiString('freeaddrinfo')));
 GetNameInfo:=GetProcAddress(LibHandle,PAnsiChar(AnsiString('getnameinfo')));
 if not (assigned(GetAddrInfo) and assigned(FreeAddrInfo) and assigned(GetNameInfo)) then begin
  FreeLibrary(LibHandle);
  LibHandle:=LoadLibrary(PChar('wship6.dll'));
  GetAddrInfo:=GetProcAddress(LibHandle,PAnsiChar(AnsiString('getaddrinfo')));
  FreeAddrInfo:=GetProcAddress(LibHandle,PAnsiChar(AnsiString('freeaddrinfo')));
  GetNameInfo:=GetProcAddress(LibHandle,PAnsiChar(AnsiString('getnameinfo')));
  if not (assigned(GetAddrInfo) and assigned(FreeAddrInfo) and assigned(GetNameInfo)) then begin
   FreeLibrary(LibHandle);
   LibHandle:=0;
   WSACleanup;
   result:=-1;
   exit;
  end;
 end;
 timeBeginPeriod(1);
 result:=0;
end;

procedure enet_deinitialize;
begin
 FreeLibrary(LibHandle);
 timeEndPeriod(1);
 WSACleanup;
end;

function enet_host_random_seed:longword;
begin
 result:=timeGetTime-timeBase;
end;

function enet_time_get:longword;
begin
 result:=timeGetTime-timeBase;
end;

procedure enet_time_set(newTimeBase:longword);
begin
 timeBase:=timeGetTime-newTimeBase;
end;

function enet_af(family:TENetAddressFamily):word;
begin
 case family of
  ENET_IPV4:begin
   result:=AF_INET;
  end;
  ENET_IPV6:begin
   result:=AF_INET6;
  end;
  else begin
   result:=0;
  end;
 end;
end;

function enet_sa_size(family:TENetAddressFamily):longint;
begin
 case family of
  ENET_IPV4:begin
   result:=sizeof(TSockAddrIn);
  end;
  ENET_IPV6:begin
   result:=sizeof(TSockAddrIn6);
  end;
  else begin
   result:=0;
  end;
 end;
end;

function enet_address_set_address(address:PENetAddress;sin:pointer):TENetAddressFamily;
begin
 FillChar(address^,SizeOf(TENetAddress),AnsiChar(#0));
 case PSockAddrIn(sin)^.sin_family of
  AF_INET:begin
   address^.host:=enet_address_map4(PSockAddrIn(sin)^.sin_addr.S_addr);
   address^.scopeID:=0;
   address^.port:=ENET_NET_TO_HOST_16(PSockAddrIn(sin)^.sin_port);
   result:=ENET_IPV4;
  end;
  AF_INET6:begin
   address^.host:=PENetHostAddress(pointer(@PSockAddrIn6(sin)^.sin6_addr))^;
   address^.scopeID:=PSockAddrIn6(sin)^.sin6_scope_id;
   address^.port:=ENET_NET_TO_HOST_16(PSockAddrIn6(sin)^.sin6_port);
   result:=ENET_IPV6;
  end;
  else begin
   result:=ENET_NO_ADDRESS_FAMILY;
  end;
 end;
end;

function enet_address_set_sin(sin:pointer;address:PENetAddress;family:TENetAddressFamily):longint;
begin
 FillChar(sin^,enet_sa_size(family),AnsiChar(#0));
 if (family=ENET_IPV4) and ((enet_get_address_family(address)=ENET_IPV4) or
     ((address^.host.addr[0]=ENET_HOST_ANY.addr[0]) and
      (address^.host.addr[1]=ENET_HOST_ANY.addr[1]) and
      (address^.host.addr[2]=ENET_HOST_ANY.addr[2]) and
      (address^.host.addr[3]=ENET_HOST_ANY.addr[3]) and
      (address^.host.addr[4]=ENET_HOST_ANY.addr[4]) and
      (address^.host.addr[5]=ENET_HOST_ANY.addr[5]) and
      (address^.host.addr[6]=ENET_HOST_ANY.addr[6]) and
      (address^.host.addr[7]=ENET_HOST_ANY.addr[7]) and
      (address^.host.addr[8]=ENET_HOST_ANY.addr[8]) and
      (address^.host.addr[9]=ENET_HOST_ANY.addr[9]) and
      (address^.host.addr[10]=ENET_HOST_ANY.addr[10]) and
      (address^.host.addr[11]=ENET_HOST_ANY.addr[11]) and
      (address^.host.addr[12]=ENET_HOST_ANY.addr[12]) and
      (address^.host.addr[13]=ENET_HOST_ANY.addr[13]) and
      (address^.host.addr[14]=ENET_HOST_ANY.addr[14]) and
      (address^.host.addr[15]=ENET_HOST_ANY.addr[15]))) then begin
  PSockAddrIn(sin)^.sin_family:=AF_INET;
  PSockAddrIn(sin)^.sin_addr.S_addr:=longword(pointer(@address^.host.addr[12])^);
  PSockAddrIn(sin)^.sin_port:=ENET_HOST_TO_NET_16(address^.port);
  result:=0;
 end else if family=ENET_IPV6 then begin
  PSockAddrIn6(sin)^.sin6_family:=AF_INET6;
  PENetHostAddress(pointer(@PSockAddrIn6(sin)^.sin6_addr))^:=address^.host;
  PSockAddrIn6(sin)^.sin6_scope_id:=address^.scopeID;
  PSockAddrIn6(sin)^.sin6_port:=ENET_HOST_TO_NET_16(address^.port);
  result:=0;
 end else begin
  result:=-1;
 end;
end;

function enet_address_set_host(address:PENetAddress;name:PAnsiChar):longint;
var port:word;
    Hints:TAddrInfo;
    r,res:PAddrInfo;
begin
 port:=address^.port;
 FillChar(Hints,SizeOf(TAddrInfo),AnsiChar(#0));
 hints.ai_flags:=AI_ADDRCONFIG;
 hints.ai_family:=AF_UNSPEC;
 if getaddrinfo(name,nil,@hints,@r)<>0 then begin
  result:=-1;
  exit;
 end;
 res:=r;
 while assigned(res) do begin
  if enet_address_set_address(address,res^.ai_addr)<>ENET_NO_ADDRESS_FAMILY then begin
   break;
  end;
  res:=res^.ai_next;
 end;
 address^.port:=port;
 freeaddrinfo(r);
 if not assigned(res) then begin
  result:=-1;
  exit;
 end;
 result:=0;
end;

function enet_address_get_host_x(address:PENetAddress;name:PAnsiChar;nameLength:longint;flags:longint):longint;
var sin:TSockaddrStorage;
begin
 enet_address_set_sin(@sin,address,ENET_IPV6);
 if getnameinfo(pointer(@sin),enet_sa_size(ENET_IPV6),name,nameLength,nil,0,flags)=0 then begin
  result:=-1;
  exit;
 end;
 result:=0;
end;

function enet_address_get_host_ip(address:PENetAddress;name:PAnsiChar;nameLength:longint):longint;
begin
 result:=enet_address_get_host_x(address,name,nameLength,NI_NUMERICHOST);
end;

function enet_address_get_host(address:PENetAddress;name:PAnsiChar;nameLength:longint):longint;
begin
 result:=enet_address_get_host_x(address,name,nameLength,0);
end;

function enet_socket_bind(socket:TENetSocket;address:PENetAddress;family:TENetAddressFamily):longint;
var sin:TSockaddrStorage;
    address_:TENetAddress;
begin
 if assigned(address) then begin
  enet_address_set_sin(pointer(@sin),address,family);
 end else begin
  address_.host:=ENET_HOST_ANY_INIT;
  address_.scopeID:=0;
  address_.port:=0;
  enet_address_set_sin(pointer(@sin),@address_,family);
 end;
 if bind(socket,pointer(@sin),enet_sa_size(family))=SOCKET_ERROR then begin
  result:=-1;
 end else begin
  result:=0;
 end;
end;

function enet_socket_get_address(socket:TENetSocket;address:PENetAddress;family:TENetAddressFamily):longint;
var sin:TSockaddrStorage;
    sinLength:longint;
    addressTemp:TENetAddress;
begin
 sinLength:=enet_sa_size(family);
 if getsockname(socket,TSockAddr(pointer(@sin)^),sinLength)=-1 then begin
  result:=-1;
 end else begin
  if enet_address_set_address(@addressTemp,pointer(@sin))=ENET_NO_ADDRESS_FAMILY then begin
   result:=-1;
  end else begin
   address^:=addressTemp;
   result:=0;
  end;
 end;
end;

function enet_socket_listen(socket:TENetSocket;backlog:longint):longint;
begin
 if backlog<0 then begin
  backlog:=SOMAXCONN;
 end;
 if listen(socket,backlog)=SOCKET_ERROR then begin
  result:=-1;
 end else begin
  result:=0;
 end;
end;

function enet_socket_create(type_:TENetSocketType;family:TENetAddressFamily):TENetSocket;
begin
 if type_=ENET_SOCKET_TYPE_DATAGRAM then begin
  result:=socket(enet_af(family),SOCK_DGRAM,0);
 end else begin
  result:=socket(enet_af(family),SOCK_STREAM,0);
 end;
end;

function enet_socket_set_option(socket:TENetSocket;option:TENetSocketOption;value:longint):longint;
var nonBlocking:longword;
begin
 result:=SOCKET_ERROR;
 case option of
  ENET_SOCKOPT_NONBLOCK:begin
   nonBlocking:=value;
   result:=ioctlsocket(socket,FIONBIO,nonBlocking);
  end;
  ENET_SOCKOPT_BROADCAST:begin
   result:=setsockopt(socket,SOL_SOCKET,SO_BROADCAST,pointer(@value),SizeOf(longint));
  end;
  ENET_SOCKOPT_REUSEADDR:begin
   result:=setsockopt(socket,SOL_SOCKET,SO_REUSEADDR,pointer(@value),SizeOf(longint));
  end;
  ENET_SOCKOPT_RCVBUF:begin
   result:=setsockopt(socket,SOL_SOCKET,SO_RCVBUF,pointer(@value),SizeOf(longint));
  end;
  ENET_SOCKOPT_SNDBUF:begin
   result:=setsockopt(socket,SOL_SOCKET,SO_SNDBUF,pointer(@value),SizeOf(longint));
  end;
  ENET_SOCKOPT_RCVTIMEO:begin
   result:=setsockopt(socket,SOL_SOCKET,SO_RCVTIMEO,pointer(@value),SizeOf(longint));
  end;
  ENET_SOCKOPT_SNDTIMEO:begin
   result:=setsockopt(socket,SOL_SOCKET,SO_SNDTIMEO,pointer(@value),SizeOf(longint));
  end;
  ENET_SOCKOPT_NODELAY:begin
   result:=setsockopt(socket,IPPROTO_TCP,TCP_NODELAY,pointer(@value),SizeOf(longint));
  end;
 end;
 if result=SOCKET_ERROR then begin
  result:=-1;
 end else begin
  result:=0;
 end;
end;

function enet_socket_get_option(socket:TENetSocket;option:TENetSocketOption;var value:longint):longint;
//var nonBlocking:longword;
begin
 result:=SOCKET_ERROR;
 case option of
  ENET_SOCKOPT_ERROR:begin
   result:=setsockopt(socket,SOL_SOCKET,SO_ERROR,pointer(@value),SizeOf(longint));
  end;
 end;
 if result=SOCKET_ERROR then begin
  result:=-1;
 end else begin
  result:=0;
 end;
end;

function enet_socket_shutdown(socket:TENetSocket;how:TENetSocketShutdown):longint;
begin
 if shutdown(socket,how)=SOCKET_ERROR then begin
  result:=-1;
 end else begin
  result:=0;
 end;
end;

function enet_socket_connect(socket:TENetSocket;address:PENetAddress;family:TENetAddressFamily):longint;
var sin:TSockaddrStorage;
begin
 enet_address_set_sin(pointer(@sin),address,family);
 result:=connect(socket,pointer(@sin),enet_sa_size(family));
 if (result=SOCKET_ERROR) and (WSAGetLastError<>WSAEWOULDBLOCK) then begin
  result:=-1;
 end else begin
  result:=0;
 end;
end;

function enet_socket_accept(socket:TENetSocket;address:PENetAddress;family:TENetAddressFamily):TENetSocket;
var sin:TSockaddrStorage;
    sinLength:longint;
begin
 sinLength:=enet_sa_size(family);
 if assigned(address) then begin
  result:=accept(socket,TSockAddr(pointer(@sin)^),sinLength);
 end else begin
  result:=accept(socket,TSockAddr(pointer(nil)^),longint(pointer(nil)^));
 end;
 if result=INVALID_SOCKET then begin
  result:=ENET_SOCKET_NULL;
  exit;
 end;
 if assigned(address) then begin
  enet_address_set_address(address,pointer(@sin));
 end;
end;

procedure enet_socket_destroy(socket:TENetSocket);
begin
 if socket<>INVALID_SOCKET then begin
  closesocket(socket);
 end;
end;

function enet_socket_send(socket:TENetSocket;address:PENetAddress;buffers:PENetBuffer;bufferCount:longword;family:TENetAddressFamily):longint;
var sin:TSockaddrStorage;
    sentLength:longword;
begin
 if assigned(address) then begin
  enet_address_set_sin(pointer(@sin),address,family);
  if WSASendTo(socket,LPWSABUF(buffers),bufferCount,sentLength,0,pointer(@sin),enet_sa_size(family),nil,nil)=SOCKET_ERROR then begin
   if WSAGetLastError=WSAEWOULDBLOCK then begin
    result:=0;
   end else begin
    result:=-1;
   end;
   exit;
  end;
 end else begin
  if WSASendTo(socket,LPWSABUF(buffers),bufferCount,sentLength,0,nil,0,nil,nil)=SOCKET_ERROR then begin
   if WSAGetLastError=WSAEWOULDBLOCK then begin
    result:=0;
   end else begin
    result:=-1;
   end;
   exit;
  end;
 end;
 result:=sentLength;
end;

function enet_socket_receive(socket:TENetSocket;address:PENetAddress;buffers:PENetBuffer;bufferCount:longword;family:TENetAddressFamily):longint;
var sin:TSockaddrStorage;
    sinLength:longint;
    flags,recvLength:longword;
begin
 sinLength:=enet_sa_size(family);
 flags:=0;
 if assigned(address) then begin
  if WSARecvFrom(socket,LPWSABUF(buffers),bufferCount,recvLength,flags,pointer(@sin),@sinLength,nil,nil)=SOCKET_ERROR then begin
   case WSAGetLastError of
    WSAEWOULDBLOCK,WSAECONNRESET:begin
     result:=0;
    end;
    else begin
     result:=-1;
    end;
   end;
   exit;
  end;
 end else begin
  if WSARecvFrom(socket,LPWSABUF(buffers),bufferCount,recvLength,flags,nil,nil,nil,nil)=SOCKET_ERROR then begin
   case WSAGetLastError of
    WSAEWOULDBLOCK,WSAECONNRESET:begin
     result:=0;
    end;
    else begin
     result:=-1;
    end;
   end;
   exit;
  end;
 end;
 if (flags and MSG_PARTIAL)<>0 then begin
  result:=-1;
  exit;
 end;
 if assigned(address) then begin
  enet_address_set_address(address,pointer(@sin));
 end;
 result:=recvLength;
end;

function enet_socketset_select(maxSocket:TENetSocket;readSet,writeSet:PENetSocketSet;timeout:longword):longint;
var tv:TTimeVal;
begin
 tv.tv_sec:=timeout div 1000;
 tv.tv_usec:=(timeout mod 1000)*1000;
 result:=select(maxSocket+1,@readSet,@writeSet,nil,@tv);
end;

function enet_socket_wait(socket4,socket6:TENetSocket;condition:pointer;timeout:longword):longint;
var readSet,writeSet:TFDSet;
    tv:TTimeVal;
    selectCount:longint;
    maxSocket:TENetSocket;
begin
 tv.tv_sec:=timeout div 1000;
 tv.tv_usec:=(timeout mod 1000)*1000;
 FD_ZERO(readSet);
 FD_ZERO(writeSet);
 if (longword(condition^) and ENET_SOCKET_WAIT_SEND)<>0 then begin
  if socket4<>ENET_SOCKET_NULL then begin
   FD_SET(socket4,writeSet);
  end;
  if socket6<>ENET_SOCKET_NULL then begin
   FD_SET(socket6,writeSet);
  end;
 end;
 if (longword(condition^) and ENET_SOCKET_WAIT_RECEIVE)<>0 then begin
  if socket4<>ENET_SOCKET_NULL then begin
   FD_SET(socket4,readSet);
  end;
  if socket6<>ENET_SOCKET_NULL then begin
   FD_SET(socket6,readSet);
  end;
 end;
 if socket4<>ENET_SOCKET_NULL then begin
  maxSocket:=socket4;
 end else begin
  maxSocket:=0;
 end;
 if (socket6<>ENET_SOCKET_NULL) and (maxSocket<socket6) then begin
  maxSocket:=socket6;
 end;
 selectCount:=select(maxSocket+1,@readSet,@writeSet,nil,@tv);
 if selectCount<0 then begin
  result:=-1;
  exit;
 end;
 longword(condition^):=ENET_SOCKET_WAIT_NONE;
 if selectCount=0 then begin
  result:=0;
  exit;
 end;
 if ((socket4<>ENET_SOCKET_NULL) and FD_ISSET(socket4,writeSet)) or ((socket6<>ENET_SOCKET_NULL) and FD_ISSET(socket6,writeSet)) then begin
  longword(condition^):=longword(condition^) or ENET_SOCKET_WAIT_SEND;
 end;
 if ((socket4<>ENET_SOCKET_NULL) and FD_ISSET(socket4,readSet)) or ((socket6<>ENET_SOCKET_NULL) and FD_ISSET(socket6,readSet)) then begin
  longword(condition^):=longword(condition^) or ENET_SOCKET_WAIT_RECEIVE;
 end;
 result:=0;
end;

{$endif}

function enet_linked_version:TENetVersion;
begin
 result:=ENET_VERSION;
end;

type PENetSymbol=^TENetSymbol;
     TENetSymbol=record
      value:byte;
      count:byte;
      under:word;
      left:word;
      right:word;
      symbols:word;
      escapes:word;
      total:word;
      parent:word;
     end;

     PENetSymbols=^TENetSymbols;
     TENetSymbols=array[0..0] of TENetSymbol;

const ENET_RANGE_CODER_TOP=1 shl 24;
      ENET_RANGE_CODER_BOTTOM=1 shl 16;
      ENET_CONTEXT_SYMBOL_DELTA=3;
      ENET_CONTEXT_SYMBOL_MINIMUM=1;
      ENET_CONTEXT_ESCAPE_MINIMUM=1;
      ENET_SUBCONTEXT_ORDER=2;
      ENET_SUBCONTEXT_SYMBOL_DELTA=2;
      ENET_SUBCONTEXT_ESCAPE_DELTA=5;

type PENetRangeCoder=^TENetRangeCoder;
     TENetRangeCoder=record
      symbols:array[0..4092] of TENetSymbol;
     end;

function enet_range_coder_create:PENetRangeCoder;
begin
 GetMem(result,sizeof(TENetRangeCoder));
end;

procedure enet_range_coder_destroy(context:pointer);
begin
 if not assigned(context) then begin
  FreeMem(context);
 end;
end;

procedure ENET_SYMBOL_CREATE(rangeCoder:PENetRangeCoder;symbol:PENetSymbol;value_,count_:word;var nextSymbol:longint);
begin
 symbol:=@rangeCoder^.symbols[nextSymbol];
 inc(nextSymbol);
 symbol^.value:=value_;
 symbol^.count:=count_;
 symbol^.under:=count_;
 symbol^.left:=0;
 symbol^.right:=0;
 symbol^.symbols:=0;
 symbol^.escapes:=0;
 symbol^.total:=0;
 symbol^.parent:=0;
end;

procedure ENET_CONTEXT_CREATE(rangecoder:PENetRangeCoder;context:PENetSymbol;escapes,minimum:word;var nextSymbol:longint);
begin
 ENET_SYMBOL_CREATE(rangecoder,context,0,0,nextSymbol);
 context^.escapes:=escapes;
 context^.total:=escapes+(256*minimum);
 context^.symbols:=0;
end;

function enet_symbol_rescale(symbol:PENetSymbol):word;
begin
 result:=0;
 while true do begin
  dec(symbol^.count,symbol^.count shr 1);
  symbol^.under:=symbol^.count;
  if symbol^.left<>0 then begin
   inc(symbol^.under,enet_symbol_rescale(@PENetSymbols(symbol)^[symbol^.left]));
  end;
  inc(result,symbol^.under);
  if symbol^.right=0 then begin
   break;
  end;
  inc(symbol,symbol^.right);
 end;
end;

procedure ENET_CONTEXT_RESCALE(context:PENetSymbol;minimum:word);
begin
 if context^.symbols<>0 then begin
  context^.total:=enet_symbol_rescale(@PENetSymbols(pointer(context))^[context^.symbols]);
 end else begin
  context^.total:=0;
 end;
 dec(context^.escapes,context^.escapes shr 1);
 inc(context^.total,context^.escapes+(256*minimum));
end;

function ENET_RANGE_CODER_OUTPUT(var outData:pbyte;outEnd:pbyte;value:byte):boolean;
begin
 result:=false;
 if ptruint(outData)>=ptruint(outEnd) then begin
  exit;
 end;
 outData^:=value;
 inc(outData);
 result:=true;
end;

function ENET_RANGE_CODER_ENCODE(var outData:pbyte;outEnd:pbyte;var encodeLow,encodeRange:longword;under,count,total:word):boolean;
begin
 result:=false;
 encodeRange:=encodeRange div total;
 inc(encodeLow,under*encodeRange);
 encodeRange:=encodeRange*count;
 while true do begin
  if (encodeLow xor (encodeLow+encodeRange))>=ENET_RANGE_CODER_TOP then begin
   if encodeRange>=ENET_RANGE_CODER_BOTTOM then begin
    break;
   end;
   encodeRange:=(-encodeLow) and (ENET_RANGE_CODER_BOTTOM-1);
  end;
  if not ENET_RANGE_CODER_OUTPUT(outData,outEnd,encodeLow shr 24) then begin
   exit;
  end;
  encodeRange:=encodeRange shl 8;
  encodeLow:=encodeLow shl 8;
 end;
 result:=true;
end;

function ENET_RANGE_CODER_FLUSH(var outData:pbyte;outEnd:pbyte;var encodeLow:longword):boolean;
begin
 result:=false;
 while encodeLow<>0 do begin
  if not ENET_RANGE_CODER_OUTPUT(outData,outEnd,encodeLow shr 24) then begin
   exit;
  end;
  encodeLow:=encodeLow shl 8;
 end;
 result:=true;
end;

procedure ENET_RANGE_CODER_FREE_SYMBOLS(rangeCoder:PENetRangeCoder;var root:PENetSymbol;var nextSymbol:longint;var predicted:word;var order:longint);
begin
 if nextSymbol>=((sizeof(rangeCoder^.symbols) div sizeof(TENetSymbol))-ENET_SUBCONTEXT_ORDER) then begin
  nextSymbol:=0;
  ENET_CONTEXT_CREATE(rangeCoder,root,ENET_CONTEXT_ESCAPE_MINIMUM,ENET_CONTEXT_SYMBOL_MINIMUM,nextSymbol);
  predicted:=0;
  order:=0;
 end;
end;

procedure ENET_CONTEXT_ENCODE(rangeCoder:PENetRangeCoder;var context:PENetSymbol;var symbol_:PENetSymbol;var value_:byte;var under_:word;var count_:word;update:word;minimum:word;var nextSymbol:longint);
var node:PENetSymbol;
begin
 under_:=value_*minimum;
 count_:=minimum;
 if context^.symbols=0 then begin
  ENET_SYMBOL_CREATE(rangeCoder,symbol_,value_,update,nextSymbol);
  context^.symbols:=(ptrint(symbol_)-ptrint(context)) div sizeof(TENetSymbol);
 end else begin
  node:=@PENetSymbols(pointer(context))^[context^.symbols];
  while true do begin
   if value_<node^.value then begin
    inc(node^.under,update);
    if node^.left<>0 then begin
     inc(node,node^.left);
     continue;
    end;
    ENET_SYMBOL_CREATE(rangeCoder,symbol_,value_,update,nextSymbol);
    node^.left:=(ptrint(symbol_)-ptrint(node)) div sizeof(TENetSymbol);
   end else if value_>node^.value then begin
    inc(under_,node^.under);
    if node^.right<>0 then begin
     inc(node,node^.right);
     continue;
    end;
    ENET_SYMBOL_CREATE(rangeCoder,symbol_,value_,update,nextSymbol);
    node^.right:=(ptrint(symbol_)-ptrint(node)) div sizeof(TENetSymbol);
   end else begin
    inc(count_,node^.count);
    inc(under_,node^.under-node^.count);
    inc(node^.under,update);
    inc(node^.count,update);
    symbol_:=node;
   end;
   break;
  end;
 end;
end;

function enet_range_coder_compress(context:pointer;inBuffers:PENetBuffer;inBufferCount,inLimit:longint;outData:pointer;outLimit:longint):longint;
label nextInput;
type pword=^word;
var rangeCoder:PENetRangeCoder;
    outStart,outEnd,inData,inEnd:pbyte;
    encodeLow,encodeRange:longword;
    root,subcontext,symbol:PENetSymbol;
    predicted,count,under,total:word;
    parent:pword;
    order,nextSymbol:longint;
    value:byte;
begin
 rangeCoder:=context;
 outStart:=outData;
 outEnd:=pointer(@pansichar(outData)[outLimit]);
 encodeLow:=0;
 encodeRange:=$ffffffff;
 predicted:=0;
 order:=0;
 nextSymbol:=0;

 if (not assigned(rangeCoder)) or (inBufferCount<=0) or (inLimit<=0) then begin
  result:=0;
  exit;
 end;

 inData:=pointer(inBuffers^.data);
 inEnd:=pointer(@pansichar(inData)[inBuffers^.dataLength]);
 inc(inBuffers);
 dec(inBufferCount);

 ENET_CONTEXT_CREATE(rangeCoder,root,ENET_CONTEXT_ESCAPE_MINIMUM,ENET_CONTEXT_SYMBOL_MINIMUM,nextSymbol);

 while true do begin
  parent:=@predicted;
  if ptruint(inData)>=ptruint(inEnd) then begin
   if inBufferCount<=0 then begin
    break;
   end;
   inData:=pointer(inBuffers^.data);
   inEnd:=pointer(@pansichar(inData)[inBuffers^.dataLength]);
   inc(inBuffers);
   dec(inBufferCount);
  end;
  value:=inData^;
  inc(inData);
  subContext:=@rangeCoder^.symbols[predicted];
  while subcontext<>root do begin
   ENET_CONTEXT_ENCODE(rangeCoder,subcontext,symbol,value,under,count,ENET_SUBCONTEXT_SYMBOL_DELTA,0,nextSymbol);
   parent^:=(ptrint(symbol)-ptrint(@rangeCoder^.symbols[0])) div sizeof(TENetSymbol);
   parent:=@symbol^.parent;
   total:=subcontext^.total;
   if count>0 then begin
    if not ENET_RANGE_CODER_ENCODE(pbyte(outData),outEnd,encodeLow,encodeRange,subcontext^.escapes+under,count,total) then begin
     result:=0;
     exit;
    end;
   end else begin
    if (subcontext^.escapes>0) and (subcontext^.escapes<total) then begin
     if not ENET_RANGE_CODER_ENCODE(pbyte(outData),outEnd,encodeLow,encodeRange,0,subcontext^.escapes,total) then begin
      result:=0;
      exit;
     end;
    end;
    inc(subcontext^.escapes,ENET_SUBCONTEXT_ESCAPE_DELTA);
    inc(subcontext^.total,ENET_SUBCONTEXT_ESCAPE_DELTA);
   end;
   inc(subcontext^.total,ENET_SUBCONTEXT_SYMBOL_DELTA);
   if (count>($FF-(2*ENET_SUBCONTEXT_SYMBOL_DELTA))) or (subcontext^.total>(ENET_RANGE_CODER_BOTTOM-$100)) then begin
    ENET_CONTEXT_RESCALE(subcontext,0);
   end;
   if count>0 then begin
    goto nextInput;
   end;
   subcontext:=@rangeCoder^.symbols[subcontext^.parent];
  end;
  ENET_CONTEXT_ENCODE(rangeCoder,subcontext,symbol,value,under,count,ENET_SUBCONTEXT_SYMBOL_DELTA,ENET_CONTEXT_SYMBOL_MINIMUM,nextSymbol);
  parent^:=(ptrint(symbol)-ptrint(@rangeCoder^.symbols[0])) div sizeof(TENetSymbol);
  parent:=@symbol^.parent;
  total:=root^.total;
  if not ENET_RANGE_CODER_ENCODE(pbyte(outData),outEnd,encodeLow,encodeRange,root^.escapes+under,count,total) then begin
   result:=0;
   exit;
  end;
  inc(root^.total,ENET_CONTEXT_SYMBOL_DELTA);
  if (count>(($FF-(2*ENET_CONTEXT_SYMBOL_DELTA))+ENET_CONTEXT_SYMBOL_MINIMUM)) or (root^.total>(ENET_RANGE_CODER_BOTTOM-$100)) then begin
   ENET_CONTEXT_RESCALE(root,ENET_CONTEXT_SYMBOL_MINIMUM);
  end;
nextInput:
  if order>=ENET_SUBCONTEXT_ORDER then begin
   predicted:=rangeCoder^.symbols[predicted].parent;
  end else begin
   inc(order);
  end;
  ENET_RANGE_CODER_FREE_SYMBOLS(rangeCoder,root,nextSymbol,predicted,order);
 end;
 if not ENET_RANGE_CODER_FLUSH(pbyte(outData),outEnd,encodeLow) then begin
  result:=0;
  exit;
 end;
 result:=ptrint(outData)-ptrint(outStart);
end;

procedure ENET_RANGE_CODER_SEED(var inData:pbyte;inEnd:pbyte;var decodeCode:longword);
begin
 if ptruint(inData)<ptruint(inEnd) then begin
  decodeCode:=decodeCode or (inData^ shl 24);
  inc(inData);
 end;
 if ptruint(inData)<ptruint(inEnd) then begin
  decodeCode:=decodeCode or (inData^ shl 16);
  inc(inData);
 end;
 if ptruint(inData)<ptruint(inEnd) then begin
  decodeCode:=decodeCode or (inData^ shl 8);
  inc(inData);
 end;
 if ptruint(inData)<ptruint(inEnd) then begin
  decodeCode:=decodeCode or inData^;
  inc(inData);
 end;
end;

function ENET_RANGE_CODER_READ(decodeCode,decodeLow:longword;var decodeRange:longword;total:word):word;
begin
 decodeRange:=decodeRange div total;
 result:=(decodeCode-decodeLow)-decodeRange;
end;

procedure ENET_RANGE_CODER_DECODE(var inData:pbyte;inEnd:pbyte;var decodeCode,decodeLow,decodeRange:longword;under:word;var count,total:word);
begin
 inc(decodeLow,under*decodeRange);
 decodeRange:=decodeRange*count;
 while true do begin
  if (decodeLow xor (decodeLow+decodeRange))>=ENET_RANGE_CODER_TOP then begin
   if decodeRange>=ENET_RANGE_CODER_BOTTOM then begin
    break;
   end;
   decodeRange:=(-decodeLow) and (ENET_RANGE_CODER_BOTTOM-1);
  end;
  decodeCode:=decodeCode shl 8;
  if ptruint(inData)<ptruint(inEnd) then begin
   decodeCode:=decodeCode or inData^;
   inc(inData);
  end;
  decodeRange:=decodeRange shl 8;
  decodeLow:=decodeLow shl 8;
 end;
end;

function ENET_CONTEXT_TRY_DECODE(rangeCoder:PENetRangeCoder;context:PENetSymbol;var symbol_:PENetSymbol;var code:word;var value_:byte;var under_,count_:word;update,minimum:word):boolean;
var node:PENetSymbol;
    after,before:word;
begin
 result:=false;
 under_:=0;
 count_:=minimum;
 if context^.symbols=0 then begin
  exit;
 end else begin
  node:=@PENetSymbols(pointer(context))^[context^.symbols];
  while true do begin
   after:=under_+node^.under+((node^.value+1)*minimum);
   before:=node^.count+minimum;
   if code>=after then begin
    inc(under_,node^.under);
    if node^.right<>0 then begin
     inc(node,node^.right);
     continue;
    end;
    exit;
   end else if code<(after-before) then begin
    inc(node^.under,update);
    if node^.left<>0 then begin
     inc(node,node^.left);
     continue;
    end;
    exit;
   end else begin
    value_:=node^.value;
    inc(count_,node^.count);
    under_:=after-before;
    inc(node^.under,update);
    inc(node^.count,update);
    symbol_:=node;
   end;
   break;
  end;
 end;
 result:=true;
end;

procedure ENET_CONTEXT_ROOT_DECODE(rangeCoder:PENetRangeCoder;context:PENetSymbol;var symbol_:PENetSymbol;var code:word;var value_:byte;var under_,count_:word;update,minimum:word;var nextSymbol:longint);
var node:PENetSymbol;
    after,before:word;
begin
 under_:=0;
 count_:=minimum;
 if context^.symbols=0 then begin
  value_:=code div minimum;
  under_:=code-(code mod minimum);
  ENET_SYMBOL_CREATE(rangeCoder,symbol_,value_,update,nextSymbol);
  context^.symbols:=(ptrint(symbol_)-ptrint(context)) div sizeof(TENetSymbol);
 end else begin
  node:=@PENetSymbols(pointer(context))^[context^.symbols];
  while true do begin
   after:=under_+node^.under+((node^.value+1)*minimum);
   before:=node^.count+minimum;
   if code>=after then begin
    inc(under_,node^.under);
    if node^.right<>0 then begin
     inc(node,node^.right);
     continue;
    end;
    value_:=(node^.value+1)+((code-after) div minimum);
    under_:=code-((code-after) mod minimum);
    ENET_SYMBOL_CREATE(rangeCoder,symbol_,value_,update,nextSymbol);
    node^.right:=(ptrint(symbol_)-ptrint(node)) div sizeof(TENetSymbol);
   end else if code<(after-before) then begin
    inc(node^.under,update);
    if node^.left<>0 then begin
     inc(node,node^.left);
     continue;
    end;
    value_:=(node^.value-1)-((((after-before)-code)-1) div minimum);
    under_:=code-((((after-before)-code)-1) mod minimum);
    ENET_SYMBOL_CREATE(rangeCoder,symbol_,value_,update,nextSymbol);
    node^.left:=(ptrint(symbol_)-ptrint(node)) div sizeof(TENetSymbol);
   end else begin
    value_:=node^.value;
    inc(count_,node^.count);
    under_:=after-before;
    inc(node^.under,update);
    inc(node^.count,update);
    symbol_:=node;
   end;
   break;
  end;
 end;
end;

function enet_range_coder_decompress(context:pointer;inData:pointer;inLimit:longint;outData:pointer;outLimit:longint):longint;
label patchContexts;
type pword=^word;
var rangeCoder:PENetRangeCoder;
    outStart,outEnd,inEnd:pbyte;
    decodeLow,decodeCode,decodeRange:longword;
    root,subcontext,symbol,patch:PENetSymbol;
    predicted,count,under,bottom,total,code:word;
    parent:pword;
    order,nextSymbol:longint;
    value:byte;
begin
 rangeCoder:=context;
 outStart:=outData;
 outEnd:=pointer(@pansichar(outData)[outLimit]);
 inEnd:=pointer(@pansichar(inData)[inLimit]);
 decodeLow:=0;
 decodeCode:=0;
 decodeRange:=$ffffffff;
 predicted:=0;
 order:=0;
 nextSymbol:=0;
 if (not assigned(rangeCoder)) or (inLimit<=0) then begin
  result:=0;
  exit;
 end;
 ENET_CONTEXT_CREATE(rangeCoder,root,ENET_CONTEXT_ESCAPE_MINIMUM,ENET_CONTEXT_SYMBOL_MINIMUM,nextSymbol);
 ENET_RANGE_CODER_SEED(pbyte(inData),inEnd,decodeCode);
 while true do begin
  value:=0;
  parent:=@predicted;
  subcontext:=@rangeCoder^.symbols[predicted];
  while subcontext<>root do begin
   if subcontext^.escapes<=0 then begin
    continue;
   end;
   total:=subcontext^.total;
   if subcontext^.escapes>=total then begin
    continue;
   end;
   code:=ENET_RANGE_CODER_READ(decodeCode,decodeLow,decodeRange,total);
   if code<subcontext^.escapes then begin
    ENET_RANGE_CODER_DECODE(pbyte(inData),inEnd,decodeCode,decodeLow,decodeRange,0,subcontext^.escapes,total);
    continue;
   end;
   dec(code,subcontext^.escapes);
   if not ENET_CONTEXT_TRY_DECODE(rangeCoder,subcontext,symbol,code,value,under,count,ENET_SUBCONTEXT_SYMBOL_DELTA,0) then begin
    result:=0;
    exit;
   end;
   bottom:=(ptrint(symbol)-ptrint(@rangeCoder^.symbols[0])) div sizeof(TENetSymbol);
   ENET_RANGE_CODER_DECODE(pbyte(inData),inEnd,decodeCode,decodeLow,decodeRange,subcontext^.escapes+under,count,total);
   inc(subcontext^.total,ENET_SUBCONTEXT_SYMBOL_DELTA);
   if (count>($FF-(2*ENET_SUBCONTEXT_SYMBOL_DELTA))) or (subcontext^.total>(ENET_RANGE_CODER_BOTTOM-$100)) then begin
    ENET_CONTEXT_RESCALE(subcontext,0);
   end;
   goto patchContexts;
   subcontext:=@rangeCoder^.symbols[subcontext^.parent];
  end;
  total:=root^.total;
  code:=ENET_RANGE_CODER_READ(decodeCode,decodeLow,decodeRange,total);
  if code<root^.escapes then begin
   ENET_RANGE_CODER_DECODE(pbyte(inData),inEnd,decodeCode,decodeLow,decodeRange,0,root^.escapes,total);
   break;
  end;
  dec(code,root^.escapes);
  ENET_CONTEXT_ROOT_DECODE(rangeCoder,root,symbol,code,value,under,count,ENET_CONTEXT_SYMBOL_DELTA,ENET_CONTEXT_SYMBOL_MINIMUM,nextSymbol);
  bottom:=(ptrint(symbol)-ptrint(@rangeCoder^.symbols[0])) div sizeof(TENetSymbol);
  ENET_RANGE_CODER_DECODE(pbyte(inData),inEnd,decodeCode,decodeLow,decodeRange,root^.escapes+under,count,total);
  inc(root^.total,ENET_CONTEXT_SYMBOL_DELTA);
  if (count>(($FF-(2*ENET_CONTEXT_SYMBOL_DELTA))+ENET_CONTEXT_SYMBOL_MINIMUM)) or (root^.total>(ENET_RANGE_CODER_BOTTOM-$100)) then begin
   ENET_CONTEXT_RESCALE(root,ENET_CONTEXT_SYMBOL_MINIMUM);
  end;
patchContexts:
  patch:=@rangeCoder^.symbols[predicted];
  while patch<>subcontext do begin
   ENET_CONTEXT_ENCODE(rangeCoder,patch,symbol,value,under,count,ENET_SUBCONTEXT_SYMBOL_DELTA,0,nextSymbol);
   parent^:=(ptrint(symbol)-ptrint(@rangeCoder^.symbols[0])) div sizeof(TENetSymbol);
   parent:=@symbol^.parent;
   if count<=0 then begin
    inc(patch^.escapes,ENET_SUBCONTEXT_ESCAPE_DELTA);
    inc(patch^.total,ENET_SUBCONTEXT_ESCAPE_DELTA);
   end;
   inc(patch^.total,ENET_SUBCONTEXT_SYMBOL_DELTA);
   if (count>($FF-(2*ENET_SUBCONTEXT_SYMBOL_DELTA))) or (patch^.total>(ENET_RANGE_CODER_BOTTOM-$100)) then begin
    ENET_CONTEXT_RESCALE(patch,0);
   end;
   patch:=@rangeCoder^.symbols[patch^.parent];
  end;
  parent^:=bottom;
  ENET_RANGE_CODER_OUTPUT(pbyte(outData),outEnd,value);
  if order>=ENET_SUBCONTEXT_ORDER then begin
   predicted:=rangeCoder^.symbols [predicted].parent;
  end else begin
   inc(order);
  end;
  ENET_RANGE_CODER_FREE_SYMBOLS(rangeCoder,root,nextSymbol,predicted,order);
 end;
 result:=ptrint(outData)-ptrint(outStart);
end;

function enet_host_compress_with_range_coder(host:PENetHost):longint;
var compressor:TENetCompressor;
begin
 FillChar(compressor,sizeof(TENetcompressor),#0);
 compressor.context:=enet_range_coder_create();
 if not assigned(compressor.context) then begin
  result:=-1;
 end else begin
  compressor.compress:=enet_range_coder_compress;
  compressor.decompress:=enet_range_coder_decompress;
  compressor.destroy:=enet_range_coder_destroy;
  enet_host_compress(host,@compressor);
  result:=0;
 end;
end;

function enet_packet_create(data:pointer;dataLength:longint;flags:Longword):PENetPacket;
var packet:PENetPacket;
begin
 GetMem(packet,sizeof(TENetPacket));
 if assigned(packet) then begin
  FillCHar(packet^,sizeof(TENetPacket),AnsiChar(#0));
 end else begin
  result:=nil;
  exit;
 end;
 if (flags and ENET_PACKET_FLAG_NO_ALLOCATE)<>0 then begin
  packet^.data:=data;
 end else if dataLength<=0 then begin
  packet^.data:=nil;
 end else begin
  GetMem(packet^.data,dataLength);
  if not assigned(packet^.data) then begin
   FreeMem(packet);
   result:=nil;
   exit;
  end;
  if assigned(data) then begin
   Move(data^,packet^.data^,dataLength);
  end else begin
   FillChar(packet^.data^,dataLength,AnsiChar(#0));
  end;
 end;
 packet^.referenceCount:=0;
 packet^.flags:=flags;
 packet^.dataLength:=dataLength;
 packet^.freeCallback:=nil;
 packet^.userData:=nil;
 result:=packet;
end;

function enet_packet_create(const data:TENETRawByteString;flags:Longword):PENetPacket; overload;
begin
 if length(data)>0 then begin
  result:=enet_packet_create(@data[1],length(data),flags);
 end;
end;

procedure enet_packet_destroy(packet:PENetPacket);
begin
 if not assigned(packet) then begin
  exit;
 end;
 if assigned(packet^.freeCallback) then begin
  packet^.freeCallback(packet);
 end;
 if ((packet^.flags and ENET_PACKET_FLAG_NO_ALLOCATE)=0) and assigned(packet^.data) then begin
  FreeMem(packet^.data);
 end;
 FreeMem(packet);
end;

function enet_packet_resize(packet:PENetPacket;dataLength:longword):longint;
var newData:pointer;
begin
 if (dataLength<=packet^.dataLength) or ((packet^.flags and ENET_PACKET_FLAG_NO_ALLOCATE)<>0) then begin
  packet^.dataLength:=dataLength;
  result:=0;
  exit;
 end;
 GetMem(newData,DataLength);
 if not assigned(newData) then begin
  result:=-1;
  exit;
 end;
 FillChar(newData^,DataLength,AnsiChar(#0));
 Move(packet^.data^,newData^,packet^.dataLength);
 FreeMem(packet^.data);
 packet^.data:=newData;
 packet^.dataLength:=dataLength;
 result:=0;
end;

const initializedCRC32:boolean=false;

var crcTable:array[byte] of longword;

function reflect_crc(val:longword;bits:longint):longword;
var bit:longint;
begin
 result:=0;
 for bit:=0 to bits-1 do begin
  if (val and 1)<>0 then begin
   result:=result or (1 shl ((bits-1)-bit));
  end;
  val:=val shr 1;
 end;
end;

procedure initialize_crc32;
var b,o:longint;
    crc:longword;
begin
 for b:=0 to 255 do begin
  crc:=reflect_crc(b,8) shl 24;
  for o:=0 to 7 do begin
   if (crc and $80000000)<>0 then begin
    crc:=(crc shl 1) xor $04c11db7;
   end else begin
    crc:=crc shl 1;
   end;
  end;
  crcTable[b]:=reflect_crc(crc,32);
 end;
 initializedCRC32:=true;
end;
    
function enet_crc32(buffers:PENetBuffer;bufferCount:longint):longword;
var crc:longword;
    data,dataEnd:pansichar;
begin
 crc:=$FFFFFFFF;
 if not initializedCRC32 then begin
  initialize_crc32;
 end;
 while bufferCount>0 do begin
  dec(bufferCount);
  data:=buffers^.data;
  dataEnd:=@data[buffers^.dataLength];
  while data<dataEnd do begin
   crc:=(crc shr 8) xor crcTable[(crc and $FF) xor byte(data^)];
   inc(data);
  end;
  inc(buffers);
 end;
 result:=ENET_HOST_TO_NET_32(not crc);
end;

procedure enet_peer_throttle_configure(peer:PENetPeer;interval,acceleration,deceleration:longword);
var command:PENetProtocol;
begin
 peer^.packetThrottleInterval:=interval;
 peer^.packetThrottleAcceleration:=acceleration;
 peer^.packetThrottleDeceleration:=deceleration;
 command.header.command:=ENET_PROTOCOL_COMMAND_THROTTLE_CONFIGURE or ENET_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE;
 command.header.channelID:=$FF;
 command.throttleConfigure.packetThrottleInterval:=ENET_HOST_TO_NET_32(interval);
 command.throttleConfigure.packetThrottleAcceleration:=ENET_HOST_TO_NET_32(acceleration);
 command.throttleConfigure.packetThrottleDeceleration:=ENET_HOST_TO_NET_32(deceleration);
 enet_peer_queue_outgoing_command(peer,@command,nil,0,0);
end;

function enet_peer_throttle(peer:PENetPeer;rtt:longword):longint;
begin
 if peer^.lastRoundTripTime<=peer^.lastRoundTripTimeVariance then begin
  peer^.packetThrottle:=peer^.packetThrottleLimit;
  result:=0;
 end else if rtt<peer^.lastRoundTripTime then begin
  inc(peer^.packetThrottle,peer^.packetThrottleAcceleration);
  if peer^.packetThrottle>peer^.packetThrottleLimit then begin
   peer^.packetThrottle:=peer^.packetThrottleLimit;
  end;
  result:=1;
 end else if rtt>(peer^.lastRoundTripTime+(2*peer^.lastRoundTripTimeVariance)) then begin
  if peer^.packetThrottle>peer^.packetThrottleDeceleration then begin
   dec(peer^.packetThrottle,peer^.packetThrottleDeceleration);
  end else begin
   peer^.packetThrottle:=0;
  end;
  result:=-1;
 end else begin
  result:=0;
 end;
end;

function enet_peer_send(peer:PENetPeer;channelID:byte;packet:PENetPacket):longint;
var channel:PENetChannel;
    command:TENetProtocol;
    fragmentLength:longword;
    fragmentCount,fragmentNumber,fragmentOffset:longword;
    commandNumber:byte;
    startSequenceNumber:word;
    fragments:TENetList;
    fragment:PENetOutgoingCommand;
begin
 channel:=@peer^.channels[channelID];
 if (peer^.state<>ENET_PEER_STATE_CONNECTED) or (channelID>=peer^.channelCount) or (packet^.dataLength>peer^.host^.maximumPacketSize) then begin
  result:=-1;
  exit;
 end;
 fragmentLength:=(peer^.mtu-sizeof(TENetProtocolHeader))-sizeof(TENetProtocolSendFragment);
 if assigned(peer^.host^.checksum) then begin
  dec(fragmentLength,sizeof(longword));
 end;
 if packet^.dataLength>fragmentLength then begin
  fragmentCount:=(packet^.dataLength+(fragmentLength-1)) div fragmentLength;
  if fragmentCount>ENET_PROTOCOL_MAXIMUM_FRAGMENT_COUNT then begin
   result:=-1;
   exit;
  end;
  if ((packet^.flags and (ENET_PACKET_FLAG_RELIABLE or ENET_PACKET_FLAG_UNRELIABLE_FRAGMENT))=ENET_PACKET_FLAG_UNRELIABLE_FRAGMENT) and (channel^.outgoingUnreliableSequenceNumber<$FFFF) then begin
   commandNumber:=ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE_FRAGMENT;
   startSequenceNumber:=ENET_HOST_TO_NET_16 (channel^.outgoingUnreliableSequenceNumber+1);
  end else begin
   commandNumber:=ENET_PROTOCOL_COMMAND_SEND_FRAGMENT or ENET_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE;
   startSequenceNumber:=ENET_HOST_TO_NET_16(channel^.outgoingReliableSequenceNumber+1);
  end;
  enet_list_clear(@fragments);
  fragmentNumber:=0;
  fragmentOffset:=0;
  while fragmentOffset<packet^.dataLength do begin
   if (packet^.dataLength-fragmentOffset)<fragmentLength then begin
    fragmentLength:=packet^.dataLength-fragmentOffset;
   end;
   GetMem(fragment,sizeof(TENetOutgoingCommand));
   if assigned(Fragment) then begin
    FillChar(fragment^,sizeof(TENetOutgoingCommand),AnsiChar(#0));
   end else begin
    while not enet_list_empty(@fragments) do begin
     fragment:=PENetOutgoingCommand(enet_list_remove(enet_list_begin(@fragments)));
     FreeMem(fragment);
    end;
    result:=-1;
    exit;
   end;
   fragment^.fragmentOffset:=fragmentOffset;
   fragment^.fragmentLength:=fragmentLength;
   fragment^.packet:=packet;
   fragment^.command.header.command:=commandNumber;
   fragment^.command.header.channelID:=channelID;
   fragment^.command.sendFragment.startSequenceNumber:=startSequenceNumber;
   fragment^.command.sendFragment.dataLength:=ENET_HOST_TO_NET_16(fragmentLength);
   fragment^.command.sendFragment.fragmentCount:=ENET_HOST_TO_NET_32(fragmentCount);
   fragment^.command.sendFragment.fragmentNumber:=ENET_HOST_TO_NET_32(fragmentNumber);
   fragment^.command.sendFragment.totalLength:=ENET_HOST_TO_NET_32(packet^.dataLength);
   fragment^.command.sendFragment.fragmentOffset:=ENET_NET_TO_HOST_32(fragmentOffset);
   enet_list_insert(enet_list_end(@fragments),fragment);
   inc(fragmentNumber);
   inc(fragmentOffset,fragmentLength);
  end;
  inc(packet^.referenceCount,fragmentNumber);
  while not enet_list_empty(@fragments) do begin
   fragment:=PENetOutgoingCommand(enet_list_remove(enet_list_begin(@fragments)));
   enet_peer_setup_outgoing_command(peer,fragment);
  end;
  result:=0;
  exit;
 end;
 command.header.channelID:=channelID;
 if (packet^.flags and (ENET_PACKET_FLAG_RELIABLE or ENET_PACKET_FLAG_UNSEQUENCED))=ENET_PACKET_FLAG_UNSEQUENCED then begin
  command.header.command:=ENET_PROTOCOL_COMMAND_SEND_UNSEQUENCED or ENET_PROTOCOL_COMMAND_FLAG_UNSEQUENCED;
  command.sendUnsequenced.dataLength:=ENET_HOST_TO_NET_16(packet^.dataLength);
 end else if ((packet^.flags and ENET_PACKET_FLAG_RELIABLE)<>0) or (channel^.outgoingUnreliableSequenceNumber>=$FFFF) then begin
  command.header.command:=ENET_PROTOCOL_COMMAND_SEND_RELIABLE or ENET_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE;
  command.sendReliable.dataLength:=ENET_HOST_TO_NET_16 (packet^.dataLength);
 end else begin
  command.header.command:=ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE;
  command.sendUnreliable.dataLength:=ENET_HOST_TO_NET_16(packet^.dataLength);
 end;
 if assigned(enet_peer_queue_outgoing_command(peer,@command,packet,0,packet^.dataLength)) then begin
  result:=0;
 end else begin
  result:=-1;
 end;
end;

function enet_peer_receive(peer:PENetPeer;channelID:pbyte):PENetPacket;
var incomingCommand:PENetIncomingCommand;
    packet:PENetPacket;
begin   
 if enet_list_empty(@peer^.dispatchedCommands) then begin
  result:=nil;
  exit;
 end;
 incomingCommand:=PENetIncomingCommand(enet_list_remove(enet_list_begin(@peer^.dispatchedCommands)));
 if assigned(channelID) then begin
  channelID^:=incomingCommand^.command.header.channelID;
 end;
 packet:=incomingCommand^.packet;
 dec(packet^.referenceCount);
 if assigned(incomingCommand^.fragments) then begin
  FreeMem(incomingCommand^.fragments);
 end;
 FreeMem(incomingCommand);
 dec(peer^.totalWaitingData,packet^.dataLength);
 result:=packet;
end;

procedure enet_peer_reset_outgoing_commands(queue:PENetList);
var outgoingCommand:PENetOutgoingCommand;
begin
 while not enet_list_empty(queue) do begin
  outgoingCommand:=PENetOutgoingCommand(enet_list_remove(enet_list_begin(queue)));
  if assigned(outgoingCommand^.packet) then begin
   dec(outgoingCommand^.packet^.referenceCount);
   if outgoingCommand^.packet^.referenceCount=0 then begin
    enet_packet_destroy(outgoingCommand^.packet);
   end;
  end;
  FreeMem(outgoingCommand);
 end;
end;

procedure enet_peer_remove_incoming_commands(queue:PENetList;startCommand,endCommand:TENetListIterator);
var currentCommand:TENetListIterator;
    incomingCommand:PENetIncomingCommand;
begin
 currentCommand:=startCommand;
 while currentCommand<>endCommand do begin
  incomingCommand:=PENetIncomingCommand(currentCommand);
  currentCommand:=enet_list_next(currentCommand);
  enet_list_remove(@incomingCommand^.incomingCommandList);
  if assigned(incomingCommand^.packet) then begin
   dec(incomingCommand^.packet^.referenceCount);
   if incomingCommand^.packet^.referenceCount=0 then begin
    enet_packet_destroy(incomingCommand^.packet);
   end;
  end;
  if assigned(incomingCommand^.fragments) then begin
   FreeMem(incomingCommand^.fragments);
  end;
  FreeMem(incomingCommand);
 end;
end;

procedure enet_peer_reset_incoming_commands(queue:PENetList);
begin
 enet_peer_remove_incoming_commands(queue,enet_list_begin(queue),enet_list_end(queue));
end;

procedure enet_peer_reset_queues(peer:PENetPeer);
var channel:PENetChannel;
    i:longint;
begin
 if peer^.needsDispatch then begin
  enet_list_remove(@peer^.dispatchList);
  peer^.needsDispatch:=false;
 end;
 while not enet_list_empty(@peer^.acknowledgements) do begin
  FreeMem(enet_list_remove(enet_list_begin(@peer^.acknowledgements)));
 end;
 enet_peer_reset_outgoing_commands(@peer^.sentReliableCommands);
 enet_peer_reset_outgoing_commands(@peer^.sentUnreliableCommands);
 enet_peer_reset_outgoing_commands(@peer^.outgoingReliableCommands);
 enet_peer_reset_outgoing_commands(@peer^.outgoingUnreliableCommands);
 enet_peer_reset_incoming_commands(@peer^.dispatchedCommands);
 if assigned(peer^.channels) and (peer^.channelCount>0) then begin
  for i:=0 to peer^.channelCount-1 do begin
   channel:=@peer^.channels[i];
   enet_peer_reset_incoming_commands(@channel^.incomingReliableCommands);
   enet_peer_reset_incoming_commands(@channel^.incomingUnreliableCommands);
  end;
  FreeMem(peer^.channels);
 end;
 peer^.channels:=nil;
 peer^.channelCount:=0;
end;

procedure enet_peer_reset(peer:PENetPeer);
begin
 enet_peer_on_disconnect(peer);
 peer^.outgoingPeerID:=ENET_PROTOCOL_MAXIMUM_PEER_ID;
 peer^.connectID:=0; 
 peer^.state:=ENET_PEER_STATE_DISCONNECTED;
 peer^.incomingBandwidth:=0;
 peer^.outgoingBandwidth:=0;
 peer^.incomingBandwidthThrottleEpoch:=0;
 peer^.outgoingBandwidthThrottleEpoch:=0;
 peer^.incomingDataTotal:=0;
 peer^.outgoingDataTotal:=0;
 peer^.lastSendTime:=0;
 peer^.lastReceiveTime:=0;
 peer^.nextTimeout:=0;
 peer^.earliestTimeout:=0;
 peer^.packetLossEpoch:=0;
 peer^.packetsSent:=0;
 peer^.packetsLost:=0;
 peer^.packetLoss:=0;
 peer^.packetLossVariance:=0;
 peer^.packetThrottle:=ENET_PEER_DEFAULT_PACKET_THROTTLE;
 peer^.packetThrottleLimit:=ENET_PEER_PACKET_THROTTLE_SCALE;
 peer^.packetThrottleCounter:=0;
 peer^.packetThrottleEpoch:=0;
 peer^.packetThrottleAcceleration:=ENET_PEER_PACKET_THROTTLE_ACCELERATION;
 peer^.packetThrottleDeceleration:=ENET_PEER_PACKET_THROTTLE_DECELERATION;
 peer^.packetThrottleInterval:=ENET_PEER_PACKET_THROTTLE_INTERVAL;
 peer^.pingInterval:=ENET_PEER_PING_INTERVAL_;
 peer^.timeoutLimit:=ENET_PEER_TIMEOUT_LIMIT;
 peer^.timeoutMinimum:=ENET_PEER_TIMEOUT_MINIMUM;
 peer^.timeoutMaximum:=ENET_PEER_TIMEOUT_MAXIMUM;
 peer^.lastRoundTripTime:=ENET_PEER_DEFAULT_ROUND_TRIP_TIME;
 peer^.lowestRoundTripTime:=ENET_PEER_DEFAULT_ROUND_TRIP_TIME;
 peer^.lastRoundTripTimeVariance:=0;
 peer^.highestRoundTripTimeVariance:=0;
 peer^.roundTripTime:=ENET_PEER_DEFAULT_ROUND_TRIP_TIME;
 peer^.roundTripTimeVariance:=0;
 peer^.mtu:=peer^.host^.mtu;
 peer^.reliableDataInTransit:=0;
 peer^.outgoingReliableSequenceNumber:=0;
 peer^.windowSize:=ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE;
 peer^.incomingUnsequencedGroup:=0;
 peer^.outgoingUnsequencedGroup:=0;
 peer^.eventData:=0;
 peer^.totalWaitingData:=0;
 FillChar(peer^.unsequencedWindow,sizeof(peer^.unsequencedWindow),AnsiChar(#0));
 enet_peer_reset_queues(peer);
end;

procedure enet_peer_ping(peer:PENetPeer);
var command:TENetProtocol;
begin
 if peer^.state=ENET_PEER_STATE_CONNECTED then begin
  command.header.command:=ENET_PROTOCOL_COMMAND_PING or ENET_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE;
  command.header.channelID:=$FF;
  enet_peer_queue_outgoing_command(peer,@command,nil,0,0);
 end;
end;

procedure enet_peer_ping_interval(peer:PENetPeer;pingInterval:longword);
begin
 if pingInterval<>0 then begin
  peer^.pingInterval:=pingInterval;
 end else begin
  peer^.pingInterval:=ENET_PEER_PING_INTERVAL_;
 end;
end;

procedure enet_peer_timeout(peer:PENetPeer;timeoutLimit,timeoutMinimum,timeoutMaximum:longword);
begin
 if timeoutLimit<>0 then begin
  peer^.timeoutLimit:=timeoutLimit;
 end else begin
  peer^.timeoutLimit:=ENET_PEER_TIMEOUT_LIMIT;
 end;
 if timeoutMinimum<>0 then begin
  peer^.timeoutMinimum:=timeoutMinimum;
 end else begin
  peer^.timeoutMinimum:=ENET_PEER_TIMEOUT_MINIMUM;
 end;
 if timeoutMaximum<>0 then begin
  peer^.timeoutMaximum:=timeoutMaximum;
 end else begin
  peer^.timeoutMaximum:=ENET_PEER_TIMEOUT_MAXIMUM;
 end;
end;

procedure enet_peer_disconnect_now(peer:PENetPeer;data:longword);
var command:TENetProtocol;
begin
 if peer^.state=ENET_PEER_STATE_DISCONNECTED then begin
  exit;
 end;
 if (peer^.state<>ENET_PEER_STATE_ZOMBIE) and (peer^.state<>ENET_PEER_STATE_DISCONNECTING) then begin
  enet_peer_reset_queues(peer);
  command.header.command:=ENET_PROTOCOL_COMMAND_DISCONNECT or ENET_PROTOCOL_COMMAND_FLAG_UNSEQUENCED;
  command.header.channelID:=$FF;
  command.disconnect.data:=ENET_HOST_TO_NET_32(data);
  enet_peer_queue_outgoing_command(peer,@command,nil,0,0);
  enet_host_flush(peer^.host);
 end;
 enet_peer_reset(peer);
end;

procedure enet_peer_disconnect(peer:PENetPeer;data:longword);
var command:TENetProtocol;
begin
 if peer^.state in [ENET_PEER_STATE_DISCONNECTING,ENET_PEER_STATE_DISCONNECTED,ENET_PEER_STATE_ACKNOWLEDGING_DISCONNECT,ENET_PEER_STATE_ZOMBIE] then begin
  exit;
 end;
 enet_peer_reset_queues(peer);
 command.header.command:=ENET_PROTOCOL_COMMAND_DISCONNECT;
 command.header.channelID:=$FF;
 command.disconnect.data:=ENET_HOST_TO_NET_32(data);
 if peer^.state in [ENET_PEER_STATE_CONNECTED,ENET_PEER_STATE_DISCONNECT_LATER] then begin
  command.header.command:=command.header.command or ENET_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE;
 end else begin
  command.header.command:=command.header.command or ENET_PROTOCOL_COMMAND_FLAG_UNSEQUENCED;
 end;
 enet_peer_queue_outgoing_command(peer,@command,nil,0,0);
 if peer^.state in [ENET_PEER_STATE_CONNECTED,ENET_PEER_STATE_DISCONNECT_LATER] then begin
  enet_peer_on_disconnect(peer);
  peer^.state:=ENET_PEER_STATE_DISCONNECTING;
 end else begin
  enet_host_flush(peer^.host);
  enet_peer_reset(peer);
 end;
end;

procedure enet_peer_disconnect_later(peer:PENetPeer;data:longword);
begin
 if (peer^.state in [ENET_PEER_STATE_CONNECTED,ENET_PEER_STATE_DISCONNECT_LATER]) and not (enet_list_empty(@peer^.outgoingReliableCommands) and enet_list_empty(@peer^.outgoingUnreliableCommands) and enet_list_empty(@peer^.sentReliableCommands)) then begin
  peer^.state:=ENET_PEER_STATE_DISCONNECT_LATER;
  peer^.eventData:=data;
 end else begin
  enet_peer_disconnect(peer,data);
 end;
end;

function enet_peer_queue_acknowledgement(peer:PENetPeer;command:PENetProtocol;sentTime:word):PENetAcknowledgement;
var acknowledgement:PENetAcknowledgement;
    channel:PENetChannel;
    reliableWindow,currentWindow:word;
begin
 if command^.header.channelID<peer^.channelCount then begin
  channel:=@peer^.channels[command^.header.channelID];
  reliableWindow:=command^.header.reliableSequenceNumber div ENET_PEER_RELIABLE_WINDOW_SIZE;
  currentWindow:=channel^.incomingReliableSequenceNumber div ENET_PEER_RELIABLE_WINDOW_SIZE;
  if command^.header.reliableSequenceNumber<channel^.incomingReliableSequenceNumber then begin
   inc(reliableWindow,ENET_PEER_RELIABLE_WINDOWS);
  end;
  if (reliableWindow>=(currentWindow+(ENET_PEER_FREE_RELIABLE_WINDOWS-1))) and (reliableWindow<=(currentWindow+ENET_PEER_FREE_RELIABLE_WINDOWS)) then begin
   result:=nil;
   exit;
  end;
 end;
 GetMem(acknowledgement,SizeOf(TENetAcknowledgement));
 if assigned(acknowledgement) then begin
  FillChar(acknowledgement^,SizeOf(TENetAcknowledgement),AnsiChar(#0));
 end else begin
  result:=nil;
  exit;
 end;
 inc(peer^.outgoingDataTotal,sizeof(TENetProtocolAcknowledge));
 acknowledgement^.sentTime:=sentTime;
 acknowledgement^.command:=command^;
 enet_list_insert(enet_list_end(@peer^.acknowledgements),acknowledgement);
 result:=acknowledgement;
end;

procedure enet_peer_setup_outgoing_command(peer:PENetPeer;outgoingCommand:PENetOutgoingCommand);
var channel:PENetChannel;
begin
 channel:=@peer^.channels[outgoingCommand^.command.header.channelID];
 inc(peer^.outgoingDataTotal,enet_protocol_command_size(outgoingCommand^.command.header.command)+outgoingCommand^.fragmentLength);
 if outgoingCommand^.command.header.channelID=$FF then begin
  inc(peer^.outgoingReliableSequenceNumber);
  outgoingCommand^.reliableSequenceNumber:=peer^.outgoingReliableSequenceNumber;
  outgoingCommand^.unreliableSequenceNumber:=0;
 end else if (outgoingCommand^.command.header.command and ENET_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE)<>0 then begin
  inc(channel^.outgoingReliableSequenceNumber);
  channel^.outgoingUnreliableSequenceNumber:=0;
  outgoingCommand^.reliableSequenceNumber:=channel^.outgoingReliableSequenceNumber;
  outgoingCommand^.unreliableSequenceNumber:=0;
 end else if (outgoingCommand^.command.header.command and ENET_PROTOCOL_COMMAND_FLAG_UNSEQUENCED)<>0 then begin
  inc(peer^.outgoingUnsequencedGroup);
  outgoingCommand^.reliableSequenceNumber:=0;
  outgoingCommand^.unreliableSequenceNumber:=0;
 end else begin
  if outgoingCommand^.fragmentOffset=0 then begin
   inc(channel^.outgoingUnreliableSequenceNumber);
  end;
  outgoingCommand^.reliableSequenceNumber:=channel^.outgoingReliableSequenceNumber;
  outgoingCommand^.unreliableSequenceNumber:=channel^.outgoingUnreliableSequenceNumber;
 end;
 outgoingCommand^.sendAttempts:=0;
 outgoingCommand^.sentTime:=0;
 outgoingCommand^.roundTripTimeout:=0;
 outgoingCommand^.roundTripTimeoutLimit:=0;
 outgoingCommand^.command.header.reliableSequenceNumber:=ENET_HOST_TO_NET_16(outgoingCommand^.reliableSequenceNumber);
 case outgoingCommand^.command.header.command and ENET_PROTOCOL_COMMAND_MASK of
  ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE:begin
   outgoingCommand^.command.sendUnreliable.unreliableSequenceNumber:=ENET_HOST_TO_NET_16 (outgoingCommand^.unreliableSequenceNumber);
  end;
  ENET_PROTOCOL_COMMAND_SEND_UNSEQUENCED:begin
   outgoingCommand^.command.sendUnsequenced.unsequencedGroup:=ENET_HOST_TO_NET_16 (peer^.outgoingUnsequencedGroup);
  end;
 end;
 if (outgoingCommand^.command.header.command and ENET_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE)<>0 then begin
  enet_list_insert(enet_list_end(@peer^.outgoingReliableCommands),outgoingCommand);
 end else begin
  enet_list_insert(enet_list_end(@peer^.outgoingUnreliableCommands),outgoingCommand);
 end;
end;

function enet_peer_queue_outgoing_command(peer:PENetPeer;command:PENetProtocol;packet:PENetPacket;offset:longword;length:word):PENetOutgoingCommand;
var outgoingCommand:PENetOutgoingCommand;
begin
 GetMem(outgoingCommand,SizeOf(TENetOutgoingCommand));
 if assigned(outgoingCommand) then begin
  FillChar(outgoingCommand^,SizeOf(TENetOutgoingCommand),AnsiChar(#0));
 end else begin
  result:=nil;
  exit;
 end;
 outgoingCommand^.command:=command^;
 outgoingCommand^.fragmentOffset:=offset;
 outgoingCommand^.fragmentLength:=length;
 outgoingCommand^.packet:=packet;
 if assigned(packet) then begin
  inc(packet^.referenceCount);
 end;
 enet_peer_setup_outgoing_command(peer,outgoingCommand);
 result:=outgoingCommand;
end;

procedure enet_peer_dispatch_incoming_unreliable_commands(peer:PENetPeer;channel:PENetChannel);
var droppedCommand,startCommand,currentCommand:TENetListIterator;
    incomingCommand:PENetIncomingCommand;
    reliableWindow,currentWindow:word;
begin
 droppedCommand:=enet_list_begin(@channel^.incomingUnreliableCommands);
 startCommand:=droppedCommand;
 currentCommand:=droppedCommand;
 while currentCommand<>enet_list_end(@channel^.incomingUnreliableCommands) do begin
  incomingCommand:=PENetIncomingCommand(currentCommand);
  if (incomingCommand^.command.header.command and ENET_PROTOCOL_COMMAND_MASK)=ENET_PROTOCOL_COMMAND_SEND_UNSEQUENCED then begin
   currentCommand:=enet_list_next(currentCommand);
   continue;
  end;
  if incomingCommand^.reliableSequenceNumber=channel^.incomingReliableSequenceNumber then begin
   if incomingCommand^.fragmentsRemaining<=0 then begin
    channel^.incomingUnreliableSequenceNumber:=incomingCommand^.unreliableSequenceNumber;
    currentCommand:=enet_list_next(currentCommand);
    continue;
   end;
   if startCommand<>currentCommand then begin
    enet_list_move(enet_list_end(@peer^.dispatchedCommands),startCommand,enet_list_previous(currentCommand));
    if not peer^.needsDispatch then begin
     enet_list_insert(enet_list_end(@peer^.host^.dispatchQueue),@peer^.dispatchList);
     peer^.needsDispatch:=true;
    end;
    droppedCommand:=currentCommand;
   end else if droppedCommand<>currentCommand then begin
    droppedCommand:=enet_list_previous(currentCommand);
   end;
  end else begin
   reliableWindow:=incomingCommand^.reliableSequenceNumber div ENET_PEER_RELIABLE_WINDOW_SIZE;
   currentWindow:=channel^.incomingReliableSequenceNumber div ENET_PEER_RELIABLE_WINDOW_SIZE;
   if incomingCommand^.reliableSequenceNumber<channel^.incomingReliableSequenceNumber then begin
    inc(reliableWindow,ENET_PEER_RELIABLE_WINDOWS);
   end;
   if (reliableWindow>=currentWindow) and (reliableWindow<(currentWindow+(ENET_PEER_FREE_RELIABLE_WINDOWS-1))) then begin
    break;
   end;
   droppedCommand:=enet_list_next(currentCommand);
   if startCommand<>currentCommand then begin
    enet_list_move(enet_list_end(@peer^.dispatchedCommands),startCommand,enet_list_previous(currentCommand));
    if not peer^.needsDispatch then begin
     enet_list_insert(enet_list_end(@peer^.host^.dispatchQueue),@peer^.dispatchList);
     peer^.needsDispatch:=true;
    end;
   end;
  end;
  startCommand:=enet_list_next(currentCommand);
  currentCommand:=enet_list_next(currentCommand);
 end;
 if startCommand<>currentCommand then begin
  enet_list_move(enet_list_end(@peer^.dispatchedCommands),startCommand,enet_list_previous(currentCommand));
  if not peer^.needsDispatch then begin
   enet_list_insert(enet_list_end(@peer^.host^.dispatchQueue),@peer^.dispatchList);
   peer^.needsDispatch:=true;
  end;
  droppedCommand:=currentCommand;
 end;
 enet_peer_remove_incoming_commands(@channel^.incomingUnreliableCommands,enet_list_begin(@channel^.incomingUnreliableCommands),droppedCommand);
end;

procedure enet_peer_dispatch_incoming_reliable_commands(peer:PENetPeer;channel:PENetChannel);
var currentCommand:TENetListIterator;
    incomingCommand:PENetIncomingCommand;
begin
 currentCommand:=enet_list_begin(@channel^.incomingReliableCommands);
 while currentCommand<>enet_list_end(@channel^.incomingReliableCommands) do begin
  incomingCommand:=PENetIncomingCommand(currentCommand);
  if (incomingCommand^.fragmentsRemaining>0) or (incomingCommand^.reliableSequenceNumber<>(channel^.incomingReliableSequenceNumber+1)) then begin
   break;
  end;
  channel^.incomingReliableSequenceNumber:=incomingCommand^.reliableSequenceNumber;
  if incomingCommand^.fragmentCount>0 then begin
   inc(channel^.incomingReliableSequenceNumber,incomingCommand^.fragmentCount-1);
  end;
  currentCommand:=enet_list_next(currentCommand);
 end;
 if currentCommand=enet_list_begin(@channel^.incomingReliableCommands) then begin
  exit;
 end;
 channel^.incomingUnreliableSequenceNumber:=0;
 enet_list_move(enet_list_end(@peer^.dispatchedCommands),enet_list_begin(@channel^.incomingReliableCommands),enet_list_previous(currentCommand));
 if not peer^.needsDispatch then begin
  enet_list_insert(enet_list_end(@peer^.host^.dispatchQueue),@peer^.dispatchList);
  peer^.needsDispatch:=true;
 end;
 if not enet_list_empty(@channel^.incomingUnreliableCommands) then begin
  enet_peer_dispatch_incoming_unreliable_commands(peer,channel);
 end;
end;

function enet_peer_queue_incoming_command(peer:PENetPeer;command:PENetProtocol;data:pointer;dataLength:ENETptruint;flags:longword;fragmentCount:longword):PENetIncomingCommand;
label discardCommand,notifyError;
var dummyCommand:TENetIncomingCommand;
    channel:PENetChannel;
    unreliableSequenceNumber,reliableSequenceNumber:longword;
    reliableWindow,currentWindow:word;
    incomingCommand:PENetIncomingCommand;
    currentCommand:TENetListIterator;
    packet:PENetPacket;
begin
 channel:=@peer^.channels[command^.header.channelID];
 unreliableSequenceNumber:=0;
 reliableSequenceNumber:=0;
 packet:=nil;

 if peer^.state=ENET_PEER_STATE_DISCONNECT_LATER then begin
  goto discardCommand;
 end;

 if (command^.header.command and ENET_PROTOCOL_COMMAND_MASK)<>ENET_PROTOCOL_COMMAND_SEND_UNSEQUENCED then begin
  reliableSequenceNumber:=command^.header.reliableSequenceNumber;
  reliableWindow:=reliableSequenceNumber div ENET_PEER_RELIABLE_WINDOW_SIZE;
  currentWindow:=channel^.incomingReliableSequenceNumber div ENET_PEER_RELIABLE_WINDOW_SIZE;
  if reliableSequenceNumber<channel^.incomingReliableSequenceNumber then begin
   inc(reliableWindow,ENET_PEER_RELIABLE_WINDOWS);
  end;
  if (reliableWindow<currentWindow) or (reliableWindow>=(currentWindow+(ENET_PEER_FREE_RELIABLE_WINDOWS-1))) then begin
   goto discardCommand;
  end;
 end;

 case command^.header.command and ENET_PROTOCOL_COMMAND_MASK of
  ENET_PROTOCOL_COMMAND_SEND_FRAGMENT,ENET_PROTOCOL_COMMAND_SEND_RELIABLE:begin
   if reliableSequenceNumber=channel^.incomingReliableSequenceNumber then begin
    goto discardCommand;
   end;
   currentCommand:=enet_list_previous(enet_list_end(@channel^.incomingReliableCommands));
   while currentCommand<>enet_list_end(@channel^.incomingReliableCommands) do begin
    incomingCommand:=PENetIncomingCommand(currentCommand);
    if reliableSequenceNumber>=channel^.incomingReliableSequenceNumber then begin
     if incomingCommand^.reliableSequenceNumber<channel^.incomingReliableSequenceNumber then begin
      currentCommand:=enet_list_previous(currentCommand);
      continue;
     end;
    end else if incomingCommand^.reliableSequenceNumber>=channel^.incomingReliableSequenceNumber then begin
     break;
    end;
    if incomingCommand^.reliableSequenceNumber<=reliableSequenceNumber then begin
     if incomingCommand^.reliableSequenceNumber<reliableSequenceNumber then begin
      break;
     end;
     goto discardCommand;
    end;
    currentCommand:=enet_list_previous(currentCommand);
   end;
  end;
  ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE,ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE_FRAGMENT:begin
   unreliableSequenceNumber:=ENET_NET_TO_HOST_16(command^.sendUnreliable.unreliableSequenceNumber);
   if (reliableSequenceNumber=channel^.incomingReliableSequenceNumber) and (unreliableSequenceNumber<=channel^.incomingUnreliableSequenceNumber) then begin
    goto discardCommand;
   end;
   currentCommand:=enet_list_previous(enet_list_end(@channel^.incomingUnreliableCommands));
   while currentCommand<>enet_list_end(@channel^.incomingUnreliableCommands) do begin
    incomingCommand:=PENetIncomingCommand(currentCommand);
    if (command^.header.command and ENET_PROTOCOL_COMMAND_MASK)=ENET_PROTOCOL_COMMAND_SEND_UNSEQUENCED then begin
     currentCommand:=enet_list_previous(currentCommand);
     continue;
    end;
    if reliableSequenceNumber>=channel^.incomingReliableSequenceNumber then begin
     if incomingCommand^.reliableSequenceNumber<channel^.incomingReliableSequenceNumber then begin
      currentCommand:=enet_list_previous(currentCommand);
      continue;
     end;
    end else if incomingCommand^.reliableSequenceNumber>=channel^.incomingReliableSequenceNumber then begin
     break;
    end;
    if incomingCommand^.reliableSequenceNumber<reliableSequenceNumber then begin
     break;
    end;
    if incomingCommand^.reliableSequenceNumber>reliableSequenceNumber then begin
     currentCommand:=enet_list_previous(currentCommand);
     continue;
    end;
    if incomingCommand^.unreliableSequenceNumber<=unreliableSequenceNumber then begin
     if incomingCommand^.unreliableSequenceNumber<unreliableSequenceNumber then begin
      break;
     end;
     goto discardCommand;
    end;
    currentCommand:=enet_list_previous(currentCommand);
   end;
  end;
  ENET_PROTOCOL_COMMAND_SEND_UNSEQUENCED:begin
   currentCommand:=enet_list_end(@channel^.incomingUnreliableCommands);
  end;
  else begin
   goto discardCommand;
  end;
 end;

 if peer^.totalWaitingData>=peer^.host^.maximumWaitingData then begin
  goto notifyError;
 end;

 packet:=enet_packet_create(data,dataLength,flags);
 if not assigned(packet) then begin
  goto notifyError;
 end;

 GetMem(incomingCommand,SizeOf(TENetincomingCommand));
 if assigned(incomingCommand) then begin
  FillChar(incomingCommand^,SizeOf(TENetincomingCommand),AnsiChar(#0));
 end else begin
  goto notifyError;
 end;

 incomingCommand^.reliableSequenceNumber:=command^.header.reliableSequenceNumber;
 incomingCommand^.unreliableSequenceNumber:=unreliableSequenceNumber and $FFFF;
 incomingCommand^.command:=command^;
 incomingCommand^.fragmentCount:=fragmentCount;
 incomingCommand^.fragmentsRemaining:=fragmentCount;
 incomingCommand^.packet:=packet;
 incomingCommand^.fragments:=nil;
    
 if fragmentCount>0 then begin
  if fragmentCount<=ENET_PROTOCOL_MAXIMUM_FRAGMENT_COUNT then begin
   GetMem(incomingCommand^.fragments,((fragmentCount+31) div 32)*sizeof(longword));
  end;
  if not assigned(incomingCommand^.fragments) then begin
   FreeMem(incomingCommand);
   goto notifyError;
  end;
  FillChar(incomingCommand^.fragments^,((fragmentCount+31) div 32)*sizeof(longword),AnsiChar(#0));
 end;

 if assigned(packet) then begin
  inc(packet^.referenceCount);
  inc(peer^.totalWaitingData,packet^.dataLength);
 end;

 enet_list_insert(enet_list_next(currentCommand),incomingCommand);

 case command^.header.command and ENET_PROTOCOL_COMMAND_MASK of
  ENET_PROTOCOL_COMMAND_SEND_FRAGMENT,ENET_PROTOCOL_COMMAND_SEND_RELIABLE:begin
   enet_peer_dispatch_incoming_reliable_commands(peer,channel);
  end;
  else begin
   enet_peer_dispatch_incoming_unreliable_commands(peer,channel);
  end;
 end;

 result:=incomingCommand;
 exit;

discardCommand:
 if fragmentCount>0 then begin
  goto notifyError;
 end;

 if assigned(packet) and (packet^.referenceCount=0) then begin
  enet_packet_destroy(packet);
 end;

 result:=@dummyCommand;
 exit;

notifyError:
 if assigned(packet) and (packet^.referenceCount=0) then begin
  enet_packet_destroy(packet);
 end;
 result:=nil;
end;

procedure enet_peer_on_connect(peer:PENetPeer);
begin
 if (peer^.state<>ENET_PEER_STATE_CONNECTED) and (peer^.state<>ENET_PEER_STATE_DISCONNECT_LATER) then begin
  if peer^.incomingBandwidth<>0 then begin
   inc(peer^.host^.bandwidthLimitedPeers);
  end;
  inc(peer^.host^.connectedPeers);
 end;
end;

procedure enet_peer_on_disconnect(peer:PENetPeer);
begin
 if (peer^.state=ENET_PEER_STATE_CONNECTED) or (peer^.state=ENET_PEER_STATE_DISCONNECT_LATER) then begin
  if peer^.incomingBandwidth<>0 then begin
   dec(peer^.host^.bandwidthLimitedPeers);
  end;
  dec(peer^.host^.connectedPeers);
 end;
end;

function enet_socket_create_bind(address:PENetAddress;family:TENetAddressFamily):TENetSocket;
begin
 result:=enet_socket_create(ENET_SOCKET_TYPE_DATAGRAM,family);
 if result=ENET_SOCKET_NULL then begin
  exit;
 end;
 if enet_socket_bind(result,address,family)<0 then begin
  enet_socket_destroy(result);
  result:=ENET_SOCKET_NULL;
  exit;
 end;                
 enet_socket_set_option(result,ENET_SOCKOPT_NONBLOCK,1);
 enet_socket_set_option(result,ENET_SOCKOPT_BROADCAST,1);
 enet_socket_set_option(result,ENET_SOCKOPT_RCVBUF,ENET_HOST_RECEIVE_BUFFER_SIZE);
 enet_socket_set_option(result,ENET_SOCKOPT_SNDBUF,ENET_HOST_SEND_BUFFER_SIZE);
end;

function enet_host_create(address:PENetAddress;peerCount,channelLimit,incomingBandwidth,outgoingBandwidth:longword):PENetHost;
var host:PENetHost;
    currentPeer:PENetPeer;
    family:longint;
begin
 if peerCount>ENET_PROTOCOL_MAXIMUM_PEER_ID then begin
  result:=nil;
  exit;
 end;
 GetMem(host,SizeOf(TENetHost));
 if not assigned(host) then begin
  result:=nil;
  exit;
 end;
 FillChar(host^,SizeOf(TENetHost),AnsiChar(#0));
 GetMem(host^.peers,peerCount*sizeof(TENetPeer));
 if not assigned(host^.peers) then begin
  FreeMem(host);
  result:=nil;
  exit;
 end;
 FillChar(host^.peers^,peerCount*sizeof(TENetPeer),AnsiChar(#0));
 if (not assigned(address)) or enet_compare_address(address^.host,ENET_HOST_ANY) then begin
  family:=ENET_IPV4 or ENET_IPV6;
 end else begin
  family:=enet_get_address_family(address);
 end;
 if (family and ENET_IPV4)<>0 then begin
  host^.socket4:=enet_socket_create_bind(address,ENET_IPV4);
 end else begin
  host^.socket4:=ENET_SOCKET_NULL;
 end;
 if (family and ENET_IPV6)<>0 then begin
  host^.socket6:=enet_socket_create_bind(address,ENET_IPV6);
 end else begin
  host^.socket6:=ENET_SOCKET_NULL;
 end;
 if (host^.socket4=ENET_SOCKET_NULL) and (host^.socket6=ENET_SOCKET_NULL)  then begin
  FreeMem(host^.peers);
  FreeMem(host);
  result:=nil;
  exit;
 end;
 if host^.socket4<>ENET_SOCKET_NULL then begin
  enet_socket_set_option(host^.socket4,ENET_SOCKOPT_NONBLOCK,1);
  enet_socket_set_option(host^.socket4,ENET_SOCKOPT_BROADCAST,1);
  enet_socket_set_option(host^.socket4,ENET_SOCKOPT_RCVBUF,ENET_HOST_RECEIVE_BUFFER_SIZE);
  enet_socket_set_option(host^.socket4,ENET_SOCKOPT_SNDBUF,ENET_HOST_SEND_BUFFER_SIZE);
 end;
 if host^.socket6<>ENET_SOCKET_NULL then begin
  enet_socket_set_option(host^.socket6,ENET_SOCKOPT_NONBLOCK,1);
  enet_socket_set_option(host^.socket6,ENET_SOCKOPT_BROADCAST,1);
  enet_socket_set_option(host^.socket6,ENET_SOCKOPT_RCVBUF,ENET_HOST_RECEIVE_BUFFER_SIZE);
  enet_socket_set_option(host^.socket6,ENET_SOCKOPT_SNDBUF,ENET_HOST_SEND_BUFFER_SIZE);
 end;
 if assigned(address) and
    (((host^.socket4<>ENET_SOCKET_NULL) and (enet_socket_get_address(host^.socket4,@host^.address,ENET_IPV4)<0)) or
     ((host^.socket6<>ENET_SOCKET_NULL) and (enet_socket_get_address(host^.socket6,@host^.address,ENET_IPV6)<0))) then begin
  host^.address:=address^;
 end;
 if (channelLimit=0) or (channelLimit>ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT) then begin
  channelLimit:=ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT;
 end else if channelLimit<ENET_PROTOCOL_MINIMUM_CHANNEL_COUNT then begin
  channelLimit:=ENET_PROTOCOL_MINIMUM_CHANNEL_COUNT;
 end;
 host^.randomSeed:=longword(enet_host_random_seed)+host^.address.host.addr32[0];
 host^.randomSeed:=(host^.randomSeed shl 16) or (host^.randomSeed shr 16);
 host^.channelLimit:=channelLimit;
 host^.incomingBandwidth:=incomingBandwidth;
 host^.outgoingBandwidth:=outgoingBandwidth;
 host^.bandwidthThrottleEpoch:=0;
 host^.recalculateBandwidthLimits:=0;
 host^.mtu:=ENET_HOST_DEFAULT_MTU;
 host^.peerCount:=peerCount;
 host^.commandCount:=0;
 host^.bufferCount:=0;
 host^.checksum:=nil;
 host^.receivedAddress.host:=ENET_HOST_ANY;
 host^.receivedAddress.port:=0;
 host^.receivedData:=nil;
 host^.receivedDataLength:=0;
 host^.totalSentData:=0;
 host^.totalSentPackets:=0;
 host^.totalReceivedData:=0;
 host^.totalReceivedPackets:=0;
 host^.connectedPeers:=0;
 host^.bandwidthLimitedPeers:=0;
 host^.duplicatePeers:=ENET_PROTOCOL_MAXIMUM_PEER_ID;
 host^.maximumPacketSize:=ENET_HOST_DEFAULT_MAXIMUM_PACKET_SIZE;
 host^.maximumWaitingData:=ENET_HOST_DEFAULT_MAXIMUM_WAITING_DATA;
 host^.compressor.context:=nil;
 host^.compressor.compress:=nil;
 host^.compressor.decompress:=nil;
 host^.compressor.destroy:=nil;
 host^.intercept:=nil;
 enet_list_clear(@host^.dispatchQueue);
 currentPeer:=@host^.peers[0];
 while ptruint(pointer(currentPeer))<ptruint(pointer(@host^.peers[host^.peerCount])) do begin
  currentPeer^.host:=host;
  currentPeer^.incomingPeerID:=(ptruint(pointer(currentPeer))-ptruint(pointer(@host^.peers[0]))) div sizeof(TENetPeer);
  currentPeer^.outgoingSessionID:=$ff;
  currentPeer^.incomingSessionID:=$ff;
  currentPeer^.data:=nil;
  enet_list_clear(@currentPeer^.acknowledgements);
  enet_list_clear(@currentPeer^.sentReliableCommands);
  enet_list_clear(@currentPeer^.sentUnreliableCommands);
  enet_list_clear(@currentPeer^.outgoingReliableCommands);
  enet_list_clear(@currentPeer^.outgoingUnreliableCommands);
  enet_list_clear(@currentPeer^.dispatchedCommands);
  enet_peer_reset(currentPeer);
  inc(currentPeer);
 end;
 result:=host;
end;

procedure enet_host_destroy(host:PENetHost);
var currentPeer:PENetPeer;
begin
 if not assigned(host) then begin
  exit;
 end;
 if host^.socket4<>ENET_SOCKET_NULL then begin
  enet_socket_destroy(host^.socket4);
 end;
 if host^.socket6<>ENET_SOCKET_NULL then begin
  enet_socket_destroy(host^.socket6);
 end;
 currentPeer:=@host^.peers[0];
 while ptruint(pointer(currentPeer))<ptruint(pointer(@host^.peers[host^.peerCount])) do begin
  enet_peer_reset(currentPeer);
  inc(currentPeer);
 end;
 if assigned(host^.compressor.context) and assigned(host^.compressor.destroy) then begin
  host^.compressor.destroy(host^.compressor.context);
 end;
 FreeMem(host^.peers);
 FreeMem(host);
end;

function enet_host_connect(host:PENetHost;address:PENetAddress;channelCount,data:longword):PENetPeer;
var currentPeer:PENetPeer;
    channel:PENetChannel;
    command:TENetProtocol;
begin
 if channelCount<ENET_PROTOCOL_MINIMUM_CHANNEL_COUNT then begin
  channelCount:=ENET_PROTOCOL_MINIMUM_CHANNEL_COUNT;
 end else if channelCount>ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT then begin
  channelCount:=ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT;
 end;
 currentPeer:=@host^.peers[0];
 while ptruint(pointer(currentPeer))<ptruint(pointer(@host^.peers[host^.peerCount])) do begin
  if currentPeer^.state=ENET_PEER_STATE_DISCONNECTED then begin
   break;
  end;
  inc(currentPeer);
 end;
 if ptruint(pointer(currentPeer))>=ptruint(pointer(@host^.peers[host^.peerCount])) then begin
  result:=nil;
  exit;
 end;
 GetMem(currentPeer^.channels,channelCount*sizeof(TENetChannel));
 if not assigned(currentPeer^.channels) then begin
  result:=nil;
  exit;
 end;
 currentPeer^.channelCount:=channelCount;
 currentPeer^.state:=ENET_PEER_STATE_CONNECTING;
 currentPeer^.address:=address^;
 inc(host^.randomSeed);
 currentPeer^.connectID:=host^.randomSeed;
 if host^.outgoingBandwidth=0 then begin
  currentPeer^.windowSize:=ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE;
 end else begin
  currentPeer^.windowSize:=(host^.outgoingBandwidth div ENET_PEER_WINDOW_SIZE_SCALE)*ENET_PROTOCOL_MINIMUM_WINDOW_SIZE;
 end;
 if currentPeer^.windowSize<ENET_PROTOCOL_MINIMUM_WINDOW_SIZE then begin
  currentPeer^.windowSize:=ENET_PROTOCOL_MINIMUM_WINDOW_SIZE;
 end else if currentPeer^.windowSize>ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE then begin
  currentPeer^.windowSize:=ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE;
 end;
 channel:=@currentPeer^.channels^[0];
 while ptruint(pointer(channel))<ptruint(pointer(@currentPeer^.channels^[channelCount])) do begin
  channel^.outgoingReliableSequenceNumber:=0;
  channel^.outgoingUnreliableSequenceNumber:=0;
  channel^.incomingReliableSequenceNumber:=0;
  channel^.incomingUnreliableSequenceNumber:=0;
  enet_list_clear(@channel^.incomingReliableCommands);
  enet_list_clear(@channel^.incomingUnreliableCommands);
  channel^.usedReliableWindows:=0;
  FillChar(channel^.reliableWindows,sizeof(channel^.reliableWindows),#0);
  inc(Channel);
 end;
 command.header.command:=ENET_PROTOCOL_COMMAND_CONNECT or ENET_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE;
 command.header.channelID:=$FF;
 command.connect.outgoingPeerID:=ENET_HOST_TO_NET_16(currentPeer^.incomingPeerID);
 command.connect.incomingSessionID:=currentPeer^.incomingSessionID;
 command.connect.outgoingSessionID:=currentPeer^.outgoingSessionID;
 command.connect.mtu:=ENET_HOST_TO_NET_32(currentPeer^.mtu);
 command.connect.windowSize:=ENET_HOST_TO_NET_32(currentPeer^.windowSize);
 command.connect.channelCount:=ENET_HOST_TO_NET_32(channelCount);
 command.connect.incomingBandwidth:=ENET_HOST_TO_NET_32(host^.incomingBandwidth);
 command.connect.outgoingBandwidth:=ENET_HOST_TO_NET_32(host^.outgoingBandwidth);
 command.connect.packetThrottleInterval:=ENET_HOST_TO_NET_32(currentPeer^.packetThrottleInterval);
 command.connect.packetThrottleAcceleration:=ENET_HOST_TO_NET_32(currentPeer^.packetThrottleAcceleration);
 command.connect.packetThrottleDeceleration:=ENET_HOST_TO_NET_32(currentPeer^.packetThrottleDeceleration);
 command.connect.connectID:=currentPeer^.connectID;
 command.connect.data:=ENET_HOST_TO_NET_32(data);
 enet_peer_queue_outgoing_command(currentPeer,@command,nil,0,0);
 result:=currentPeer;
end;

procedure enet_host_broadcast(host:PENetHost;channelID:byte;packet:PENetPacket);
var currentPeer:PENetPeer;
begin
 currentPeer:=@host^.peers[0];
 while ptruint(pointer(currentPeer))<ptruint(pointer(@host^.peers[host^.peerCount])) do begin
  if currentPeer^.state<>ENET_PEER_STATE_CONNECTED then begin
   inc(currentPeer);
   continue;
  end;
  enet_peer_send(currentPeer,channelID,packet);
  inc(currentPeer);
 end;
 if packet^.referenceCount=0 then begin
  enet_packet_destroy(packet);
 end;
end;

procedure enet_host_compress(host:PENetHost;compressor:PENetCompressor);
begin
 if assigned(host^.compressor.context) and assigned(host^.compressor.destroy) then begin
  host^.compressor.destroy(host^.compressor.context);
 end;
 if assigned(compressor) then begin
  host^.compressor:=compressor^;
 end else begin
  host^.compressor.context:=nil;
 end;
end;

procedure enet_host_channel_limit(host:PENetHost;channelLimit:longword);
begin
 if (channelLimit=0) or (channelLimit>ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT) then begin
  channelLimit:=ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT;
 end else if channelLimit<ENET_PROTOCOL_MINIMUM_CHANNEL_COUNT then begin
  channelLimit:=ENET_PROTOCOL_MINIMUM_CHANNEL_COUNT;
 end;
 host^.channelLimit:=channelLimit;
end;

procedure enet_host_bandwidth_limit(host:PENetHost;incomingBandwidth,outgoingBandwidth:longword);
begin
 host^.incomingBandwidth:=incomingBandwidth;
 host^.outgoingBandwidth:=outgoingBandwidth;
 host^.recalculateBandwidthLimits:=1;
end;

procedure enet_host_bandwidth_throttle(host:PENetHost);
var timeCurrent,elapsedTime,dataTotal,peersRemaining,bandwidth,throttle,bandwidthLimit,
    peerBandwidth:longword;
    needsAdjustment:longint;
    peer:PENetPeer;
    command:TENetProtocol;
begin
 timeCurrent:=enet_time_get;
 elapsedTime:=timeCurrent-host^.bandwidthThrottleEpoch;
 peersRemaining:=host^.connectedPeers;
 dataTotal:=longword(not 0);
 bandwidth:=longword(not 0);
 throttle:=0;
 if throttle<>0 then begin
 end;
 bandwidthLimit:=0;
 if host^.bandwidthLimitedPeers>0 then begin
  needsAdjustment:=1;
 end else begin
  needsAdjustment:=0;
 end;
 if elapsedTime<ENET_HOST_BANDWIDTH_THROTTLE_INTERVAL then begin
  exit;
 end;
 host^.bandwidthThrottleEpoch:=timeCurrent;
 if peersRemaining=0 then begin
  exit;
 end;
 if host^.outgoingBandwidth<>0 then begin
  dataTotal:=0;
  bandwidth:=(host^.outgoingBandwidth*elapsedTime) div 1000;
  peer:=@host^.peers[0];
  while ptruint(pointer(peer))<ptruint(pointer(@host^.peers[host^.peerCount])) do begin
   if (peer^.state<>ENET_PEER_STATE_CONNECTED) and (peer^.state<>ENET_PEER_STATE_DISCONNECT_LATER) then begin
    inc(peer);
    continue;
   end;
   inc(dataTotal,peer^.outgoingDataTotal);
   inc(peer);
  end;
 end;
 while (peersRemaining>0) and (needsAdjustment<>0) do begin
  needsAdjustment:=0;
  if dataTotal<=bandwidth then begin
   throttle:=ENET_PEER_PACKET_THROTTLE_SCALE;
  end else begin
   throttle:=(bandwidth*ENET_PEER_PACKET_THROTTLE_SCALE) div dataTotal;
  end;
  peer:=@host^.peers[0];
  while ptruint(pointer(peer))<ptruint(pointer(@host^.peers[host^.peerCount])) do begin
   if ((peer^.state<>ENET_PEER_STATE_CONNECTED) and (peer^.state<>ENET_PEER_STATE_DISCONNECT_LATER)) or
      (peer^.incomingBandwidth=0) or (peer^.outgoingBandwidthThrottleEpoch=timeCurrent) then begin
    inc(peer);
    continue;
   end;
   peerBandwidth:=(peer^.incomingBandwidth*elapsedTime) div 1000;
   if ((throttle*peer^.outgoingDataTotal) div ENET_PEER_PACKET_THROTTLE_SCALE)<=peerBandwidth then begin
    inc(peer);
    continue;
   end;
   peer^.packetThrottleLimit:=(peerBandwidth*ENET_PEER_PACKET_THROTTLE_SCALE) div peer^.outgoingDataTotal;
   if peer^.packetThrottleLimit=0 then begin
    peer^.packetThrottleLimit:=1;
   end;
   if peer^.packetThrottle>peer^.packetThrottleLimit then begin
    peer^.packetThrottle:=peer^.packetThrottleLimit;
   end;
   peer^.outgoingBandwidthThrottleEpoch:=timeCurrent;
   peer^.incomingDataTotal:=0;
   peer^.outgoingDataTotal:=0;
   needsAdjustment:=1;
   dec(peersRemaining);
   dec(bandwidth,peerBandwidth);
   dec(dataTotal,peerBandwidth);
   inc(peer);
  end;
 end;
 if peersRemaining>0 then begin
  if dataTotal<=bandwidth then begin
   throttle:=ENET_PEER_PACKET_THROTTLE_SCALE;
  end else begin
   throttle:=(bandwidth*ENET_PEER_PACKET_THROTTLE_SCALE) div dataTotal;
  end;
  peer:=@host^.peers[0];
  while ptruint(pointer(peer))<ptruint(pointer(@host^.peers[host^.peerCount])) do begin
   if ((peer^.state<>ENET_PEER_STATE_CONNECTED) and (peer^.state<>ENET_PEER_STATE_DISCONNECT_LATER)) or
      (peer^.outgoingBandwidthThrottleEpoch=timeCurrent) then begin
    inc(peer);
    continue;
   end;
   peer^.packetThrottleLimit:=throttle;
   if peer^.packetThrottle>peer^.packetThrottleLimit then begin
    peer^.packetThrottle:=peer^.packetThrottleLimit;
   end;
   peer^.incomingDataTotal:=0;
   peer^.outgoingDataTotal:=0;
   inc(peer);
  end;
 end;
 if host^.recalculateBandwidthLimits<>0 then begin
  host^.recalculateBandwidthLimits:=0;
  peersRemaining:=host^.connectedPeers;
  bandwidth:=host^.incomingBandwidth;
  needsAdjustment:=1;
  if bandwidth=0 then begin
   bandwidthLimit:=0;
  end else begin
   while (peersRemaining>0) and (needsAdjustment<>0) do begin
    needsAdjustment:=0;
    bandwidthLimit:=bandwidth div peersRemaining;
    peer:=@host^.peers[0];
    while ptruint(pointer(peer))<ptruint(pointer(@host^.peers[host^.peerCount])) do begin
     if ((peer^.state<>ENET_PEER_STATE_CONNECTED) and (peer^.state<>ENET_PEER_STATE_DISCONNECT_LATER)) or (peer^.incomingBandwidthThrottleEpoch=timeCurrent) then begin
      inc(peer);
      continue;
     end;
     if (peer^.outgoingBandwidth>0) and (peer^.outgoingBandwidth>=bandwidthLimit) then begin
      inc(peer);
      continue;
     end;
     peer^.incomingBandwidthThrottleEpoch:=timeCurrent;
     needsAdjustment:=1;
     dec(peersRemaining);
     inc(bandwidth,peer^.outgoingBandwidth);
     inc(peer);
    end;
   end;
  end;
  peer:=@host^.peers[0];
  while ptruint(pointer(peer))<ptruint(pointer(@host^.peers[host^.peerCount])) do begin
   if (peer^.state<>ENET_PEER_STATE_CONNECTED) and (peer^.state<>ENET_PEER_STATE_DISCONNECT_LATER) then begin
    inc(peer);
    continue;
   end;
   command.header.command:=ENET_PROTOCOL_COMMAND_BANDWIDTH_LIMIT or ENET_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE;
   command.header.channelID:=$ff;
   command.bandwidthLimit.outgoingBandwidth:=ENET_HOST_TO_NET_32 (host^.outgoingBandwidth);
   if peer^.incomingBandwidthThrottleEpoch=timeCurrent then begin
    command.bandwidthLimit.incomingBandwidth:=ENET_HOST_TO_NET_32(peer^.outgoingBandwidth);
   end else begin
    command.bandwidthLimit.incomingBandwidth:=ENET_HOST_TO_NET_32(bandwidthLimit);
   end;
   enet_peer_queue_outgoing_command(peer,@command,nil,0,0);
   inc(peer);
  end;
 end;
end;

const commandSizes:array[0..ENET_PROTOCOL_COMMAND_COUNT-1] of longint=
(
 0,
 sizeof(TENetProtocolAcknowledge),
 sizeof(TENetProtocolConnect),
 sizeof(TENetProtocolVerifyConnect),
 sizeof(TENetProtocolDisconnect),
 sizeof(TENetProtocolPing),
 sizeof(TENetProtocolSendReliable),
 sizeof(TENetProtocolSendUnreliable),
 sizeof(TENetProtocolSendFragment),
 sizeof(TENetProtocolSendUnsequenced),
 sizeof(TENetProtocolBandwidthLimit),
 sizeof(TENetProtocolThrottleConfigure),
 0
);

function enet_protocol_command_size(command:byte):longint;
begin
 result:=commandSizes[command];
end;

procedure enet_protocol_change_state(host:PENetHost;peer:PENetPeer;state:TENetPeerState);
begin
 if (state=ENET_PEER_STATE_CONNECTED) or (state=ENET_PEER_STATE_DISCONNECT_LATER) then begin
  enet_peer_on_connect(peer);
 end else begin
  enet_peer_on_disconnect(peer);
 end;
 peer^.state:=state;
end;

procedure enet_protocol_dispatch_state(host:PENetHost;peer:PENetPeer;state:TENetPeerState);
begin
 enet_protocol_change_state(host,peer,state);
 if not peer^.needsDispatch then begin
  enet_list_insert(enet_list_end(@host^.dispatchQueue),@peer^.dispatchList);
  peer^.needsDispatch:=true;
 end;
end;

function enet_protocol_dispatch_incoming_commands(host:PENetHost;event:PENetEvent):longint;
var peer:PENetPeer;
begin
 while not enet_list_empty(@host^.dispatchQueue) do begin
  peer:=enet_list_remove(enet_list_begin(@host^.dispatchQueue));
  peer^.needsDispatch:=false;
  case peer^.state of
   ENET_PEER_STATE_CONNECTION_PENDING,ENET_PEER_STATE_CONNECTION_SUCCEEDED:begin
    enet_protocol_change_state(host,peer,ENET_PEER_STATE_CONNECTED);
    event^.type_:=ENET_EVENT_TYPE_CONNECT;
    event^.peer:=peer;
    event^.data:=peer^.eventData;
    result:=1;
    exit;
   end;
   ENET_PEER_STATE_ZOMBIE:begin
    host^.recalculateBandwidthLimits:=1;
    event^.type_:=ENET_EVENT_TYPE_DISCONNECT;
    event^.peer:=peer;
    event^.data:=peer^.eventData;
    enet_peer_reset(peer);
    result:=1;
    exit;
   end;
   ENET_PEER_STATE_CONNECTED:begin
    if enet_list_empty(@peer^.dispatchedCommands) then begin
     continue;
    end;
    event^.packet:=enet_peer_receive(peer,@event^.channelID);
    if not assigned(event^.packet) then begin
     continue;
    end;
    event^.type_:=ENET_EVENT_TYPE_RECEIVE;
    event^.peer:=peer;
    if not enet_list_empty(@peer^.dispatchedCommands) then begin
     peer^.needsDispatch:=true;
     enet_list_insert(enet_list_end(@host^.dispatchQueue),@peer^.dispatchList);
    end;
    result:=1;
    exit;
   end;
  end;
 end;
 result:=0;
end;

procedure enet_protocol_notify_connect(host:PENetHost;peer:PENetPeer;event:PENetEvent);
begin
 host^.recalculateBandwidthLimits:=1;
 if assigned(event) then begin
  enet_protocol_change_state(host,peer,ENET_PEER_STATE_CONNECTED);
  event^.type_:=ENET_EVENT_TYPE_CONNECT;
  event^.peer:=peer;
  event^.data:=peer^.eventData;
 end else begin
  if peer^.state=ENET_PEER_STATE_CONNECTING then begin
   enet_protocol_dispatch_state(host,peer,ENET_PEER_STATE_CONNECTION_SUCCEEDED);
  end else begin
   enet_protocol_dispatch_state(host,peer,ENET_PEER_STATE_CONNECTION_PENDING);
  end;
 end;
end;

procedure enet_protocol_notify_disconnect(host:PENetHost;peer:PENetPeer;event:PENetEvent);
begin
 if peer^.state>=ENET_PEER_STATE_CONNECTION_PENDING then begin
  host^.recalculateBandwidthLimits:=1;
 end;
 if (peer^.state<>ENET_PEER_STATE_CONNECTING) and (peer^.state<ENET_PEER_STATE_CONNECTION_SUCCEEDED) then begin
  enet_peer_reset(peer);
 end else if assigned(event) then begin
  event^.type_:=ENET_EVENT_TYPE_DISCONNECT;
  event^.peer:=peer;
  event^.data:=0;
  enet_peer_reset(peer);
 end else begin
  peer^.eventData:=0;
  enet_protocol_dispatch_state(host,peer,ENET_PEER_STATE_ZOMBIE);
 end;
end;

procedure enet_protocol_remove_sent_unreliable_commands(peer:PENetPeer);
var outgoingCommand:PENetOutgoingCommand;
begin
 while not enet_list_empty(@peer^.sentUnreliableCommands) do begin
  outgoingCommand:=PENetOutgoingCommand(enet_list_front(@peer^.sentUnreliableCommands));
  enet_list_remove(@outgoingCommand^.outgoingCommandList);
  if assigned(outgoingCommand^.packet) then begin
   dec(outgoingCommand^.packet^.referenceCount);
   if outgoingCommand^.packet^.referenceCount=0 then begin
    outgoingCommand^.packet^.flags:=outgoingCommand^.packet^.flags or ENET_PACKET_FLAG_SENT;
    enet_packet_destroy(outgoingCommand^.packet);
   end;
  end;
  FreeMem(outgoingCommand);
 end;
end;

function enet_protocol_remove_sent_reliable_command(peer:PENetPeer;reliableSequenceNumber:word;channelID:byte):TENetProtocolCommand;
var outgoingCommand:PENetOutgoingCommand;
    currentCommand:TENetListIterator;
    commandNumber:TENetProtocolCommand;
    wasSent:boolean;
    channel:PENetChannel;
    reliableWindow:word;
begin
 outgoingCommand:=nil;
 wasSent:=true;
 currentCommand:=enet_list_begin(@peer^.sentReliableCommands);
 while currentCommand<>enet_list_end(@peer^.sentReliableCommands) do begin
  outgoingCommand:=PENetOutgoingCommand(currentCommand);
  if (outgoingCommand^.reliableSequenceNumber=reliableSequenceNumber) and (outgoingCommand^.command.header.channelID=channelID) then begin
   break;
  end;
  currentCommand:=enet_list_next (currentCommand);
 end;
 if currentCommand=enet_list_end(@peer^.sentReliableCommands) then begin
  currentCommand:=enet_list_begin(@peer^.outgoingReliableCommands);
  while currentCommand<>enet_list_end(@peer^.outgoingReliableCommands) do begin
   outgoingCommand:=PENetOutgoingCommand(CurrentCommand);
   if outgoingCommand^.sendAttempts<1 then begin
    result:=ENET_PROTOCOL_COMMAND_NONE;
    exit;
   end;
   if (outgoingCommand^.reliableSequenceNumber=reliableSequenceNumber) and (outgoingCommand^.command.header.channelID=channelID) then begin
    break;
   end;
   currentCommand:=enet_list_next(currentCommand);
  end;
  if currentCommand=enet_list_end(@peer^.outgoingReliableCommands) then begin
   result:=ENET_PROTOCOL_COMMAND_NONE;
   exit;
  end;
  wasSent:=false;
 end;
 if not assigned(outgoingCommand) then begin
  result:=ENET_PROTOCOL_COMMAND_NONE;
  exit;
 end;
 if channelID<peer^.channelCount then begin
  channel:=@peer^.channels[channelID];
  reliableWindow:=reliableSequenceNumber div ENET_PEER_RELIABLE_WINDOW_SIZE;
  if channel^.reliableWindows[reliableWindow]>0 then begin
   dec(channel^.reliableWindows [reliableWindow]);
   if channel^.reliableWindows[reliableWindow]=0 then begin
    channel^.usedReliableWindows:=channel^.usedReliableWindows and not (1 shl reliableWindow);
   end;
  end;
 end;
 commandNumber:=TENetProtocolCommand(outgoingCommand^.command.header.command and ENET_PROTOCOL_COMMAND_MASK);
 enet_list_remove(@outgoingCommand^.outgoingCommandList);
 if assigned(outgoingCommand^.packet) then begin
  if wasSent then begin
   dec(peer^.reliableDataInTransit,outgoingCommand^.fragmentLength);
  end;
  dec(outgoingCommand^.packet^.referenceCount);
  if outgoingCommand^.packet^.referenceCount=0 then begin
   outgoingCommand^.packet^.flags:=outgoingCommand^.packet^.flags or ENET_PACKET_FLAG_SENT;
   enet_packet_destroy(outgoingCommand^.packet);
  end;
 end;
 FreeMem(outgoingCommand);
 if enet_list_empty(@peer^.sentReliableCommands) then begin
  result:=commandNumber;
  exit;
 end;
 outgoingCommand:=PENetOutgoingCommand(enet_list_front(@peer^.sentReliableCommands));
 peer^.nextTimeout:=outgoingCommand^.sentTime+outgoingCommand^.roundTripTimeout;
 result:=commandNumber;
end;

function enet_protocol_handle_connect(host:PENetHost;header:PENetProtocolHeader;command:PENetProtocol):PENetPeer;
var incomingSessionID,outgoingSessionID:byte;
    mtu,windowSize:longword;
    channelCount,duplicatePeers:ENETptruint;
    channel:PENetChannel;
    currentPeer:PENetPeer;
    verifyCommand:TENetProtocol;
    i:longint;
begin
 result:=nil;
 channelCount:=ENET_NET_TO_HOST_32(command^.connect.channelCount);
 duplicatePeers:=0;
 if (channelCount<ENET_PROTOCOL_MINIMUM_CHANNEL_COUNT) or (channelCount>ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT) then begin
  result:=nil;
  exit;
 end;
 for i:=0 to host^.peerCount-1 do begin
  currentPeer:=@host^.peers^[i];
  if currentPeer^.state=ENET_PEER_STATE_DISCONNECTED then begin
   if not assigned(result) then begin
    result:=currentPeer;
   end;
  end else if (currentPeer^.state<>ENET_PEER_STATE_CONNECTING) and
              (currentPeer^.address.host.addr[0]=host^.receivedAddress.host.addr[0]) and
              (currentPeer^.address.host.addr[1]=host^.receivedAddress.host.addr[1]) and
              (currentPeer^.address.host.addr[2]=host^.receivedAddress.host.addr[2]) and
              (currentPeer^.address.host.addr[3]=host^.receivedAddress.host.addr[3]) and
              (currentPeer^.address.host.addr[4]=host^.receivedAddress.host.addr[4]) and
              (currentPeer^.address.host.addr[5]=host^.receivedAddress.host.addr[5]) and
              (currentPeer^.address.host.addr[6]=host^.receivedAddress.host.addr[6]) and
              (currentPeer^.address.host.addr[7]=host^.receivedAddress.host.addr[7]) and
              (currentPeer^.address.host.addr[8]=host^.receivedAddress.host.addr[8]) and
              (currentPeer^.address.host.addr[9]=host^.receivedAddress.host.addr[9]) and
              (currentPeer^.address.host.addr[10]=host^.receivedAddress.host.addr[10]) and
              (currentPeer^.address.host.addr[11]=host^.receivedAddress.host.addr[11]) and
              (currentPeer^.address.host.addr[12]=host^.receivedAddress.host.addr[12]) and
              (currentPeer^.address.host.addr[13]=host^.receivedAddress.host.addr[13]) and
              (currentPeer^.address.host.addr[14]=host^.receivedAddress.host.addr[14]) and
              (currentPeer^.address.host.addr[15]=host^.receivedAddress.host.addr[15]) then begin
   if (currentPeer^.address.port=host^.receivedAddress.port) and
      (currentPeer^.connectID=command^.connect.connectID) then begin
    result:=nil;
    exit;
   end;
   inc(duplicatePeers);
  end;
 end;

 if (not assigned(result)) or (duplicatePeers>=host^.duplicatePeers) then begin
  result:=nil;
  exit;
 end;

 if channelCount>host^.channelLimit then begin
  channelCount:=host^.channelLimit;
 end;

 GetMem(result^.channels,channelCount*sizeof(TENetChannel));
 if not assigned(result^.channels) then begin
  result:=nil;
  exit;
 end;
 FillChar(result^.channels^,channelCount*sizeof(TENetChannel),AnsiChar(#0));
 result^.channelCount:=channelCount;
 result^.state:=ENET_PEER_STATE_ACKNOWLEDGING_CONNECT;
 result^.connectID:=command^.connect.connectID;
 result^.address:=host^.receivedAddress;
 result^.outgoingPeerID:=ENET_NET_TO_HOST_16(command^.connect.outgoingPeerID);
 result^.incomingBandwidth:=ENET_NET_TO_HOST_32(command^.connect.incomingBandwidth);
 result^.outgoingBandwidth:=ENET_NET_TO_HOST_32(command^.connect.outgoingBandwidth);
 result^.packetThrottleInterval:=ENET_NET_TO_HOST_32(command^.connect.packetThrottleInterval);
 result^.packetThrottleAcceleration:=ENET_NET_TO_HOST_32(command^.connect.packetThrottleAcceleration);
 result^.packetThrottleDeceleration:=ENET_NET_TO_HOST_32(command^.connect.packetThrottleDeceleration);
 result^.eventData:=ENET_NET_TO_HOST_32 (command^.connect.data);

 if command^.connect.incomingSessionID=$ff then begin
  incomingSessionID:=result^.outgoingSessionID;
 end else begin
  incomingSessionID:=command^.connect.incomingSessionID;
 end;
 incomingSessionID:=(incomingSessionID+1) and (ENET_PROTOCOL_HEADER_SESSION_MASK shr ENET_PROTOCOL_HEADER_SESSION_SHIFT);
 if incomingSessionID=result^.outgoingSessionID then begin
  incomingSessionID:=(incomingSessionID+1) and (ENET_PROTOCOL_HEADER_SESSION_MASK shr ENET_PROTOCOL_HEADER_SESSION_SHIFT);
 end;
 result^.outgoingSessionID:=incomingSessionID;

 if command^.connect.outgoingSessionID=$ff then begin
  outgoingSessionID:=result^.incomingSessionID;
 end else begin
  outgoingSessionID:=command^.connect.outgoingSessionID;
 end;
 outgoingSessionID:=(outgoingSessionID+1) and (ENET_PROTOCOL_HEADER_SESSION_MASK shr ENET_PROTOCOL_HEADER_SESSION_SHIFT);
 if outgoingSessionID=currentPeer^.incomingSessionID then begin
  outgoingSessionID:=(outgoingSessionID+1) and (ENET_PROTOCOL_HEADER_SESSION_MASK shr ENET_PROTOCOL_HEADER_SESSION_SHIFT);
 end;
 result^.incomingSessionID:=outgoingSessionID;

 for i:=0 to channelCount-1 do begin
  channel:=@result^.channels^[i];
  channel^.outgoingReliableSequenceNumber:=0;
  channel^.outgoingUnreliableSequenceNumber:=0;
  channel^.incomingReliableSequenceNumber:=0;
  channel^.incomingUnreliableSequenceNumber:=0;
  enet_list_clear(@channel^.incomingReliableCommands);
  enet_list_clear(@channel^.incomingUnreliableCommands);
  channel^.usedReliableWindows:=0;
  FillChar(channel^.reliableWindows,sizeof(channel^.reliableWindows),AnsiChar(#0));
 end;

 mtu:=ENET_NET_TO_HOST_32(command^.connect.mtu);

 if mtu<ENET_PROTOCOL_MINIMUM_MTU then begin
  mtu:=ENET_PROTOCOL_MINIMUM_MTU;
 end else if mtu>ENET_PROTOCOL_MAXIMUM_MTU then begin
  mtu:=ENET_PROTOCOL_MAXIMUM_MTU;
 end;

 result^.mtu:=mtu;

 if (host^.outgoingBandwidth=0) and (result^.incomingBandwidth=0) then begin
  result^.windowSize:=ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE;
 end else if (host^.outgoingBandwidth=0) or (result^.incomingBandwidth=0) then begin
  result^.windowSize:=(Max(host^.outgoingBandwidth,result^.incomingBandwidth) div ENET_PEER_WINDOW_SIZE_SCALE)*ENET_PROTOCOL_MINIMUM_WINDOW_SIZE;
 end else begin
  result^.windowSize:=(Min(host^.outgoingBandwidth,result^.incomingBandwidth) div ENET_PEER_WINDOW_SIZE_SCALE)*ENET_PROTOCOL_MINIMUM_WINDOW_SIZE;
 end;

 if result^.windowSize<ENET_PROTOCOL_MINIMUM_WINDOW_SIZE then begin
  result^.windowSize:=ENET_PROTOCOL_MINIMUM_WINDOW_SIZE;
 end else if result^.windowSize>ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE then begin
  result^.windowSize:=ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE;
 end;

 if host^.incomingBandwidth=0 then begin
  windowSize:=ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE;
 end else begin
  windowSize:=(host^.incomingBandwidth div ENET_PEER_WINDOW_SIZE_SCALE)*ENET_PROTOCOL_MINIMUM_WINDOW_SIZE;
 end;

 if windowSize>ENET_NET_TO_HOST_32(command^.connect.windowSize) then begin
  windowSize:=ENET_NET_TO_HOST_32(command^.connect.windowSize);
 end;

 if windowSize<ENET_PROTOCOL_MINIMUM_WINDOW_SIZE then begin
  windowSize:=ENET_PROTOCOL_MINIMUM_WINDOW_SIZE;
 end else if windowSize>ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE then begin
  windowSize:=ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE;
 end;

 verifyCommand.header.command:=ENET_PROTOCOL_COMMAND_VERIFY_CONNECT or ENET_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE;
 verifyCommand.header.channelID:=$ff;
 verifyCommand.verifyConnect.outgoingPeerID:=ENET_HOST_TO_NET_16(result^.incomingPeerID);
 verifyCommand.verifyConnect.incomingSessionID:=incomingSessionID;
 verifyCommand.verifyConnect.outgoingSessionID:=outgoingSessionID;
 verifyCommand.verifyConnect.mtu:=ENET_HOST_TO_NET_32(result^.mtu);
 verifyCommand.verifyConnect.windowSize:=ENET_HOST_TO_NET_32(windowSize);
 verifyCommand.verifyConnect.channelCount:=ENET_HOST_TO_NET_32(channelCount);
 verifyCommand.verifyConnect.incomingBandwidth:=ENET_HOST_TO_NET_32(host^.incomingBandwidth);
 verifyCommand.verifyConnect.outgoingBandwidth:=ENET_HOST_TO_NET_32(host^.outgoingBandwidth);
 verifyCommand.verifyConnect.packetThrottleInterval:=ENET_HOST_TO_NET_32(result^.packetThrottleInterval);
 verifyCommand.verifyConnect.packetThrottleAcceleration:=ENET_HOST_TO_NET_32(result^.packetThrottleAcceleration);
 verifyCommand.verifyConnect.packetThrottleDeceleration:=ENET_HOST_TO_NET_32(result^.packetThrottleDeceleration);
 verifyCommand.verifyConnect.connectID:=result^.connectID;

 enet_peer_queue_outgoing_command(result,@verifyCommand,nil,0,0);

 result:=currentPeer;
end;

function enet_protocol_handle_send_reliable(host:PENetHost;peer:PENetPeer;command:PENetProtocol;currentData:PPAnsiChar):longint;
var dataLength:longint;
begin
 if (command^.header.channelID>=peer^.channelCount) or ((peer^.state<>ENET_PEER_STATE_CONNECTED) and (peer^.state<>ENET_PEER_STATE_DISCONNECT_LATER)) then begin
  result:=-1;
  exit;
 end;
 dataLength:=ENET_NET_TO_HOST_16(command^.sendReliable.dataLength);
 inc(currentData^,dataLength);
 if (dataLength>longint(host^.maximumPacketSize)) or (currentData^<host^.receivedData) or (currentData^>@host^.receivedData[host^.receivedDataLength]) then begin
  result:=-1;
  exit;
 end;
 if not assigned(enet_peer_queue_incoming_command(peer,command,@PAnsiChar(pointer(command))[sizeof(TENetProtocolSendReliable)],dataLength,ENET_PACKET_FLAG_RELIABLE,0)) then begin
  result:=-1;
  exit;
 end;
 result:=0;
end;

function enet_protocol_handle_send_unsequenced(host:PENetHost;peer:PENetPeer;command:PENetProtocol;currentData:PPAnsiChar):longint;
var unsequencedGroup,index:longword;
    dataLength:Longint;
begin
 if (command^.header.channelID>=peer^.channelCount) or ((peer^.state<>ENET_PEER_STATE_CONNECTED) and (peer^.state<>ENET_PEER_STATE_DISCONNECT_LATER)) then begin
  result:=-1;
  exit;
 end;
 dataLength:=ENET_NET_TO_HOST_16(command^.sendUnsequenced.dataLength);
 inc(currentData^,dataLength);
 if (dataLength>longint(host^.maximumPacketSize)) or (currentData^<host^.receivedData) or (currentData^>@host^.receivedData[host^.receivedDataLength]) then begin
  result:=-1;
  exit;
 end;
 unsequencedGroup:=ENET_NET_TO_HOST_16(command^.sendUnsequenced.unsequencedGroup);
 index:=unsequencedGroup mod ENET_PEER_UNSEQUENCED_WINDOW_SIZE;
 if unsequencedGroup<peer^.incomingUnsequencedGroup then begin
  inc(unsequencedGroup,$10000);
 end;
 if unsequencedGroup>=(peer^.incomingUnsequencedGroup+(ENET_PEER_FREE_UNSEQUENCED_WINDOWS*ENET_PEER_UNSEQUENCED_WINDOW_SIZE)) then begin
  result:=0;
  exit;
 end;
 unsequencedGroup:=unsequencedGroup and $FFFF;
 if (unsequencedGroup-index)<>peer^.incomingUnsequencedGroup then begin
  peer^.incomingUnsequencedGroup:=unsequencedGroup-index;
  FillChar(peer^.unsequencedWindow,sizeof(peer^.unsequencedWindow),AnsiChar(#0));
 end else if (peer^.unsequencedWindow[index shr 5] and (1 shl (index and 31)))<>0 then begin
  result:=0;
  exit;
 end;
 if not assigned(enet_peer_queue_incoming_command(peer,command,@PAnsiChar(pointer(command))[sizeof(TENetProtocolSendUnsequenced)],dataLength,ENET_PACKET_FLAG_UNSEQUENCED,0)) then begin
  result:=-1;
  exit;
 end;
 peer^.unsequencedWindow[index shr 5]:=peer^.unsequencedWindow[index shr 5] or (1 shl (index and 31));
 result:=0;
end;

function enet_protocol_handle_send_unreliable(host:PENetHost;peer:PENetPeer;command:PENetProtocol;currentData:PPAnsiChar):longint;
var dataLength:longint;
begin
 if (command^.header.channelID>=peer^.channelCount) or ((peer^.state<>ENET_PEER_STATE_CONNECTED) and (peer^.state<>ENET_PEER_STATE_DISCONNECT_LATER)) then begin
  result:=-1;
  exit;
 end;
 dataLength:=ENET_NET_TO_HOST_16(command^.sendUnreliable.dataLength);
 inc(currentData^,dataLength);
 if (dataLength>longint(host^.maximumPacketSize)) or (currentData^<host^.receivedData) or (currentData^>@host^.receivedData[host^.receivedDataLength]) then begin
  result:=-1;
  exit;
 end;
 if not assigned(enet_peer_queue_incoming_command(peer,command,@PAnsiChar(pointer(command))[sizeof(TENetProtocolSendUnreliable)],dataLength,0,0)) then begin
  result:=-1;
  exit;
 end;
 result:=0;
end;

function enet_protocol_handle_send_fragment(host:PENetHost;peer:PENetPeer;command:PENetProtocol;currentData:PPAnsiChar):longint;
var fragmentNumber,fragmentCount,fragmentOffset,fragmentLength,startSequenceNumber,totalLength:longword;
    channel:PENetChannel;
    startWindow,currentWindow:word;
    currentCommand:TENetListIterator;
    startCommand:PENetIncomingCommand;
    incomingCommand:PENetIncomingCommand;
    hostCommand:TENetProtocol;
begin
 startCommand:=nil;
 if (command^.header.channelID>=peer^.channelCount) or ((peer^.state<>ENET_PEER_STATE_CONNECTED) and (peer^.state<>ENET_PEER_STATE_DISCONNECT_LATER)) then begin
  result:=-1;
  exit;
 end;
 fragmentLength:=ENET_NET_TO_HOST_16(command^.sendFragment.dataLength);
 inc(currentData^,fragmentLength);
 if (fragmentLength>host^.maximumPacketSize) or (currentData^<host^.receivedData) or (currentData^>@host^.receivedData[host^.receivedDataLength]) then begin
  result:=-1;
  exit;
 end;
 channel:=@peer^.channels[command^.header.channelID];
 startSequenceNumber:=ENET_NET_TO_HOST_16(command^.sendFragment.startSequenceNumber);
 startWindow:=startSequenceNumber div ENET_PEER_RELIABLE_WINDOW_SIZE;
 currentWindow:=channel^.incomingReliableSequenceNumber div ENET_PEER_RELIABLE_WINDOW_SIZE;
 if startSequenceNumber<channel^.incomingReliableSequenceNumber then begin
  inc(startWindow,ENET_PEER_RELIABLE_WINDOWS);
 end;
 if (startWindow<currentWindow) or (startWindow>=(currentWindow+(ENET_PEER_FREE_RELIABLE_WINDOWS-1))) then begin
  result:=0;
  exit;
 end;
 fragmentNumber:=ENET_NET_TO_HOST_32(command^.sendFragment.fragmentNumber);
 fragmentCount:=ENET_NET_TO_HOST_32(command^.sendFragment.fragmentCount);
 fragmentOffset:=ENET_NET_TO_HOST_32(command^.sendFragment.fragmentOffset);
 totalLength:=ENET_NET_TO_HOST_32(command^.sendFragment.totalLength);
 if (fragmentCount>ENET_PROTOCOL_MAXIMUM_FRAGMENT_COUNT) or (fragmentNumber>=fragmentCount) or
    (totalLength>host^.maximumPacketSize) or (fragmentOffset>=totalLength) or
    (fragmentLength>(totalLength-fragmentOffset)) then begin
  result:=-1;
  exit;
 end;
 currentCommand:=enet_list_previous(enet_list_end(@channel^.incomingReliableCommands));
 while currentCommand<>enet_list_end(@channel^.incomingReliableCommands) do begin
  incomingCommand:=PENetIncomingCommand(currentCommand);
  if startSequenceNumber>=channel^.incomingReliableSequenceNumber then begin
   if incomingCommand^.reliableSequenceNumber<channel^.incomingReliableSequenceNumber then begin
    currentCommand:=enet_list_previous(currentCommand);
    continue;
   end;
  end else if incomingCommand^.reliableSequenceNumber>=channel^.incomingReliableSequenceNumber then begin
   break;
  end;
  if incomingCommand^.reliableSequenceNumber<=startSequenceNumber then begin
   if incomingCommand^.reliableSequenceNumber<startSequenceNumber then begin
    break;
   end;
   if ((incomingCommand^.command.header.command and ENET_PROTOCOL_COMMAND_MASK)<>ENET_PROTOCOL_COMMAND_SEND_FRAGMENT) or
      (totalLength<>incomingCommand^.packet^.dataLength) or (fragmentCount<>incomingCommand^.fragmentCount) then begin
    result:=-1;
    exit;
   end;
   startCommand:=incomingCommand;
   break;
  end;
  currentCommand:=enet_list_previous(currentCommand);
 end;
 if not assigned(startCommand) then begin
  hostCommand:=command^;
  hostCommand.header.reliableSequenceNumber:=startSequenceNumber;
  startCommand:=enet_peer_queue_incoming_command(peer,@hostCommand,nil,totalLength,ENET_PACKET_FLAG_RELIABLE,fragmentCount);
  if not assigned(startCommand) then begin
   result:=-1;
   exit;
  end;
 end;
 if (startCommand^.fragments[fragmentNumber shr 5] and (1 shl (fragmentNumber and 31)))=0 then begin
  dec(startCommand^.fragmentsRemaining);
  startCommand^.fragments[fragmentNumber shr 5]:=startCommand^.fragments[fragmentNumber shr 5] or (1 shl (fragmentNumber and 31));
  if (fragmentOffset+fragmentLength)>startCommand^.packet^.dataLength then begin
   fragmentLength:=startCommand^.packet^.dataLength-fragmentOffset;
  end;
  Move(PAnsiChar(pointer(command))[sizeof(TENetProtocolSendFragment)],PAnsiChar(pointer(startCommand^.packet^.data))[fragmentOffset],fragmentLength);
  if startCommand^.fragmentsRemaining<=0 then begin
   enet_peer_dispatch_incoming_reliable_commands(peer,channel);
  end;
 end;
 result:=0;
end;

function enet_protocol_handle_send_unreliable_fragment(host:PENetHost;peer:PENetPeer;command:PENetProtocol;currentData:PPAnsiChar):longint;
var fragmentNumber,fragmentCount,fragmentOffset,fragmentLength,reliableSequenceNumber,startSequenceNumber,totalLength:longword;
    reliableWindow,currentWindow:word;
    channel:PENetChannel;
    currentCommand:TENetListIterator;
    startCommand:PENetIncomingCommand;
    incomingCommand:PENetIncomingCommand;
begin
 startCommand:=nil;
 if (command^.header.channelID>=peer^.channelCount) or ((peer^.state<>ENET_PEER_STATE_CONNECTED) and (peer^.state<>ENET_PEER_STATE_DISCONNECT_LATER)) then begin
  result:=-1;
  exit;
 end;
 fragmentLength:=ENET_NET_TO_HOST_16(command^.sendFragment.dataLength);
 inc(currentData^,fragmentLength);
 if (fragmentLength>host^.maximumPacketSize) or (currentData^<host^.receivedData) or (currentData^>@host^.receivedData[host^.receivedDataLength]) then begin
  result:=-1;
  exit;
 end;
 channel:=@peer^.channels[command^.header.channelID];
 reliableSequenceNumber:=command^.header.reliableSequenceNumber;
 startSequenceNumber:=ENET_NET_TO_HOST_16(command^.sendFragment.startSequenceNumber);
 reliableWindow:=reliableSequenceNumber div ENET_PEER_RELIABLE_WINDOW_SIZE;
 currentWindow:=channel^.incomingReliableSequenceNumber div ENET_PEER_RELIABLE_WINDOW_SIZE;
 if reliableSequenceNumber<channel^.incomingReliableSequenceNumber then begin
  inc(reliableWindow,ENET_PEER_RELIABLE_WINDOWS);
 end;
 if (reliableWindow<currentWindow) or (reliableWindow>=(currentWindow+(ENET_PEER_FREE_RELIABLE_WINDOWS-1))) then begin
  result:=0;
  exit;
 end;
 if (reliableSequenceNumber=channel^.incomingReliableSequenceNumber) and (startSequenceNumber<=channel^.incomingUnreliableSequenceNumber) then begin
  result:=0;
  exit;
 end;
 fragmentNumber:=ENET_NET_TO_HOST_32(command^.sendFragment.fragmentNumber);
 fragmentCount:=ENET_NET_TO_HOST_32(command^.sendFragment.fragmentCount);
 fragmentOffset:=ENET_NET_TO_HOST_32(command^.sendFragment.fragmentOffset);
 totalLength:=ENET_NET_TO_HOST_32(command^.sendFragment.totalLength);
 if (fragmentCount>ENET_PROTOCOL_MAXIMUM_FRAGMENT_COUNT) or
    (fragmentNumber>=fragmentCount) or
    (totalLength>host^.maximumPacketSize) or
    (fragmentOffset>=totalLength) or
    (fragmentLength>(totalLength-fragmentOffset)) then begin
  result:=-1;
  exit;
 end;
 currentCommand:=enet_list_previous(enet_list_end(@channel^.incomingUnreliableCommands));
 while currentCommand<>enet_list_end(@channel^.incomingUnreliableCommands) do begin
  incomingCommand:=PENetIncomingCommand(currentCommand);
  if reliableSequenceNumber>=channel^.incomingReliableSequenceNumber then begin
   if (incomingCommand^.reliableSequenceNumber<channel^.incomingReliableSequenceNumber) then begin
    currentCommand:=enet_list_previous(currentCommand);
    continue;
   end;
  end else if incomingCommand^.reliableSequenceNumber>=channel^.incomingReliableSequenceNumber then begin
   break;
  end;
  if incomingCommand^.reliableSequenceNumber<reliableSequenceNumber then begin
   break;
  end;
  if incomingCommand^.reliableSequenceNumber>reliableSequenceNumber then begin
   currentCommand:=enet_list_previous(currentCommand);
   continue;
  end;
  if incomingCommand^.unreliableSequenceNumber<=startSequenceNumber then begin
   if incomingCommand^.unreliableSequenceNumber<startSequenceNumber then begin
    break;
   end;
   if ((incomingCommand^.command.header.command and ENET_PROTOCOL_COMMAND_MASK)<>ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE_FRAGMENT) or
      (totalLength<>incomingCommand^.packet^.dataLength) or (fragmentCount<>incomingCommand^.fragmentCount) then begin
    result:=-1;
    exit;
   end;
   startCommand:=incomingCommand;
   break;
  end;
  currentCommand:=enet_list_previous(currentCommand);
 end;
 if not assigned(startCommand) then begin
  startCommand:=enet_peer_queue_incoming_command(peer,command,nil,totalLength,ENET_PACKET_FLAG_UNRELIABLE_FRAGMENT,fragmentCount);
  if not assigned(startCommand) then begin
   result:=-1;
   exit;
  end;
 end;
 if (startCommand^.fragments[fragmentNumber shr 5] and (1 shl (fragmentNumber and 31)))=0 then begin
  dec(startCommand^.fragmentsRemaining);
  startCommand^.fragments[fragmentNumber shr 5]:=startCommand^.fragments[fragmentNumber shr 5] or (1 shl (fragmentNumber and 31));
  if (fragmentOffset+fragmentLength)>startCommand^.packet^.dataLength then begin
   fragmentLength:=startCommand^.packet^.dataLength-fragmentOffset;
  end;
  Move(PAnsiChar(pointer(command))[sizeof(TENetProtocolSendFragment)],PAnsiChar(pointer(startCommand^.packet^.data))[fragmentOffset],fragmentLength);
  if startCommand^.fragmentsRemaining<=0 then begin
   enet_peer_dispatch_incoming_reliable_commands(peer,channel);
  end;
 end;
 result:=0;
end;

function enet_protocol_handle_ping(host:PENetHost;peer:PENetPeer;command:PENetProtocol):longint;
begin
 if (peer^.state<>ENET_PEER_STATE_CONNECTED) and (peer^.state<>ENET_PEER_STATE_DISCONNECT_LATER) then begin
  result:=-1;
 end else begin
  result:=0;
 end;
end;

function enet_protocol_handle_bandwidth_limit(host:PENetHost;peer:PENetPeer;command:PENetProtocol):longint;
begin
 if not (peer^.state in [ENET_PEER_STATE_CONNECTED,ENET_PEER_STATE_DISCONNECT_LATER]) then begin
  result:=-1;
 end else begin
  if peer^.incomingBandwidth<>0 then begin
   dec(host^.bandwidthLimitedPeers);
  end;
  peer^.incomingBandwidth:=ENET_NET_TO_HOST_32(command^.bandwidthLimit.incomingBandwidth);
  peer^.outgoingBandwidth:=ENET_NET_TO_HOST_32(command^.bandwidthLimit.outgoingBandwidth);
  if peer^.incomingBandwidth<>0 then begin
   inc(host^.bandwidthLimitedPeers);
  end;
  if (peer^.incomingBandwidth=0) and (host^.outgoingBandwidth=0) then begin
   peer^.windowSize:=ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE;
  end else begin
   peer^.windowSize:=(Min(peer^.incomingBandwidth,host^.outgoingBandwidth) div ENET_PEER_WINDOW_SIZE_SCALE)*ENET_PROTOCOL_MINIMUM_WINDOW_SIZE;
  end;
  if peer^.windowSize<ENET_PROTOCOL_MINIMUM_WINDOW_SIZE then begin
   peer^.windowSize:=ENET_PROTOCOL_MINIMUM_WINDOW_SIZE;
  end else if peer^.windowSize>ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE then begin
   peer^.windowSize:=ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE;
  end;
  result:=0;
 end;
end;

function enet_protocol_handle_throttle_configure(host:PENetHost;peer:PENetPeer;command:PENetProtocol):longint;
begin
 if not (peer^.state in [ENET_PEER_STATE_CONNECTED,ENET_PEER_STATE_DISCONNECT_LATER]) then begin
  result:=-1;
 end else begin
  peer^.packetThrottleInterval:=ENET_NET_TO_HOST_32(command^.throttleConfigure.packetThrottleInterval);
  peer^.packetThrottleAcceleration:=ENET_NET_TO_HOST_32(command^.throttleConfigure.packetThrottleAcceleration);
  peer^.packetThrottleDeceleration:=ENET_NET_TO_HOST_32(command^.throttleConfigure.packetThrottleDeceleration);
  result:=0;
 end;
end;

function enet_protocol_handle_disconnect(host:PENetHost;peer:PENetPeer;command:PENetProtocol):longint;
begin
 if peer^.state in [ENET_PEER_STATE_DISCONNECTED,ENET_PEER_STATE_ZOMBIE,ENET_PEER_STATE_ACKNOWLEDGING_DISCONNECT] then begin
  result:=0;
  exit;
 end;
 enet_peer_reset_queues(peer);
 if peer^.state in [ENET_PEER_STATE_CONNECTION_SUCCEEDED,ENET_PEER_STATE_DISCONNECTING] then begin
  enet_protocol_dispatch_state(host,peer,ENET_PEER_STATE_ZOMBIE);
 end else if (peer^.state<>ENET_PEER_STATE_CONNECTED) and (peer^.state<>ENET_PEER_STATE_DISCONNECT_LATER) then begin
  if peer^.state=ENET_PEER_STATE_CONNECTION_PENDING then begin
   host^.recalculateBandwidthLimits:=1;
  end;
  enet_peer_reset(peer);
 end else if (command^.header.command and ENET_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE)<>0 then begin
  enet_protocol_change_state(host,peer,ENET_PEER_STATE_ACKNOWLEDGING_DISCONNECT);
 end else begin
  enet_protocol_dispatch_state(host,peer,ENET_PEER_STATE_ZOMBIE);
 end;
 if peer^.state<>ENET_PEER_STATE_DISCONNECTED then begin
  peer^.eventData:=ENET_NET_TO_HOST_32(command^.disconnect.data);
 end;
 result:=0;
end;

function enet_protocol_handle_acknowledge(host:PENetHost;event:PENetEvent;peer:PENetPeer;command:PENetProtocol):longint;
var roundTripTime,receivedSentTime,receivedReliableSequenceNumber:longword;
    commandNumber:TENetProtocolCommand;
begin
 if peer^.state in [ENET_PEER_STATE_DISCONNECTED,ENET_PEER_STATE_ZOMBIE] then begin
  result:=0;
  exit;
 end;
 receivedSentTime:=ENET_NET_TO_HOST_16(command^.acknowledge.receivedSentTime);
 receivedSentTime:=receivedSentTime or (host^.serviceTime and $FFFF0000);
 if (receivedSentTime and $8000)>(host^.serviceTime and $8000) then begin
  dec(receivedSentTime,$10000);
 end;
 if ENET_TIME_LESS(host^.serviceTime,receivedSentTime) then begin
  result:=0;
  exit;
 end;
 peer^.lastReceiveTime:=host^.serviceTime;
 peer^.earliestTimeout:=0;
 roundTripTime:=ENET_TIME_DIFFERENCE(host^.serviceTime,receivedSentTime);
 enet_peer_throttle(peer,roundTripTime);
 dec(peer^.roundTripTimeVariance,peer^.roundTripTimeVariance div 4);
 if roundTripTime>=peer^.roundTripTime then begin
  inc(peer^.roundTripTime,(roundTripTime-peer^.roundTripTime) div 8);
  inc(peer^.roundTripTimeVariance,(roundTripTime-peer^.roundTripTime) div 4);
 end else begin
  dec(peer^.roundTripTime,(peer^.roundTripTime-roundTripTime) div 8);
  inc(peer^.roundTripTimeVariance,(peer^.roundTripTime-roundTripTime) div 4);
 end;
 if peer^.roundTripTime<peer^.lowestRoundTripTime then begin
  peer^.lowestRoundTripTime:=peer^.roundTripTime;
 end;
 if peer^.roundTripTimeVariance>peer^.highestRoundTripTimeVariance then begin
  peer^.highestRoundTripTimeVariance:=peer^.roundTripTimeVariance;
 end;
 if (peer^.packetThrottleEpoch=0) or (ENET_TIME_DIFFERENCE(host^.serviceTime,peer^.packetThrottleEpoch)>=longint(peer^.packetThrottleInterval)) then begin
  peer^.lastRoundTripTime:=peer^.lowestRoundTripTime;
  peer^.lastRoundTripTimeVariance:=peer^.highestRoundTripTimeVariance;
  peer^.lowestRoundTripTime:=peer^.roundTripTime;
  peer^.highestRoundTripTimeVariance:=peer^.roundTripTimeVariance;
  peer^.packetThrottleEpoch:=host^.serviceTime;
 end;
 receivedReliableSequenceNumber:=ENET_NET_TO_HOST_16(command^.acknowledge.receivedReliableSequenceNumber);
 commandNumber:=enet_protocol_remove_sent_reliable_command(peer,receivedReliableSequenceNumber,command^.header.channelID);
 case peer^.state of
  ENET_PEER_STATE_ACKNOWLEDGING_CONNECT:begin
   if commandNumber<>ENET_PROTOCOL_COMMAND_VERIFY_CONNECT then begin
    result:=-1;
    exit;
   end;
   enet_protocol_notify_connect(host,peer,event);
  end;
  ENET_PEER_STATE_DISCONNECTING:begin
   if commandNumber<>ENET_PROTOCOL_COMMAND_DISCONNECT then begin
    result:=-1;
    exit;
   end;
   enet_protocol_notify_disconnect(host,peer,event);
  end;
  ENET_PEER_STATE_DISCONNECT_LATER:begin
   if enet_list_empty(@peer^.outgoingReliableCommands) and enet_list_empty(@peer^.outgoingUnreliableCommands) and enet_list_empty(@peer^.sentReliableCommands) then begin
    enet_peer_disconnect(peer,peer^.eventData);
   end;
  end;
 end;
 result:=0;
end;

function enet_protocol_handle_verify_connect(host:PENetHost;event:PENetEvent;peer:PENetPeer;command:PENetProtocol):longint;
var mtu,windowSize:longword;
    channelCount:longword;
begin
 if peer^.state<>ENET_PEER_STATE_CONNECTING then begin
  result:=0;
  exit;
 end;
 channelCount:=ENET_NET_TO_HOST_32(command^.verifyConnect.channelCount);
 if (channelCount<ENET_PROTOCOL_MINIMUM_CHANNEL_COUNT) or
    (channelCount>ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT) or
    (ENET_NET_TO_HOST_32(command^.verifyConnect.packetThrottleInterval)<>peer^.packetThrottleInterval) or
    (ENET_NET_TO_HOST_32(command^.verifyConnect.packetThrottleAcceleration)<>peer^.packetThrottleAcceleration) or
    (ENET_NET_TO_HOST_32(command^.verifyConnect.packetThrottleDeceleration)<>peer^.packetThrottleDeceleration) or
    (command^.verifyConnect.connectID<>peer^.connectID) then begin
  peer^.eventData:=0;
  enet_protocol_dispatch_state (host, peer, ENET_PEER_STATE_ZOMBIE);
  result:=-1;
  exit;
 end;
 enet_protocol_remove_sent_reliable_command(peer,1,$FF);
 if channelCount<peer^.channelCount then begin
  peer^.channelCount:=channelCount;
 end;
 peer^.outgoingPeerID:=ENET_NET_TO_HOST_16(command^.verifyConnect.outgoingPeerID);
 peer^.incomingSessionID:=command^.verifyConnect.incomingSessionID;
 peer^.outgoingSessionID:=command^.verifyConnect.outgoingSessionID;
 mtu:=ENET_NET_TO_HOST_32(command^.verifyConnect.mtu);
 if mtu<ENET_PROTOCOL_MINIMUM_MTU then begin
  mtu:=ENET_PROTOCOL_MINIMUM_MTU;
 end else if mtu>ENET_PROTOCOL_MAXIMUM_MTU then begin
  mtu:=ENET_PROTOCOL_MAXIMUM_MTU;
 end;
 if mtu<peer^.mtu then begin
  peer^.mtu:=mtu;
 end;
 windowSize:=ENET_NET_TO_HOST_32(command^.verifyConnect.windowSize);
 if windowSize<ENET_PROTOCOL_MINIMUM_WINDOW_SIZE then begin
  windowSize:=ENET_PROTOCOL_MINIMUM_WINDOW_SIZE;
 end;
 if windowSize>ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE then begin
  windowSize:=ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE;
 end;
 if windowSize<peer^.windowSize then begin
  peer^.windowSize:=windowSize;
 end;
 peer^.incomingBandwidth:=ENET_NET_TO_HOST_32(command^.verifyConnect.incomingBandwidth);
 peer^.outgoingBandwidth:=ENET_NET_TO_HOST_32(command^.verifyConnect.outgoingBandwidth);
 enet_protocol_notify_connect(host,peer,event);
 result:=0;
end;

function enet_protocol_handle_incoming_commands(host:PENetHost;event:PENetEvent):longint;
label commandError;
var header:PENetProtocolHeader;
    command:PENetProtocol;
    peer:PENetPeer;
    currentData:PAnsiChar;
    checksum:PLongword;
    headerSize,originalSize,desiredChecksum,commandSize:longword;
    peerID,flags,sentTime:word;
    sessionID,commandNumber:byte;
    buffer:TENetBuffer;
begin
 if ENETptruint(host^.receivedDataLength)<{%H-}ENETptruint(pointer(@PENetProtocolHeader(nil)^.sentTime)) then begin
  result:=0;
  exit;
 end;
 header:=PENetProtocolHeader(host^.receivedData);
 peerID:=ENET_NET_TO_HOST_16(header^.peerID);
 sessionID:=(peerID and ENET_PROTOCOL_HEADER_SESSION_MASK) shr ENET_PROTOCOL_HEADER_SESSION_SHIFT;
 flags:=peerID and ENET_PROTOCOL_HEADER_FLAG_MASK;
 peerID:=peerID and not (ENET_PROTOCOL_HEADER_FLAG_MASK or ENET_PROTOCOL_HEADER_SESSION_MASK);
 if (flags and ENET_PROTOCOL_HEADER_FLAG_SENT_TIME)<>0 then begin
  headerSize:=sizeof(TENetProtocolHeader);
 end else begin
  headerSize:={%H-}ENETptruint(pointer(@PENetProtocolHeader(nil)^.sentTime));
 end;
 if assigned(host^.checksum) then begin
  inc(headerSize,sizeof(longword));
 end;
 if peerID=ENET_PROTOCOL_MAXIMUM_PEER_ID then begin
  peer:=nil;
 end else if peerID>=host^.peerCount then begin
  result:=0;
  exit;
 end else begin
  peer:=@host^.peers[peerID];
  if (peer^.state in [ENET_PEER_STATE_DISCONNECTED,ENET_PEER_STATE_ZOMBIE]) or
     ((peer^.outgoingPeerID<ENET_PROTOCOL_MAXIMUM_PEER_ID) and (sessionID<>peer^.incomingSessionID)) or
       ((not enet_compare_address(peer^.address.host,host^.receivedAddress.host)) and
        (not enet_compare_address(peer^.address.host,ENET_HOST_BROADCAST_)) and
        (peer^.address.host.addr[0]<>$ff)) then begin
   result:=0;
   exit;
  end;
 end;
 if (flags and ENET_PROTOCOL_HEADER_FLAG_COMPRESSED)<>0 then begin
  if (not assigned(host^.compressor.context)) or not assigned(host^.compressor.decompress) then begin
   result:=0;
   exit;
  end;
  originalSize:=host^.compressor.decompress(host^.compressor.context,pointer(@pansichar(host^.receivedData)[headerSize]),longword(host^.receivedDataLength)-headerSize,@host^.packetData[1,headerSize],sizeof(host^.packetData[1])-headerSize);
  if (originalSize<=0) or (originalSize>(sizeof(host^.packetData[1])-headerSize)) then begin
   result:=0;
   exit;
  end;
  move(header,host^.packetData[1],headerSize);
  host^.receivedData:=@host^.packetData[1];
  host^.receivedDataLength:=headerSize+originalSize;
 end;
 if assigned(host^.checksum) then begin
  checksum:=pointer(@host^.receivedData[headerSize-sizeof(longword)]);
  desiredChecksum:=checksum^;
  if assigned(peer) then begin
   checksum^:=peer^.connectID;
  end else begin
   checksum^:=0;
  end;
  buffer.data:=host^.receivedData;
  buffer.dataLength:=host^.receivedDataLength;
  if host^.checksum(@buffer,1)<>desiredChecksum then begin
   result:=0;
   exit;
  end;
 end;
 if assigned(peer) then begin
  peer^.address:=host^.receivedAddress;
  inc(peer^.incomingDataTotal,host^.receivedDataLength);
 end;
 currentData:=@host^.receivedData[headerSize];
 while currentData<@host^.receivedData[host^.receivedDataLength] do begin
  command:=PENetProtocol(currentData);
  if PAnsiChar(@currentData[sizeof(TENetProtocolCommandHeader)])>PAnsiChar(@host^.receivedData[host^.receivedDataLength]) then begin
   break;
  end;
  commandNumber:=command^.header.command and ENET_PROTOCOL_COMMAND_MASK;
  if commandNumber>=ENET_PROTOCOL_COMMAND_COUNT then begin
   break;
  end;
  commandSize:=commandSizes[commandNumber];
  if (commandSize=0) or (PAnsiChar(@currentData[commandSize])>PAnsiChar(@host^.receivedData[host^.receivedDataLength])) then begin
   break;
  end;
  inc(currentData,commandSize);
  if (not assigned(peer)) and (commandNumber<>ENET_PROTOCOL_COMMAND_CONNECT) then begin
   break;
  end;
  command^.header.reliableSequenceNumber:=ENET_NET_TO_HOST_16(command^.header.reliableSequenceNumber);
  case commandNumber of
   ENET_PROTOCOL_COMMAND_ACKNOWLEDGE:begin
    if enet_protocol_handle_acknowledge(host,event,peer,command)<>0 then begin
     goto commandError;
    end;
   end;
   ENET_PROTOCOL_COMMAND_CONNECT:begin
    peer:=enet_protocol_handle_connect(host,header,command);
    if not assigned(peer) then begin
     goto commandError;
    end;
   end;
   ENET_PROTOCOL_COMMAND_VERIFY_CONNECT:begin
    if enet_protocol_handle_verify_connect(host,event,peer,command)<>0 then begin
     goto commandError;
    end;
   end;
   ENET_PROTOCOL_COMMAND_DISCONNECT:begin
    if enet_protocol_handle_disconnect(host,peer,command)<>0 then begin
     goto commandError;
    end;
   end;
   ENET_PROTOCOL_COMMAND_PING:begin
    if enet_protocol_handle_ping(host,peer,command)<>0 then begin
     goto commandError;
    end;
   end;
   ENET_PROTOCOL_COMMAND_SEND_RELIABLE:begin
    if enet_protocol_handle_send_reliable(host,peer,command,@currentData)<>0 then begin
     goto commandError;
    end;
   end;
   ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE:begin
    if enet_protocol_handle_send_unreliable(host,peer,command,@currentData)<>0 then begin
     goto commandError;
    end;
   end;
   ENET_PROTOCOL_COMMAND_SEND_UNSEQUENCED:begin
    if enet_protocol_handle_send_unsequenced(host,peer,command,@currentData)<>0 then begin
     goto commandError;
    end;
   end;
   ENET_PROTOCOL_COMMAND_SEND_FRAGMENT:begin
    if enet_protocol_handle_send_fragment(host,peer,command,@currentData)<>0 then begin
     goto commandError;
    end;
   end;
   ENET_PROTOCOL_COMMAND_BANDWIDTH_LIMIT:begin
    if enet_protocol_handle_bandwidth_limit(host,peer,command)<>0 then begin
     goto commandError;
    end;
   end;
   ENET_PROTOCOL_COMMAND_THROTTLE_CONFIGURE:begin
    if enet_protocol_handle_throttle_configure(host,peer,command)<>0 then begin
     goto commandError;
    end;
   end;
   ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE_FRAGMENT:begin
    if enet_protocol_handle_send_unreliable_fragment(host,peer,command,@currentData)<>0 then begin
     goto commandError;
    end;
   end;
   else begin
    goto commandError;
   end;
  end;
  if assigned(peer) and ((command^.header.command and ENET_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE)<>0) then begin
   if (flags and ENET_PROTOCOL_HEADER_FLAG_SENT_TIME)=0 then begin
    break;
   end;
   sentTime:=ENET_NET_TO_HOST_16(header^.sentTime);
   case peer^.state of
    ENET_PEER_STATE_DISCONNECTING,ENET_PEER_STATE_ACKNOWLEDGING_CONNECT,ENET_PEER_STATE_DISCONNECTED,ENET_PEER_STATE_ZOMBIE:begin
    end;
    ENET_PEER_STATE_ACKNOWLEDGING_DISCONNECT:begin
     if (command^.header.command and ENET_PROTOCOL_COMMAND_MASK)=ENET_PROTOCOL_COMMAND_DISCONNECT then begin
      enet_peer_queue_acknowledgement(peer,command,sentTime);
     end;
    end;
    else begin
     enet_peer_queue_acknowledgement(peer,command,sentTime);
    end;
   end;
  end;
 end;
commandError:
 if assigned(event) and (event^.type_<>ENET_EVENT_TYPE_NONE) then begin
  result:=1;
 end else begin
  result:=0;
 end;
end;

function enet_protocol_receive_incoming_commands(host:PENetHost;event:PENetEvent;family:TENetAddressFamily):longint;
var packets,receivedLength:longint;
    buffer:TENetBuffer;
begin
 for packets:=0 to 255 do begin
  buffer.data:=@host^.packetData[0];
  buffer.dataLength:=sizeof(host^.packetData[0]);
  if family=ENET_IPV4 then begin
   receivedLength:=enet_socket_receive(host^.socket4,@host^.receivedAddress,@buffer,1,family);
  end else begin
   receivedLength:=enet_socket_receive(host^.socket6,@host^.receivedAddress,@buffer,1,family);
  end;
  if receivedLength<0 then begin
   result:=-1;
   exit;
  end;
  if receivedLength=0 then begin
   result:=0;
   exit;
  end;
  if enet_get_address_family(@host^.receivedAddress)<>family then begin
   result:=-1;
   exit;
  end;
  host^.receivedData:=@host^.packetData[0];
  host^.receivedDataLength:=receivedLength;
  inc(host^.totalReceivedData,receivedLength);
  inc(host^.totalReceivedPackets);
  if assigned(host^.intercept) then begin
   case host^.intercept(host,event) of
    1:begin
     if assigned(event) and (event^.type_<>ENET_EVENT_TYPE_NONE) then begin
      result:=1;
      exit;
     end;
     continue;
    end;
    -1:begin
     result:=-1;
     exit;
    end;
   end;
  end;
  case enet_protocol_handle_incoming_commands(host,event) of
   1:begin
    result:=1;
    exit;
   end;
   -1:begin
    result:=-1;
    exit;
   end;
  end;
 end;
 result:=-1;
end;

procedure enet_protocol_send_acknowledgements(host:PENetHost;peer:PENetPeer);
var command:PENetProtocol;
    buffer:PENetBuffer;
    acknowledgement:PENetAcknowledgement;
    currentAcknowledgement:TENetListIterator;
    reliableSequenceNumber:word;
begin
 command:=@host^.commands[host^.commandCount];
 buffer:=@host^.buffers[host^.bufferCount];
 currentAcknowledgement:=enet_list_begin(@peer^.acknowledgements);
 while currentAcknowledgement<>enet_list_end(@peer^.acknowledgements) do begin
  if (ptruint(pointer(command))>=ptruint(pointer(@host^.commandCount))) or
     (ptruint(pointer(buffer))>=ptruint(pointer(@host^.bufferCount))) or
     ((peer^.mtu-longword(host^.packetSize))<sizeof(TENetProtocolAcknowledge)) then begin
   host^.continueSending:=1;
   break;
  end;
  acknowledgement:=PENetAcknowledgement(currentAcknowledgement);
  currentAcknowledgement:=enet_list_next(currentAcknowledgement);
  buffer^.data:=pointer(command);
  buffer^.dataLength:=sizeof(TENetProtocolAcknowledge);
  inc(host^.packetSize,buffer^.dataLength);
  reliableSequenceNumber:=ENET_HOST_TO_NET_16(acknowledgement^.command.header.reliableSequenceNumber);
  command^.header.command:=ENET_PROTOCOL_COMMAND_ACKNOWLEDGE;
  command^.header.channelID:=acknowledgement^.command.header.channelID;
  command^.header.reliableSequenceNumber:=reliableSequenceNumber;
  command^.acknowledge.receivedReliableSequenceNumber:=reliableSequenceNumber;
  command^.acknowledge.receivedSentTime:=ENET_HOST_TO_NET_16(acknowledgement^.sentTime);
  if (acknowledgement^.command.header.command and ENET_PROTOCOL_COMMAND_MASK)=ENET_PROTOCOL_COMMAND_DISCONNECT then begin
   enet_protocol_dispatch_state(host,peer,ENET_PEER_STATE_ZOMBIE);
  end;
  enet_list_remove(@acknowledgement^.acknowledgementList);
  FreeMem(acknowledgement);
  inc(command);
  inc(buffer);
 end;
 host^.commandCount:=(ptruint(pointer(command))-ptruint(pointer(@host^.commands))) div SizeOf(TENetProtocol);
 host^.bufferCount:=(ptruint(pointer(buffer))-ptruint(pointer(@host^.buffers))) div SizeOf(TENetBuffer);
end;

procedure enet_protocol_send_unreliable_outgoing_commands(host:PENetHost;peer:PENetPeer);
var command:PENetProtocol;
    buffer:PENetBuffer;
    outgoingCommand:PENetOutgoingCommand;
    currentCommand:TENetListIterator;
    commandSize:longword;
    reliableSequenceNumber,unreliableSequenceNumber:word;
begin
 command:=@host^.commands[host^.commandCount];
 buffer:=@host^.buffers[host^.bufferCount];
 currentCommand:=enet_list_begin(@peer^.outgoingUnreliableCommands);
 while currentCommand<>enet_list_end(@peer^.outgoingUnreliableCommands) do begin
  outgoingCommand:=PENetOutgoingCommand(currentCommand);
  commandSize:=commandSizes[outgoingCommand^.command.header.command and ENET_PROTOCOL_COMMAND_MASK];
  if (ptruint(pointer(command))>=ptruint(pointer(@host^.commandCount))) or
     ((ptruint(pointer(buffer))+ptruint(sizeof(TENetBuffer)))>=ptruint(pointer(@host^.bufferCount))) or
     ((peer^.mtu-longword(host^.packetSize))<commandSize) or
     ((not assigned(outgoingCommand^.packet)) and
      ((peer^.mtu-longword(host^.packetSize))<(commandSize+outgoingCommand^.fragmentLength))) then begin
   host^.continueSending:=1;
   break;
  end;
  currentCommand:=enet_list_next(currentCommand);
  if assigned(outgoingCommand^.packet) and (outgoingCommand^.fragmentOffset=0) then begin
   peer^.packetThrottleCounter:=(peer^.packetThrottleCounter+ENET_PEER_PACKET_THROTTLE_COUNTER) mod ENET_PEER_PACKET_THROTTLE_SCALE;
   if peer^.packetThrottleCounter>peer^.packetThrottle then begin
    reliableSequenceNumber:=outgoingCommand^.reliableSequenceNumber;
    unreliableSequenceNumber:=outgoingCommand^.unreliableSequenceNumber;
    while true do begin
     dec(outgoingCommand^.packet^.referenceCount);
     if outgoingCommand^.packet^.referenceCount=0 then begin
      enet_packet_destroy(outgoingCommand^.packet);
     end;
     enet_list_remove(@outgoingCommand^.outgoingCommandList);
     FreeMem(outgoingCommand);
     if currentCommand=enet_list_end(@peer^.outgoingUnreliableCommands) then begin
      break;
     end;
     outgoingCommand:=PENetOutgoingCommand(currentCommand);
     if (outgoingCommand^.reliableSequenceNumber<>reliableSequenceNumber) or
        (outgoingCommand^.unreliableSequenceNumber<>unreliableSequenceNumber) then begin
      break;
     end;
     currentCommand:=enet_list_next(currentCommand);
    end;
    continue;
   end;
  end;
  buffer^.data:=pointer(command);
  buffer^.dataLength:=commandSize;
  inc(host^.packetSize,buffer^.dataLength);
  command^:=outgoingCommand^.command;
  enet_list_remove(@outgoingCommand^.outgoingCommandList);
  if assigned(outgoingCommand^.packet) then begin
   inc(buffer);
   buffer^.data:=@outgoingCommand^.packet^.data[outgoingCommand^.fragmentOffset];
   buffer^.dataLength:=outgoingCommand^.fragmentLength;
   inc(host^.packetSize,buffer^.dataLength);
   enet_list_insert(enet_list_end(@peer^.sentUnreliableCommands),outgoingCommand);
  end else begin
   FreeMem(outgoingCommand);
  end;
  inc(command);
  inc(buffer);
 end;
 host^.commandCount:=(ptruint(pointer(command))-ptruint(pointer(@host^.commands))) div SizeOf(TENetProtocol);
 host^.bufferCount:=(ptruint(pointer(buffer))-ptruint(pointer(@host^.buffers))) div SizeOf(TENetBuffer);
 if (peer^.state=ENET_PEER_STATE_DISCONNECT_LATER) and
    enet_list_empty(@peer^.outgoingReliableCommands) and
    enet_list_empty(@peer^.outgoingUnreliableCommands) and
    enet_list_empty(@peer^.sentReliableCommands) then begin
  enet_peer_disconnect(peer,peer^.eventData);
 end;
end;

function enet_protocol_check_timeouts(host:PENetHost;peer:PENetPeer;event:PENetEvent):longint;
var outgoingCommand:PENetOutgoingCommand;
    currentCommand,insertPosition:TENetListIterator;
begin
 currentCommand:=enet_list_begin(@peer^.sentReliableCommands);
 insertPosition:=enet_list_begin(@peer^.outgoingReliableCommands);
 while currentCommand<>enet_list_end(@peer^.sentReliableCommands) do begin
  outgoingCommand:=PENetOutgoingCommand(currentCommand);
  currentCommand:=enet_list_next(currentCommand);
  if ENET_TIME_DIFFERENCE(host^.serviceTime,outgoingCommand^.sentTime)<longint(outgoingCommand^.roundTripTimeout) then begin
   continue;
  end;
  if (peer^.earliestTimeout=0) or ENET_TIME_LESS(outgoingCommand^.sentTime,peer^.earliestTimeout) then begin
   peer^.earliestTimeout:=outgoingCommand^.sentTime;
  end;
  if (peer^.earliestTimeout<>0) and
     ((ENET_TIME_DIFFERENCE(host^.serviceTime,peer^.earliestTimeout)>=longint(peer^.timeoutMaximum)) or
      ((outgoingCommand^.roundTripTimeout>=outgoingCommand^.roundTripTimeoutLimit) and
       (ENET_TIME_DIFFERENCE(host^.serviceTime,peer^.earliestTimeout)>=longint(peer^.timeoutMinimum)))) then begin
   enet_protocol_notify_disconnect(host,peer,event);
   result:=1;
   exit;
  end;
  if assigned(outgoingCommand^.packet) then begin
   dec(peer^.reliableDataInTransit,outgoingCommand^.fragmentLength);
  end;
  inc(peer^.packetsLost);
  inc(outgoingCommand^.roundTripTimeout,outgoingCommand^.roundTripTimeout);
  enet_list_insert (insertPosition,enet_list_remove(@outgoingCommand^.outgoingCommandList));
  if (currentCommand=enet_list_begin(@peer^.sentReliableCommands)) and not enet_list_empty(@peer^.sentReliableCommands) then begin
   outgoingCommand:=PENetOutgoingCommand(currentCommand);
   peer^.nextTimeout:=outgoingCommand^.sentTime+outgoingCommand^.roundTripTimeout;
  end;
 end;
 result:=0;
end;

function enet_protocol_send_reliable_outgoing_commands(host:PENetHost;peer:PENetPeer):longint;
var command:PENetProtocol;
    buffer:PENetBuffer;
    outgoingCommand:PENetOutgoingCommand;
    currentCommand:TENetListIterator;
    channel:PENetChannel;
    reliableWindow:word;
    commandSize:word;
    windowExceeded,windowWrap,canPing:longint;
    windowSize:longword;
begin
 command:=@host^.commands[host^.commandCount];
 buffer:=@host^.buffers[host^.bufferCount];
 windowExceeded:=0;
 windowWrap:=0;
 canPing:=1;
 currentCommand:=enet_list_begin(@peer^.outgoingReliableCommands);
 while currentCommand<>enet_list_end(@peer^.outgoingReliableCommands) do begin
  outgoingCommand:=PENetOutgoingCommand(currentCommand);
  if outgoingCommand^.command.header.channelID<peer^.channelCount then begin
   channel:=@peer^.channels[outgoingCommand^.command.header.channelID];
  end else begin
   channel:=nil;
  end;
  reliableWindow:=outgoingCommand^.reliableSequenceNumber div ENET_PEER_RELIABLE_WINDOW_SIZE;
  if assigned(channel) then begin
   if ((windowWrap=0) and (outgoingCommand^.sendAttempts<1) and
       ((outgoingCommand^.reliableSequenceNumber mod ENET_PEER_RELIABLE_WINDOW_SIZE)=0) and
       ((channel^.reliableWindows[(reliableWindow+(ENET_PEER_RELIABLE_WINDOWS-1)) mod ENET_PEER_RELIABLE_WINDOWS]>=ENET_PEER_RELIABLE_WINDOW_SIZE) or
        (channel^.usedReliableWindows and ((((1 shl ENET_PEER_FREE_RELIABLE_WINDOWS)-1) shl reliableWindow) or (((1 shl ENET_PEER_FREE_RELIABLE_WINDOWS)-1) shr (ENET_PEER_RELIABLE_WINDOW_SIZE-reliableWindow)))<>0))) then begin
    windowWrap:=1;
   end;
   if windowWrap<>0 then begin
    currentCommand:=enet_list_next (currentCommand);
    continue;
   end;
  end;
  if assigned(outgoingCommand^.packet) then begin
   if windowExceeded=0 then begin
    windowSize:=(peer^.packetThrottle*peer^.windowSize) div ENET_PEER_PACKET_THROTTLE_SCALE;
    if (peer^.reliableDataInTransit+outgoingCommand^.fragmentLength)>Max(windowSize,peer^.mtu) then begin
     windowExceeded:=1;
    end;
   end;
   if windowExceeded<>0 then begin
    currentCommand:=enet_list_next(currentCommand);
    continue;
   end;
  end;
  canPing:=0;
  commandSize:=commandSizes[outgoingCommand^.command.header.command and ENET_PROTOCOL_COMMAND_MASK];
  if (ptruint(pointer(command))>=ptruint(pointer(@host^.commandCount))) or
     ((ptruint(pointer(buffer))+ptruint(sizeof(TENetBuffer)))>=ptruint(pointer(@host^.bufferCount))) or
     ((peer^.mtu-longword(host^.packetSize))<commandSize) or
     ((not assigned(outgoingCommand^.packet)) and
      (word(peer^.mtu-longword(host^.packetSize))<word(commandSize+outgoingCommand^.fragmentLength))) then begin
   host^.continueSending:=1;
   break;
  end;
  currentCommand:=enet_list_next(currentCommand);
  if assigned(channel) and (outgoingCommand^.sendAttempts<1) then begin
   channel^.usedReliableWindows:=channel^.usedReliableWindows or (1 shl reliableWindow);
   inc(channel^.reliableWindows[reliableWindow]);
  end;
  inc(outgoingCommand^.sendAttempts);
  if outgoingCommand^.roundTripTimeout=0 then begin
   outgoingCommand^.roundTripTimeout:=peer^.roundTripTime+(4*peer^.roundTripTimeVariance);
   outgoingCommand^.roundTripTimeoutLimit:=peer^.timeoutLimit*outgoingCommand^.roundTripTimeout;
  end;
  if enet_list_empty(@peer^.sentReliableCommands) then begin
   peer^.nextTimeout:=host^.serviceTime+outgoingCommand^.roundTripTimeout;
  end;
  enet_list_insert(enet_list_end(@peer^.sentReliableCommands),enet_list_remove(@outgoingCommand^.outgoingCommandList));
  outgoingCommand^.sentTime:=host^.serviceTime;
  buffer^.data:=pointer(command);
  buffer^.dataLength:=commandSize;
  inc(host^.packetSize,buffer^.dataLength);
  host^.headerFlags:=host^.headerFlags or ENET_PROTOCOL_HEADER_FLAG_SENT_TIME;
  command^:=outgoingCommand^.command;
  if assigned(outgoingCommand^.packet) then begin
   inc(buffer);
   buffer^.data:=@outgoingCommand^.packet^.data[outgoingCommand^.fragmentOffset];
   buffer^.dataLength:=outgoingCommand^.fragmentLength;
   inc(host^.packetSize,outgoingCommand^.fragmentLength);
   inc(peer^.reliableDataInTransit,outgoingCommand^.fragmentLength);
  end;
  inc(peer^.packetsSent);
  inc(command);
  inc(buffer);
 end;
 host^.commandCount:=(ptruint(pointer(command))-ptruint(pointer(@host^.commands))) div SizeOf(TENetProtocol);
 host^.bufferCount:=(ptruint(pointer(buffer))-ptruint(pointer(@host^.buffers))) div SizeOf(TENetBuffer);
 result:=canPing;
end;

function enet_protocol_send_outgoing_commands(host:PENetHost;event:PENetEvent;checkForTimeouts:longint):longint;
var headerData:array[0..(sizeof(TENetProtocolHeader)+sizeof(longword))-1] of byte;
    header:PENetProtocolHeader;
    currentPeer:PENetPeer;
    sentLength:longint;
    shouldCompress,packetLoss,originalSize,compressedSize:longword;
    family:TENetAddressFamily;
    socket:TENetSocket;
    checksum:plongword;
begin
 header:=pointer(@headerData);
//shouldCompress:=0;
 host^.continueSending:=1;
 while host^.continueSending<>0 do begin
  host^.continueSending:=0;
  currentPeer:=@host^.peers[0];
  while ptruint(pointer(currentPeer))<ptruint(pointer(@host^.peers [host^.peerCount])) do begin
   if currentPeer^.state in [ENET_PEER_STATE_DISCONNECTED,ENET_PEER_STATE_ZOMBIE] then begin
    inc(currentPeer);
    continue;
   end;
   host^.headerFlags:=0;
   host^.commandCount:=0;
   host^.bufferCount:=1;
   host^.packetSize:=sizeof(TENetProtocolHeader);
   if not enet_list_empty(@currentPeer^.acknowledgements) then begin
    enet_protocol_send_acknowledgements(host,currentPeer);
   end;
   if (checkForTimeouts<>0) and
      (not enet_list_empty(@currentPeer^.sentReliableCommands)) and
       ENET_TIME_GREATER_EQUAL(host^.serviceTime,currentPeer^.nextTimeout) and
       (enet_protocol_check_timeouts(host,currentPeer,event)=1) then begin
    if assigned(event) and (event^.type_<>ENET_EVENT_TYPE_NONE) then begin
     result:=1;
     exit;
    end else begin
     inc(currentPeer);
     continue;
    end;
   end;
   if ((enet_list_empty(@currentPeer^.outgoingReliableCommands) or
       (enet_protocol_send_reliable_outgoing_commands(host,currentPeer)<>0)) and
       enet_list_empty(@currentPeer^.sentReliableCommands) and
       (ENET_TIME_DIFFERENCE(host^.serviceTime,currentPeer^.lastReceiveTime)>=longint(currentPeer^.pingInterval)) and
       (longword(currentPeer^.mtu-longword(host^.packetSize))>=longword(sizeof(TENetProtocolPing)))) then begin
    enet_peer_ping(currentPeer);
    enet_protocol_send_reliable_outgoing_commands(host,currentPeer);
   end;
   if not enet_list_empty(@currentPeer^.outgoingUnreliableCommands) then begin
    enet_protocol_send_unreliable_outgoing_commands(host,currentPeer);
   end;
   if host^.commandCount=0 then begin
    inc(currentPeer);
    continue;
   end;
   if currentPeer^.packetLossEpoch=0 then begin
    currentPeer^.packetLossEpoch:=host^.serviceTime;
   end else if (ENET_TIME_DIFFERENCE(host^.serviceTime,currentPeer^.packetLossEpoch)>=ENET_PEER_PACKET_LOSS_INTERVAL) and (currentPeer^.packetsSent>0) then begin
    packetLoss:=(currentPeer^.packetsLost div ENET_PEER_PACKET_LOSS_SCALE) div currentPeer^.packetsSent;
{$ifdef ENET_DEBUG}
    if assigned(currentPeer^.channels) then begin
     writeln('peer ',currentPeer^.incomingPeerID,': ',
             currentPeer^.packetLoss/ENET_PEER_PACKET_LOSS_SCALE:1:8,'+-',
             currentPeer^.packetLossVariance/ENET_PEER_PACKET_LOSS_SCALE:1:8,
             ' packet loss ',currentPeer^.roundTripTime,'+-',currentPeer^.roundTripTimeVariance,
             ' ms round trip time, ',
             currentPeer^.packetThrottle/ENET_PEER_PACKET_THROTTLE_SCALE:1:8,
             ' throttle, ',
             enet_list_size(@currentPeer^.outgoingReliableCommands),'/',
             enet_list_size(@currentPeer^.outgoingUnreliableCommands),' outgoing, ',
             enet_list_size(@currentPeer^.channels^[0].incomingReliableCommands),'/',
             enet_list_size(@currentPeer^.channels^[0].incomingUnreliableCommands),' incoming');
    end else begin
     writeln('peer ',currentPeer^.incomingPeerID,': ',
             currentPeer^.packetLoss/ENET_PEER_PACKET_LOSS_SCALE:1:8,'+-',
             currentPeer^.packetLossVariance/ENET_PEER_PACKET_LOSS_SCALE:1:8,
             ' packet loss ',currentPeer^.roundTripTime,'+-',currentPeer^.roundTripTimeVariance,
             ' ms round trip time, ',
             currentPeer^.packetThrottle/ENET_PEER_PACKET_THROTTLE_SCALE:1:8,
             ' throttle, ',
             enet_list_size(@currentPeer^.outgoingReliableCommands),'/',
             enet_list_size(@currentPeer^.outgoingUnreliableCommands),' outgoing, ',
             0,'/',
             0,' incoming');
    end;
{$endif}
    dec(currentPeer^.packetLossVariance,currentPeer^.packetLossVariance div 4);
    if packetLoss>=currentPeer^.packetLoss then begin
     inc(currentPeer^.packetLoss,(packetLoss-currentPeer^.packetLoss) div 8);
     inc(currentPeer^.packetLossVariance,(packetLoss-currentPeer^.packetLoss) div 4);
    end else begin
     dec(currentPeer^.packetLoss,(currentPeer^.packetLoss-packetLoss) div 8);
     dec(currentPeer^.packetLossVariance,(currentPeer^.packetLoss-packetLoss) div 4);
    end;
    currentPeer^.packetLossEpoch:=host^.serviceTime;
    currentPeer^.packetsSent:=0;
    currentPeer^.packetsLost:=0;
   end;
   host^.buffers[0].data:=@headerData;
   if (host^.headerFlags and ENET_PROTOCOL_HEADER_FLAG_SENT_TIME)<>0 then begin
    header^.sentTime:=ENET_HOST_TO_NET_16(host^.serviceTime and $FFFF);
    host^.buffers[0].dataLength:=sizeof(TENetProtocolHeader);
   end else begin
    host^.buffers[0].dataLength:={%H-}ENETptruint(Pointer(@PENetProtocolHeader(nil)^.sentTime));
   end;
   shouldCompress:=0;
   if assigned(host^.compressor.context) and assigned(host^.compressor.compress) then begin
    originalSize:=host^.packetSize-sizeof(TENetProtocolHeader);
    compressedSize:=host^.compressor.compress(host^.compressor.context,@host^.buffers[1],host^.bufferCount-1,originalSize,@host^.packetData[1,0],originalSize);
    if (compressedSize>0) and (compressedSize<originalSize) then begin
     host^.headerFlags:=host^.headerFlags or ENET_PROTOCOL_HEADER_FLAG_COMPRESSED;
     shouldCompress:=compressedSize;
{$ifdef ENET_DEBUG_COMPRESS}
     writeln('peer ', currentPeer^.incomingPeerID,': compressed ', originalSize,'^.', compressedSize,' (',(compressedSize*100) div originalSize,')');
{$endif}
    end;
   end;
   if currentPeer^.outgoingPeerID<ENET_PROTOCOL_MAXIMUM_PEER_ID then begin
    host^.headerFlags:=host^.headerFlags or (currentPeer^.outgoingSessionID shl ENET_PROTOCOL_HEADER_SESSION_SHIFT);
   end;
   header^.peerID:=ENET_HOST_TO_NET_16(currentPeer^.outgoingPeerID or host^.headerFlags);
   if assigned(host^.checksum) then begin
    checksum:=pointer(@headerData[host^.buffers[0].dataLength]);
    if currentPeer^.outgoingPeerID<ENET_PROTOCOL_MAXIMUM_PEER_ID then begin
     checksum^:=currentPeer^.connectID;
    end else begin
     checksum^:=0;
    end;
    inc(host^.buffers[0].dataLength,sizeof(longword));
    checksum^:=host^.checksum(@host^.buffers[0],host^.bufferCount);
   end;
   if shouldCompress>0 then begin
    host^.buffers[1].data:=pointer(@host^.packetData[1,0]);
    host^.buffers[1].dataLength:=shouldCompress;
    host^.bufferCount:=2;
   end;
   currentPeer^.lastSendTime:=host^.serviceTime;
   family:=enet_get_address_family(@currentPeer^.address);
   if family=ENET_IPV4 then begin
    socket:=host^.socket4;
   end else begin
    socket:=host^.socket6;
   end;
   if socket=ENET_SOCKET_NULL then begin
    result:=-1;
    exit;
   end;
   sentLength:=enet_socket_send(socket,@currentPeer^.address,@host^.buffers[0],host^.bufferCount,family);
   enet_protocol_remove_sent_unreliable_commands(currentPeer);
   if sentLength<0 then begin
    result:=-1;
    exit;
   end;
   inc(host^.totalSentData,sentLength);
   inc(host^.totalSentPackets);
   inc(currentPeer);
  end;
 end;
 result:=0;
end;

procedure enet_host_flush(host:PENetHost);
begin
 host^.serviceTime:=enet_time_get;
 enet_protocol_send_outgoing_commands(host,nil,0);
end;

function enet_host_check_events(host:PENetHost;event:PENetEvent):longint;
begin
 if not assigned(event) then begin
  result:=-1;
  exit;
 end;
 event^.type_:=ENET_EVENT_TYPE_NONE;
 event^.peer:=nil;
 event^.packet:=nil;
 result:=enet_protocol_dispatch_incoming_commands(host,event);
end;

function enet_host_service(host:PENetHost;event:PENetEvent;timeout:longword):longint;
var waitCondition:longword;
begin
 if assigned(event) then begin
  event^.type_:=ENET_EVENT_TYPE_NONE;
  event^.peer:=nil;
  event^.packet:=nil;
  case enet_protocol_dispatch_incoming_commands(host,event) of
   1:begin
    result:=1;
    exit;
   end;
   -1:begin
{$ifdef ENET_DEBUG}
    writeln(ERROR,'Error dispatching incoming packets');
{$endif}
    result:=-1;
    exit;
   end;
  end;
 end;
 host^.serviceTime:=enet_time_get;
 inc(timeout,host^.serviceTime);
 repeat
  if ENET_TIME_DIFFERENCE(host^.serviceTime,host^.bandwidthThrottleEpoch)>=ENET_HOST_BANDWIDTH_THROTTLE_INTERVAL then begin
   enet_host_bandwidth_throttle(host);
  end;
  case enet_protocol_send_outgoing_commands(host,event,1) of
   1:begin
    result:=1;
    exit;
   end;
   -1:begin
{$ifdef ENET_DEBUG}
    writeln(ERROR,'Error sending outgoing packets');
{$endif}
    result:=-1;
    exit;
   end;
  end;
  if host^.socket4<>ENET_SOCKET_NULL then begin
   case enet_protocol_receive_incoming_commands(host,event,ENET_IPV4) of
    1:begin
     result:=1;
     exit;
    end;
    -1:begin
{$ifdef ENET_DEBUG}
     writeln(ERROR,'Error receiving incoming packets');
{$endif}
     result:=-1;
     exit;
    end;
   end;
  end;
  if host^.socket6<>ENET_SOCKET_NULL then begin
   case enet_protocol_receive_incoming_commands(host,event,ENET_IPV6) of
    1:begin
     result:=1;
     exit;
    end;
    -1:begin
{$ifdef ENET_DEBUG}
     writeln(ERROR,'Error receiving incoming packets');
{$endif}
     result:=-1;
     exit;
    end;
   end;
  end;
  case enet_protocol_send_outgoing_commands(host,event,1) of
   1:begin
    result:=1;
    exit;
   end;
   -1:begin
{$ifdef ENET_DEBUG}
    writeln(ERROR,'Error sending outgoing packets');
{$endif}
    result:=-1;
    exit;
   end;
  end;
  if assigned(event) then begin
   case enet_protocol_dispatch_incoming_commands(host,event) of
    1:begin
     result:=1;
     exit;
    end;
    -1:begin
{$ifdef ENET_DEBUG}
     writeln(ERROR,'Error dispatching incoming packets');
{$endif}
     result:=-1;
     exit;
    end;
   end;
  end;
  if ENET_TIME_GREATER_EQUAL(host^.serviceTime,timeout) then begin
   result:=0;
   exit;
  end;
  repeat
   host^.serviceTime:=enet_time_get;
   if ENET_TIME_GREATER_EQUAL(host^.serviceTime,timeout) then begin
    result:=0;
    exit;
   end;
   waitCondition:=ENET_SOCKET_WAIT_RECEIVE or ENET_SOCKET_WAIT_INTERRUPT;
   if enet_socket_wait(host^.socket4,host^.socket6,@waitCondition,ENET_TIME_DIFFERENCE(timeout,host^.serviceTime))<>0 then begin
    result:=-1;
    exit;
   end;
  until (waitCondition and ENET_SOCKET_WAIT_INTERRUPT)=0;
  host^.serviceTime:=enet_time_get;
 until (waitCondition and ENET_SOCKET_WAIT_RECEIVE)=0;
 result:=0;
end;

end.
