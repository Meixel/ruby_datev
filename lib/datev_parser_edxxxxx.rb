require 'rubygems'
require 'ruby-debug'

class Object
  def metaclass
    class << self
      self
    end
  end
end

# need foldl function
class Array
  
  def foldl neutral=0, &block
    
    unless block_given?
      
      if neutral == 0
        block = proc do |a,b|
          a+b
        end
      elsif neutral == 1
        block = proc do |a,b|
          a*b
        end
      elsif neutral == ""
        block = proc do |a,b|
          a+b
        end
      else
        block = proc do |a,b|
          neutral
        end
      end
    end
      
    
    res= neutral
    
    self.each do |a|
      
      res=block[res,a]
      
    end
    
    res
  end
  
end



module Datev
  
  class Parser
    
    # chops string in to blocks of length 'length=256', as per definition of datev format EDxxxxx
    def self.make_blocks(str ,length=@@block_length)
      total_length= str.length
      length = length.to_i unless length.is_a?(Integer)

      num_blocks = total_length/length

      ranges=(0...num_blocks).to_a.map do |a|
        a*length
      end.map do |a|
        (a...a+length)
      end

      ranges.map do |r|
        str[r]
      end
    end

    # chops of trailing \000 characters of each block and returns merged string
    def self.merge_blocks (str_blocks)
      #check that every block ends in \000 x 6
      end_zeros=str_blocks.map do |a|
        a[-6..-1]
      end.join

      raise "Something wrong with the zero padding at the end of the blocks!" unless end_zeros.map(&:to_i).map(&:abs).foldl == 0


      content = str_blocks.map do |a|
        a[0...-6]
      end.join

    end




    protected

    def self.load_file file_name
      ff=File.new(file_name, 'r')
      content=ff.read
      ff.close

      content

    end


    
  end
  
  
  
  
  class Edxxxxx < Parser
    
    #Datev file block length is
    @@block_length = 256
    
    #class Transaction contains everythin to do with the transaction part of the datev file
    class Transaction < Hash
      #extended alpha-numeric regex
      an="[A-Za-z0-9\\:\\$\\%\\&\\*\\-\\_\\/ ]"
    
      #define the parts of the transaction regex
      @@transaction_regex_parts = {
        :umsatz_vorzeichen => '(\+|\-)',
        :umsatz => '(\d*)', 
        :buchungsschluessel => '(?:l(\d{1,2}))?', 
        :gegenkonto => 'a(\d{1,9})', 
        :belegfeld_1 => '(?:\xBD(\w{1,12})\x1C)?', 
        :belegfeld_2 => '(?:\xBE(\w{1,12})\x1C)?', 
        :datum => 'd(\d{4,4})', 
        :konto => 'e(\d{1,9})', 
        :kost_1 => '(?:\xBB(\w{1,8})\x1C)?', 
        :kost_2 => '(?:\xBC(\w{1,8})\x1C)?', 
        :kost_menge => '(?:k(\d{1,11}))?', 
        :skonto => '(?:h(\d{1,10}))?', 
        :buchungstext => "(?:\\x1E(#{an}{1,30})\\x1C)?", 
        :eu_id => '(?:\xBA(\w{2,2}\w{1,13})\x1C)?', 
        :eu_steuersatz => '(?:j(\d{1,4}))?',
        :waehrungs_kz_umsatz => '(?:\xB3(\w{1,3})\x1C)', 
        :basiswaehrungsbetrag => '(?:m(\d{1,12}))?', 
        :waehrungs_kz_basiswaehrung => '(?:\xB4(\w{1,3})\x1C)?', 
        :waehrungskurs => '(?:n(\d{1,11}))?', 
        :reserviert_1 => '(?:g(\w{1,12}))?', 
        :reserviert_2 => '(?:\xB0(\w{1,20})\x1C)?', 
        :reserviert_3 => '(:?\xB1(\w{1,20})\x1C)?', 
        :reserviert_4 => '(:?\xB2(\w{1,20})\x1C)?', 
        :reserviert_5 => '(?:f(\d{1,11}))?', 
        :reserviert_6 => '(?:p(\d{1,3}))?', 
        :reserviert_7 => '(?:q(\d{1,12}))?y'
      }
      def self.transaction_regex_parts
        @@transaction_regex_parts
      end
      def self.transaction_regex_parts= trp
        @@transaction_regex_parts = trp
      end
    
    
    
      #order in which the transaction_regex/transaction_string_template is built
    
      @@transaction_parts_order = [
      :umsatz_vorzeichen, 
      :umsatz,  
      :buchungsschluessel,  
      :gegenkonto,  
      :belegfeld_1,  
      :belegfeld_2,  
      :datum,  
      :konto,  
      :kost_1,  
      :kost_2,  
      :kost_menge,  
      :skonto,  
      :buchungstext,  
      :eu_id,  
      :eu_steuersatz, 
      :waehrungs_kz_umsatz,  
      :basiswaehrungsbetrag,  
      :waehrungs_kz_basiswaehrung,  
      :waehrungskurs,  
      :reserviert_1,  
      :reserviert_2,  
      :reserviert_3,  
      :reserviert_4,  
      :reserviert_5,  
      :reserviert_6,  
      :reserviert_7]
    
      def self.transaction_parts_order
        @@transaction_parts_order
      end
      def self.transaction_parts_order= tpo
        @@transaction_parts_order = tpo
      end
    
      #makes the transaction regex out of the parts and stores it in a class variable
      @@transaction_regex=''
      def self.make_transaction_regex
        regex_string = @@transaction_parts_order.map do |tp|
          @@transaction_regex_parts[tp]
        end.join
        
        @@transaction_regex = Regexp.new regex_string
      end
    
      make_transaction_regex
    
      #class methods to override the regex generation, at own risk
      def self.transaction_regex
        @@transaction_regex
      end
      def self.transaction_regex= tr
        @@transaction_regex=tr
      end
      
      #takes a string and look for the first transaction
      def self.parse_one str
        match = @@transaction_regex.match str
        
        transaction=Transaction[*@@transaction_parts_order.zip(match[1..-1]).flatten] unless match.nil?
        
        rest_str=""
        rest_str="#{match.pre_match}#{match.post_match}" unless match.nil?
        #debugger
        [transaction, rest_str]

      end
      
      def self.parse_all str
        
        transaction, rest_string = *parse_one(str)
        
        transactions=[]
        
        until transaction.nil?
          transactions=transactions+[transaction]
          transaction, rest_string = *parse_one(rest_string)
          
          #debugger
        end
        
        transactions
      end
      
    end #end of class Transaction
    
    
    # a class header to parse the header
    class Header < Hash
      
      # header is read using ranges, because the lengths of the data set are fixed
      @@header_ranges ={
        :datentraegernummer => 3...6,
        :anwendungsnummer => 6...8,
        :namenskuerzel => 8...10,
        :beraternummer => 10...17,
        :mandantennummer => 17...22,
        :abrechnungsnummer => 22...28,
        :datum_von => 28...34,
        :datum_bis => 34...40,
        :primanota_seite => 40...43,
        :passwort => 43...47,
        :anwendungsinfo => 47 ...63,
        :input_info => 63...79}
        
      def self.header_ranges
        @@header_ranges
      end
      def self.header_ranges= hr
        @@header_ranges = hr
      end
      
        
      @@header_ranges_order=[
        :datentraegernummer, 
        :anwendungsnummer, 
        :namenskuerzel, 
        :beraternummer, 
        :mandantennummer, 
        :abrechnungsnummer, 
        :datum_von, 
        :datum_bis, 
        :primanota_seite, 
        :passwort, 
        :anwendungsinfo, 
        :input_info]
        
      def self.header_ranges_order
        @@header_ranges_order
      end
      def self.header_ranges_order= hro
        @@header_ranges_order= hro
      end
      
      #this is the structure to be used to extract the information
      def self.make_header_range_extractor
        @@header_range_extractor= @@header_ranges_order.map do |hr|
          @@header_ranges[hr]
        end
      end
      
      make_header_range_extractor
      
      #getter and setter at own risk
      def self.header_range_extractor
        @@header_range_extractor
      end
      def self.header_range_extractor= hre
        @@header_range_extractor= hre
      end
      
      # parser, can take the whole file or only the first block. only looks at first 80 bytes anyway
      def self.parse_all str
        values = @@header_range_extractor.map do |hr|
          str[hr]
        end
        
        Header[*@@header_ranges_order.zip(values).flatten]
        
      end
      
        
      
    end # end of class Header
    
    #class Version to parse the version information
    class Version < Hash
      @@version_offset=80-1
      @@version_ranges ={
        :versionsnummer => 2..2,
        :aufgezeichnete_sachkontonummernlaenge => 4..4,
        :gespeicherte_sachkontonummernlaenge => 6..6,
        :produktkuerzel => 8...12
      }
      
      
      @@version_ranges_order =[
      :versionsnummer,
      :aufgezeichnete_sachkontonummernlaenge,
      :gespeicherte_sachkontonummernlaenge,
      :produktkuerzel
      ]
      
      def self.make_version_range_extractor
        @@version_range_extractor = @@version_ranges_order.map do |vr|
          r=@@version_ranges[vr]
          f= r.first + @@version_offset
          l= r.last + @@version_offset
          
          if r.exclude_end?
            f...l
          else
            f..l
          end
          
        end
      end
      
      make_version_range_extractor
      
      #parse the first block of an EDxxxxx file
      def self.parse_all str    
        values = @@version_range_extractor.map do |vr|
          str[vr]
        end
          
        Version[*@@version_ranges_order.zip(values).flatten]
      end
        
      
      
    end # end of class Version
    
    
    
    
    
    
    
    
    attr_reader :transactions, :header, :version

    
    def initialize file_name #initialize object given an EDxxxxx file name. Loads content, removes end-of-block whitespace and parses the file
      
      content=self.class.load_file file_name
      blocks=self.class.make_blocks content, 256
      merged=self.class.merge_blocks blocks
      
      @header = Header.parse_all blocks.first
      @version = Version.parse_all blocks.first
      @transactions = Transaction.parse_all merged
      
      
    end
    
      
    
  end # end of class Edxxxxx
  
  
  class Ev01 < Parser
    
    
    
    
    
  end
  
  
  
  
  
  
  

  
end
