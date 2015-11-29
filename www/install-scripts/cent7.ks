#version=RHEL7
# System authorization information
auth --enableshadow --enablemd5
# Install OS instead of upgrade
install
# Reboot after installation
# temporarily power off to change boot load preference
poweroff
# Use network installation
url --url="http://10.0.2.2:80/centos/7/os/x86_64"
# Use text mode install
text
# SELinux configuration
selinux --disabled
# Firewall configuration
firewall --disabled
firstboot --disable
ignoredisk --only-use=sda
# Keyboard layouts
# old format: keyboard us
# new format:
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8
# Installation logging level
logging --level=warning
# Network information
network  --bootproto=dhcp --hostname=cent.localdomain
# Root password
rootpw --iscrypted $1$abc$1DR2ANdfiFYe1Qh/zPsNX0
# System services
services --enabled="sshd"
# Do not configure the X Window System
skipx
# System timezone
timezone Australia/Sydney --isUtc
# user
user --name=alexk --gecos="Alex Kruchkoff" --password=$1$ikl$hT.4ef3sh.KS5.be/qtdF/ --iscrypted --uid=1056
# System bootloader configuration
bootloader --append="console=ttyS0 ignore_loglevel crashkernel=auto" --location=mbr --boot-drive=sda
# Clear the Master Boot Record
zerombr
# Partition clearing information
clearpart --all --initlabel --drives=sda
# Disk partitioning information
part pv.57 --fstype="lvmpv" --ondisk=sda --size=17025
part /boot --fstype="ext4" --ondisk=sda --size=200
volgroup vg.0 --pesize=4096 pv.57
logvol /  --fstype="ext4" --grow --size=1 --name=lv.root --vgname=vg.0
logvol swap  --fstype="swap" --size=1024 --name=lv.swap --vgname=vg.0

%pre
vgchange -a n
%end

%post
KICKSTART_SERVER=10.0.2.2
echo "installing local puppet repo" >/dev/console
# local puppet yum repo
cat <<EOF > /etc/yum.repos.d/localpuppet.repo
[puppetlabs-products]
name=Puppet Labs Products El 7 - \$basearch
baseurl=http://$KICKSTART_SERVER/yum.puppetlabs.com/el/7/products/\$basearch
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs
enabled=1
gpgcheck=1

[puppetlabs-deps]
name=Puppet Labs Dependencies El 7 - \$basearch
baseurl=http://$KICKSTART_SERVER/yum.puppetlabs.com/el/7/dependencies/\$basearch
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs
enabled=1
gpgcheck=1

[puppetlabs-devel]
name=Puppet Labs Devel El 7 - \$basearch
baseurl=http://$KICKSTART_SERVER/yum.puppetlabs.com/el/7/devel/\$basearch
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs
enabled=0
gpgcheck=1

[puppetlabs-products-source]
name=Puppet Labs Products El 7 - \$basearch - Source
baseurl=http://$KICKSTART_SERVER/yum.puppetlabs.com/el/7/products/SRPMS
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs
failovermethod=priority
enabled=0
gpgcheck=1

[puppetlabs-deps-source]
name=Puppet Labs Source Dependencies El 7 - \$basearch - Source
baseurl=http://$KICKSTART_SERVER/yum.puppetlabs.com/el/7/dependencies/SRPMS
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs
enabled=0
gpgcheck=1

[puppetlabs-devel-source]
name=Puppet Labs Devel El 7 - \$basearch - Source
baseurl=http://$KICKSTART_SERVER/yum.puppetlabs.com/el/7/devel/SRPMS
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs
enabled=0
gpgcheck=1
EOF

# puppet repo key
cat <<EOF > /etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG/MacGPG2 v2.0.17 (Darwin)

