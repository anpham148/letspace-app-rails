class UsersController < ApplicationController

    def new
        @user = User.new
    end

    def create
        @user = User.new(user_params)
        if @user.save
            if @user.landlord 
                landlord = Landlord.create(user_id: @user.id)
                session[:landlord_id] = landlord.id 
    
                redirect_to landlord_path(landlord)
            else
                tenant = Tenant.create(user_id: @user.id)
                session[:tenant_id] = tenant.id 
    
                redirect_to tenant_path(tenant)
            end
        else
            render :new
        end
            
    end

    def edit
        @user = User.find(params[:id])
        @isEdit = true
    end

    def update
        @user = User.find(params[:id])
        @user.update(user_params)
        if @user.landlord 
            landlord = Landlord.create(user_id: @user.id)
            session[:landlord_id] = landlord.id 

            redirect_to landlord_path(landlord)
        else
            tenant = Tenant.create(user_id: @user.id)
            session[:tenant_id] = tenant.id 

            redirect_to tenant_path(tenant)
        end
    end



    private
    def user_params
        params.require(:user).permit(:first_name, :last_name, :email, :password_digest, :bio, :image_url)
    end
end