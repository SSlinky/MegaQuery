// Copyright (C) 2023 Samuel Vanderslink
// Permission granted under the MIT Open Source licence.
// The above copyright notice shall be included in all
// copies or substantial portions of the Software.

// Namespace: /Utils/Source
// QueryName: SharePointDirectory
// Dependencies:
//  - /Util/String/DecodeUrl
//  - /Util/String/ParseSharePointUrl

// Paste the full SharePoint URL directly from the browser. Sign in may be required.
(sharePointUrl as text) as table =>
// Returns SharePoint files at a given directory path.
//
// Args:
//    sharePointUrl: a full, unedited SharePoint url.
//
// Returns:
//    A table with files at the URL.
//
let
    // Flag true to import subdirectories, false to match exact path only.
    optionImportSubdirectories = false,

    // Parses the URL to return {company, team, file path}
    parsedUrl = ParseSharePointUrl(sharePointUrl),
    // Builds the base SharePoint URL.
    baseUrl = Text.Format("https://#{0}.sharepoint.com/sites/#{1}/", parsedUrl),
    // Extracts the path from the parse results.
    urlPath = parsedUrl{2},
    // True if the path is different to the base.
    hasSubdirectory = urlPath <> baseUrl,

    // Connect to SharePoint folder and filter on the file path.
    // Buffers the results because this can be slow with a lot of files.
    Source = Table.Buffer(
        if hasSubdirectory
        then Table.SelectRows(
                SharePoint.Files(baseUrl, [ApiVersion = 15]),
                each if optionImportSubdirectories
                then Text.StartsWith([Folder Path], urlPath)
                else [Folder Path] = urlPath)
        else SharePoint.Files(baseUrl, [ApiVersion = 15])
    )
in
    Source
