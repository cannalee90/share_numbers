class SharingController < ApplicationController
  before_action :check_session, except: [:index, :confirm_id, :reassure, :confirm_sms, :reject_sms]    
  require 'bitly'
  require 'savon'
  #isCheck = 2는 허락 함
  #isCheck = 1은 허락 안함
  #isCheck = 0은 확인 안함
    
    
  #번호를 공유한다고 했을때 자신의 번호를 요청한 사람에게 보내는 페이지.  
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
  
  #번호를 거절했을때 나타나는 페이지.
  def reject_sms
    @post = Post.find(params[:id])
    if(@post.ischeck == 0)
      @post.ischeck = 1
      @post.save
    end
    redirect_to '/'
  end
  
  #번호를 교환할건지 아닌지 물어보는 페이지.
  def reassure
    @post = Post.find(params[:id])
  end

  #자신이 보낸 메세지들을 확인하는 페이지  
  def mymessages
    @user = User.find(session[:user_id])
  end


  #index 맨 처음 페이지..
  def index
    if(session[:user_id].nil?)
      render layout: false
    else
      redirect_to select_univ_path
    end
  end
  
  #학교 선택 controller -> next selection2
  def selection 
    @select = User.group(:school)
    #@select = User.find_by_sql "SELECT id, school From Users group by school"
  end

  #보낼 사람 선택 controller -> next selection3
  def selection2
    @school = User.find(params[:id]).school
    @select = User.where(:school => @school).all
    @team = @select.group(:team)
    @new_post = Post.new
  end
  
  #메세지 입력받는 controller -> next sendsms
  def selection3
    @id = params[:id]
    @new_post = Post.new
  end
  
  #selection3 에서 입력받은 메세지를 보내는 controller
  def sendsms
    @post = Post.new(params.require(:post).permit(:context, :receiver_id))
    
    current_user = User.find(session[:user_id])
    
  #  @post.receiver_id = params[:id]
    @post.user_id = current_user.id
    @post.ischeck = 0
    
    if verify_recaptcha(:model => @post) && @post.save
      @temp = Bitly.client.shorten('http://share.likelion.net/sharing/reassure/' + @post.id.to_s)

      #current_user & sender = 요청한 사람
      #receiver = 요청받은 사람
      
      lms_user = '*****'
      lms_password = '*****'
      msg = @post.context + "\n번호공개의 동의하시면 다음 링크를 클릭해주세요  " + @temp.short_url
      title  = "멋쟁이 사자의 "  + current_user.name + "님이 보낸 문자입니다" ##문자 메시지
      
      h = Hash.new
      h["senderPhone"] = "*****"
      h["receivePhone"] = User.find(params[:id]).mobile
      
      hash_value = Digest::MD5.hexdigest(lms_user + lms_password + h["receivePhone"])
      h["hashValue"] = hash_value
      h["lmsContent"] = msg
      h["lmsID"] = lms_user
      h["lmsTitle"] = title
      
      client = Savon.client(wsdl: "http://lmsservice.tongkni.co.kr/lms.1/ServiceLMS.asmx?WSDL")
      res = client.call :send_lms, :message => h
      puts res.inspect
      flash.delete :recaptcha_error
      flash[:success] = "성공적으로 문자를 보냈습니다"
    else
      flash.delete :recaptcha_error
      flash[:error] = "recapcha 인증에 실패하였습니다"
      redirect_to :back
    end  
  end
  
  
  
  #로그인 controller 이쪽은 무시하셔도 됩니다.
  def confirm_id
    @user = User.where(:email => params[:user_id]).take
    if @user.nil?
      redirect_to :back
      flash[:error] = "잘못된 정보로 로그인했습니다"
    else
      password = BCrypt::Password.create(params[:user_password])
      salt = @user.password[0...29]
      
      @a = BCrypt::Engine.hash_secret(params[:user_password], salt)
      if (@user.password == @a)  
        redirect_to '/sharing/selection'
        session[:user_id] = @user.id
        flash[:success] = "로그인 하였습니다."
      else
        flash[:error] = "잘못된 정보로 로그인했습니다"
        redirect_to :back
      end      
    end
    
  end
  
  
  #로그 아웃 controller
  def logout
    reset_session
    redirect_to '/'
  end
  
private
  def check_session
    if(session[:user_id].nil?)
      redirect_to root_path
    end
  end
end
