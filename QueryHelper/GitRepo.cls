VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "GitRepo"
Attribute VB_Description = "Makes use of the Github API to pull directly form the online repository."
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
' Copyright 2023 Sam Vanderslink
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
'   Class: GitRepo
'   Makes use of the Github API to pull directly form the online repository.
'-------------------------------------------------------------------------------

' Enums
'-------------------------------------------------------------------------------


' Events
'-------------------------------------------------------------------------------


' Private Backing Store
'-------------------------------------------------------------------------------
Private Const REPOURL As String = "https://github.com/SSlinky/MegaQuery/"

Private mHttp As Object


' Properties
'-------------------------------------------------------------------------------


' Constructor
'-------------------------------------------------------------------------------


' Methods
'-------------------------------------------------------------------------------
Public Function GetQuery(queryName As String) As PowerQuery
Attribute GetQuery.VB_Description = "Gets a query from the repo."
'   Gets a query from the repo.
'
'   Args:
'       queryName: The fully qualified name of the query.
'
'   Returns:
'       A PowerQuery if the name is resolved.
'
    Dim result As PowerQuery
    

    GetQuery = result
End Function


' Helpers
'-------------------------------------------------------------------------------
Private Function GetFileText(filePath As String) As String
Attribute GetFileText.VB_Description = "Gets the raw file text."
'   Gets the raw file text.
'
'   Args:
'       filePath: The path to the file.
'
'   Returns:
'
'   Raises:
'
    With HttpObject()
        .Open "GET", 
    End With 
    

    GetFileText = result
End Function

Private Function HttpObject() As Object
Attribute HttpObject.VB_Description = "Gets the MSXML2.XMLHTTP object."
'   Gets the MSXML2.XMLHTTP object.
    If mHttp Is Nothing Then Set mHttp = CreateObject("MSXML2.XMLHTTP")
    Set HttpObject = mHttp
End Function

Private Function ApiUrlFromPath(filePath As String) As String
Attribute ApiUrlFromPath.VB_Description = "Generates a Github API URL from a content path."
'   Generates a Github API URL from a content path.
'
'   Args:
'       filePath: The path to the file.
'
'   Returns:
'       The full API URL.
'
'   Raises:
'
    Dim result As String
    

    ApiUrlFromPath = result
End Function


' Event Handlers
'-------------------------------------------------------------------------------


' Interface Implementation
'-------------------------------------------------------------------------------

