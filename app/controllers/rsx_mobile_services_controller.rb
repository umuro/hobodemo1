class RsxMobileServicesController < ApplicationController

  hobo_model_controller

  def render_with_encrypt params={}
    if @rsx_mobile_service
      unless [200, nil, :success].include?(params[:status])
        render_without_encrypt params
      else
        @_render_with_encrypt_call ||= false
        if @_render_with_encrypt_call == false and not (request.format == :pkcs5)
          params[:status] = :forbidden
          render_without_encrypt params
        else
          @_render_with_encrypt_call = true
          if request.format == :pkcs5
            request.format = :xml
            stuff = @rsx_mobile_service.shadow_update do
             render_to_string params
            end
            response = $SECURITY[:rsx_mobile_service].encrypt stuff
            render_without_encrypt :text => response, :layout => false, :content_type => 'application/pkcs5'
          else
            render_without_encrypt params
          end
        end
      end
    else
      params[:status] = :forbidden
      render_without_encrypt params
    end
  end
  
  alias_method_chain :render, :encrypt

  def show
    return unless fetch
  end
  
  def position_update
    return unless fetch
    @rsx_mobile_service.shadow_update do
      @rsx_mobile_service.lifecycle.position_update!(::Guest)
    end
    Resque.enqueue RsxMobileServiceJobs::PositionUpdate, @rsx_mobile_service.id, request.raw_post.unpack("C*")
  end
  
  private
  
  def fetch
    @rsx_mobile_service = RsxMobileService.first :conditions => {:event_id => params[:id]}
    
    unless @rsx_mobile_service
      error 2, "No Rsx Mobile Service found"
      return false
    end
    
    unless @rsx_mobile_service.api_key == request.headers['X-Key']
      error 1, "No valid X-Key found in header"
      return false
    end
    
    return true
  end
  
  def error code, string
    doc = Nokogiri::XML::Builder.new do |xml|
      xml.error {
        xml.code code
        xml.string string
      }
    end
    render :text => doc.to_xml, :status => :forbidden
  end
end
