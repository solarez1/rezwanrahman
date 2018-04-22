New-EC2Subnet -AvailabilityZone eu-west-1a -VpcId $a.vpcid


function get-test{
param(
    $awscredentials,
    $region
)

   $baseparams = @{
        Region = $region
        Credential = $awscredentials
    }
    get-ec2instance @baseparams
}