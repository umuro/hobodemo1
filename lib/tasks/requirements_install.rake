#
# Usage: sudo rake watch_it:requirements:install
#

namespace :application do
  namespace :requirements do
    desc "apt-get requirements"
    task(:install => :environment) do
      puts %x{sudo apt-get install -qqy memcached}
      puts
      puts 'Check memcached config:'
      puts 'sudo kate /etc/memcached.conf'
      puts
      puts %x{sudo apt-get install -qqy libmemcached-tools}
      puts
      puts 'Memcached cmd line tools:'
      puts 'http://tangent.org/552/libmemcached.html'
      puts %x{dpkg -L libmemcached-tools | grep bin}
    end
  end
end