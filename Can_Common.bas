
'**********************************************************************
'* Purpose: Init CAN module listening to Async and Pub Messages (0x408,0x008)
'* Input:  none
'* Output: none
'**********************************************************************
Function btn_CanConnect( id, id1 )
  Dim ShuttleConfig,Net,TitleText, CANData, i
  Dim CANDataLength
  Set CANData = CreateObject( "MATH.Array" )
  
  
  For i = 0  To 7
  	CANData.Add(0)
  Next
  
  Memory.Set "CANData",CANData  
  Memory.Set "CANDataLength",CANDataLength  
  DebugMessage"Launch Can Connect"
  Net = Visual.Script("opt_net")
  ShuttleConfig = Visual.Script("opt_config")
  DebugMessage "Selected Config :"&ShuttleConfig
  DebugMessage "Selected Net :"&Net
  TitleText = "Shuttle TX Control " & String.Format(  "%01d",AppVersionMax) & "." & String.Format("%02d",AppVersionMin) & " - "
  If ShuttleConfig = 0 Then
    TitleText = TitleText & "Upstream"
  Elseif ShuttleConfig = 1 Then
    TitleText = TitleText & "Downstream"
  End If
  Window.Title = TitleText
  Visual.Script("dhxWins").unload()
  'Initialise can using the settings by user.
  InitCAN ShuttleConfig,Net,"1000"
  Visual.Select("Layer_CanSetup").Style.Display = "none"
  Visual.Select("Layer_MessageLog").Style.Display = "block"
  Visual.Select("Layer_TabStrip").Style.Display = "block"

End Function
'------------------------------------------------------------------

Function InitCAN ( Config, Net, BaudRate )
  Dim CanManager, CanConfig
  set CANConfig = Object.CreateRecord( "Net", "CANIDcmd", "CANIDAck", "CANIDPub","Baudrate" )
  
  'Config:
  '0 = UpStream   : CAN ID Cmd: 0x644 Ack: 0x645 Pub: 0x647
  '1 = DownStream : CAN ID Cmd: 0x64C Ack: 0x64D Pub: 0x64F
  If Config = 0 Then
    With CANConfig    
      .Net = Net
      .BaudRate = BaudRate
      .CANIDcmd = &h644
      .CANIDAck = &h645
      .CANIDPub = &h647    
    End With
  Else
    With CANConfig    
      .Net = Net
      .BaudRate = BaudRate
      .CANIDcmd = &h64C
      .CANIDAck = &h64D
      .CANIDPub = &h64F
    End With
  End If
  Memory.Set "CANConfig",CANConfig
  DebugMessage "InitCAN with settings: Net:" &Net&" BaudRate:"& BaudRate&" CmdID:" & String.Format("0x%03X",CANConfig.CANIDcmd)
  
  DeleteCanManager 0,True  
  Set CanManager = LaunchCanManager( Net, BaudRate )
  If Lang.IsObject(CanManager) Then
    CanManager.Events = True
    CanManager.Deliver = True
    'CanManager.Platform = 3
    CanManager.ChangeFunnel String.Format("%d,%d",CANConfig.CANIDAck,CANConfig.CANIDPub),True
    DebugMessage "CanManager1: FunnelSet:" & String.Format("0x%03X,0x%03X",CANConfig.CANIDAck,CANConfig.CANIDPub)
    CanManager.SetArbitrationOrder CAN_ARBITRATION_SYNCHRONOUS 
    WithEvents.ConnectObject CanManager, "CanManager_"  
    InitCANMgr2
  Else
    LogAdd "No Can Manager!"
  End If    
    
End Function

'**********************************************************************
'* Purpose: Init CAN module listening to only Public Messages (0x008)
'* Input:  none
'* Output: none
'**********************************************************************
Sub InitCANMgr2
  Dim CanManagerPUB, CANConfig
  Set CanManagerPUB = Memory.CanManager.Clone
  Memory.Get "CANConfig",CANConfig
  CanManagerPUB.Events = True
  CanManagerPUB.Deliver = True

  'CanManagerPUB.Platform = 3  
  CanManagerPUB.ChangeFunnel String.Format("%d,%d",CANConfig.CANIDAck,CANConfig.CANIDPub), True
  DebugMessage "CanManager2: FunnelSet:" &  String.Format("0x%03X,0x%03X",CANConfig.CANIDAck,CANConfig.CANIDPub)
  CanManagerPUB.SetArbitrationOrder CAN_ARBITRATION_PRIVATE_OR_PUBLIC
  WithEvents.ConnectObject CanManagerPUB, "CanManagerPUB_"
  Memory.Set "CanManagerPUB",CanManagerPUB
