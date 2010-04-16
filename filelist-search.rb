#!/usr/bin/ruby
require 'rubygems'
require 'hpricot'



#LISTDIR="/home/ayoung/devel/candlepin/dependencies/filelists"
#`find #{LISTDIR} -name \*.xml`.each {|xmlFile|
#  puts xmlFile
#  xmlFile.chomp
#  xml = XmlSimple.xml_in(xmlFile)

xmlFile="/home/ayoung/devel/candlepin/dependencies/filelists/fedora/12/filelists.xml"

doc = open(xmlFile) { |f| Hpricot.XML(f) }

# }
