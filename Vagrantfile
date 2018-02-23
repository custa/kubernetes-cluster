# -*- mode: ruby -*-
# vi: set ft=ruby :

# 安装必备插件：
# 1. 配置代理，需要 vagrant-proxyconf 插件
required_plugins = %w(vagrant-proxyconf)
plugins_to_install = required_plugins.select { |plugin| not Vagrant.has_plugin? plugin }
if not plugins_to_install.empty?
  puts "Installing plugins: #{plugins_to_install.join(' ')}"
  if system "vagrant plugin install #{plugins_to_install.join(' ')}"
    exec "vagrant #{ARGV.join(' ')}"
  else
    abort "Installation of one or more plugins has failed. Aborting."
  end
end

# https://www.vagrantup.com/docs/vagrantfile/tips.html#overwrite-host-locale-in-ssh-session
ENV["LC_ALL"] = "en_US.UTF-8"

Vagrant.configure("2") do |config|

  config.ssh.forward_agent = true

  config.vm.box = "centos/7"

  config.vm.box_check_update = false

  if Vagrant.has_plugin?("vagrant-proxyconf")
    #config.proxy.http     = "http://10.0.2.2:8080"
    #config.proxy.https    = "http://10.0.2.2:8080"
  end

  config.vm.provision "shell", inline: <<-SHELL
set -xe
export PS4='+[$LINENO]'

# no_proxy
cat >/etc/profile.d/zzz_no_proxy.sh <<\EOF
# Named 'zzz_no_proxy.sh', so it will be loaded finally, and overwrite Env variable 'no_proxy'.
export no_proxy=\\$(echo 172.17.0.{1..255} | sed "s/ /,/g")
export no_proxy=\\${no_proxy},10.0.2.2,10.0.2.15,127.0.0.1,localhost,.example.com
export NO_PROXY=\\${no_proxy}
EOF
source /etc/profile.d/zzz_no_proxy.sh &>/dev/null

  SHELL

end