End Sub
'------------------------------------------------------------------

Function CanManager_Deliver( ByVal CanReadArg )
  DebugMessage "CanMgr1:" & CanReadArg.Format(CFM_SHORT)
End Function 
'------------------------------------------------------------------

Function CanManagerPUB_Deliver( ByVal CanReadArg )
  'DebugMessage "CanPubMgr: " & CanReadArg.Format(CFM_SHORT)  
  'If Prepare ID(CanData(2) = 0, meaning it is a spontanous public message, we handle the message
  
  If CanReadArg.Data(1) = 0 Then 
    If CanReadArg.Data(2) = 0 Then
      PUB_Handler CanReadArg
    Else
      Get_PUB_Info CanReadArg
    End If
  Else
    If NOT CanReadArg.Data(1) = &h04 Then
    LogAdd "Error! (" & Get_Err_Name(CanReadArg.Data(1))& ")"
    End If
    DebugMessage "PubMsg: " & CanReadArg.Format(CFM_SHORT) & " Err: (" & Get_Err_Name(CanReadArg.Data(1))& ")"
    If NOT CanReadArg.Data(1) = &h16  AND Memory.InhibitErrors = 0 Then
      If NOT CanReadArg.Data(1) = &h04 Then
        If Memory.Exists("sig_externalstop") Then
          LogAdd "SA Run Stopped Due to Error"
          Memory.sig_externalstop.Set
        End If
        If Memory.Exists("sig_ERexternalstop") Then
          LogAdd "Endurance Run Stopped due to Error"
          Memory.sig_ERexternalstop.Set
        End If      
      End If
    End If
  End If  

End Function
'------------------------------------------------------------------

'No longer needed since we are using DHTMLX window
Function InitWindowCanSetup

  Visual.Select("Layer_CanSetup").Style.Height  = CANSETUP_HEIGHT
  Visual.Select("Layer_CanSetup").Style.Width   = CANSETUP_WIDTH
  Visual.Select("Layer_CanSetup").Style.Display = "block"
  Visual.Select("Layer_CanSetup").Align = "center"

End Function
'------------------------------------------------------------------

Function PUB_Handler ( CanReadArg )
  
  DebugMessage "PUB Msg: " & CanReadArg.Format
  Select Case  CanReadArg.Data(3)
    case $(PUB_MSG_ERR_PARAM):  
        DebugMessage "PubErr_Add " & CanReadArg.Format
        'LogAdd "Pub Msg: Additonal Error Parameters"
    case $(PUB_MSG_IO_STATE):
        'DebugMessage "IO State"
        'LogAdd "Pub Msg: IO State "& CanReadArg.Format(CFM_SHORT)
      PUB_IO_Handler CanReadArg
    case $(PUB_MSG_BARCODE):
      PUB_Barcode_Handler CanReadArg
    case $(PUB_MSG_PCB_STATE):
      PUB_PCBState_Handler CanReadArg
    case $(PUB_MSG_MACHINE_INTERFACE):
    case $(PUB_MSG_ENDURANCE_RUN):
    case $(PUB_MSG_CONV_MOTOR_POSITION):
    case $(PUB_MSG_SHUTTLE_MOTOR_POSITION):
    case $(PUB_MSG_WA_MOTOR_POSITION):
      
  End Select
  
