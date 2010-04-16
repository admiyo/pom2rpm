#!/usr/bin/ruby
require 'rubygems'
require 'hpricot'
require 'ftools'
require 'fileutils'
require 'net/http'
require 'uri'



def localfetch(jarname)
  repo = "/home/#{ENV['USER']}/.m2/repository"

  `find #{repo} -name #{jarname}\* `.each do |found|
    dir=File.dirname(found)
    pom="#{dir}/#{jarname}.pom"
    source="#{dir}/#{jarname}-sources.jar"

    if File.exists?(pom) then
      puts "Found #{pom}"
      File.copy(pom,".")
    end	

    if File.exists?(source) then
      puts "Found #{source}"
      File.copy(source,"../SOURCES")
    end	
  end  
end



def fetchSourceFromPom(repo, dirURI)
  tmpdir=`mktemp -d`.chomp
  puts "Made Dir #{tmpdir}"

  oldpwd = FileUtils.pwd
  FileUtils.cd(tmpdir)
  pwd = FileUtils.pwd
  puts "We are in #{pwd}"


  #command="wget --user-agent=\"\" #{dirURL} -O index.html "
  #puts command
  #system(command)

  resp=nil
  http = Net::HTTP.new(repo, 80)
  http.start do |http|
    req = Net::HTTP::Get.new(dirURI, {"User-Agent" => ""})
    response = http.request(req)
    resp = response.body
    index =   Hpricot( resp )
    index.search("a"){|a| 
      href= a['href']
      if  /-sources.jar$/ =~ href || /.pom$/ =~ href
        puts "link:"+repo+"/" +dirURI+"/"+href

        req = Net::HTTP::Get.new(dirURI+"/"+href, {"User-Agent" => ""})
        response2 = http.request(req)
        sourceJar = File.new(href,'w')
        sourceJar.write( response2.body )
      end
    }
  end

end


jar=ARGV[0]
unless jar != nil
	puts "usage #{ARGV[0]} URL"
	exit 1
end


localfetch(jar)

#path=$1
#repo="repo2.maven.org"
#fetchSourceFromPom(repo, path)
