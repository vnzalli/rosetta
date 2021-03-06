#!/usr/bin/env ruby
$LOAD_PATH << File.expand_path('./lib')
#gems
require 'rspec'
require 'find'
require 'etc'
# libs
require 'determineos'
require 'messages'
require 'variables'
require 'cmd'

os_select = Determineos.new
os_decided = os_select.os.to_s
commands = []
ARGV.each {|arg| commands << arg}
rc_list_txt_fin = []
group_list_txt_fin = []
user_list_txt_fin = []
filetype_ary = []

#####################
# Debian and Ubuntu #
#####################
if os_decided == "nix" && File.exist?(Variables.package_deb)
	puts Messages.deb

	if ARGV[1] == Variables.opt_sel[0]

		unless !File.exist?(Variables.package_deb2)
			puts Messages.apt_present
			system(Cmd.apt_file_inst)
		end
		unless File.exist?(Variables.package_cc)
			puts Messages.chkconfig_present
			system(Cmd.apt_file_inst_chk)
		end

		f = File.open(Messages.fs_find_file+Variables.fs_ext[0], "w")
		Find.find('/'){|path| f.write(path + "\n") != ((path.start_with? ".") || (path.start_with? "/dev/") || (path.start_with? "/proc/") || (path.start_with? "/sys/") || (path.start_with? "/root/") || (path.start_with? "/usr/share/doc/") || (path.start_with? "/var/lib/yum") || (path.start_with? "/home"))}
		f.close()
		puts Messages.file_footprint_done
		
		# Network services
		puts ""
		puts Messages.net_stat_txt
		system(Cmd.net_stat+Messages.output_file_net_stat+Variables.fs_ext[0])
		puts Messages.net_stat_txt_fin+Variables.fs_ext[0]+"."
		
		# Group information
		puts ""
		puts Messages.group_list_txt_fp
		Etc.group {|g| group_list_txt_fin << g.name + ": " + g.mem.join(', ') + "\n"}
		grp = File.open(Messages.output_file_group+Variables.fs_ext[0], "w")
		group_list_txt_fin.each {|grp_list| grp.write(grp_list)}
		grp.close()
		puts Messages.group_list_txt+Variables.fs_ext[0]+"."
		
		# User information
		puts ""
		puts Messages.user_list_txt_fp
		Etc.passwd {|u| user_list_txt_fin << u.name + " = " + u.gecos + "\n"}
		usr = File.open(Messages.output_file_user+Variables.fs_ext[0], "w")
		user_list_txt_fin.each { |usr_list| usr.write(usr_list)}
		puts Messages.user_list_txt+Variables.fs_ext[0]+"."
		
		# CHKCONFIG Information
		puts ""
		puts Messages.chk_config_txt
		system(Cmd.chk_config+Messages.output_file_chk_config+Variables.fs_ext[0])
		puts Messages.chk_config_txt_fin+Variables.fs_ext[0]+"."

	elsif ARGV[1] == Variables.opt_sel[1]
		puts Messages.post_fs_footprint 
		# Filesystem footprinting
		puts ""
		f = File.open(Messages.fs_find_file+Variables.fs_ext[1], "w")
		Find.find('/'){|path| f.write(path + "\n") != ((path.start_with? ".") || (path.start_with? "/dev/") || (path.start_with? "/proc/") || (path.start_with? "/sys/") || (path.start_with? "/root/") || (path.start_with? "/usr/share/doc/") || (path.start_with? "/var/lib/yum") || (path.start_with? "/home"))}
		f.close()
		puts Messages.fs_footprint_fin+Variables.fs_ext[1]+"."

		# Network services
		puts ""
		puts Messages.net_stat_txt
		system(Cmd.net_stat+Messages.output_file_net_stat+Variables.fs_ext[1])
		puts Messages.net_stat_txt_fin+Variables.fs_ext[0]+"."
		
		# Group information
		puts ""
		puts Messages.group_list_txt_fp
		Etc.group {|g| group_list_txt_fin << g.name + ": " + g.mem.join(', ') + "\n"}
		grp = File.open(Messages.output_file_group+Variables.fs_ext[1], "w")
		group_list_txt_fin.each {|grp_list| grp.write(grp_list)}
		grp.close()
		puts Messages.group_list_txt+Variables.fs_ext[1]+"."

		# User information
		puts ""
		puts Messages.user_list_txt_fp
		Etc.passwd {|u| user_list_txt_fin << u.name + " = " + u.gecos + "\n"}
		usr = File.open(Messages.output_file_user+Variables.fs_ext[1], "w")
		user_list_txt_fin.each { |usr_list| usr.write(usr_list)}
		puts Messages.user_list_txt+Variables.fs_ext[1]+"."
		
		# CHKCONFIG Information
		puts ""
		puts Messages.chk_config_txt
		system(Cmd.chk_config+Messages.output_file_chk_config+Variables.fs_ext[1])
		puts Messages.chk_config_txt_fin+Variables.fs_ext[1]+"."

	else ARGV[1] == Variables.opt_sel[2]
		puts Messages.post_a_compare
		Variables.name_files.each do |naming|
			f1 = IO.readlines(Variables.workingdir + "/" + naming + ".pre").map(&:chomp)
			f2 = IO.readlines(Variables.workingdir + "/" + naming + ".post").map(&:chomp)
		File.open(Variables.workingdir + "/" + naming + ".out", "w"){ |f| f.write((f2 - f1).join("\n")) }
		end
		
		puts Messages.prob_config

		IO.readlines(Variables.workingdir + "/filesystem.out").map(&:chomp).each do |filetype|
			if filetype =~ /\.conf/
				filetype_ary << filetype
			elsif filetype =~ /\.properties/
				filetype_ary << filetype
			elsif filetype =~ /\.config/
				filetype_ary << filetype
			elsif filetype =~ /\.xml/
				filetype_ary << filetype
			elsif filetype =~ /\.json/
				filetype_ary << filetype
			end
		File.open(Messages.output_filetype_ary+Variables.fs_ext[1], "w"){ |f| f.write((filetype_ary).join("\n"))}
		end
		puts Messages.post_analysis
	end


