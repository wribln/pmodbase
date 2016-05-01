# BaseItemList is shown on the base page having NO_OF_COLUMNS_ON_BASE_PAGE
# columns (defined in config/initializers/basic_settings.rb)

class BaseItemList

  # return all features and associated headings in an array to be passed on
  # to the BaseController; the array is multi-dimensional, the first index
  # is over the columns to be shown; the second index contains the feature
  # category heading and another array with the feature_names and their
  # controller.

  def self.all( current_user )

    # determine which feature groups will be shown to the user; for this
    # I define a structure to hold feature group specific information

    a_category = Struct.new( :item_count, :features, :seqno, :label, :column_no )

    all_features = Feature.select( :id, :code, :label, :feature_category_id, :access_level ).order( :seqno ).all
    all_categories = Hash.new
    all_features.each_with_index do |f, fi|
      if f.feature_category_id.nil? || f.feature_category_id <= 0 then
        Rails.logger.debug( "BaseItemList: FeatureCategory #{ f.feature_category_id } referenced in Feature #{ f.id } is invalid!" )
        next
      end
      next if f.no_direct_access?
      if f.access_to_index? || current_user.permission_to_index?( f.id ) then
        if all_categories[ f.feature_category_id ].nil? then # new group - initialize
          all_categories[ f.feature_category_id ] = a_category.new( 1, [ fi ], 0, "", nil )
        else # existing group - increment count, add new feature to list
          all_categories[ f.feature_category_id ].item_count += 1
          all_categories[ f.feature_category_id ].features << fi
        end
      end
    end

    # pick up data for feature groups, increment item cound by one
    # (for the group title, compute maximum of all groups, and
    # total count over all groups

    total_no_items = 0
    no_items_per_col = 0

    all_categories.each do |tgi, tgv|
      begin
        tgd = FeatureCategory.find(tgi)
        tgv.item_count += 1.5
        tgv.seqno = tgd.seqno
        tgv.label = tgd.label
        total_no_items += tgv.item_count
        no_items_per_col = tgv.item_count if tgv.item_count > no_items_per_col
      rescue ActiveRecord.RecordNotFound
        Rails.logger.debug( "BaseItemList: FeatureCategory #{ tgi } referenced in Feature(s) #{ tgv.features } not in database!" )
      end
    end

    # if there is nothing to display, return nil

    return nil if total_no_items == 0

    # remove all empty groups

    all_categories.delete_if{ |tgi,tgv| tgv.item_count == 0 }

    # hash is not useful from now on - continue with all_categories as array,
    # sort into seqno order

    all_categories = all_categories.to_a
    all_categories.sort! { |ag1, ag2| ag1[ 1 ].seqno <=> ag2[ 1 ].seqno }

    # adjust approximate number of items in each column:
    # [no_items_per_col, total_no_items.fdiv(NO_OF_COLUMNS_ON_BASE_PAGE).ceil].max

    no_items_per_col = total_no_items.fdiv(NO_OF_COLUMNS_ON_BASE_PAGE).ceil unless
      (no_items_per_col * NO_OF_COLUMNS_ON_BASE_PAGE ) > total_no_items

    # ready for first loop: distribute groups to columns
    # column_item_count holds total of items assigned to column,
    # total_no_items will be the number of items left to distribute

    column_item_count = Array.new( NO_OF_COLUMNS_ON_BASE_PAGE, 0)
    all_categories.each do |tgv|
      column_item_count.each_index do |ci|
        if (column_item_count[ci] + tgv[1].item_count) <= no_items_per_col then
          column_item_count[ci] += tgv[1].item_count
          total_no_items -= tgv[1].item_count
          tgv[1].column_no = ci
          break
        end # if
      end # column_item_count do
    end # all_categories do

    # distribute remaining items to colum, largest group to shortest column first

    while total_no_items > 0

      ci = column_item_count.index(column_item_count.min)
      g_max = 0
      i_max = nil
      all_categories.each_with_index do | tgv, tgi |
        if tgv[1].column_no.nil? and tgv[1].item_count > g_max then
          g_max = tgv[1].item_count
          i_max = tgi
        end
      end
      column_item_count[ci] += all_categories[i_max][1].item_count
      total_no_items -= all_categories[i_max][1].item_count
      all_categories[i_max][1].column_no = ci

    end

    # final stage: collect output into array for controller

    result = Array.new(NO_OF_COLUMNS_ON_BASE_PAGE){Array.new}
    all_categories.each do |tgv|
      result[tgv[1].column_no] << [0,tgv[1].label] # header
      tgv[1].features.each do |t|
        result[tgv[1].column_no] << [1,all_features[t].label,all_features[t].code] # detail
      end
      result[tgv[1].column_no] << [2] # end of group
    end

    return result

  end # def

end
