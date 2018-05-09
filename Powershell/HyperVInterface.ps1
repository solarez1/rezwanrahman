  
$xaml = @'

<Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="HyperV Manager" Height="550" Width="725" MinWidth="210" Background="#FF02B6F9" Foreground="Black" BorderBrush="#FF02B6F9" Opacity="0.7" WindowStartupLocation="CenterScreen" ResizeMode="NoResize" SizeToContent="WidthAndHeight">
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="64*"/>
            <ColumnDefinition Width="71*"/>
            <ColumnDefinition Width="417*"/>
            <ColumnDefinition Width="45*"/>
        </Grid.ColumnDefinitions>
        <Image Grid.ColumnSpan="3" HorizontalAlignment="Left" Height="92" Margin="10,10,0,0" VerticalAlignment="Top" Width="409"/>
        <Image Grid.ColumnSpan="2" HorizontalAlignment="Left" Height="75" Margin="10,10,0,0" VerticalAlignment="Top" Width="75" Source="https://i.warosu.org/data/g/img/0611/92/1499034053923.png"/>
        <TextBox Grid.Column="1"  IsReadOnly="true" HorizontalAlignment="Left" Height="32" Margin="46,10,0,0" TextWrapping="Wrap" Text="Hyper V Manager - Administration Console" VerticalAlignment="Top" Width="542" FontFamily="Segoe WP Black" FontSize="16" FontWeight="Thin" Grid.ColumnSpan="2" TextDecorations="{x:Null}"/>
        <Button Name="showvm" Content="Show VMs" HorizontalAlignment="Left" Margin="10,89,0,0" VerticalAlignment="Top" Width="150"  ToolTip="Click here to list your VMs" Background="#FFDDDFE0" FontFamily="Segoe UI Emoji" Grid.ColumnSpan="2"/>
        <Button Name="details" Content="Show Details" HorizontalAlignment="Left" Margin="10,115,0,0" VerticalAlignment="Top" Width="150"  ToolTip="Click here to list your VM Details" Background="#FFDDDFE0" FontFamily="Segoe UI Emoji" Grid.ColumnSpan="2"/>
        <Button Name="features" Content="Show Roles/Features" HorizontalAlignment="Left" Margin="10,141,0,0" VerticalAlignment="Top" Width="150"  ToolTip="Click here to list your Roles and Features" Background="#FFDDDFE0" FontFamily="Segoe UI Emoji" Grid.ColumnSpan="2"/>
        <TextBox Name="machinename" Grid.Column="1" HorizontalAlignment="Left" Height="29" Margin="46,0,0,436" TextWrapping="Wrap" VerticalAlignment="Bottom" Width="542" FontSize="16" FontFamily="SimSun" Grid.ColumnSpan="2" Cursor="None"/>
        <TextBox Name="textbox" Grid.Column="1" HorizontalAlignment="Left" Height="409" Margin="46,102,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="542" FontSize="16" FontFamily="SimSun" Grid.ColumnSpan="2"/>

    </Grid>
</Window>

