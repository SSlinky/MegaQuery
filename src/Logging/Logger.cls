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

' Private Backing Store
'-------------------------------------------------------------------------------
Private mLogLevel As LoggerLevelCode
Private mExceptionLevel As LoggerLevelCode
Private mCatching As Variant
Private mCaught As IException


' Properties
'-------------------------------------------------------------------------------
Public Property Let LogLevel(var As LoggerLevelCode)
Attribute LogLevel.VB_Description = "The logger level."
'   The logger level.
    mLogLevel = var
End Property

Public Property Get LogLevel() As LoggerLevelCode
    LogLevel = mLogLevel
End Property

Public Property Let ExceptionLevel(var As LoggerLevelCode)
Attribute ExceptionLevel.VB_Description = "The exception level."
'   The exception level.
    mExceptionLevel = var
End Property

Public Property Get ExceptionLevel() As LoggerLevelCode
    ExceptionLevel = mExceptionLevel
End Property

Public Property Let Catching(var As Variant)
Attribute Catching.VB_Description = "Exceptions being caught."
'   Exceptions being caught.
    mCatching = Iif(TypeName(var) = "Variant()", var, Array(var))
End Property

Public Property Get Catching() As Variant
    Catching = mCatching
End Property

Public Property Get Caught() As IException
Attribute Caught.VB_Description = "The caught exception."
'   The caught exception.
    Set Caught = mCaught
End Property


' Constructor
'-------------------------------------------------------------------------------
Private Sub Class_Initialize()
    LogLevel = LoggerLevelCode.LLNone
    ExceptionLevel = LoggerLevelCode.LLNone
    Debug.Print "---- [Logging Started] ----"
End Sub


' Methods
'-------------------------------------------------------------------------------
Public Sub EndCatching()
Attribute EndCatching.VB_Description = "Stops tracking exceptions to catch."
'   Stops tracking exceptions to catch.
'
    Set mCatching = Nothing
    Set mCaught = Nothing
End Sub

Public Sub Log(level As LoggerLevelCode, msg As String)
Attribute Log.VB_Description = "Logs the message if it meets the LoggerLevelCode."
'   Logs the message if it meets the LoggerLevelCode.
'
'   Args:
'       level: The logger level.
'       msg: The text to log.
'
    If level < LogLevel Then Exit Sub
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
'       e unless we're catching it.
'
'   Check whether to catch the exception or not.
    Dim isCaught As Boolean
    If TypeName(Catching) = "Nothing" Then
        isCaught = True
    Else
        Dim n As Variant
        For Each n In Catching
            If e = n Then
                isCaught = True
                Exit For
            End If  
        Next n
    End If

'   Log, catch, and raise the exception as required.
    Log e.ExceptionLevel, Iif(src = "", "", "[" & src & "]") & e.Description
    If isCaught Then
        Set mCaught = e
    ElseIf e.ExceptionLevel >= LoggerLevelCode.LLError Then
        e.Raise src
    End If
End Sub

Public Sub Debg(msg As String)
Attribute Debg.VB_Description = "Logs a Debug message."
'   Logs a Debug message.
'
'   Args:
'       msg: The text to log.
'
    Log LLDebug, msg
End Sub

Public Sub Info(msg As String)
Attribute Info.VB_Description = "Logs an Info message."
'   Logs an Info message.
'
'   Args:
'       msg: The text to log.
'
    Log LLInfo, msg
End Sub

Public Sub Warn(msg As String)
Attribute Warn.VB_Description = "Logs a Warn message."
'   Logs a Warn message.
'
'   Args:
'       msg: The text to log.
'
    Log LLWarn, msg
End Sub

Public Sub Error(msg As String)
Attribute Error.VB_Description = "Logs an Error message."
'   Logs an Error message.
'
'   Args:
'       msg: The text to log.
'
    Log LLError, msg
End Sub

Public Sub Critical(msg As String)
Attribute Critical.VB_Description = "Logs a Critical message."
'   Logs a Critical message.
'
'   Args:
'       msg: The text to log.
'
    Log LLCritical, msg
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
        Case Is = LoggerLevelCode.LLDebug:
            LoggerLevelLabel = "D: "
        Case Is = LoggerLevelCode.LLInfo:
            LoggerLevelLabel = "I: "
        Case Is = LoggerLevelCode.LLWarn:
            LoggerLevelLabel = "W: "
        Case Is = LoggerLevelCode.LLError:
            LoggerLevelLabel = "E:  "
        Case Is = LoggerLevelCode.LLCritical:
            LoggerLevelLabel = "C: "
        Case Else:
            LoggerLevelLabel = "****: "
    End Select
End Function
