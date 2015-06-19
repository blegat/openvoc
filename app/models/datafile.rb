class Datafile
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  

  
  def self.save(upload)
      file_name =  upload['datafile'].original_filename
      just_filename = File.basename(file_name) 
      name = just_filename.sub(/[^\w\.\-]/,'_') 
      
      
      directory = "public/data"
      # create the file path
      path = File.join(directory, name)
      # write the file
      File.open(path, "wb") { |f| f.write(upload['datafile'].read) }
  end
  

  
end
