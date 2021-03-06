:: Name:     SetFirewallRules.bat
:: Purpose:  Configure firewall rules for working with Teamcenter and its components
:: Author:   alexey.sedoykin@siemens.com

netsh advfirewall firewall add rule name="FSC_4544" dir=in action=allow protocol=TCP localport=4544
netsh advfirewall firewall add rule name="License_28000" dir=in action=allow protocol=TCP localport=28000
netsh advfirewall firewall add rule name="LicenseInternal_1010" dir=in action=allow protocol=TCP localport=1010
netsh advfirewall firewall add rule name="WebTier_7001" dir=in action=allow protocol=TCP localport=7001
netsh advfirewall firewall add rule name="AWC_3000" dir=in action=allow protocol=TCP localport=3000
netsh advfirewall firewall add rule name="SOLR_8983" dir=in action=allow protocol=TCP localport=8983
netsh advfirewall firewall add rule name="VisPoolProxyPoolURL_8090" dir=in action=allow protocol=TCP localport=8090
netsh advfirewall firewall add rule name="VisURL_8089" dir=in action=allow protocol=TCP localport=8089
netsh advfirewall firewall add rule name="VisDataSrv_9990" dir=in action=allow protocol=TCP localport=9990  
netsh advfirewall firewall add rule name="VisPoolProxyRange_50001_52999" dir=in action=allow protocol=TCP localport=50001-52999
netsh advfirewall firewall add rule name="VisPoolProxyLocNode_55577" dir=in action=allow protocol=TCP localport=55577
netsh advfirewall firewall add rule name="VisPoolProxyPeerNode_55566" dir=in action=allow protocol=TCP localport=55566
netsh advfirewall firewall add rule name="DSP1_2001" dir=in action=allow protocol=TCP localport=2001
netsh advfirewall firewall add rule name="DSP2_9090" dir=in action=allow protocol=TCP localport=9090
netsh advfirewall firewall add rule name="DSP3_1999" dir=in action=allow protocol=TCP localport=1999
netsh advfirewall firewall add rule name="ORA_1521" dir=in action=allow protocol=TCP localport=1521
netsh advfirewall firewall add rule name="TCMUX_8087" dir=in action=allow protocol=TCP localport=8087				
netsh advfirewall firewall add rule name="PoolPort_8085" dir=in action=allow protocol=TCP localport=8085
netsh advfirewall firewall add rule name="PoolJMXRMI_8088" dir=in action=allow protocol=TCP localport=8088
netsh advfirewall firewall add rule name="PoolLocPort_17800" dir=in action=allow protocol=TCP localport=17800
netsh advfirewall firewall add rule name="PoolAssServPort_8086" dir=in action=allow protocol=TCP localport=8086
netsh advfirewall firewall add rule name="MicroServ_8787" dir=in action=allow protocol=TCP localport=8787

