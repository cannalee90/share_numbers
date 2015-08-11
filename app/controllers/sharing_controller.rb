class SharingController < ApplicationController
  before_action :check_session, except: [ :index, :confirm_id, :reassure, :confirm_sms, :reject_sms]    
  require 'bitly'
  require 'savon'
  #isCheck = 2는 허락 함
  #isCheck = 1은 허락 안함
  #isCheck = 0은 확인 안함
    
  def confirm_sms
    @post = Post.find(params[:id])
    if(@post.ischeck == 0)
      @post.ischeck = 2
      @post.save
      @receiver = User.find(@post.receiver_id)
      @sender = User.find(@post.user_id)
      lms_user = 'likelion'
      lms_password = 'likelion1111'
      
      msg = @receiver.name + "님의 번호는 " + @receiver.mobile + "입니다"
      title = "멋쟁이 사자입니다." ##문자 메시지
      
      h = Hash.new
      h["senderPhone"] = "010-3707-4919"
      h["receivePhone"] = @sender.mobile
      
      hash_value = Digest::MD5.hexdigest(lms_user + lms_password + h["receivePhone"])
      h["hashValue"] = hash_value
      h["lmsContent"] = msg
      h["lmsID"] = lms_user
      h["lmsTitle"] = title
      
      client = Savon.client(wsdl: "http://lmsservice.tongkni.co.kr/lms.1/ServiceLMS.asmx?WSDL")
      res = client.call :send_lms, :message => h
      puts res.inspect    
    end
  end
  
  def reject_sms

    @post = Post.find(params[:id])
    if(@post.ischeck == 0)
      @post.ischeck = 1
      @post.save
    end
    redirect_to '/'
  end
  
  def reassure
    @post = Post.find(params[:id])
  end

  def sendsms
    @post = Post.new(params.require(:post).permit(:context, :user_id))
    
    current_user = User.find(session[:user_id])
    
    @post.receiver_id = params[:id]
    @post.user_id = current_user.id
    @post.ischeck = 0
    
    if verify_recaptcha(:model => @post) && @post.save
      @temp = Bitly.client.shorten('http://share.likelion.net/sharing/reassure/' + @post.id.to_s)

      #current_user & sender = 요청한 사람
      #receiver = 요청받은 사람
      
      lms_user = 'likelion'
      lms_password = 'likelion1111'
      msg = @post.context + "\n번호공개의 동의하시면 다음 링크를 클릭해주세요  " + @temp.short_url + current_user.name
      title  = "멋쟁이 사자의 "  + current_user.name + "님이 보낸 문자입니다" ##문자 메시지
      
      h = Hash.new
      h["senderPhone"] = "010-3707-4919"
      h["receivePhone"] = User.find(params[:id]).mobile
      
      hash_value = Digest::MD5.hexdigest(lms_user + lms_password + h["receivePhone"])
      h["hashValue"] = hash_value
      h["lmsContent"] = msg
      h["lmsID"] = lms_user
      h["lmsTitle"] = title
      
      client = Savon.client(wsdl: "http://lmsservice.tongkni.co.kr/lms.1/ServiceLMS.asmx?WSDL")
      res = client.call :send_lms, :message => h
      puts res.inspect
    else
      redirect_to :back
    end  
  end

  def index
    unless session[:user_id].nil?
      redirect_to '/sharing/selection' 
    end
  end
  
  def selection
    @select = User.group(:school)
    #@select = User.find_by_sql "SELECT id, school From Users group by school"
  end
  def logout
    reset_session
    redirect_to '/'
  end
  def selection2
    @school = User.find(params[:id]).school
    @select = User.where(:school => @school).all
  end
  
  def selection3
    @id = params[:id]
    @new_post = Post.new
  end
  
  def mymessages
    @user = User.find(session[:user_id])
    
    
  end
  
  def confirm_id
    @user = User.where(:email => params[:user_id]).take
    if @user.nil?
      redirect_to :back
    else
      password = BCrypt::Password.create(params[:user_password])
      salt = @user.password[0...29]
      
      @a = BCrypt::Engine.hash_secret(params[:user_password], salt)
      if (@user.password == @a)  
        redirect_to '/sharing/selection'
        session[:user_id] = @user.id
      else
        redirect_to :back
      end      
    end
  end
private
  def check_session
    if(session[:user_id].nil?)
      redirect_to '/'
    end
  end
  
end
