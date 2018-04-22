Function Create-PatchManagerRole{
param(
$PolicyName = 'PatchManagerPolicy',
$Description = 'Patch Manager Policy',
$RoleName = 'AWSPatchManagerRole',
[parameter(Mandatory)]
$awscredentials
)

$BaseParams = @{
        Credential = $awscredentials 
        ErrorAction = 'Stop'
    }

try{
#create policy
New-IAMPolicy @BaseParams -PolicyName $PolicyName -Description $Description  -PolicyDocument (Invoke-WebRequest https://stash.sdl.com/projects/CS/repos/aws-infrastructure/raw/CloudFormation/AWS%20Patch%20Manager/PatchManagerPolicy.json?at=refs%2Fheads%2FAWS_PatchManager).content

#create role
New-IAMRole @BaseParams -RoleName $RoleName -AssumeRolePolicyDocument (Invoke-WebRequest https://stash.sdl.com/projects/CS/repos/aws-infrastructure/raw/CloudFormation/AWS%20Patch%20Manager/PatchManagerTrust.json?at=refs%2Fheads%2FAWS_PatchManager).content

#attach policy to role
Write-IAMRolePolicy @BaseParams -RoleName $RoleName -PolicyName $PolicyName -PolicyDocument (Invoke-WebRequest https://stash.sdl.com/projects/CS/repos/aws-infrastructure/raw/CloudFormation/AWS%20Patch%20Manager/PatchManagerPolicy.json?at=refs%2Fheads%2FAWS_PatchManager).content
}
catch
    {
    write-host $_.Exception.Message -BackgroundColor Black -ForegroundColor Red
    }
}