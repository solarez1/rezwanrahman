function Invoke-WindowsPatchingForAutoScalingGroups{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        # The name of the autoscaling group
        [parameter(Mandatory=$true)]
        [string]$AutoScalingGroupName,

        # An array of pure instances (e.g. the Instances property of the object returned from Get-EC2Instances)
        #[parameter(Mandatory=$true)]
        [array]$Instances,

        # AWS Credential Object for the account in question
        [parameter(Mandatory=$true)]
        $AWSCredential,

        # PSCredential Object which has localadmin on the remote servers
        #[parameter(Mandatory=$true)]
        [pscredential]$WindowsCredential,

        # AWS Region (e.g. us-west-2)
        [parameter(Mandatory=$true)]
        [string]$Region
    )

    <#$AutoScalingGroup = Get-ASAutoScalingGroup -AutoScalingGroupNames $AutoScalingGroupName -Credential $AWSCredential -Region $Region
    $HealthyInstancesAtStart = $AutoScalingGroup.instances | ?{$_.HealthStatus -eq "Healthy"}#>

    $AutoScalingGroup = (Get-ASAutoScalingGroup -AutoScalingGroupName RezAuto -Region eu-west-1 -Credential $Role.Credentials)

    #$hash=@{Name=$AutoScalingGroup.Instances.Instanceid[0];Name2=$AutoScalingGroup.Instances.Instanceid[1]}

    $HealthyInstancesAtStart = $AutoScalingGroup.Instances | ?{$_.HealthStatus -eq "Healthy"}
    $HealthyInstancesAtStart

    if($HealthyInstancesAtStart.Count -lt "2" -and !$pscmdlet.ShouldContinue($AutoScalingGroupName, "Patching an autoscaling group with only one healthy instance"))
    {
    return $false 
    }
    else {Write-Warning "Continuing as there is more than one instance available`r`n"}

    $instances = (Get-EC2Instance -Region eu-west-1 -Credential $Role.Credentials).Instances.InstanceId

    foreach($noinstances in $Instances)
        {

    $AutoScalingGroup1 = (Get-ASAutoScalingGroup -AutoScalingGroupName RezAuto -Region eu-west-1 -Credential $Role.Credentials)

    $InstancesNotInAutoScalingGroup = (Get-EC2Instance -Region eu-west-1 -Credential $Role.Credentials -Instance $noinstances | ?{$AutoScalingGroup1.Instances.InstanceId[1] -notcontains $noinstances}).Instances.Instanceid

     #Read-Host -Prompt "Press Enter to continue"

    if($InstancesNotInAutoScalingGroup.count -gt 0)
            {
        Write-Warning ("$noinstances instance not in the auto scaling group you named" -f $InstancesNotInAutoScalingGroup.count)
            }

        }

    Write-Verbose "Stopping $AutoScalingGroupName's ReplaceUnhealthy process to prevent the instance we're patching being terminated"
    Suspend-ASProcess -AutoScalingGroupName RezAuto -ScalingProcesses 'ReplaceUnhealthy' -Credential $Role.Credentials -Region eu-west-1

    Resume-ASProcess -AutoScalingGroupName RezAuto -Credential $Role.Credentials -Region eu-west-1

    }