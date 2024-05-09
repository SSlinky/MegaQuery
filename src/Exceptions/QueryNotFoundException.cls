VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "QueryNotFoundException"
Attribute VB_Description = "Query not found exception."
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
' Copyright 2024 Sam Vanderslink
' 
' Permission is hereby granted, free of charge, to any person obtaining a copy 
' of this software and associated documentation files (the "Software"), to deal 
' in the Software without restriction, including without limitation the rights 
' to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
' copies of the Software, and to permit persons to whom the Software is 
' furnished to do so, subject to the following conditions:
' 
' The above copyright notice and this permission notice shall be included in 
' all copies or substantial portions of the Software.
' 
' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
' IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
' FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
' AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
' LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
' FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
' IN THE SOFTWARE.

Option Explicit
Implements IException

'-------------------------------------------------------------------------------
'   Class: QueryNotFoundException
'   Query not found exception.
'-------------------------------------------------------------------------------

' Properties
'-------------------------------------------------------------------------------
Private Const LOGLVL As Long = LoggerLevelCode.LLError
Private Const ERRNUM As Long = 4
Private Const ERRDESC As String = _
    "Query not found{{CONTEXT}}."

Public Property Get ExceptionLevel() As LoggerLevelCode
Attribute ExceptionLevel.VB_Description = "The exception level."
'   The exception level.
    ExceptionLevel = LOGLVL
End Property

Public Property Get Number() As Long
Attribute Number.VB_UserMemId = 0
Attribute Number.VB_Description = "The error number with vbObjectError added."
'   The error number with vbObjectError added.
    Number = ERRNUM + vbObjectError
End Property

Public Property Get Description() As String
Attribute Description.VB_Description = "The description for the error."
'   The description for the error.
    Description = ERRDESC
End Property

Public Property Let Context(var As String)
Attribute Context.VB_Description = "Adds context to the description."
'   Adds context to the description.
    mContext = var
End Property

Public Property Get Context() As String
    Context = Iif(Trim(mContext) = "", "", " [" & mContext & "]")
End Property

Public Property Get Self() As IException
Attribute Self.VB_Description = "Shortcut to use in With blocks."
'   Shortcut to use in With blocks.
    Set Self = Me
End Property


' Methods
'-------------------------------------------------------------------------------
Public Sub Raise(Optional Source As String)
Attribute Raise.VB_Description = "Raises this exception."
'   Raises this exception.
'
'   Args:
'       Source: The source of the exception.
'
'   Raises:
'       Itself.
'
    Select Case Source:
        Case Is = "":
            Err.Raise Number, Source, Description
        Case Else
            Err.Raise Number, Description:=Description
    End Select
End Sub


' Interface Implementation
'-------------------------------------------------------------------------------
Public Property Get IException_ExceptionLevel() As LoggerLevelCode
Attribute IException_ExceptionLevel.VB_Description = "The exception level."
    IException_ExceptionLevel = ExceptionLevel
End Property

Public Property Get IException_Number() As Long
Attribute IException_Number.VB_Description = "The error number with vbObjectError added."
    IException_Number = Number
End Property

Public Property Get IException_Description() As String
Attribute IException_Description.VB_Description = "The description for the error."
    IException_Description = Description
End Property

Public Sub IException_Raise(Optional Source As String)
Attribute IException_Raise.VB_Description = "Raises this exception."
    Raise Source
End Sub