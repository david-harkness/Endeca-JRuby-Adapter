require 'java'
require 'endeca_navigation.jar'
java_import 'com.endeca.navigation.ENEQueryResults'
java_import 'com.endeca.navigation.HttpENEConnection'
java_import 'com.endeca.navigation.UrlENEQuery'
java_import 'com.endeca.navigation.FieldList'

FIELD_LIMIT = false # If set to true, it respects &F= in the url

class Endeca
  
  def initialize(host, port)
    @eneConn = HttpENEConnection.new(host, port);
  end
  
  def query(url, perPage, offset)
    @eneQuery = UrlENEQuery.new(url, "UTF-8");
    puts "QUERY = #{url}"
    if FIELD_LIMIT
      fieldList = FieldList.new
      fields = url.match(/&F=.*/).to_s.split('&')[1].split('=').last.split('|').collect {|x| x.split(':').first}
      fields.each do |field|
        fieldList.addField(field)
      end
      @eneQuery.setSelection(fieldList)
    end
    @eneQuery.setNavNumERecs(perPage)
    @eneQuery.setNavERecsOffset(offset)
    parse_results @eneConn.query(@eneQuery)
  end
  
  private 
    def parse_results(results)
      nav = results.getNavigation()
      recs = nav.getERecs()
      array = []
      hash = {}
      recs.each do |x|
        inner_hash = {}
        x.getProperties.each do |prop|
          inner_hash[prop.shift] = prop.last.gsub('+',' ').split('^')
          raise "More than one Value" if prop.size > 1
        end 
        array << inner_hash        

        x.getDimValues.each do |dv|
        dv.each do |dimloc|
            hash[dimloc.getDimValue.getDimensionName.to_sym] = dimloc.getDimValue.getName
          end
        end
      end

      return {:hash => hash, :array => array}
    end

end
