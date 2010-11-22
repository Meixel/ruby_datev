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



module DatevParser
  
  
  
  class Edxxxxx
    
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
    
    
    
    
    attr_reader :transactions

    
    def initialize file_name #initialize object given an EDxxxxx file name. Loads content, removes end-of-block whitespace and parses the file
      
      content=load_file file_name
      blocks=self.class.make_blocks content, 256
      merged=self.class.merge_blocks blocks
      
      @transactions = Transaction.parse_all merged
      
      
    end
    
    
    
    
    
    private
    
    def load_file file_name
      ff=File.new(file_name, 'r')
      content=ff.read
      ff.close

      content
      
    end
    
    
  end
  
  
end
