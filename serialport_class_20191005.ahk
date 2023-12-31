;Serial Port class, Modified by sendust 2019/10/05
; set dtr on for rs-422 converter

class serialport
{
  RS232_FileHandle := -1
  RS232_Settings := ""
  
	__new(port := "COM2", baud := 9600, parity := "N", data := 8, stop := 1)
	{
      static RS232_FileHandle := -1
      RS232_Port := port
      RS232_Baud := baud
      RS232_Parity := parity
      RS232_Data   := data
      RS232_Stop   := stop
      RS232_Settings = %RS232_Port%:baud=%RS232_Baud% parity=%RS232_Parity% data=%RS232_Data% stop=%RS232_Stop% dtr=On
      this.RS232_Settings := RS232_Settings
	}
	
	__delete()
	{
		if (this.RS232_FileHandle != -1)
			this.RS232_Close()
	}

	RS232_Initialize()
  {
    ;###### Extract/Format the RS232 COM Port Number ######
    ;7/23/08 Thanks krisky68 for finding/solving the bug in which RS232 COM Ports greater than 9 didn't work.
	RS232_Settings := this.RS232_Settings
    StringSplit, RS232_Temp, RS232_Settings, `:
    RS232_Temp1_Len := StrLen(RS232_Temp1)  ;For COM Ports > 9 \\.\ needs to prepended to the COM Port name.
    If (RS232_Temp1_Len > 4)                   ;So the valid names are
        RS232_COM = \\.\%RS232_Temp1%             ; ... COM8  COM9   \\.\COM10  \\.\COM11  \\.\COM12 and so on...
    Else                                          ;
        RS232_COM = %RS232_Temp1%

    ;8/10/09 A BIG Thanks to trenton_xavier for figuring out how to make COM Ports greater than 9 work for USB-Serial Dongles.
    StringTrimLeft, RS232_Settings, RS232_Settings, RS232_Temp1_Len+1 ;Remove the COM Number (+1 for the semicolon) for BuildCommDCB.
    ;MsgBox, RS232_COM=%RS232_COM% `nRS232_Settings=%RS232_Settings%

    ;###### Build RS232 COM DCB ######
    ;Creates the structure that contains the RS232 COM Port number, baud rate,...
    VarSetCapacity(DCB, 28)
    BCD_Result := DllCall("BuildCommDCB"
            ,"str" , RS232_Settings ;lpDef
            ,"UInt", &DCB)        ;lpDCB
    ;FileAppend, BCD reuilt is %BCD_Result%, *
    If (BCD_Result <> 1)
      {
        ;MsgBox,16,, There is a problem with Serial Port communication. `nFailed Dll BuildCommDCB, BCD_Result=%BCD_Result% `nThe Script Will Now Exit.
        FileAppend, `r`nThere is a problem with Serial Port communication. `nFailed Dll BuildCommDCB`, BCD_Result=%BCD_Result% `nThe Script Will Now Exit., *
        this.RS232_FileHandle := -1
        Return RS232_FileHandle
      }

    ;###### Create RS232 COM File ######
    ;Creates the RS232 COM Port File Handle
    RS232_FileHandle := DllCall("CreateFile"
            ,"Str" , RS232_COM     ;File Name
            ,"UInt", 0xC0000000   ;Desired Access
            ,"UInt", 3            ;Safe Mode
            ,"UInt", 0            ;Security Attributes
            ,"UInt", 3            ;Creation Disposition
            ,"UInt", 0            ;Flags And Attributes
            ,"UInt", 0            ;Template File
            ,"Cdecl Int")

    If (RS232_FileHandle < 1)
      {
        ;MsgBox,16,, There is a problem with Serial Port communication. `nFailed Dll CreateFile, RS232_FileHandle=%RS232_FileHandle% `nThe Script Will Now Exit.
        FileAppend, `r`nThere is a problem with Serial Port communication. `nFailed Dll CreateFile`, RS232_FileHandle=%RS232_FileHandle% `nThe Script Will Now Exit., *
        this.RS232_FileHandle := -1
        Return RS232_FileHandle
      }

    ;###### Set COM State ######
    ;Sets the RS232 COM Port number, baud rate,...
    SCS_Result := DllCall("SetCommState"
            ,"UInt", RS232_FileHandle ;File Handle
            ,"UInt", &DCB)          ;Pointer to DCB structure
    If (SCS_Result <> 1)
      {
        ;MsgBox,16,, There is a problem with Serial Port communication. `nFailed Dll SetCommState, SCS_Result=%SCS_Result% `nThe Script Will Now Exit.
        FileAppend, `r`nThere is a problem with Serial Port communication. `nFailed Dll SetCommState`, SCS_Result=%SCS_Result% `nThe Script Will Now Exit., *
        this.RS232_Close()
        this.RS232_FileHandle := -1
        Return RS232_FileHandle
      }

    ;###### Create the SetCommTimeouts Structure ######
    ReadIntervalTimeout        = 0xffffffff
    ReadTotalTimeoutMultiplier = 0x00000000
    ReadTotalTimeoutConstant   = 0x00000000
    WriteTotalTimeoutMultiplier= 0x00000000
    WriteTotalTimeoutConstant  = 0x00000000

    VarSetCapacity(Data, 20, 0) ; 5 * sizeof(DWORD)
    NumPut(ReadIntervalTimeout,         Data,  0, "UInt")
    NumPut(ReadTotalTimeoutMultiplier,  Data,  4, "UInt")
    NumPut(ReadTotalTimeoutConstant,    Data,  8, "UInt")
    NumPut(WriteTotalTimeoutMultiplier, Data, 12, "UInt")
    NumPut(WriteTotalTimeoutConstant,   Data, 16, "UInt")

    ;###### Set the RS232 COM Timeouts ######
    SCT_result := DllCall("SetCommTimeouts"
            ,"UInt", RS232_FileHandle ;File Handle
            ,"UInt", &Data)         ;Pointer to the data structure
    If (SCT_result <> 1)
      {
        ;errorout = There is a problem with Serial Port communication. `nFailed Dll SetCommState, SCT_result=%SCT_result%
        ;throw Exception(errorout)
        ;MsgBox,16,, There is a problem with Serial Port communication. `nFailed Dll SetCommState, SCT_result=%SCT_result% `nThe Script Will Now Exit.
        FileAppend, `r`nThere is a problem with Serial Port communication. `nFailed Dll SetCommState`, SCT_result=%SCT_result% `nThe Script Will Now Exit., *
        this.RS232_Close()
        this.RS232_FileHandle := -1
        Return RS232_FileHandle
      }
	  this.RS232_FileHandle := RS232_FileHandle
    Return RS232_FileHandle
  }
	
;########################################################################
;###### Close RS232 COM Subroutine #######################################
;########################################################################

	RS232_Close()
  {
    ;###### Close the COM File ######
    CH_result := 0
	RS232_FileHandle := this.RS232_FileHandle
    if (RS232_FileHandle <> -1)
      CH_result := DllCall("CloseHandle", "UInt", RS232_FileHandle)
    If (CH_result <> 1)
    {
      ;errorout = Failed Dll CloseHandle CH_result=%CH_result% FHanlde = %RS232_FileHandle%
      ;throw Exception(errorout)
        ;'MsgBox,16,, Failed Dll CloseHandle CH_result=%CH_result% FHanlde = %RS232_FileHandle%
        FileAppend, `r`nFailed Dll CloseHandle CH_result=%CH_result% FHanlde = %RS232_FileHandle%, *
        return RS232_FileHandle
      }
    Return CH_result
  }


;########################################################################
;###### Read from RS232 COM Subroutines #################################
;########################################################################
RS232_Read_Hex(Num_Bytes, ByRef RS232_Bytes_Received)           ; output form is 0AADEF4533 etc......
  {
    SetFormat, Integer, HEX
	RS232_FileHandle := this.RS232_FileHandle
    Data_Length  := VarSetCapacity(Data, Num_Bytes, 0x55)
    ;MsgBox, Data_Length=%Data_Length%

    ;###### Read the data from the RS232 COM Port ######
    ;MsgBox, RS232_FileHandle=%RS232_FileHandle% `nNum_Bytes=%Num_Bytes%
    Read_Result := DllCall("ReadFile"
            ,"UInt" , RS232_FileHandle   ; hFile
            ,"Str"  , Data             ; lpBuffer
            ,"Int"  , Num_Bytes        ; nNumberOfBytesToRead
            ,"UInt*", RS232_Bytes_Received   ; lpNumberOfBytesReceived
            ,"Int"  , 0)               ; lpOverlapped

    ;MsgBox, RS232_FileHandle=%RS232_FileHandle% `nRead_Result=%Read_Result% `nBR=%RS232_Bytes_Received% ,`nData=%Data%
    If (Read_Result <> 1)
      {
        ;errorout = There is a problem with Serial Port communication. `nFailed Dll ReadFile on RS232 COM, result=%Read_Result%
        ;throw Exception(errorout)
        ;MsgBox,16,, There is a problem with Serial Port communication. `nFailed Dll ReadFile on RS232 COM, result=%Read_Result% - The Script Will Now Exit.
        FileAppend, `r`nThere is a problem with Serial Port communication. `nFailed Dll ReadFile on RS232 COM`, result=%Read_Result% - The Script Will Now Exit., *
        this.RS232_Close()
        Exit
      }
      
        ;###### Format the received data ######
    ;This loop is necessary because AHK doesn't handle NULL (0x00) characters very nicely.
    ;Quote from AHK documentation under DllCall:
    ;     "Any binary zero stored in a variable by a function will hide all data to the right
    ;     of the zero; that is, such data cannot be accessed or changed by most commands and
    ;     functions. However, such data can be manipulated by the address and dereference operators
    ;     (& and *), as well as DllCall itself."
    i = 0
    Data_HEX =
    Loop %RS232_Bytes_Received%
      {
        ;First byte into the Rx FIFO ends up at position 0

        Data_HEX_Temp := NumGet(Data, i, "UChar") ;Convert to HEX byte-by-byte
        StringTrimLeft, Data_HEX_Temp, Data_HEX_Temp, 2 ;Remove the 0x (added by the above line) from the front
        ;If there is only 1 character then add the leading "0'
        Length := StrLen(Data_HEX_Temp)
        If (Length =1)
            Data_HEX_Temp = 0%Data_HEX_Temp%
        i++
        ;Put it all together
        Data_HEX := Data_HEX . Data_HEX_Temp
      }
    ;MsgBox, Read_Result=%Read_Result% `nRS232_Bytes_Received=%RS232_Bytes_Received% ,`nData_HEX=%Data_HEX%
    SetFormat, Integer, DEC
    Data := Data_HEX
    Return Data

  }

RS232_Read(Num_Bytes, ByRef RS232_Bytes_Received)                   ; output form is 3234523424342318567 etc......
  {
    ;SetFormat, Integer, HEX
	RS232_FileHandle := this.RS232_FileHandle
    Data_Length  := VarSetCapacity(Data, Num_Bytes, 00)
    ;MsgBox, Data_Length=%Data_Length%

    ;###### Read the data from the RS232 COM Port ######
    ;MsgBox, RS232_FileHandle=%RS232_FileHandle% `nNum_Bytes=%Num_Bytes%
    Read_Result := DllCall("ReadFile"
            ,"UInt" , RS232_FileHandle   ; hFile
            ,"Str"  , Data             ; lpBuffer
            ,"Int"  , Num_Bytes        ; nNumberOfBytesToRead
            ,"UInt*", RS232_Bytes_Received   ; lpNumberOfBytesReceived
            ,"Int"  , 0)               ; lpOverlapped

    ;MsgBox, RS232_FileHandle=%RS232_FileHandle% `nRead_Result=%Read_Result% `nBR=%RS232_Bytes_Received% ,`nData=%Data%
    If (Read_Result <> 1)
      {
        ;errorout = There is a problem with Serial Port communication. `nFailed Dll ReadFile on RS232 COM, result=%Read_Result%
        ;throw Exception(errorout)
        ;MsgBox,16,, There is a problem with Serial Port communication. `nFailed Dll ReadFile on RS232 COM, result=%Read_Result% - The Script Will Now Exit.
        FileAppend, `r`nThere is a problem with Serial Port communication. `nFailed Dll ReadFile on RS232 COM`, result=%Read_Result% - The Script Will Now Exit, *
        this.RS232_Close()
        Exit
      }
      
        ;###### Format the received data ######
    ;This loop is necessary because AHK doesn't handle NULL (0x00) characters very nicely.
    ;Quote from AHK documentation under DllCall:
    ;     "Any binary zero stored in a variable by a function will hide all data to the right
    ;     of the zero; that is, such data cannot be accessed or changed by most commands and
    ;     functions. However, such data can be manipulated by the address and dereference operators
    ;     (& and *), as well as DllCall itself."
    i = 0
    Data_HEX =
    Loop %RS232_Bytes_Received%
      {
        ;First byte into the Rx FIFO ends up at position 0

        Data_HEX_Temp := NumGet(Data, i, "UChar") ;Convert to HEX byte-by-byte
        ;StringTrimLeft, Data_HEX_Temp, Data_HEX_Temp, 2 ;Remove the 0x (added by the above line) from the front
        ;If there is only 1 character then add the leading "0'
        ;Length := StrLen(Data_HEX_Temp)
        ;If (Length =1)
        ;Data_HEX_Temp = 0%Data_HEX_Temp%
        i++
        ;Put it all together
        Data_HEX := Data_HEX . " " . Data_HEX_Temp
      }
    ;MsgBox, Read_Result=%Read_Result% `nRS232_Bytes_Received=%RS232_Bytes_Received% ,`nData_HEX=%Data_HEX%
    ;SetFormat, Integer, DEC
    Data = %Data_HEX%
    Return Data

  }

;########################################################################
;###### Write to RS232 COM Subroutines ##################################
;########################################################################
; Example                                            result := sp.RS232_Write("0x11,0x12")
RS232_Write(Message)
  {
    SetFormat, Integer, DEC
	RS232_FileHandle := this.RS232_FileHandle
    ;Parse the Message. Byte0 is the number of bytes in the array.
    StringSplit, Byte, Message, `,
    Data_Length := Byte0
    ;MsgBox, Data_Length=%Data_Length% b1=%Byte1% b2=%Byte2% b3=%Byte3% b4=%Byte4%

    ;Set the Data buffer size, prefill with 0xFF.
    VarSetCapacity(Data, Byte0, 0xFF)

    ;Write the Message into the Data buffer
    i=1
    Loop %Byte0%
      {
        NumPut(Byte%i%, Data, (i-1) , "UChar")
        ;MsgBox, %i%
        i++
      }
    ;MsgBox, Data string=%Data%

    ;###### Write the data to the RS232 COM Port ######
    WF_Result := DllCall("WriteFile"
            ,"UInt" , RS232_FileHandle ;File Handle
            ,"UInt" , &Data          ;Pointer to string to send
            ,"UInt" , Data_Length    ;Data Length
            ,"UInt*", Bytes_Sent     ;Returns pointer to num bytes sent
            ,"Int"  , "NULL")
    If (WF_Result <> 1 or Bytes_Sent <> Data_Length)
    {
        ;MsgBox,16,, Failed Dll WriteFile to RS232 COM, result=%WF_Result% `nData Length=%Data_Length% `nBytes_Sent=%Bytes_Sent%
        FileAppend, `r`nFailed Dll WriteFile to RS232 COM`, result=%WF_Result% `nData Length=%Data_Length% `nBytes_Sent=%Bytes_Sent%, *
      }
	return WF_Result
  }
}