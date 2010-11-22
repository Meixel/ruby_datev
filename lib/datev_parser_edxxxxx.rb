
class Object
  def metaclass
    class << self
      self
    end
  end
end

module DatevParser
  
  
  
  class Edxxxxx
    
    #Datev file block length is
    @@block_length = 256
    
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
    
    #order in which the transaction_regex is built
    
    @@transaction_regex_order = [
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
    ]
      
    

    
    def initialize file_name #initialize object given an EDxxxxx file name. Loads content, removes end-of-block whitespace and parses the file
      
      
      
    end
    
    
    
    
    
    private:
    
    def load_file file_name
      ff=File.new(file_name, 'r')
      content=ff.read
      ff.close

      content
      
    end
    
    
  end
  
  
end
