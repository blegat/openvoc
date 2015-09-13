class GroupsController < ApplicationController
  before_filter :signed_in_user
  before_filter :get_user
  before_filter :get_group, only:[:leave, :managegeneral, :managegeneralpatch, :managemembers, :add, :addpeople, :managemembersremove]
  before_filter :get_group2, only:[:destroy]
  before_filter :correct_user, only: [:index, :destroy, :add]
  before_filter :admin_user, only: [:destroy]
  # before_filter :get_list, only: [:show, :edit, :destroy]
  # before_filter :get_list2, only: [:moving, :move, :export, :exporting]
  # before_filter :correct_user, only: [:show, :destroy, :deit, :moving, :move, :import, :export, :exporting]
  # before_filter :get_data_show, only: [:new, :show, :move, :moving, :export, :exporting]
  # before_filter :check_data_export, only: [:exporting]
  def index
    @groups_list = @user.groups
  end
  
  def new
    @new_group = Group.new()
  end
  
  def create
    @new_group = Group.new(name: params[:group][:name], public: false)
    if not @new_group.save
      flash_errors(@new_group)
      redirect_to root_path
    end
    
    @new_fake_user = User.new(name:@new_group.name,
                             email:"#{@new_group.id}@faker.openvoc.com",
                            faker:true,
                   faker_for_group:@new_group.id)
    
    if not @new_fake_user.save
      flash_errors(@new_fake_user)
      redirect_to root_path
    end
    
    @new_group.faker_id = @new_fake_user.id
    if not @new_group.save
      flash_errors(@new_group)
      redirect_to root_path
    end            
    
    @new_membership = GroupMembership.new(group_id:@new_group.id, 
                                           user_id:current_user.id,
                                            admin:true)
    
    if not @new_membership.save
      flash_errors(@new_membership)
      redirect_to root_path
    end
    
    flash.now[:success] = "#{@new_group.name} successfully created"
    redirect_to group_lists_path(@new_group)
   
  end
  
  def destroy
    User.find(@group.faker_id).destroy
    GroupMembership.find_by(group_id:@group.id).destroy
    @group.destroy
    
    redirect_to lists_path
  end
  
  
  def show
  end
  
  def search
    if params[:q]
      @groups_list = Group.where(public:true).where("name LIKE ?", params[:q])
      
    else
      @groups_list = Group.where(public:true)
    end
  end
  
  def lists
    render :show
  end
  
  def leave
    gmb = GroupMembership.find_by(user_id:@user.id, group_id:@group.id)
    if gmb
      gmb.destroy
      flash[:success] = "You left the group"
      if @group.members.empty?
        User.find(@group.faker_id).destroy
        @group.destroy
      end
    else
      flash[:error] = "An error occured: your membership was not found"
    end
    redirect_to lists_path
  end
  
  def add
    @new_membership = GroupMembership.new(group_id:@group.id, 
                                           user_id:current_user.id,
                                            admin:false)
    
    if not @new_membership.save
      flash_errors(@new_membership)
      redirect_to root_path
    end
    
    flash[:success] = "#{@group.name} successfully added to your groups"
    redirect_to group_lists_path(@group)
   
  end
  
  def addpeople
    if params[:user_id]
      new_usr = User.find(params[:user_id])
        
      if new_usr && (not new_usr.faker)
        if new_usr.is_member?(@group)
          flash.now[:warning] = "#{new_usr.name} is already in the group"
        else
          new_membership = GroupMembership.new(group_id:@group.id, 
                                                user_id:new_usr.id,
                                                  admin:false)
          if not new_membership.save
            flash_errors(new_membership)
            redirect_to root_path
          else
            flash.now[:success] = "#{new_usr.name} has been added to the group"
          end
        end
      end
    end
    
    if params[:q]
      @users_list = []
      User.where(faker:false).where("name LIKE ? or email LIKE ?", params[:q], params[:q]).each do |u|
        if not u.is_member?(@group)
          @users_list.append(u)
        end
      end
      
    else
      @users_list = []
    end
  end
  
  def managegeneralpatch
    group_params = params.require(:group).permit(:name, :public)
    if @group.update_attributes(group_params)
      flash[:success] = "The group settings have been changed."
    else
      flash[:alert] = "A problem occured."
    end
    redirect_to group_manage_general_path(@group)
  end
  
  def managegeneral
    @m_general = true
    render layout: 'groupmanage'
  end
  
  def managemembersremove
    if params[:user_id]
      gmb = GroupMembership.find_by(user_id:params[:user_id], group_id:@group.id)
      if gmb
        gmb.destroy
        flash[:warning] = "#{User.find(params[:user_id]).name} left the group"
      else
        flash[:error] = "An error occured: the member was not found"
      end
    else
      
    end
    redirect_to group_manage_members_path(@group)
  end
  
  
  def managemembers
    @m_members = true
    
    if params[:user_id]
      new_usr = User.find(params[:user_id])
      if new_usr && (not new_usr.faker)
        if new_usr.is_member?(@group)
          flash.now[:warning] = "#{new_usr.name} is already in the group"
        else
          new_membership = GroupMembership.new(group_id:@group.id, 
                                                user_id:new_usr.id,
                                                  admin:false)
          if not new_membership.save
            flash_errors(new_membership)
            redirect_to root_path
          else
            flash.now[:success] = "#{new_usr.name} has been added to the group"
          end
        end
      end
    end
    
    if params[:q]
      @users_search_list = []
      User.where(faker:false).where("name LIKE ? or email LIKE ?", params[:q], params[:q]).each do |u|
        if not u.is_member?(@group)
          @users_search_list.append(u)
        end
      end
      
    else
      @users_list = []
    end
    
    render layout: 'groupmanage'
  end
  
  
  private
  
  def get_user
    @user = current_user
  end
  
  def get_group
    @group = Group.find(params[:group_id])
    unless @group
      redirect_to root_path
    end
  end
  
  def get_group2
    @group = Group.find(params[:id])
    unless @group
      redirect_to root_path
    end
  end
  
  def correct_user
    unless (current_user.is_member?(@group) || @group.public) 
      flash[:danger] = "You may not access this page1"
      redirect_to(root_url) 
    end
  end
  
  def admin_user
    unless (current_user.is_admin(@group)) 
      flash[:danger] = "You may not access this page2"
      redirect_to(root_url) 
    end
  end
end