End Function
'------------------------------------------------------------------
Function PUB_PCBState_Handler ( CanReadArg )
  Dim PCBState,PCBStateorg
  Dim Status1,Status2
  Dim Location
  Dim PCBID
  Dim Message
  
  'PCB ID Bytes 4 & 5 
  PCBID = Lang.MakeInt(CanReadArg.Data(4),CanReadArg.Data(5))
  
  'PCB Status Byte 6 Failed field
  If ( CanReadArg.Data(6) AND &H10 ) Then
    Status1 = " Failed"
  Else
    Status1 = " OK"
  End If
  
  'PCB Location Byte 6 inserted field
  If (CanReadArg.Data(6) AND &H20 ) Then
    Status2 = " Manually inserted"
  Else
    Status2 = " From Machine"
  End If
  'PCB Location Byte 6 Status field (byte 0-3)
  'PCBStateorg = CanReadArg.Data(6) AND &h0F 
  Select Case ( CanReadArg.Data(6) AND &h0F )
    case 0: PCBState = "State:Deleted"
    case 1: PCBState = "State:Inserted"
    case 2: PCBState = "State:Removed"
    case 3: PCBState = "State:Moving"
    case 4: PCBState = "State:Moved"
    case 5: PCBState = "State:MovingShuttle"
    case 6: PCBState = "State:MovedShuttle"
    case 7: PCBState = "State:Error"
    case else PCBState = "???"
  End Select
  
  Select Case  CanReadArg.Data(7)
    case &h01 : Location = "Upstream,right lane"
    case &h02 : Location = "Upstream,left lane"
    case &h10 : Location = "In Shuttle,undefined lane"
    case &h11 : Location = "In Shuttle,move in from right lane"
    case &h12 : Location = "In Shuttle,move in from left lane"
    case &h13 : Location = "In Shuttle,to move out right lane"
    case &h14 : Location = "In Shuttle,to move out left lane"
    case &h23 : Location = "Downstream,right lane"
    case &h24 : Location = "Downstream,right lane"
    case else Location = "???"
  End Select
  
  DebugMessage "PCBID:" & PCBID & ":" & Status1 &","&Status2&","&PCBState&","&Location
End Function
'------------------------------------------------------------------
Function PUB_Barcode_Handler ( CanReadArg )
  Dim PCBID
  Dim TopBottom
  Dim Barcode
  Barcode = ""
  If CanReadArg.Data(1) = ACK_OK Then
    PCBID = Lang.MakeInt(CanReadArg.Data(4),CanReadArg.Data(5))
    If CanReadArg.Data(6) = 1 Then
      TopBottom = "Top Barcode Scanner"
    ElseIf CanReadArg.Data(6) = 2 Then
      TopBottom = "Bottom Barcode Scanner"  
    Else
      TopBottom = "Unknown Pos BCScanner"      
    End If 
    
    If CanReadArg.Data(6) = 1 OR  CanReadArg.Data(6) = 2 Then
      Barcode = Get_BarcodeLabel (CanReadArg.Data(6))
    End If
    
    If Barcode = -1 Then
      LogAdd TopBottom & " read PCBID: " & PCBID & " Failed"    
    Else
      LogAdd TopBottom & " read PCBID: " & PCBID & " Barcode:" & Barcode    
    End If
  Else
    LogAdd "Barcode Scanner Error"
  End If 
  
End Function
'------------------------------------------------------------------
Function PUB_IO_Handler ( CanReadArg )
  Dim Message
  Dim status
  
  If CanReadArg.Data(5) = 0 Then 
    Status = "Off"
  Elseif CanReadArg.Data(5) = 1 Then
    Status = "On"
  Else
    Status = "Invalid Input"
  End If
  
  IO_setValue CanReadArg.Data(4),CanReadArg.Data(5) 
  Message = "PubMsg: " & CanReadArg.Format(CFM_SHORT) & " " & IO_getName(CanReadArg.Data(4)) & " " & Status
  DebugMessage Message

End Function
'------------------------------------------------------------------

Function CANSendCMD( CanSendArg , CanReadArg, Timeout )
  Dim CanManager
  Dim CANData,CANDataLength
  If Memory.Exists("CanManager") Then 
    Memory.Get "CanManager",CanManager
    Memory.Get "CANData",CANData
    Memory.Get "CANDataLength",CANDataLength

    DebugMessage "Cmd:"&CanSendArg.Format(CFM_SHORT)
    If CanManager.SendCmd(CanSendArg,Timeout,SC_CHECK_ERROR_BYTE,CanReadArg) = SCA_NO_ERROR Then    
      DebugMessage "Command " & String.Format("%02X",CanSendArg.Data(0)) &" OK"
      CANDataLength = CanReadArg.Length
      CANData.Data(0) = CanReadArg.Data(0) 
      CANData.Data(1) = CanReadArg.Data(1) 
      CANData.Data(2) = CanReadArg.Data(2) 
      CANData.Data(3) = CanReadArg.Data(3) 
      CANData.Data(4) = CanReadArg.Data(4)
      CANData.Data(5) = CanReadArg.Data(5)
      CANData.Data(6) = CanReadArg.Data(6)
      CANData.Data(7) = CanReadArg.Data(7)      
      CANSendCMD = True
      Memory.Set "CANData",CanData 
      Memory.Set "CANDataLength",CanDataLength
    Else
      DebugMessage "Error with Command " & String.Format("%02X",CanSendArg.Data(0))
      CANSendCMD = False
    End If    
    CanManager.Deliver = True
  Else
      CANSendCMD = False
  End If