######################
# Red Hat and CentOS #
######################
elsif os_decided == "nix" && File.exist?(Variables.package_rh)
	if ARGV[1] == Variables.opt_sel[0]
		puts Messages.rh
		
		# Filesystem footprinting
		puts ""
		puts Messages.fs_footprint
		#Cmd.fs_open
		#Cmd.exclude_and_write
		#Cmd.close_file
		f = File.open(Messages.fs_find_file+Variables.fs_ext[0], "w")
		Find.find('/'){|path| f.write(path + "\n") != ((path.start_with? ".") || (path.start_with? "/dev/") || (path.start_with? "/proc/") || (path.start_with? "/sys/") || (path.start_with? "/root/") || (path.start_with? "/usr/share/doc/") || (path.start_with? "/var/lib/yum") || (path.start_with? "/home"))}
		f.close()
		puts Messages.file_footprint_done
		
		# Network services
		puts ""
		puts Messages.net_stat_txt
		system(Cmd.net_stat+Messages.output_file_net_stat+Variables.fs_ext[0])
		puts Messages.net_stat_txt_fin+Variables.fs_ext[0]+"."
		
		# Group information
		puts ""
		puts Messages.group_list_txt_fp
		Etc.group {|g| group_list_txt_fin << g.name + ": " + g.mem.join(', ') + "\n"}
		grp = File.open(Messages.output_file_group+Variables.fs_ext[0], "w")
		group_list_txt_fin.each {|grp_list| grp.write(grp_list)}
		grp.close()
		puts Messages.group_list_txt+Variables.fs_ext[0]+"."
		
		# User information
		puts ""
		puts Messages.user_list_txt_fp
		Etc.passwd {|u| user_list_txt_fin << u.name + " = " + u.gecos + "\n"}
		usr = File.open(Messages.output_file_user+Variables.fs_ext[0], "w")
		user_list_txt_fin.each { |usr_list| usr.write(usr_list)}
		puts Messages.user_list_txt+Variables.fs_ext[0]+"."
		
		# CHKCONFIG Information
		puts ""
		puts Messages.chk_config_txt
		system(Cmd.chk_config+Messages.output_file_chk_config+Variables.fs_ext[0])
		puts Messages.chk_config_txt_fin+Variables.fs_ext[0]+"."
		
	elsif ARGV[1] == Variables.opt_sel[1]
		puts Messages.post_fs_footprint 
		# Filesystem footprinting
		puts ""
		f = File.open(Messages.fs_find_file+Variables.fs_ext[1], "w")
		Find.find('/'){|path| f.write(path + "\n") != ((path.start_with? ".") || (path.start_with? "/dev/") || (path.start_with? "/proc/") || (path.start_with? "/sys/") || (path.start_with? "/root/") || (path.start_with? "/usr/share/doc/") || (path.start_with? "/var/lib/yum") || (path.start_with? "/home"))}
		f.close()
		puts Messages.fs_footprint_fin+Variables.fs_ext[1]+"."

		# Network services
		puts ""
		puts Messages.net_stat_txt
		system(Cmd.net_stat+Messages.output_file_net_stat+Variables.fs_ext[1])
		puts Messages.net_stat_txt_fin+Variables.fs_ext[0]+"."
		
		# Group information
		puts ""
		puts Messages.group_list_txt_fp
		Etc.group {|g| group_list_txt_fin << g.name + ": " + g.mem.join(', ') + "\n"}
		grp = File.open(Messages.output_file_group+Variables.fs_ext[1], "w")
		group_list_txt_fin.each {|grp_list| grp.write(grp_list)}
		grp.close()
		puts Messages.group_list_txt+Variables.fs_ext[1]+"."

		# User information
		puts ""
		puts Messages.user_list_txt_fp
		Etc.passwd {|u| user_list_txt_fin << u.name + " = " + u.gecos + "\n"}
		usr = File.open(Messages.output_file_user+Variables.fs_ext[1], "w")
		user_list_txt_fin.each { |usr_list| usr.write(usr_list)}
		puts Messages.user_list_txt+Variables.fs_ext[1]+"."
		
		# CHKCONFIG Information
		puts ""
		puts Messages.chk_config_txt
		system(Cmd.chk_config+Messages.output_file_chk_config+Variables.fs_ext[1])
		puts Messages.chk_config_txt_fin+Variables.fs_ext[1]+"."
		
	else ARGV[1] == Variables.opt_sel[2]
		puts Messages.post_a_compare
		Variables.name_files.each do |naming|
			f1 = IO.readlines(Variables.workingdir + "/" + naming + ".pre").map(&:chomp)
			f2 = IO.readlines(Variables.workingdir + "/" + naming + ".post").map(&:chomp)
		File.open(Variables.workingdir + "/" + naming + ".out", "w"){ |f| f.write((f2 - f1).join("\n")) }
		end

		puts Messages.prob_config

		IO.readlines(Variables.workingdir + "/filesystem.out").map(&:chomp).each do |filetype|
			if filetype =~ /\.conf/
				filetype_ary << filetype
			elsif filetype =~ /\.properties/
				filetype_ary << filetype
			elsif filetype =~ /\.config/
				filetype_ary << filetype
			elsif filetype =~ /\.xml/
				filetype_ary << filetype
			elsif filetype =~ /\.json/
				filetype_ary << filetype
			end
		File.open(Messages.output_filetype_ary+Variables.fs_ext[1], "w"){ |f| f.write((filetype_ary).join("\n"))}
		end

		puts Messages.post_analysis
	end
	

