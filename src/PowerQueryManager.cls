VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "PowerQueryManager"
Attribute VB_Description = "Adds some QoL to managing queries."
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
'   Class: PowerQueryManager
'   Adds some QoL to managing queries.
'-------------------------------------------------------------------------------

' Enums
'-------------------------------------------------------------------------------


' Events
'-------------------------------------------------------------------------------


' Private Backing Store
'-------------------------------------------------------------------------------
Private mRepositories As Dictionary


' Properties
'-------------------------------------------------------------------------------
Public Property Get Repositories() As Dictionary
Attribute Repositories.VB_Description = "The repositories attached to this query manager."
'   The repositories attached to this query manager.
    Set Repositories = mRepositories
End Property


' Constructor
'-------------------------------------------------------------------------------
Private Sub Class_Initialize()
    Set mRepositories = New Dictionary

'   Add all open workbooks using the workbook itself as the key.
    Dim wb As Workbook
    Dim qr As WorkbookPowerQueryRepository
    With Repositories
        For Each wb In Workbooks
            Set qr = New WorkbookPowerQueryRepository
            Set qr.Source = wb
            .Add wb, qr
        Next wb
    End With
End Sub


' Methods
'-------------------------------------------------------------------------------
Public Sub Clone( _
    qName As Variant, _
    repoSrc As IPowerQueryRepository, _
    repoDest As IPowerQueryRepository, _
    Optional overwrite As Boolean)
Attribute Clone.VB_Description = "Dosctring."
'   Dosctring.
'
'   Args:
'       qName: The name, or array of names, of the queries to clone.
'       repoSrc: The source repository.
'       repoDest: The destination repository.
'       overwrite: Whether to overwrite existing queries or not.
'
'   Catch possible exceptions.
    Logger.Catching = Array( _
        New DepsNotResolvedException,
        New QueryNotFoundException)

    Dim qTree As Dictionary
    Set qTree = repoSrc.GetQueryTree(qName)

'   Abort if exception was caught.
    If Not Logger.Caught Is Nothing Then
        Logger.Warn "Aborting clone"
        Exit Sub
    End If
    Logger.EndCatching

'   Copy query tree.
    Logger.Info "Cloning queries [" & Join(qTree.Keys, ",") & "]"
    repoDest.AddTree qTree, overwrite
End Sub


' Helpers
'-------------------------------------------------------------------------------


' Event Handlers
'-------------------------------------------------------------------------------


' Interface Implementation
'-------------------------------------------------------------------------------

