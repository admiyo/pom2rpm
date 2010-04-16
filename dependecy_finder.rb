#!/usr/bin/ruby

require 'fileutils'


FileUtils.cd "/tmp/hibernate-tools/hibernate-tools-needed-classes"

JAVAC_CP=".:/usr/share/java/commons-logging.jar:/usr/share/java/freemarker.jar:/usr/share/java/hibernate-core.jar:/usr/share/java/jakarta-commons-logging.jar:/usr/share/java/jakarta-commons-logging-jboss.jar:/usr/share/java/slf4j/jcl-over-slf4j.jar:/usr/share/java/jpa_api.jar:/usr/share/java/persistence-api.jar:/usr/share/java/javassist.jar:/usr/share/java/hibernate3-ejb-persistence-3.0-api.jar:/usr/share/java/ant.jar:/usr/share/java/jboss-common-core.jar:/usr/share/java/hibernate-annotations.jar:/usr/share/java/hibernate3-annotations.jar:/usr/share/java/dom4j.jar:/usr/share/java/cglib.jar:/usr/share/java/commons-collections.jar:/usr/share/java/jtidy.jar:/usr/share/java/jta.jar"


JAVAC="javac -cp #{JAVAC_CP} -d ../classes  $( find org/ -name \"*.java\" ) 2>&1"


def find_jars
end


def copy_from_source (arr)
  arr =  arr.sort.uniq.each { |j|  
    /(hibernate-tools-3.2.4.GA\/.*\/src\/java\/).*/.match j
    short =  j.gsub($1, "")
    `cp /tmp/hibernate-tools/#{j} #{short}`
#    puts "cp /tmp/hibernate-tools/#{j} #{short}"
  }
  puts "copying #{arr.length} files"

end

def find_by_symbols
  path=""

  javaArray=Array.new()
  cacheArray=Array.new()

  `#{JAVAC}`.each { |line|    

    if /(.*\.java).*cannot find symbol/.match line
      path=  File.dirname $1
#      puts "path " +path
    end

    if /symbol.*(class|variable) *(.*)/.match line
      javaFile= "#{path}/#{$2.chomp}.java"
#      puts "javaFile "+ javaFile +":"
#      puts "grep #{javaFile} /tmp/hibernate-tools-java-files.txt | sort -u "
      `grep #{javaFile} /tmp/hibernate-tools-java-files.txt | sort -u `.each {
        |java|  
#        puts "java "+java
        javaArray.push java.chomp      
      }

      `grep #{path} /tmp/jarcache.txt | cut -d' ' -f2 `.each { |cl|  
        cacheArray.push(cl)
      }
    end

  }

  copy_from_source(javaArray)
  
end


def find_by_imports

  javaArray=Array.new()
  cacheArray=Array.new()
  
  `#{JAVAC}`.each { |line|    
    if   /^import (.*);/.match line
      javaFile = $1.gsub(".", "/")
      puts "javaFile " +  javaFile 
      `grep #{javaFile} /tmp/hibernate-tools-java-files.txt | sort -u `.each {
        |java|  
        javaArray.push java.chomp
        puts " is "+java
      }

      `grep #{javaFile} /tmp/jarcache.txt | cut -d' ' -f2 `.each { |cl|  
        cacheArray.push(cl)
      }

    end   


  }
  #copy_from_source(javaArray)
  
  cacheArray.sort.uniq.each { |j|
    puts j
  }

end


def rpms_for_jars
  JAVAC_CP.split(":").each { |jar|
    puts `rpm -q -f #{jar}`
  }
end


rpms_for_jars
#find_by_imports
#find_by_symbols