#####################
# Microsoft Windows #
#####################
elsif os_decided == "windows"
	if ARGV[1] == Variables.opt_sel[0]
		puts Messages.ms

		# Filesystem footprinting
		puts ""
		puts Messages.fs_footprint
		f = File.open(Messages.fs_find_file+Variables.fs_ext[0], "w")
		Find.find('/'){|path| f.write(path + "\n") != ((path.start_with? ".") || (path.start_with? "/dev/") || (path.start_with? "/proc/") || (path.start_with? "/sys/") || (path.start_with? "/root/") || (path.start_with? "/usr/share/doc/") || (path.start_with? "/var/lib/yum") || (path.start_with? "/home"))}
		f.close()
		puts Messages.file_footprint_done

		# Network services
		puts ""
		puts Messages.net_stat_txt
		Cmd.netstat_cmd
		puts Messages.net_stat_txt_fin+Variables.fs_ext[0]+"."

		# Group information
		puts ""
		puts Messages.group_list_txt_fp
		Cmd.wmic_grp
		puts Messages.group_list_txt+Variables.fs_ext[0]+"."

 		# User information
		puts ""
		puts Messages.user_list_txt_fp
		Cmd.wmic_usr
		puts Messages.user_list_txt+Variables.fs_ext[0]+"."

		# CHKCONFIG Information
		puts ""
		puts Messages.chk_config_txt
		Cmd.wmic_srv
		puts Messages.chk_config_txt_fin+Variables.fs_ext[0]+"."