End Function
'------------------------------------------------------------------

Function Command_Get_Param( CanReadArg , Param )

  Dim CanSendArg , CANConfig
  Dim ParamL,ParamH
  Set CanSendArg = CreateObject("ICAN.CanSendArg")

  'DebugMessage "Param: " & " " & Lang.GetByte (Param,0)& " " & Lang.GetByte (Param,1)& " " & Lang.GetByte (Param,2)& " " & Lang.GetByte (Param,3)
  ParamL = Lang.GetByte (Param,0)
  ParamH = Lang.GetByte (Param,1)
  
  If Memory.Exists("CANManager") Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanID = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_GET_PARAM)
    CanSendArg.Data(1) = ParamL
    CanSendArg.Data(2) = ParamH
    CanSendArg.Length = 3
    If CANSendCMD(CanSendArg,CanReadArg, 250) = True Then
      'DebugMessage "Get Param OK"
    Else
      'DebugMessage "Get Param Failed"
    End If  
  End If
End Function
'------------------------------------------------------------------

Function Get_PUB_Info( CanReadArg )
Dim Active,Running,prepid

  If (Lang.Bit( CanReadArg.Data(0),7,1 )) = 1 Then
    Active = "active, "
  Else
    Active = "idle, "
  End If
    
  If (Lang.Bit( CanReadArg.Data(0),2,1 )) = 1 Then
    Running = "action running, "
  Else
    Running = "waiting, "
  End If
  prepid = CanReadArg.Data(2)
  DebugMessage "PubMsg: "& CanReadArg.Format(CFM_SHORT)  & " ("&Active & Running & " PrepID:" & prepid & ")"
End Function
'------------------------------------------------------------------

Function Get_BarcodeLabel ( topbottom )
  Dim BarcodeContents,exitloop,Barcode
  
  exitloop = 0
  Barcode = Command_Get_Barcodelabel($(PARAM_BARCODE_START),0,topbottom)
  
  'Read barcode failed
  If Barcode = "NOREAD" Then
    Get_BarcodeLabel = -1
    Exit Function
  End If
  
  DebugMessage "START " & Barcode
  Do
    BarcodeContents = Command_Get_Barcodelabel($(PARAM_BARCODE_NEXT),&h0000,topbottom)
    DebugMessage "LINE " & BarcodeContents
    If Not BarcodeContents = -1  Then
        'Append data to string
        Barcode = Barcode & BarcodeContents
    Else
       exitloop = 1       
    End If 
  Loop Until exitloop = 1
  Get_BarcodeLabel = Barcode
End Function

'------------------------------------------------------------------
Function Get_Err_Name( ID )
  Dim name
  Select Case ID
  Case	$(ERR_CONTROL_VOLTAGE)	:	name ="ERR_CONTROL_VOLTAGE"
  Case	$(ERR_EMERGENCY_STOP)	:	name ="ERR_EMERGENCY_STOP"
  Case	$(ERR_ABORTED)	:	name ="User Abort Function"
  Case	$(ERR_MOVE_IN)	:	name ="ERR_MOVE_IN"
  Case	$(ERR_MOVE_OUT)	:	name ="ERR_MOVE_OUT"
  Case	$(ERR_POSITION_RAIL)	:	name ="ERR_POSITION_RAIL"
  Case	$(ERR_LANE_WIDTH)	:	name ="ERR_LANE_WIDTH"
  Case	&h14	:	name ="ERR_OFFSET_WIDTH"
  Case	&h15	:	name ="ERR_SHUTTLE_BLOCKED"
  Case	&h16	:	name ="ERR_WIDTH_ADJ_BLOCKED: Check if there is PCB on conveyor or PCB sensor blocked"
  Case	&h17	:	name ="ERR_WA_NOT_REFERENCED"
  Case	&h18	:	name ="ERR_SHUTTLE_NOT_REFERENCED"
  Case	&h19	:	name ="ERR_DELIVERY_UPSTREAM"
  Case	&h1A	:	name ="ERR_ARRIVED_DOWNSTREAM"
  Case	&h1B	:	name ="ERR_TRAVEL_RANGE_SHUTTLE"
  Case	&h1C	:	name ="ERR_TRAVEL_RANGE_WA"
  Case	&h1D	:	name ="ERR_TRAVEL_RANGE_RAIL_R"
  Case	&h1E	:	name ="ERR_TRAVEL_RANGE_RAIL_L"
  Case	&h1F	:	name ="ERR_MECH_LIMIT_RIGHT_SIDE"
  Case	&h20	:	name ="ERR_MECH_LIMIT_LEFT_SIDE"
  Case	&h24	:	name ="ERR_PCB_MOVING_IN"
  Case	&h25	:	name ="ERR_PCB_MOVING_OUT"
  Case	&h2A	:	name ="ERR_NO_PCB_PRESENT"
  Case	&h2B	:	name ="ERR_PCB_PRESENT"
  Case	&h30	:	name ="ERR_MOTOR_MOVING"
  Case	&h31	:	name ="ERR_MOTOR_COUNT"
  Case	&h32	:	name ="ERR_MOTOR_INDEX_PULSE"
  Case	&h33	:	name ="ERR_MOTOR_ENCODER"
  Case	&h34	:	name ="ERR_MOTOR_REFERENCE_MOVED"
  Case	&h40	:	name ="ERR_BARCODE_TIMEOUT"
  Case	&h41	:	name ="ERR_BARCODE_SYNTAX"
  Case	&h42	:	name ="ERR_BARCODE_FEEDBACK"
  Case	&h80	:	name ="ERR_ESW_SHUTTLE"
  Case Else  name = "unknown " & ID & "). If existing command is in progress, Abort the command first"
  End Select
  Get_Err_Name = name
