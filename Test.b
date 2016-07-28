Dim CANID,CANTXID1,CANTXID2
Dim LoopCont,rc
CANID = 0x608
CANTXID1 = 0x408
CANTXID2 = 0x008
LoopCont = 1
{
rc = WaitCmd{ CANID }( 250 )
If rc.Success
{
  Delay(10)
  Switch rc.Data[0]
  {
  Case 0x00:
  {
    LoopCont = 0
  }
  
  Case 0x05:
  {
    Switch rc.Data[1]
    {
    Case 0x00:
      SendMsg{CANTXID1}(rc.Data[0],rc.Data[1],0x00,0x11,0x22,0x33,0x44)  
    Case 0x10:
      SendMsg{CANTXID1}(rc.Data[0],rc.Data[1],0x00,0x01,0x02,0x03,0x04)      
    }
  }
  ' Refill Start
  Case 0x54:  
  {
    SendMsg{CANTXID1}(rc.Data[0],0x00,0x00)   
    Delay(20)
    SendMsg{CANTXID2}(0x90,0x00,0x01,rc.Data[2])   
    Delay(20)
    SendMsg{CANTXID2}(0x40,0x00,0x01,rc.Data[2])    
    Delay(20)    
    SendMsg{CANTXID2}(0x20,0x00,0x01,rc.Data[2])    
  }
  
  }
}
Delay(50)
}
Until LoopCont == 0
'MsgBox("Command Rx " & Format("%02X",rc.Data[0]))
MsgBox("Exit Condition Met")
