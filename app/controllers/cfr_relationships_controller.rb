class CfrRelationshipsController < ApplicationController

  initialize_feature FEATURE_ID_CFR_RELATIONSHIPS, FEATURE_ACCESS_SOME 
  before_action :set_cfr_relationship, only: [ :show, :edit, :update, :destroy ]

  # GET /cft

  def index
    @cfr_relationships = CfrRelationship.all.order( :rs_group, :leading )
  end

  # GET /cft/1

  def show
  end

  # GET /cft/new

  def new
    @cfr_relationship_l = CfrRelationship.new
    @labels = Array.new( 2, '' )
  end

  # GET /cft/1/edit

  def edit
    @labels = [ @cfr_relationship_l.label, @cfr_relationship_r.label ]
  end

  # POST /cft

  def create
    p = cfr_relationship_params
    @labels = [ p[ :labels ][ 0 ], p[ :labels ][ 1 ]]
    @cfr_relationship_l = CfrRelationship.new( rs_group: p[ :rs_group ], leading: true,  label: @labels[ 0 ])
    @cfr_relationship_r = @cfr_relationship_l.build_reverse_rs( rs_group: p[ :rs_group ], leading: false, label: @labels[ 1 ])
    respond_to do |format|
      CfrRelationship.transaction do
        if @cfr_relationship_l.save
          @cfr_relationship_l.update_attribute( :reverse_rs_id, @cfr_relationship_r.id )
          format.html { redirect_to @cfr_relationship_l, notice: I18n.t( 'cfr_relationships.msg.create_ok' )}
        else
          format.html { render :new }          
        end
      end
    end
  end

  # PATCH/PUT /cft/1

  def update
    respond_to do |format|
      p = cfr_relationship_params
      @cfr_relationship_l.rs_group = p[ :rs_group ]
      @cfr_relationship_r.rs_group = p[ :rs_group ]
      @cfr_relationship_l.label = p[ :labels ][0]
      @cfr_relationship_r.label = p[ :labels ][1]
      if @cfr_relationship_l.save
        format.html { redirect_to @cfr_relationship_l, notice: I18n.t( 'cfr_relationships.msg.update_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /cft/1

  def destroy
    @cfr_relationship_l.destroy
    respond_to do |format|
      format.html { redirect_to cfr_relationships_url, notice: I18n.t( 'cfr_relationships.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions
    # Here: ensure that we always have a leading relationship

    def set_cfr_relationship
      @cfr_relationship_l = CfrRelationship.find( params[ :id ])
      if @cfr_relationship_l.leading
        @cfr_relationship_r = @cfr_relationship_l.reverse_rs
      else
        @cfr_relationship_r = @cfr_relationship_l
        @cfr_relationship_l = @cfr_relationship_r.reverse_rs
      end
    end 

    # Never trust parameters from the scary internet, only allow the white list through.

    def cfr_relationship_params
      params.require( :cfr_relationship ).permit( :rs_group, labels: [] )
    end

end
