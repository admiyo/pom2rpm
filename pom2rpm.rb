#!/usr/bin/ruby
#
require 'rubygems'
require 'xmlsimple'
require 'ftools'



def write_spec(spec, pomname)
  pom = XmlSimple.xml_in("#{pomname}", { 'KeyAttr' => 'name' })

  spec.puts "Name:      #{pom['artifactId']}"
  if   pom['version'] != nil &&  pom['version'] != "" 
      spec.puts "Version:   #{pom['version']}" 
  elsif  pom['parent'] != nil && pom['parent'][0]['version'] != nil 
    spec.puts "Version:   #{pom['parent'][0]['version']}"
  end
  spec.puts "Release:        2\%\{?dist}"
  spec.puts"Summary:       #{pom['name']} "
  spec.puts ""
  spec.puts "Group:         Development/Java"
  if pom['licenses'] == nil
    spec.puts "License:        GPL"
  else
    spec.puts "License:        #{pom['licenses'][0]['license'][0]['name']}"
  end
  spec.puts "URL:            #{pom['url']}"
  spec.puts "Source0:        %{name}-%{version}-sources.jar"
  spec.puts "BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)"
  spec.puts ""
  spec.puts "BuildRequires: java-devel  "
  spec.puts "BuildRequires:  jpackage-utils"
  spec.puts "BuildArch: noarch"
  spec.puts "Requires:  java >= 1.5"
  spec.puts "Requires:  jpackage-utils"
  classpath="src/"
   unless pom['dependencies'] == nil
     unless pom['dependencies'][0]['dependency'] == nil
       pom['dependencies'][0]['dependency'].each { 
        |dep|  
        if dep['version'] == nil
          spec.puts "BuildRequires: #{dep['artifactId']}"        
        else
          spec.puts "BuildRequires: #{dep['artifactId']} = #{dep['version']}"
        end
        classpath += ":%{_javadir}/#{dep['artifactId']}.jar"
      }
     end
   end
   unless pom['dependencies'] == nil
     unless pom['dependencies'][0]['dependency'] == nil
       pom['dependencies'][0]['dependency'].each { 
        |dep|  
        if dep['version'] == nil
          spec.puts "Requires: #{dep['artifactId']}"        
        else
          spec.puts "Requires: #{dep['artifactId']} = #{dep['version']}"
        end
      }
     end
   end
  spec.puts ""
  spec.puts "%description"
  spec.puts "%package javadoc"
  spec.puts "Summary:        Javadocs for %{name}"
  spec.puts "Group:          Development/Documentation"
  spec.puts "Requires:       %{name} = %{version}-%{release}"
  spec.puts "Requires:       jpackage-utils"
  spec.puts ""
  spec.puts "%description javadoc"
  spec.puts "This package contains the API documentation for %{name}."
  spec.puts ""
  spec.puts "%prep"
  spec.puts "%setup -cT"
  spec.puts "mkdir src javadoc classes"
  spec.puts "pushd src"
  spec.puts "jar -xf %{SOURCE0}"
  spec.puts "popd"
  spec.puts ""
  spec.puts "%build"
  spec.puts "javac -d classes -cp #{classpath}  `find . -name \*.java` "
  spec.puts "javadoc -d javadoc -classpath src  $(for JAVA in `find src/ -name \*.java` ; do  dirname $JAVA ; done | sort -u  | sed -e 's!src.!!'  -e 's!/!.!g'  )"
  spec.puts "find classes -name \*.class | sed -e  's!classes/!!g' -e 's!^! -C classes !'  | xargs jar cfm %{name}-%{version}.jar ./src/META-INF/MANIFEST.MF"
  spec.puts ""
  spec.puts ""
  spec.puts "%install"
  spec.puts "#rm -rf $RPM_BUILD_ROOT"
  spec.puts "mkdir -p $RPM_BUILD_ROOT"
  spec.puts "install -m 755 -d $RPM_BUILD_ROOT%{_javadir}"
  spec.puts "install -m 755 %{name}-%{version}.jar $RPM_BUILD_ROOT%{_javadir}"
  spec.puts "ln -s %{_javadir}/%{name}-%{version}.jar $RPM_BUILD_ROOT%{_javadir}/%{name}.jar"
  spec.puts "install -m 755 -d $RPM_BUILD_ROOT%{_javadocdir}/%{name}"
  spec.puts "cp -rp javadoc/*  $RPM_BUILD_ROOT%{_javadocdir}/%{name}"
  spec.puts ""
  spec.puts "%add_to_maven_depmap org.apache.maven %{name} %{version} JPP %{name}"
  spec.puts ""
  spec.puts "%clean"
  spec.puts "rm -rf $RPM_BUILD_ROOT"
  spec.puts ""
  spec.puts ""
  spec.puts "%post"
  spec.puts "%update_maven_depmap"
  spec.puts ""
  spec.puts "%postun"
  spec.puts "%update_maven_depmap"
  spec.puts ""
  spec.puts ""
  spec.puts "%files"
  spec.puts "%defattr(-,root,root,-)"
  spec.puts "/etc/maven/fragments/%{name}"
  spec.puts "%{_javadir}/%{name}-%{version}.jar"
  spec.puts "%{_javadir}/%{name}.jar"
  spec.puts "%doc"
  spec.puts "%files javadoc"
  spec.puts"%defattr(-,root,root,-)"
  spec.puts"%{_javadocdir}/%{name}"
  spec.puts ""
  spec.puts ""
  spec.puts "%changelog"
  spec.puts "* Sun Apr 03 2010 Adam Young ayoung@redhat.com"
  spec.puts "- Specfile Created by pom2rpm by Adam Young ayoung@redhat.com "
  spec.puts ""

end

#main program below

specRegex = /([a-zA-Z0-9\-]*)-[0-9]*.*\.pom/

ARGV.each { |arg| 
  pomname=File.basename(arg)
  specRegex =~ pomname
  specname = "#{$1}.spec"
  puts "#{arg} will gen  #{specname}"   

  if File.file?(specname)
    puts "Renaming #{specname} to #{specname}.bak"
    File.rename(specname, "#{specname}.bak");
  end

  spec = File.new(specname, 'w')
  write_spec(spec, "#{arg}") 
}



