[CmdletBinding()]
param()

# For more information on the VSTS Task SDK:
# https://github.com/Microsoft/vsts-task-lib
Trace-VstsEnteringInvocation $MyInvocation
try {
    #get the inputs
    $searchPattern = Get-VstsInput -Name searchPattern -Require
    $propertyName = Get-VstsInput -Name propertyName -Require
    $value = Get-VstsInput -Name value -Require
    
    if($propertyName -eq "Custom")
    {
        $propertyName = Get-VstsInput -Name customPropertyName
    }

    $filesFound = Get-ChildItem -Path $searchPattern -Recurse

    if($filesFound.Count -eq 0)
    {
        Write-Warning "No files matching pattern found."
    }

    if($filesFound.Count -gt 1)
    {
        Write-Warning "Multiple proj files found."
    }

    foreach($fileName in $filesFound)
    {
        Write-Host "Reading file: $fileName"
        $xmlDoc = New-Object -TypeName System.Xml.XmlDocument
        $xmlDoc.Load($fileName)

        $element = [System.Xml.XmlElement]($xmlDoc.GetElementsByTagName($propertyName) | Select-Object -First 1)

        if($element){
            $element.InnerText = $value
            $xmlDoc.Save($fileName)
        }
        else {
            Write-Warning "Could not file $propertyName in $fileName"
        }
    }
    
} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}
