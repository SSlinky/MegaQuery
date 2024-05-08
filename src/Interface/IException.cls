VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "IException"
Attribute VB_Description = "An interface describing an exception."
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

'-------------------------------------------------------------------------------
'   Class: IException
'   An interface describing an exception.
'-------------------------------------------------------------------------------


' Properties
'-------------------------------------------------------------------------------
Public Property Get Level() As LoggerLevel
Attribute Level.VB_Description = "The exception level."
    Logger.Throw New InterfaceNotClassException
End Property

Public Property Get Number() As Long
Attribute Number.VB_UserMemId = 0
Attribute Number.VB_Description = "The error number with vbObjectError added."
    Logger.Throw New InterfaceNotClassException
End Property

Public Property Get Description() As String
Attribute Description.VB_Description = "The description for the error."
    Logger.Throw New InterfaceNotClassException
End Property


' Constructor
'-------------------------------------------------------------------------------
Private Sub Class_Initialize()
    Logger.Throw New InterfaceNotClassException
End Sub

' Methods
'-------------------------------------------------------------------------------
Public Sub Raise(Optional Source As String)
Attribute Raise.VB_Description = "Raises this exception."
    Logger.Throw New InterfaceNotClassException
End Sub