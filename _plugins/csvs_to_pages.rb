module Jekyll
  require 'csv'

  class ApiPage < Page    
    def initialize(site, base, dir, template, filename)      
      @site = site
      @base = base
      @dir = dir
      @name = filename   
      puts filename   
      
      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), template)
      self.data[filename] = ""
    end
  end

  class ApiGenerator < Jekyll::Generator
    safe true

    def generate(site)
      # set directory csv data will come from
      dir = '_data'
      base = File.join(site.source, dir)
      # get all csv files in data directory
      file_names = Dir.chdir(base) { Dir["*.csv"] }
      
      csv_data = Hash.new
      file_names.each do |filename|
        path = File.join(site.source, dir, filename)
        sanitized_filename = sanitize_string(base_filename(filename))      

        file_data = CSV.read(path, :headers => true)
        data = Hash.new
        data['keys'] = file_data.headers.map { |key|
          sanitize_string(key)
        }
        puts "keys = #{data['keys']}"

        data['content'] = file_data.to_a[1..-1]

        data['keys'].each do |key|
          if key
            site.pages << ApiPage.new(site, site.source, 
              File.join('api', sanitized_filename),
              "column_request.json", "#{key}.json")
            site.pages << ApiPage.new(site, site.source, 
              File.join('api', sanitized_filename),
              "column_request.html", "#{key}.html")            
          end
        end

        data['content'].each do |row|
          row.each_index do |index|
            unless row[index].nil?
              site.pages << ApiPage.new(site, site.source, 
              File.join('api', sanitized_filename, sanitize_string(data['keys'][index])),
              "element_request.json", "#{ sanitize_string(row[index]) }.json")  

              site.pages << ApiPage.new(site, site.source, 
              File.join('api', sanitized_filename, sanitize_string(data['keys'][index])),
              "element_request.html", "#{ sanitize_string(row[index]) }.html")  
            end
          end
        end        

        # create json file
        site.pages << ApiPage.new(site, site.source, 'api', 
          "root_request.json", "#{sanitized_filename}.json")              

        # create html file
        site.pages << ApiPage.new(site, site.source, 'api', 
          "root_request.html", "#{sanitized_filename}.html")
      end
    end

    # this can be cleaned up into one or two regex's
    def sanitize_string(input)
      unless input.nil?
        input = input.downcase
        input = input.gsub(/[^\w\s_-]+/, '-')
        input = input.gsub(/(^|\b\s)\s+($|\s?\b)/, '\\1\\2')
        input = input.gsub(/\s+/, '-')
        input = input.gsub(/.,?!/, '-')
        input = input.gsub(/\//, '-')
        input = input.gsub(/\\/, '-')        
        input = input.gsub(/\-+/, '-')
        input = input[0..50]       
        input = input.gsub(/\-$/,'')
      else
        ""
      end
    end
    
    def base_filename(name)
      extn = File.extname(name)
      name = File.basename(name, extn)
    end

  end
end