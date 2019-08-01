# VMSS-Loadbalancer
This Repository contains few PS Scripts to perform certains operation on VMSS with LB which are not possible via Portal or have a hard limit.

As per Azure Service limits “Rules (NAT or load balancing rules combined) per "IP configuration" are limited to 299”. So for A VMSS 
we cannot add a new NAT or LB rule if the total rule count reaches 299. 
https://docs.microsoft.com/en-us/azure/azure-subscription-service-limits#load-balancer

There is no option from Portal to add the additional IP Config Profile in VMSS. 
You can use this script to update the VMSS with a second IP Config Profile.
