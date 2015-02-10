# Copyright (C) 2012 Andy Meneely
#
# Code and Interactive churn script for Git
#
# Contributors: Andy Meneely

require "interactive_churn/version"
require 'set'
require 'oj'
require 'csv'

module InteractiveChurn
  class << self
    def get_churn_data(rev, filename)    
      # input is the revision hash and the file - assume it's correct
      revision = rev
      file = filename

      # initialize our counts
      lines_added = 0
      lines_deleted = 0
      lines_deleted_self = 0
      lines_deleted_other = 0
      author = nil
      authors_affected = Set.new 

      #Use git log to show only that one file at the one revision, no diff context!
      patch_text = `git log -p --unified=0 -1 #{revision} -- #{file}`
      patch_text.each_line { | line |
        if line.start_with? "Author: " 
          author = line[8..line.index(' <')].chomp.strip # store just the author name
        elsif line.start_with? "@@"
          #parsing the @@ -a,b +c,d @@
          lines_deleted_start = line.split(/[ ]+/)[1].split(/[,]+/)[0] #a 
          lines_deleted_num = line.split(/[ ]+/)[1].split(/[,]+/)[1] # b 
          lines_added_num = line.split(/[ ]+/)[2].split(/[,]+/)[1] #d

          #lines_deleted_start isn't ACTUALLy negative...
          lines_deleted_start = lines_deleted_start.to_i * -1

          # The _num vars are 1 if they were nil, for the ones of this format:
          # @@ -a +c @@ (which implies a 1)
          lines_deleted_num ||= 1  
          lines_added_num ||= 1 
          # ...and they need to be integers
          lines_deleted_num = lines_deleted_num.to_i
          lines_added_num = lines_added_num.to_i

          # Ok, add to the totals now
          lines_added += lines_added_num
          lines_deleted += lines_deleted_num

          #calculate lines to look at for the git blame    
          if lines_deleted_num == 0
            line_end = lines_deleted_start
          else
            line_end = lines_deleted_start + lines_deleted_num-1
          end
          
          # Run blame, once for this particular file, storing as we go
          # * Leading up to the revision prior to that (hence the ^) 
          # * -l for showing long revision names 
          blame = Hash.new
          blame_text = `git blame -l -L #{lines_deleted_start},#{line_end} #{revision}^ -- #{file}`
          blame_text.each_line do | blame_line | 
            #blame_line = blame_line.force_encoding("iso-8859-1")
            line_number=blame_line[/[\d]+\)/].to_i
            blame[line_number] = blame_line
          end

          # Look it up in our blame hash
          if lines_deleted_num > 0 then
            num = lines_deleted_start
            begin	
              #does the blame line have the author of this commit?
              if blame[num].include?(author) 
                lines_deleted_self+=1
              else
                lines_deleted_other+=1
                author_affected = blame[num].split(/[(]+/)[1].split(/[\d]{4}/)[0].strip
                  authors_affected << author_affected	
              end	
              num+=1
            end until num > (lines_deleted_start + lines_deleted_num - 1)
          end
        end 
      }

      CSV.open("../churnlog.csv", "a+") do |row|
        row << [revision, file, lines_added + lines_deleted, lines_added, lines_deleted, lines_deleted_self, \
                lines_deleted_other ,authors_affected.size,authors_affected.to_a ]
      end
    end

    def get_data()
      valid_extns = ['.rb','.h','.cc','.js','.cpp','.gyp','.py','.c','.make','.sh','.S''.scons','.sb','Makefile']
     
      # create csv file with headers
      CSV.open('../churnlog.csv','w+') do |headers|
      headers << ["commit","filepath","total_churn","lines_added", "lines_deleted","lines_deleted_self", \
                   "lines_deleted_other","num_devs_affected","devs_affected"]
      end
     
      #get list of revisions
      revisions_text = `git log -10 --pretty=format:"%H"`
      puts "Starting to iterate over revisions at " + `date`
      
      #loop over every revision, get files, do get_churn on files for interactive churn data
      revisions_text.each_line do |rev|
        rev = rev.strip
        git_files = `git show --pretty="format:" --name-only #{rev}`
        git_files.each_line do |filename|
          filename = filename.strip
          unless filename.empty?
            valid_extns.each do |extn|
              if filename.end_with?(extn)
                get_churn_data rev, filename
              end
            end
          end
        end
      end
    end

  end
end 


