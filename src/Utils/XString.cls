VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "XString"
Attribute VB_Description = "A class that extends the functionality of a String."
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
'   Class: XString
'   A class that extends the functionality of a String.
'-------------------------------------------------------------------------------

' Enums
'-------------------------------------------------------------------------------


' Events
'-------------------------------------------------------------------------------


' Private Backing Store
'-------------------------------------------------------------------------------
Private mValue As String


' Properties
'-------------------------------------------------------------------------------
Public Property Get AsCharArray() As String()
Attribute AsCharArray.VB_Description = "Converts the string to a char array."
'   Converts the string to a char array.

    Dim upper As Long
    upper = Iif(Len(mValue) > 1, Len(mValue), 1)

    Dim result() As String
    ReDim result(1 To upper)

    Dim i As Long
    For i = 1 To upper
        result(i) = Mid(mValue, i, 1)
    Next i

    AsCharArray = result
End Property

Public Property Let Value(var As String)
Attribute Value.VB_UserMemId = 0
Attribute Value.VB_Description = "The value of the string."
'   The value of the string.
    mValue = var
End Property

Public Property Get Value() As String
    Value = mValue
End Property


' Constructor
'-------------------------------------------------------------------------------


' Methods
'-------------------------------------------------------------------------------
Public Function AfterDelimiter(subStr As String) As String
Attribute AfterDelimiter.VB_Description = "Returns the substring after a string."
'   Returns the substring after a string.
'
'   Args:
'       subStr: The string to use as a delimiter.
'
'   Returns:
'       The part of the string after substring.
'
    Dim startPos As Long
    startPos = IndexOf(subStr)
    If startPos > 0 Then
        startPos = startPos + Len(subStr) + 1
        AfterDelimiter = Mid(mValue, startPos, Len(mValue))
    End If
End Function

Public Function BeforeDelimiter(subStr As String) As String
Attribute BeforeDelimiter.VB_Description = "Returns the substring before a string."
'   Returns the substring before a string.
'
'   Args:
'       subStr: The string to use as a delimiter.
'
'   Returns:
'       The part of the string before substring.
'
    Dim startPos As Long
    startPos = IndexOf(subStr)
    If startPos > 0 Then
        BeforeDelimiter = Left(mValue, startPos - 1)
    End If
End Function

Public Function Contains(subStr As String) As Boolean
Attribute Contains.VB_Description = "Returns true if the string contains the substring."
'   Returns true if the string contains the substring.
'
    Contains = InStr(mValue, subStr) > 0
End Function

Public Function EndValue(n As Long) As String
Attribute EndValue.VB_Description = "Returns the end n characters of the string."
'   Returns the end n characters of the string.
'
    EndValue = Right(mValue, Len(mValue) - n)
End Function

Public Function EndsWith(subStr As String) As Boolean
Attribute EndsWith.VB_Description = "Returns true if the string ends with the substring."
'   Returns true if the string ends with the substring.
'
    EndsWith = Right(mValue, Len(subStr)) = subStr
End Function

Public Function FromStringCollection(c As Collection, d As String) As Boolean
Attribute FromStringCollection.VB_Description = "Joins a collection of strings by a delimiter."
'   Joins a collection of strings by a delimiter.
'
'   Args:
'       c: The collection of strings.
'       d The delimiter to join by.
'
'   Returns:
'       True if the collection generated a string.
'
    If c Is Nothing Then
        mValue = ""
        Exit Function
    End If

    Dim strings() As String
    ReDim strings(1 To c.Count)

    Dim i As Long
    For i = 1 To c.Count
        strings(i) = c.Item(i)
    Next i
    mValue = Join(strings, d)
    FromStringCollection = mValue <> ""
End Function

Public Function IndexOf(subStr As String) As Long
Attribute IndexOf.VB_Description = "Returns the index position of the substring."
'   Returns the index position of the substring.
'
'   Args:
'       subStr: The string to return the index of.
'
'   Returns:
'       The character index of the start of the substring or zero if not found.
'
    IndexOf = InStr(mValue, subStr)
End Function

Public Function StartsWith(subStr As String) As Boolean
Attribute StartsWith.VB_Description = "Returns true if the string starts with the substring."
'   Returns true if the string starts with the substring.
'
    StartsWith = Left(mValue, Len(subStr)) = subStr
End Function


' Helpers
'-------------------------------------------------------------------------------


' Event Handlers
'-------------------------------------------------------------------------------


' Interface Implementation
'-------------------------------------------------------------------------------
