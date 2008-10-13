require 'lib/html'
require 'lib/prince'

module PDF
  
  class Book
    attr_reader :book_location, :output_path, :bookname, :code_css, :code_lang
    
    # Initializer
    #
    # initialize sets up our book location and our book output
    # it will create our output_path folder if it doesn't exist
    #
    # If you have not created the HTML version of the book
    # look at the options in the HTML::Book class. The options
    # here, will be passed to HTML::Book class to create the 
    # HTML book if it doesn't exist.
    #
    # @param {:book_location => "where the root of the book is located",
    #         :bookname      => "The name of the book"}
    #
    def initialize(options={})
      @options        = options
      @book_location  = options["book-location"] || File.join(Dir.pwd, "book")
      @bookname       = options["bookname"]      || "MyBook"
      @code_css       = options["code-css"]      || "lazy"
      create_html_book
    end
    
    
    # PDF::Book.make
    #
    # Class method for a single call to create a PDF Book
    #
    # @params are the same as the initialize method above
    #
    def self.make(options={})
      book = PDF::Book.new(options)
      book.create
    end
    
    
    # Creates our PDF Book
    #
    def create
      prince  = Prince.new
      prince.add_style_sheets(merge_stylesheets)

      File.open("#{File.join(@book_location, 'output', @bookname)}.pdf", 'w') do |f|
        f.puts prince.pdf_from_string( 
          File.new( 
            File.join(@book_location, "output/#{@bookname}.html") 
          ).read 
        )
      end
    end

      
    # Grab all the stylesheets from the stylesheets folder
    #
    # If not passed, it assumes you are in the directory above 
    # the book root
    #
    # Searches the stylesheet directory, where the book layout 
    # template (book/) is located and adds all stylesheets, 
    # in order. 
    #
    # book_location =>  The Location of where the Book Layout lives  -- String / File Path
    #
    # For ordering, make sure to name your stylesheets like:
    # 001_reset.css
    # 002_base.css
    # 003_typeography.css
    #
    # Returns an array of stylesheets within
    #
    def merge_stylesheets
      stylesheets = File.join(@book_location, "layout/stylesheets")
      sheets      = Array.new
      
      Dir["#{stylesheets}/*.css"].sort.each { |css| sheets << css }
      sheets << File.join(stylesheets, "highlight/#{@code_css}.css")
      return sheets
    end
    
    
    # create_html_book
    #
    # Creates the HTML book if it doesn't exist
    #
    def create_html_book
      HTML::Book.make(@options) unless File.exists?(File.join(@book_location, "output/#{@bookname}.html"))
    end
    
  end
  
end