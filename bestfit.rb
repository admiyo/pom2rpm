#!/usr/bin/ruby --debug
require 'fileutils'
require 'ftools'
javadir="/usr/share/java/"

`find /tmp/jackson/jackson-src-1.4.3/lib/ -name \*.jar -type f`.each { |jar|
  jar = jar.chomp
  basejar=File.basename jar
  if (/(.*)-[0-9].*/ =~ basejar)
    noVersion = $1
    noVersionJar = noVersion + ".jar"
  else
    noVersion = basejar
    noVersion.gsub ".jar",""
    noVersionJar = basejar
  end

  matches=`find #{javadir} -name #{basejar} `
  if matches.length > 0
    puts "Exact match for #{basejar}"
    matches.each {|alt| 
      puts alt 
      puts "attempting to replace #{jar} with #{alt}"
      FileUtils.remove_entry_secure jar
      FileUtils.ln_s alt, jar
    }
  else    
    alternatives=`find #{javadir} -name \"#{noVersionJar}\*\" `
    if alternatives.length > 0
      puts "Alternatives for #{jar}"
      alternatives.each {|alt| puts alt }
    else
      yumResults=`yum search -qC  #{noVersion} 2>&1 | grep -iv "No matches" | grep -v "Loaded plugins:"  | grep -v "Matched:" `
      puts yumResults
    end
  end
}