mQINBEw3u0ABEAC1+aJQpU59fwZ4mxFjqNCgfZgDhONDSYQFMRnYC1dzBpJHzI6b
fUBQeaZ8rh6N4kZ+wq1eL86YDXkCt4sCvNTP0eF2XaOLbmxtV9bdpTIBep9bQiKg
5iZaz+brUZlFk/MyJ0Yz//VQ68N1uvXccmD6uxQsVO+gx7rnarg/BGuCNaVtGwy+
S98g8Begwxs9JmGa8pMCcSxtC7fAfAEZ02cYyrw5KfBvFI3cHDdBqrEJQKwKeLKY
GHK3+H1TM4ZMxPsLuR/XKCbvTyl+OCPxU2OxPjufAxLlr8BWUzgJv6ztPe9imqpH
Ppp3KuLFNorjPqWY5jSgKl94W/CO2x591e++a1PhwUn7iVUwVVe+mOEWnK5+Fd0v
VMQebYCXS+3dNf6gxSvhz8etpw20T9Ytg4EdhLvCJRV/pYlqhcq+E9le1jFOHOc0
Nc5FQweUtHGaNVyn8S1hvnvWJBMxpXq+Bezfk3X8PhPT/l9O2lLFOOO08jo0OYiI
wrjhMQQOOSZOb3vBRvBZNnnxPrcdjUUm/9cVB8VcgI5KFhG7hmMCwH70tpUWcZCN
NlI1wj/PJ7Tlxjy44f1o4CQ5FxuozkiITJvh9CTg+k3wEmiaGz65w9jRl9ny2gEl
f4CR5+ba+w2dpuDeMwiHJIs5JsGyJjmA5/0xytB7QvgMs2q25vWhygsmUQARAQAB
tEdQdXBwZXQgTGFicyBSZWxlYXNlIEtleSAoUHVwcGV0IExhYnMgUmVsZWFzZSBL
ZXkpIDxpbmZvQHB1cHBldGxhYnMuY29tPokCPgQTAQIAKAIbAwYLCQgHAwIGFQgC
CQoLBBYCAwECHgECF4AFAk/x5PoFCQtIMjoACgkQEFS3okvW7DAIKQ/9HvZyf+LH
VSkCk92Kb6gckniin3+5ooz67hSr8miGBfK4eocqQ0H7bdtWjAILzR/IBY0xj6OH
KhYP2k8TLc7QhQjt0dRpNkX+Iton2AZryV7vUADreYz44B0bPmhiE+LL46ET5ITh
LKu/KfihzkEEBa9/t178+dO9zCM2xsXaiDhMOxVE32gXvSZKP3hmvnK/FdylUY3n
WtPedr+lHpBLoHGaPH7cjI+MEEugU3oAJ0jpq3V8n4w0jIq2V77wfmbD9byIV7dX
cxApzciK+ekwpQNQMSaceuxLlTZKcdSqo0/qmS2A863YZQ0ZBe+Xyf5OI33+y+Mr
y+vl6Lre2VfPm3udgR10E4tWXJ9Q2CmG+zNPWt73U1FD7xBI7PPvOlyzCX4QJhy2
Fn/fvzaNjHp4/FSiCw0HvX01epcersyun3xxPkRIjwwRM9m5MJ0o4hhPfa97zibX
Sh8XXBnosBQxeg6nEnb26eorVQbqGx0ruu/W2m5/JpUfREsFmNOBUbi8xlKNS5CZ
ypH3Zh88EZiTFolOMEh+hT6s0l6znBAGGZ4m/Unacm5yDHmg7unCk4JyVopQ2KHM
oqG886elu+rm0ASkhyqBAk9sWKptMl3NHiYTRE/m9VAkugVIB2pi+8u84f+an4Hm
l4xlyijgYu05pqNvnLRyJDLd61hviLC8GYU=
=qHKb
-----END PGP PUBLIC KEY BLOCK-----
EOF

cat <<EOF > /etc/pki/rpm-gpg/RPM-GPG-KEY-nightly-puppetlabs 
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG/MacGPG2 v2.0.17 (Darwin)