=begin		
		# Windows Registry
		Win32::Registry::HKEY_CURRENT_USER.open('SOFTWARE') do |reg|
		reg.each_value do |name, type, data|        # Enumerate values
	    reg.each_key { |key, wtime| ... }                # Enumerate subkeys
=end

	elsif ARGV[1] == Variables.opt_sel[1]
		puts Messages.post_fs_footprint

		# Filesystem footprinting
		puts ""
		puts Messages.fs_footprint
		f = File.open(Messages.fs_find_file+Variables.fs_ext[1], "w")
		Find.find('/'){|path| f.write(path + "\n") != ((path.start_with? ".") || (path.start_with? "/dev/") || (path.start_with? "/proc/") || (path.start_with? "/sys/") || (path.start_with? "/root/") || (path.start_with? "/usr/share/doc/") || (path.start_with? "/var/lib/yum") || (path.start_with? "/home"))}
		f.close()
		puts Messages.fs_footprint_fin+Variables.fs_ext[1]+"."

		# Network services
		puts ""
		puts Messages.net_stat_txt
		Cmd.netstat_cmd
		puts Messages.net_stat_txt_fin+Variables.fs_ext[1]+"."

		# Group information
		puts ""
		puts Messages.group_list_txt_fp
		Cmd.wmic_grp
		puts Messages.group_list_txt+Variables.fs_ext[1]+"."

		# User information
		puts ""
		puts Messages.user_list_txt_fp
		Cmd.wmic_usr
		puts Messages.user_list_txt+Variables.fs_ext[1]+"."

		# CHKCONFIG Information
		puts ""
		puts Messages.chk_config_txt
		Cmd.wmic_srv
		puts Messages.chk_config_txt_fin+Variables.fs_ext[1]+"."
		
		#Windows Registry

	else ARGV[1] == Variables.opt_sel[2]
		puts Messages.post_a_compare
		Variables.name_files.each do |naming|
			f1 = IO.readlines(Variables.workingdir + "/" + naming + ".pre").map(&:chomp)
			f2 = IO.readlines(Variables.workingdir + "/" + naming + ".post").map(&:chomp)
		File.open(Variables.workingdir + "/" + naming + ".out", "w"){ |f| f.write((f2 - f1).join("\n")) }
		end
		puts Messages.post_analysis
	end

#
# Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\') do |reg|
# reg.each_value { |name, type, data| ... }        # Enumerate values
# reg.each_key { |key, wtime| ... }                # Enumerate subkeys
# end
else
  puts Messages.opt_sel_err
end