End Function 
'------------------------------------------------------------------

Function Get_PUB_PrepareID( ID )
Dim name
  Select Case ID
    Case	&h02	:	name ="PAR_CHANGED"
    Case	&h03	:	name ="PAR_CONTROL_BOARD_ID"
    Case	&h0B	:	name ="PAR_VELOCITY_DRIVE_IN"
    Case	&h0C	:	name ="PAR_VELOCITY_DRIVE_OUT"
    Case	&h0D	:	name ="PAR_CONV_ACCELERATION"
    Case	&h10	:	name ="PAR_TIMEOUT_MOVE_OUT"
    Case	&h11	:	name ="PAR_TIMEOUT_MOVE_IN"
    Case	&h12	:	name ="PAR_TIMEOUT_BARCODE"
    Case	&h13	:	name ="PAR_MIN_WIDTH"
    Case	&h14	:	name ="PAR_WA_VELOCITY"
    Case	&h15	:	name ="PAR_SHUTTLE_VELOCITY"
    Case	&h16	:	name ="PAR_SHUTTLE_ACCELERATION"
    Case	&h17	:	name ="PAR_SHUTTLE_JERK"
    Case	&h18	:	name ="PAR_CURRENT_SHUTTLE_MOTOR"
    Case	&h19	:	name ="PAR_CURRENT_WA_MOTOR"
    Case	&h1A	:	name ="PAR_VELOCITY_TEST_CONV_MOTOR"
    Case	&h1B	:	name ="PAR_VELOCITY_TEST_SHUTTLE_MOTOR"
    Case	&h1C	:	name ="PAR_VELOCITY_TEST_WA_MOTOR"
    Case	&h1D	:	name ="PAR_TRAVEL_RANGE_SHUTTLE"
    Case	&h1E	:	name ="PAR_TRAVEL_RANGE_WA"
    Case	&h31	:	name ="PAR_SHUTTLE_CURRENT_FORW"
    Case	&h32	:	name ="PAR_SHUTTLE_CURRENT_BACKW"
    Case	&h33	:	name ="PAR_WA_CURRENT_FORW"
    Case	&h34	:	name ="PAR_WA_CURRENT_BACKW"
    Case	&h35	:	name ="PAR_CONV_CURRENT_FORW"
    Case	&h36	:	name ="PAR_CONV_CURRENT_BACKW"
    Case	&h40	:	name ="PAR_OPERATING_HOURS"
    Case	&h41	:	name ="PAR_BOARD_THROUGHPUT"
    Case	&h42	:	name ="PAR_SHUTTLE_MOTOR_MILEAGE"
    Case	&h43	:	name ="PAR_WA_MOTOR_MILEAGE"
    Case	&h44	:	name ="PAR_CONV_MOTOR_MILEAGE"
    Case	&hFFF	:	name ="PAR_LAST"
    Case	&hFFF	:	name ="PAR_NEXT"

    Case Else  name = "unknown" & ID & ") "
  End Select
  Get_PUB_PrepareID = name
End Function