mQINBFERnnkBEAC6FNq5aPrrLxiqpgSmhJfAm8dFGWOLUGtTkEgwo+kHggXN+q6t
jQgBaY2INJ68TDfOntGh2FVXrU++a0l+9NY0SQ/00Qj869N0FcBLZBqRiKQV7Xcd
PetiNFnua0mS9k1irj7RkSq27OgklZTcpy6ayBJzftrCWHf9chLK0fcAbVH1TpKu
qOIQVjo+KBKoakL9TD79UT6hhICZdfbOC0vdu+3DCMK4+ed5xs7MtV8DugUCD/CI
SUGfvDpMN1GiYyx5CRMYKN1BzBXWYQDjmG65ccKt5RDZpHYI8QlAWYlTYhF/TS5v
MdR1mlv55wSB7uoO6/tRX+ajEiNoQVWp+qJuICh3SPcE4RvPVdejat2M7biuS+jY
fWuwVUCaLNK+NfTRxlz6l6jffY1kS/owKsCqM74lGIow8fJOMS56UNXSGx38BNDD
7iJIB3kCKATJMQ9bYkAu6LqlUalNYIPVSoTmX9KKQ576kPnAzMn1AoYK444pEqAg
SFQg769a+0/4FDAxF352jHwHRMtc/ap1M00UczG5eATd2Z/uB7X/gc6QJZ+h/Ie7
AW+gjtU19kIdyT061fc0km2zlv5LsklPq5BwUD82uZfqZ1g+3l2lY+/lhMfk7GCD
/RqXvxTladobfdzYIzRQKHT1vouY5uzEZPr5c44nRyevaRFKEELbpE3fCwARAQAB
tFdQdXBwZXQgTGFicyBOaWdodGx5IEJ1aWxkIEtleSAoUHVwcGV0IExhYnMgTmln
aHRseSBCdWlsZCBLZXkpIDxkZWxpdmVyeUBwdXBwZXRsYWJzLmNvbT6JAj8EEwEC
ACkFAlERs60CGwMFCQWjmoAHCwkIBwMCAQYVCAIJCgsEFgIDAQIeAQIXgAAKCRC4
+ZnAB7tsV+1FEAChgzkEttAUTRGt7aKfnUDjVpgv49QAQ1UzpBe2XPSU+aBBEs1a
H/8iFigHwm2Mh+Zd8skmSNzTkLewrMCFg2HtCUf7gYchqB5ANbedi8z+OVMSNvSu
V2ngZt6qEG1d1uhlknBpIo32idss/3SB4dJt0pAvJlBgayKqlcFd/CXLFtfws03r
WYlhpZPP5z3lIPrJxsHdts1JWZE2lYdxWx66odsbDBXa6YQzrUlObCc3m7uYepqe
3DGRC2kTTZoNzu1XkDANYcGqtOY0Lj4rEv5LTqkoCV4fKTmlKQ6FdLWuCUsGqhJF
rGR797ZmlxstEM7PV/Wzo0WyCoDdsPSWPs9jiieS+GIOVTCT2DHSqcBkkH+9GGmk
9HdTf/OD/I+wkbAwZ1TBP0w7hNrtVzP/Qe8ZnXCNvBcWa6kHNOjhklLyvb0oE5E8
V0rI6G2ofLLIuAuP80YE2bveCjoUpR+GBq8y1+4NuTO9PDcYFyYj2eyvAnnmtvJh
2H93/iaGxG6cz3nsFEQBQlxwpuHBVN9RbIl0KzYRplKUSlWsojDMzSRfMo7h6cAd
g4xnVd0EeQvDLPkTvOiZw/2Kvc3qBe0+4wgJECroe+nEHutF5ZSoVQ5Ydq6SlwLS
wG3mvYXEq2mZJty4/qCs11En9zJfcaeuco1I5vTvmuADENcBa6BhD0FBBIkCHAQQ
AQIABgUCU9F3ZAAKCRBGnps2mw8PHUeJD/9MQ5g+Sn6IdP/A1xNQ7gCvTQtrrGX1
vDe/leWdbzdiOsHSJ4KFtdwekKE1GTTy91FKDHJYK1sjCYx447yYOK9oltiuCeAl
j4VIywDOFLI9q7N7SXg9Xd2ctExmYrk2ujgY0jiiI4anSpc9wGOy2VwGcRrpe4sc
OdFgWGRxVuhkO7aj+13P44kP4JmPJ6IgC0KEwn6CGWl87dw64rTCZOEm2f94MB+M
HfgJl2S3WloplqnlstkIXRDA/4Nsl3Xz0dnL+i3rDaOk1cW3UkWejKfs2W6jow81
NlIbenOHt+/Nv3bgzWyb4LIsXMRXWtiLq6PIc6xb4phzp85QHmOT8FlA9pTq8bUl
EMsdY+Ns9/0DHy4ZBKtVcLe3GK7Y4tlyfhOLng+gd53mbsXGT1+dqJOA0YvSjH/C
Yg9six0ate5Mdx2Y/K5Ezlu1cVYIxuSdMht58QQ5B1s+X57lCBZHlx8RU6+jqpMG
y0ftoeqJYxCm6+dTuX3Gl9wnjRJrAfGJj9QIpeGl/tIlcC8TzOQwi+I8locoPLYX
ILC0IfAbXCJBKqOcIm3mCZMYJfM7/IAaFyBRZtOnKQgyKP0g9ugvtUt6v4j/cKKR
Z6zNyMGnmUmGDiTY4IGLks6Ij7wRROUVwCrFtMUTIz4hAM7CdbwbOd+cxvTvSBL2
IGTQZNUL2JceVrRTUHVwcGV0IExhYnMgTmlnaHRseSBCdWlsZCBLZXkgKFB1cHBl
dCBMYWJzIE5pZ2h0bHkgQnVpbGQgS2V5KSA8aW5mb0BwdXBwZXRsYWJzLmNvbT6J
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
=sVa9
-----END PGP PUBLIC KEY BLOCK-----
EOF

/usr/bin/rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs
/usr/bin/rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-nightly-puppetlabs

echo "done. yum repositories" >/dev/console
#/usr/bin/yum repolist >/dev/console 2>&1
echo "installing puppet:" >/dev/console
# CentOS repos are not local -- still need internet access...
/usr/bin/yum -y install puppet >/dev/console 2>&1
echo done. installed pupet version is >/dev/console
/usr/bin/puppet --version >/dev/console  2>&1
/usr/bin/facter >/dev/console  2>&1

%end

%packages --ignoremissing
@Base
@Core
kexec-tools

%end

%addon com_redhat_kdump --enable --reserve-mb='auto'

%end
