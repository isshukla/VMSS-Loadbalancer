#------------------------------------------------------------------------------   
#   
#    
# THIS CODE AND ANY ASSOCIATED INFORMATION ARE PROVIDED “AS IS” WITHOUT   
# WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT   
# LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS   
# FOR A PARTICULAR PURPOSE. THE ENTIRE RISK OF USE, INABILITY TO USE, OR    
# RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.   
#   
#------------------------------------------------------------------------------  

#Please Note: Make sure that you have taken the Backup of VMSS, data, and the configuration of the VMSS as well.

#Steps:
#1.	Create an empty Load Balancer Backend pool.
#2.	Run the PowerShell commands shared later in this mail to add the second IP Config to the VMSS.
#3.	Stop the VMSS
#4.	Update the VMSS Manually from Portal. <<< Due to some reasons the Update VMSS command was not working as expected.
#5.	Start the VMSS
#6.	Update the LB
#7.	Create the new LB Rules, which will be associated to the New IP Config and the New NICs created in the Current VMSS.

#PowerShell Commands (you have to change the values as per your requirements):
#========================================================

# Getting LB and VNET Details
$lb = Get-AzureRmLoadBalancer -ResourceGroupName LB -Name vmss300lb

# Creating the empty backend Pool for the new VMSS IP Config Profile.
Add-AzureRmLoadBalancerBackendAddressPoolConfig -LoadBalancer $lb -Name pool2
$lb | Set-AzureRmLoadBalancer

# Getting the LB details
$frontendIP = Get-AzureRmLoadBalancerFrontendIpConfig -Name LoadBalancerFrontEnd -LoadBalancer $lb
$backendPool = Get-AzureRmLoadBalancerBackendAddressPoolConfig -LoadBalancer $lb -Name bepool
$backendPool2 = Get-AzureRmLoadBalancerBackendAddressPoolConfig -LoadBalancer $lb -Name pool2
$probe = Get-AzureRmLoadBalancerProbeConfig -LoadBalancer $lb -Name tcpprobe

$vnet = get-AzureRmVirtualNetwork -Name lb1 -ResourceGroupName lb 


# VMSS Part ##################
$vmss= Get-AzureRmVmss -ResourceGroupName "lb" -Name "vmss300"

# 2nd IP Config object
$ipconf = New-AzureRmVmssIpConfig –Name "SECONDIPCONFIG" -LoadBalancerBackendAddressPoolsId $lb.BackendAddressPools.id[1]  -SubnetId $vmss.VirtualMachineProfile.NetworkProfile.NetworkInterfaceConfigurations[0].IpConfigurations[0].Subnet.Id  

# Adding 2nd NIC
Add-AzureRmVmssNetworkInterfaceConfiguration -VirtualMachineScaleSet $VMSS -Name "NIC2" -Primary $False -IPConfiguration $ipconf
                                                                                      
# Stop VMSS
Stop-AzureRmVmss -ResourceGroupName LB -VMScaleSetName vmss300

# Update the model of the scale set with the new configuration in the local PowerShell object
update-AzureRmVmss -ResourceGroupName "LB" -Name "VMSS300" -VirtualMachineScaleSet $vmss 

###Update VMSS Instance Manually###

$msg = "Update VMSS Instance Manually"
Out-GridView -InputObject $msg -OutputMode Single

# Start VMSS
Start-AzureRmVmss -ResourceGroupName LB -VMScaleSetName vmss300

# To view the IP Configuration details 
$vmss.VirtualMachineProfile.NetworkProfile.NetworkInterfaceConfigurations

# Updating LB
$lb | Set-AzureRmLoadBalancer 

#========================================================
