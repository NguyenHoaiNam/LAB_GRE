 
 Cài đặt KVM:
 
 - Cập nhật hệ thống:
 #apt-get update && apt-get dist-upgrade
 
 - Cài đặt KVM
 #apt-get install kvm libvirt-bin virtinst
 
 - Disable card virbr0 của KVM:
# virsh net-destroy default
# virsh net-autostart --disable default

- At this point, because we aren’t using the default Linux bridge,
 we can remove the ebtables package using the following command
 #aptitude purge ebtables
 - Cài đặt openvswitch:
 #apt-get install openvswitch-controller openvswitch-brcompat \
 #openvswitch-switch openvswitch-datapath-source
 - Edit file #/etc/default/openvswitch-switch
 #BRCOMPAT=no => #BRCOMPAT=yes
 
#module-assistant auto-install openvswitch-datapath

- Tạo card br0:
#ovs-vsctl add-br br0
#ovs-vsctl add-port br0 eth0

- Cấu hình lại card mạng:

#auto eth0
#iface eth0 inet static

# The OVS bridge interface
#auto br0
#iface br0 inet static
#address 192.168.1.200
#network 192.168.1.0
#netmask 255.255.255.0
#broadcast 192.168.1.255
#gateway 192.168.1.1
#bridge_ports eth0
#bridge_fd 9
#bridge_hello 2
#bridge_maxage 12
#bridge_stp off
#dns-search mydomain.local
#dns-nameservers 192.168.1.1 192.168.1.2



- Kiểm  tra openvswitch:
#ovs-vsctl show

-Tạo máy ảo:

# wget http://cdn.download.cirros-cloud.net/0.3.2/cirros-0.3.2-x86_64-disk.img 

+ Tạo máy ảo  bằng KVM :
#kvm -m 512 -net nic,macaddr=12:56:52:cc:cc:25 -net tap,script=/etc/ovs-ifup cirros-0.3.2-x86_64-disk.img -nographic

- sau khi tao xong máy ảo kiểm tra lại mạng của máy ảo.








