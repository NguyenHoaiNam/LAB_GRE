#! /bin/bash 
echo "Cài đặt KVM"
 
echo "Cập nhật hệ thống"
apt-get update && apt-get upgrade  -y && apt-get dist-upgrade
 
echo "Cài đặt KVM"
apt-get install kvm libvirt-bin virtinst -y 
echo "Disable card virbr0 của KVM"
virsh net-destroy default
virsh net-autostart --disable default

#At this point, because we aren’t using the default Linux bridge,
 #we can remove the ebtables package using the following command
aptitude purge ebtables
echo "Cài đặt openvswitch"
apt-get install openvswitch-controller openvswitch-switch openvswitch-datapath-source -y
#Edit file /etc/default/openvswitch-switch
sed "s/BRCOMPAT=no/BRCOMPAT=yes/g" /etc/default/openvswitch-switch
 
module-assistant auto-install openvswitch-datapath

echo "Tạo card br0"
ovs-vsctl add-br br0
ovs-vsctl add-port br0 eth0

echo "Cấu hình lại card mạng"
iface=/etc/network/interfaces

test -f $iface.bka | cp $iface $iface.bka

rm $iface

touch $iface

cat << EOF >> $iface
auto eth0
iface eth0 inet static

 The OVS bridge interface
auto br0
iface br0 inet static
address 192.168.1.200
network 192.168.1.0
netmask 255.255.255.0
broadcast 192.168.1.255
gateway 192.168.1.1
bridge_ports eth0
bridge_fd 9
bridge_hello 2
bridge_maxage 12
bridge_stp off
dns-nameservers 8.8.8.8
EOF

echo "Kiểm  tra openvswitch"
ovs-vsctl show

echo " Chay script de chon card "
echo "#!/bin/sh" >/etc/ovs-ifup
echo "switch='br-int'" >>/etc/ovs-ifup
echo "/sbin/ifconfig $1 0.0.0.0 up">>/etc/ovs-ifup
echo "ovs-vsctl add-port ${switch} $1" >>/etc/ovs-ifup

echo "cap quyen cho file "
chmod +x /etc/ovs-ifup 

echo "Bat dau tao may ao "
wget http://cdn.download.cirros-cloud.net/0.3.2/cirros-0.3.2-x86_64-disk.img 
echo "Tạo máy ảo  bằng KVM "
echo " Luu y khi tao may ao ban se mat quyen ssh vao phien ssh hien tai "
kvm -m 512 -net nic,macaddr=12:56:52:cc:cc:25 -net tap,script=/etc/ovs-ifup cirros-0.3.2-x86_64-disk.img -nographic



