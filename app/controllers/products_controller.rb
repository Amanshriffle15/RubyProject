class ProductsController < ApplicationController

  def recommend_by_brand
    user = UserProfile.find(params[:user_id])
    puts "user#{user.favourite_brand}"
    favorite_brand = user.favourite_brand

    recommended_products = Product.where(brand_name: favorite_brand)

    render json: recommended_products, status: 200
  end

  def search
    product_name = params[:product_name]
    
    if product_name.present?
      products = Product.where('name LIKE ?', "#{product_name}")
      render json: products
    else

      render json: { error: 'Please provide a product name for the search' }
    end
  end

  def index
    product = Product.all
    render json: product, status:200
  end
  
  def create
    if params[:user_id] && params[:user_type]
      if params[:user_type] == "customer"
          render json: { error: 'Customers are not allowed to create products' } 
          return
      end
      
      product = Product.new(product_params)
      
    
      if product.save
        product_variant = product.product_variants.create(length: 0, width: 0)  
        render json: { product: product, product_variant: product_variant }, status: :created
      else
        render json: { errors: product.errors.full_messages }
      end
      else
        render json: { error: 'User information not provided' }
    end
  end
    
  def update

      if params[:user_id] && params[:user_type]
        if params[:user_type] == "customer"
          render json: { error: 'Customers are not allowed to create products' }
          return
        else
          product = Product.find_by(id: params[:id])
        
        if product
          product.update(product_params)
          render json: product, status: 200
        else
          render json: {error: "product Not Found"}
        end
      end
    end
  end

  def destroy
    product = Product.find_by( params[:id])
    if product
      product.destroy
      render json: product , status: 204
    else
      render json: "Product not found"
    end
  end
  
  private

  def product_params
    params.require(:product).permit(:name, :price, :user_type,:user_id)
  end
end
  