FROM       java:8-jdk

MAINTAINER Michael Clausen <encodeering@gmail.com>

EXPOSE     22 2375

VOLUME     /var/lib/docker

RUN        apt-get update                                                             \
 &&        apt-get install -y apt-transport-https ca-certificates curl                \
                              btrfs-tools e2fsprogs iptables procps xfsprogs xz-utils \
                              openssh-server                                          \
 &&        apt-get autoremove -y                                                      \
 &&        rm -rf /var/lib/apt/lists/*

RUN        curl -sSL https://get.docker.com/ | bash                                                         \
 &&        curl -sSL https://raw.githubusercontent.com/docker/docker/master/hack/dind > /usr/local/bin/dind \
 &&        chmod +x                                                                     /usr/local/bin/dind \
 &&        apt-get autoremove -y                                                                            \
 &&        rm -rf /var/lib/apt/lists/*

RUN        useradd -m -s /bin/bash jenkins \
 &&        usermod -a -G docker    jenkins \
 &&        echo 'jenkins:jenkins' | chpasswd

RUN        sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd \
 &&        mkdir -p /var/run/sshd

ENTRYPOINT ["dind"]

CMD        ["/usr/sbin/sshd", "-D"]
