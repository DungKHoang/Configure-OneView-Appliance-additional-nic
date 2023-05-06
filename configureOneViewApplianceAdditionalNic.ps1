# Reference
# https://support.hpe.com/hpesc/public/docDisplay?docId=sd00001152en_us&page=s_configure-additional-nic-ov.html

$uri                    = '/rest/appliance/network-interfaces' 
# ----------------------------------------
#       Variables to be defined
# ----------------------------------------

$user                   = '<admin>'
$pass                   = '<password>'
$host_name              = '<OV-IP-address>'

$new_ipV4               = '<IP-address>'
$new_ipv4Subnet         = '<new-subnet>'    # In the form 255.255.x.x
$ipV4Type               = 'STATIC'          # Values: STATIC,DHCP,UNCONFIGURE
$new_interface_name     = ' Second NIC'

# Start Process 

$applianceConnection    = Connect-OVMgmt -Hostname $host_name -UserName $user -password $pass

$_currentconfig         = Send-OVRequest -uri $uri -Hostname $applianceConnection


$_deviceIndex           = $null
[Int]$i                 = 0
$_configured            = $false

For ($i -eq 0; $i -le ($_currentconfig.applianceNetworks.Count - 1); $i++)
{
    if($_currentconfig.applianceNetworks[$i].interfaceName -ne "Appliance")
    {

        $_deviceIndex   = $i

        $_configured    = $true

        #break out of for loop
        break
    }
}

if ($_configured)
{
    $_currentconfig.applianceNetworks[$_deviceIndex].ipv4Type       = $IPv4Type
    $_currentconfig.applianceNetworks[$_deviceIndex].virtIpv4Addr   = $new_ipV4
    $_currentconfig.applianceNetworks[$_deviceIndex].ipv4Subnet     = $new_ipv4Subnet
    $_currentconfig.applianceNetworks[$_deviceIndex].interfaceName  = $new_interface_name

    $_task = Send-OVRequest -uri $uri -Hostname $applianceConnection -method POST -body $_currentconfig | Wait-OVTaskStart
}
else 
{
    write-host " There is no addtional NIC to configure. Exiting now..."    
}



Disconnect-OVmgmt