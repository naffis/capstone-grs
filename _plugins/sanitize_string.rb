module Jekyll
  module SanitizeStringFilter
    def sanitize_string(input)
    	unless input.nil?
        input = input.gsub(/[\s+-]/, "-")
        input = input.gsub(/[^\w-]/, "-")
        input = input.downcase
	    end
    end
  end
end

Liquid::Template.register_filter(Jekyll::SanitizeStringFilter)