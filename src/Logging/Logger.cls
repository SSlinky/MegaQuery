VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Logger"
Attribute VB_Description = "A basic logger."
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
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
'   Class: Logger
'   A basic logger.
'-------------------------------------------------------------------------------

' Enums
'-------------------------------------------------------------------------------
Public Enum LoggerLevelCode
    Debug
    Info
    Warn
    Error
    Critical
    None
End Enum


' Private Backing Store
'-------------------------------------------------------------------------------
Private mLoggerLevel As LoggerLevelCode


' Properties
'-------------------------------------------------------------------------------
Public Property Let LoggerLevel(var As LoggerLevelCode)
Attribute LoggerLevel.VB_Description = "The logger level."
'   The logger level.
    mLoggerLevel = var
End Property

Public Property Get LoggerLevel() As LoggerLevelCode
    LoggerLevel = mLoggerLevel
End Property


' Constructor
'-------------------------------------------------------------------------------
Private Sub Class_Initialize()
    LoggerLevel = LoggerLevelCode.None
End Sub


' Methods
'-------------------------------------------------------------------------------
Public Sub Log(level As LoggerLevelCode, msg As String)
Attribute Log.VB_Description = "Logs the message if it meets the LoggerLevel."
'   Logs the message if it meets the LoggerLevel.
'
'   Args:
'       level: The logger level.
'       msg: The text to log.
'
    If level < LoggerLevel Then Exit Sub
    Debug.Print LoggerLevelLabel(level) & msg
End Sub

Public Sub Throw(e As IException, Optional src As String)
Attribute Throw.VB_Description = "Throws and/or logs an exception."
'   Throws and/or logs an exception.
'
'   Args:
'       e: The IException to throw.
'       src: The source of the exception.
'
'   Raises:
'       e
'
    Log e.Level, Iif(src = "", "", "[" & src & "]") & e.Description
    If e.Level >= LoggerLevelCode.Error Then e.Raise src
End Sub


' Helpers
'-------------------------------------------------------------------------------
Private Function LoggerLevelLabel(level As LoggerLevelCode) As String
Attribute LoggerLevelLabel.VB_Description = "Returns a label for the logger level."
'   Returns a label for the logger level.
'
'   Args:
'       level: The logger level to return a lable for.
'
'   Returns:
'       A logger lable.
'
    Select Case level
        Case Is = LoggerLevelCode.Debug:
            LoggerLevelLabel = "DEBG: "
        Case Is = LoggerLevelCode.Info:
            LoggerLevelLabel = "INFO: "
        Case Is = LoggerLevelCode.Warn:
            LoggerLevelLabel = "WARN: "
        Case Is = LoggerLevelCode.Critical:
            LoggerLevelLabel = "CRIT: "
        Case Else:
            LoggerLevelLabel = "****: "
    End Select

    LevelTag = result
End Function