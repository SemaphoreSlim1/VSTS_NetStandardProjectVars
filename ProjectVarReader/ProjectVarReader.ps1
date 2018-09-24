[CmdletBinding()]
param()

function SetProjectVariable
{
    param(
        [string]$varName,
        [string]$varValue
    )

    Write-Host ("Setting variable " + $varName + " to '" + $varValue + "'")
    Write-Output ("##vso[task.setvariable variable=" + $varName + ";]" +  $varValue )
}

# For more information on the VSTS Task SDK:
# https://github.com/Microsoft/vsts-task-lib
Trace-VstsEnteringInvocation $MyInvocation
try {
    #get the inputs
    $searchPattern = Get-VstsInput -Name searchPattern -Require
    $prefix = Get-VstsInput -Name variablePrefix -Default ""
    $propertyName = Get-VstsInput -Name propertyName -Require
    
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
            $name = $prefix + "." + $propertyName
            $value = $element.InnerText

            SetProjectVariable $name $value
        }
        else {
            Write-Warning "Could not file $propertyName in $fileName"
        }
    }
    
} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}
