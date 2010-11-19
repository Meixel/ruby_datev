
#
def load_ed fn
  ff=File.new(fn, 'r')
  content=ff.read
  ff.close
  
  content
  
end

def initit
  fn= '../datev/ED00001'
  b=load_ed fn
  
  c=DatevParserEdxxxxx.make_blocks b
  d=DatevParserEdxxxxx.merge_blocks c
  
end

class Object
  def metaclass
    class << self
      self
    end
  end
end

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



class DatevParserEdxxxxx
  
  def self.make_blocks(str ,length=256)
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

an="[A-Za-z0-9\\:\\$\\%\\&\\*\\-\\_\\/ ]"
  @@transaction_regex=Regexp.new(/(\+|\-)(\d*)(l\d{1,2})?a(\d{1,9})(?:\xBD(\w{1,12})\x1C)?(?:\xBE(\w{1,12})\x1C)?d(\d{4,4})e(\d{1,9})(?:\xBB(\w{1,8})\x1C)?(?:\xBC(\w{1,8})\x1C)?(?:k(\d{1,11}))?(?:h(\d{1,10}))?(?:\x1E(#{an}{1,30})\x1C)?(?:\xBA(\w{2,2}\w{1,13})\x1C)?(?:j(\d{1,4}))?(?:\xB3(\w{1,3})\x1C)(?:m(\d{1,12}))?(?:\xB4(\w{1,3})\x1C)?(?:n(\d{1,11}))?(?:g(\w{1,12}))?(?:\xB0(\w{1,20})\x1C)?(:?\xB1(\w{1,20})\x1C)?(:?\xB2(\w{1,20})\x1C)?(?:f(\d{1,11}))?(?:p(\d{1,3}))?(?:q(\d{1,12}))?y/) 

  def self.transaction_regex
    @@transaction_regex
  end
  
  def self.transaction_regex= (tar)
    @@transaction_regex = tar
  end
  
  @@transaction_field_names = [:umsatz_vorzeichen, :umsatz, :buchungs_schluessel, :gegenkonto, :belegfeld_1, :belegfeld_2, :datum, :konto, :kost_1, :kost_2, :kost_menge, :skonto, :buchungstext, :eu_land, :ust_identifikationsnummer, :eu_steuersatz, :waehrungs_kz_umsatz, :basis_waehrungs_betrag, :waehrungs_kz_basiswaehrung, :waehrungskurs, :reserviert_1, :reserviert_2, :reserviert_3, :reserviert_4, :reserviert_5, :reserviert_6, :reserviert_7]
  
  
  def self.parse_for_transactions(str)
    
    
    #match the regex until all done
    str_rest = str
    
    matches=[]
    
    
    match= @@transaction_regex.match str_rest
    
    until match.nil?
      str_rest= match.pre_match + match.post_match
      matches = matches +[match]
      match = @@transaction_regex.match str_rest
    end
    
    
    #place them into a nice hash
    matches.map do |match|
      Hash[*@@transaction_field_names.zip(match[1..-1]).flatten]
    end
    
  end
  
  
  
  
  
  #this class provides functions, to be accessed with symbols, which take a raw transaction and "make it nice". The functions corresponding to stuff that does not need to be changed are regrouped in literal_functions
  class RawToNice
    def self.umsatz transaction
      debugger
      case transaction[:umsatz_vorzeichen]
      when "+"
        sgn = 1
      when "-"
        sgn = -1
      else
        raise "No sign given for Umsatz"
      end
      
      raw_umsatz= transaction[:umsatz].to_i
      
      nice_umsatz=raw_umsatz /100.0 *sgn
    end
    
    def self.gegenkonto transaction
      transaction[:gegenkonto]
    end
    
    def self.rechnungsnummer transaction
      transaction[:belegfeld_1]
    end
    
    def self.belegfeld_2 transaction
      transaction[:belegfeld_2]
    end
    
    def self.datum transaction
      d=transaction[:datum]
      d[1..2]+"."+d[3..4]
    end
    
    def self.konto transaction
      transaction[:konto]
    end
    
    def self.waehrungskurs transaction
      waehrungskurs= transaction[:waehrungskurs]
      waehrungskurs/1000000.0
    end
    
    
    literal_functions = [:kost_1, :kost_2, :kost_menge, :skonto, :buchungstext, :eu_land, :ust_identifikationsnummer, :eu_steuersatz, :waehrungs_kz_umsatz, :basiswaehrungsbetrag, :waehrungs_kz_basiswaehrung, :reserviert_1, :reserviert_2, :reserviert_3, :reserviert_4, :reserviert_5, :reserviert_6, :reserviert_7]
    
    literal_functions.each do |lf|
      self.metaclass.send(:define_method, lf) do |transaction|
        transaction[lf]
      end
    end
    

    @@desired_properties=[:umsatz, :gegenkonto, :rechnungsnummer, :datum, :konto]
    def self.desired_properties
      @@desired_properties
    end
    def self.desired_properties= dp
      @@desired_properties = dp
    end
    
    
    
    
    #takes a transaction and returns the "nice" properties you ask for in properties
    def self.make_nice transaction, properties=@@desired_properties
      properties.map do |p|
        self.send :p, transaction
      end
      
    end
    
    
    
  end
  
  
  
  

  
end