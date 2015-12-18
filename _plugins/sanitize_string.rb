module Jekyll
  module SanitizeStringFilter
    def sanitize_string(input)
    	unless input.nil?
        input = input.gsub(/[\s+-]/, "-")
        input = input.gsub(/[^\w-]/, "-")
        input = input.gsub(/\-+/, '-');
        input = input.downcase
        input = input.slice(0, 51)
	    end
    end
  end
end

Liquid::Template.register_filter(Jekyll::SanitizeStringFilter)