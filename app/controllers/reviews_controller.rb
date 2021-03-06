class ReviewsController < ApplicationController
    before_action :tenant_require_login, only: [:new, :create, :edit, :update, :destroy]
    @@review_id

    def new
          @property = Property.find_by_id(params[:property_id])
          @tenant = Tenant.find_by_id(params[:tenant_id])
          if tenant_authorized?(@tenant) && authorized_to_review?(@property)
            @review = Review.new(tenant_id: @tenant.id, property_id: @property.id)
            @url = tenant_previous_property_path(@tenant, @property)
          else 
            flash[:error] = "Not authorized to leave a review on this property!"
            redirect_to tenant_path(@tenant)
          end
    end

    def create
          @tenant = Tenant.find_by_id(params[:tenant_id])
          @property = Property.find_by_id(params[:property_id])
          if tenant_authorized?(@tenant) && authorized_to_review?(@property)
             @review = @tenant.reviews.build(review_params)
             @review.property_id = @property.id

             if @review.save
                 redirect_to tenant_property_review_path(@tenant, @property, @review)
             else
                @url = tenant_previous_property_path(@tenant, @property)
                render :new
             end
          else
            flash[:error] = "Not authorized to leave a review on this property!"
            redirect_to tenant_path(@tenant)
          end
    end

    def show
        @tenant = Tenant.find_by_id(params[:tenant_id])
        @property = Property.find_by_id(params[:property_id])
        @review = Review.find_by_id(params[:id])

        redirect_to tenant_property_path(@tenant, @property)
    end
    
    def edit
           @tenant = Tenant.find_by_id(params[:tenant_id])
           @property = Property.find_by_id(params[:property_id])
           @review = Review.find_by_id(params[:id])
           if @review
               if authorized_to_edit_review?(@review)
                 @@review_id = @review.id
                 @url = tenant_previous_property_path(@tenant, @property)
               else
                 flash[:error] = "Not authorized to edit this review"
                 redirect_to tenant_path(@tenant)
               end
            else
              flash[:error] = "Review is not found!"
              landlord_or_tenant_path
            end
    end


    def update
           @tenant = Tenant.find_by_id(params[:tenant_id])
           @property = Property.find_by_id(params[:property_id])
           @review = Review.find_by_id(@@review_id)
           if @review
               if authorized_to_edit_review?(@review)
                  @review.update(review_params)
                  redirect_to tenant_property_review_path(@tenant, @property, @review)
               else
                  flash[:error] = "Not authorized to edit this review"
                  redirect_to tenant_path(@tenant)
               end
           else
               flash[:error] = "Review is not found!"
               landlord_or_tenant_path
           end
    end

    def destroy
          @tenant = Tenant.find_by_id(params[:tenant_id])
          @property = Property.find_by_id(params[:property_id])
          @review = Review.find_by_id(params[:id])
          if @review
             if authorized_to_edit_review?(@review)
                @review.destroy
                redirect_to tenant_previous_property_path(@tenant, @property)
             else
               flash[:error] = "Not authorized to delete this review"
               redirect_to tenant_path(@tenant)
             end
          else
            flash[:error] = "Review is not found!"
            landlord_or_tenant_path
          end
    end

    private
        def review_params
            params.require(:review).permit(:rating, :title, :content)
        end
   
end
