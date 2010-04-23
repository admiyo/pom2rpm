#!/usr/bin/ruby
require 'rubygems'
require 'libxml'
require 'rubygems'
require 'libxml'

include LibXML
class ArchiveDef
  attr_accessor   :groupId
  attr_accessor   :artifactId
  attr_accessor   :version
  def to_s
    return "#{groupId}:#{artifactId}:#{version}"
  end
  def no_version
    return "#{groupId}:#{artifactId}"
  end

end

class PostCallbacks


  include XML::SaxParser::Callbacks

  attr_accessor :trace 
  attr_accessor :arch_map
  attr_accessor :archive
  attr_accessor :current
  attr_accessor :key
  attr_accessor :value
  attr_accessor :isKey
  def initialize(trace)
    @current = nil
    @archive = @key
    @arch_map = Hash.new    
    @trace= trace
  end
  
  def on_start_element(element, attributes)
    if ( element == 'dependency')
      return
    end

    if ( element == 'jpp')
      @value = ArchiveDef.new 
      @archive  = @value
    elsif ( element == 'maven')
      @key = ArchiveDef.new 
      @archive = @key
    else
      @current = element
    end
  end

  def on_end_element(element)
      @current = nil
    if ( element == 'dependency')
      @arch_map[@key.no_version]=@value
      @arch_map[@key.to_s]=@value
      if trace
        puts "#{key.to_s}=#{value}"
        puts "#{key.no_version}=#{value}"
      end
    end
  end
  def on_characters(chars)
    if @current  && chars.length > 0
              
      case @current
      when "groupId"
        @archive.groupId = chars
      when "artifactId"     
        @archive.artifactId = chars
      when "version"
        @archive.version = chars
      end
    end
  end
end


class JPP
  attr_accessor :callbacks

  def initialize(trace)
    @callbacks = PostCallbacks.new(trace)
    parser = XML::SaxParser.file("/etc/maven/maven2-depmap.xml")
    parser.callbacks = @callbacks
    parser.parse
  end


  def rpm_search(groupId, artifactId)
    key = "#{groupId}:#{artifactId}"
    jpp= callbacks.arch_map[key]    
    return `rpmquery -f   --queryformat  "%-30{NAME}\n"  /usr/share/maven2/repository/#{jpp.groupId}/#{jpp.artifactId}.jar`
  end

  def for_classpath(groupId, artifactId)
    key = "#{groupId}:#{artifactId}"
    jpp= callbacks.arch_map[key]    
    return "#{jpp.artifactId}"
  end

end

def runJpp(argv)
  trace = false
  rpmsearch=false
  groupId=""
  command = ""

  if argv.length > 1
    rpmsearch=true
    groupId=argv[0]
    artifactId=argv[1]     
    jpp = JPP.new(false) 
    rpm = jpp.rpm_search groupId, artifactId
    puts rpm
  else
    jpp = JPP.new(true)    
  end      
end

if $0 == __FILE__
  runJpp ARGV
end
