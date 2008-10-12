%w[uri net/http fileutils lib/generate].each { |r| require r }

# Fetch
#
# What if I don't want to write a book, but instead see a book that 
# someone else is working on and would like to format it better so
# I can read it myself or produce it? 
#
# Secondly, how are we gonna handle the code blocks because the author
# hasn't set up his book as we need it to be for code blocks? 
#
# 1st problem, let's get the book and allow the user to get it from
# anywhere, as long as there is some URL.
#
# 2nd problem, code highlighting - let the copier do this.

module Fetch
  
  class Book
    
    # init
    #
    # Arguments Required
    #
    #   :url      => the url to where the book is located
    #   :type     => markdown or textile (whatever extension is used: mdown, etc.)
    #
    # Optional Arguments
    #
    #   :location => where to install this
    #
    def initialize(options)
      @url      = options[:url]
      @location = File.expand_path(options[:location]) || Dir.pwd
      @type     = options[:type]
      @basename = File.basename(@url).split('.').first
    end
    
    
    # From
    #
    # Convience class method
    # Fetch::Book.from(options)
    #
    def self.from(options)
      book = Fetch::Book.new(options)
      book.generate_book
      book.pull
      book.cleanup
    end
    
    
    # Pull
    #
    # We're only going to support git at the moment because
    # that is what I use.
    #
    def pull
      FileUtils.cd(Dir.pwd)
      `git clone #{@url}`

      Dir.glob( File.join(@basename, '**', "*#{@type}") ).each do |chapter|
        FileUtils.mv "#{chapter}", "#{@location}/book/layout/chapters/"
      end
      
    end
    
    
    # Clean Up
    #
    # Clean up after ourselves
    #
    def cleanup
      FileUtils.rm_rf( File.join(Dir.pwd, @basename) )
    end
    
    
    # Write
    #
    # Generates the Book Layout.
    #
    def generate_book
      Generate::Book.now(@location)
    end
    
  end
  
end