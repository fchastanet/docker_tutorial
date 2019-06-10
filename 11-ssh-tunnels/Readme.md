#
https://www.cyberciti.biz/faq/create-ssh-config-file-on-linux-unix/

rebondir sur une machine aws
## ~/.ssh/config ##
Host internal
  HostName admin-qa
  User dev
  ProxyCommand ssh dev@amazon -W %h:%p
  ControlPath ~/.ssh/controlmasters/%r@%h:%p
  ControlMaster auto