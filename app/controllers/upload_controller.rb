class UploadController < ApplicationController
  def upload
  end
  
  def save_upload
    post = Datafile.save(params[:upload])
    #render :text => "File has been uploaded successfully"
    redirect_to List.find(params[:list_id]),
      flash: { success: "Files has been uploaded successfully" } and return
  end
end