'@
function Convert-XAMLtoWindow
{
  param
  (
    [Parameter(Mandatory=$true)]
    [string]
    $XAML
  )
  
  Add-Type -AssemblyName PresentationFramework
  
  $reader = [XML.XMLReader]::Create([IO.StringReader]$XAML)
  
  try
  {
    $result = [Windows.Markup.XAMLReader]::Load($reader)
  }
  # NOTE: When you use a SPECIFIC catch block, exceptions thrown by -ErrorAction Stop MAY LACK
  # some InvocationInfo details such as ScriptLineNumber.
  # REMEDY: If that affects you, remove the SPECIFIC exception type [System.Windows.Markup.XamlParseException] in the code below
  # and use ONE generic catch block instead. Such a catch block then handles ALL error types, so you would need to
  # add the logic to handle different error types differently by yourself.
  catch [System.Windows.Markup.XamlParseException]
  {
    # get error record
    [Management.Automation.ErrorRecord]$e = $_

    # retrieve information about runtime error
    $info = [PSCustomObject]@{
      Exception = $e.Exception.Message
      Reason    = $e.CategoryInfo.Reason
      Target    = $e.CategoryInfo.TargetName
      Script    = $e.InvocationInfo.ScriptName
      Line      = $e.InvocationInfo.ScriptLineNumber
      Column    = $e.InvocationInfo.OffsetInLine
    }
    
    # output information. Post-process collected info, and log info (optional)
    $info
  }

  $reader.Close()
  $reader = [XML.XMLReader]::Create([IO.StringReader]$XAML)
  while ($reader.Read())
  {
    $name=$reader.GetAttribute('Name')
    if (!$name) {$name=$reader.GetAttribute('x:Name')}
    if($name)
    {$result | Add-Member NoteProperty -Name $name -Value $result.FindName($name) -Force}
  }
  $reader.Close()
  $result
}

 function Return-VM{  [CmdletBinding()]
  param(  [switch]$details  )  
  try
  {
    if($details){    $vm = Get-VM        [Array]$VMarray = $vm | Select-Object -Property Name, MemoryAssigned, @{Name='Days';     Expression={(($_.Uptime).days)}},@{Name='Hours'; Expression={(($_.Uptime).hours)}}, Status, State, @{Name='CPU %';     Expression={($_.CPUUsage)}} -ErrorAction Stop    return $VMarray    }    else{    $vm = Get-VM    [Array]$VMarray = $vm | Select-Object -Property Name, State, @{Name='CPU %'; Expression={($_.CPUUsage)}}    return $VMarray    }
  }
  
  # NOTE: When you use a SPECIFIC catch block, exceptions thrown by -ErrorAction Stop MAY LACK
  # some InvocationInfo details such as ScriptLineNumber.
  # REMEDY: If that affects you, remove the SPECIFIC exception type [System.NotSupportedException] in the code below
  # and use ONE generic catch block instead. Such a catch block then handles ALL error types, so you would need to
  # add the logic to handle different error types differently by yourself.
  catch [System.NotSupportedException]
  {
    # get error record
    [Management.Automation.ErrorRecord]$e = $_

    # retrieve information about runtime error
    $info = [PSCustomObject]@{
      Exception = $e.Exception.Message
      Reason    = $e.CategoryInfo.Reason
      Target    = $e.CategoryInfo.TargetName
      Script    = $e.InvocationInfo.ScriptName
      Line      = $e.InvocationInfo.ScriptLineNumber
      Column    = $e.InvocationInfo.OffsetInLine
    }
    
    # output information. Post-process collected info, and log info (optional)
    $info
  }

}

function Show-WPFWindow
{
  param
  (
    [Parameter(Mandatory)]
    [Windows.Window]
    $Window
  )
  
  $result = $null
  $null = $window.Dispatcher.InvokeAsync{
    $result = $window.ShowDialog()
    Set-Variable -Name result -Value $result -Scope 1
  }.Wait()
  $result
}

$window = Convert-XAMLtoWindow -XAML $xaml

$window.showvm.add_Click(
  {
    $window.textbox.Text = Return-VM | Format-List | Out-String 
  }
)
$window.features.add_Click(
  {
    $veem = $window.machinename.Text
    $window.textbox.Text = Show-Features -vmname $veem | Out-String 
  }
)
$window.details.add_Click(
  {
    $window.textbox.Text = Return-VM -details | Format-List | Out-String
  }
)

$window.machinename.Text = "Computer Name - $env:COMPUTERNAME"

$window.machinename.add_GotFocus{
  # remove param() block if access to event information is not required
  param
  (
    [Parameter(Mandatory)][Object]$sender,
    [Parameter(Mandatory)][Windows.RoutedEventArgs]$e
  )
  
  $window.machinename.Text = ""
}

  function Show-Features{
    param(
      [Parameter(Mandatory=$true)]
      $vmname
    )
    try{
      if(Test-Connection $vmname -Count 1 -Quiet){
        Invoke-Command -ComputerName $vmname -ScriptBlock{ get-windowsfeature | Select-Object -Property Name, Installstate }
      }
      if (!( Test-Connection $vmname -Count 1 -Quiet)){
        Write-output "Cannot connect to $vmname"
      }

     }
      catch{
      write-output $_.Exception.Message
      }
  }


Show-WPFWindow -Window $window
