require 'spec_helper'

describe "Frontend Facade" do

  subject(:frontend_facade) { FrontendFacade.new }
  let(:key) { key = @key }

  # describe "Users" do
  #   it "should create user", :tag => 'Users1' do |example|
  #     key = example.metadata[:tag]
  #     frontend_facade_payload = FrontendFacadePayload::Property::Users.new(key)
  #     puts frontend_facade_payload.payload
  #     response = frontend_facade.create_user(frontend_facade_payload.payload)
  #     expect(response[:status]).to be(200)
  #   end
  # end

  describe 'Property' do

    context "Get summary of a property" do

      let(:payload) { FrontendFacadePayload::Property::Summary.payload key }
      let(:response) { frontend_facade.get_summary_for_a_property(*params) }

      shared_examples "Check summary for a property"  do
        it "Check summary for a property" do |example|
          expect(response[:status]).to be(200)
          expect(response[:message]).to be_deep_equal(payload)
        end
      end

      context "for en-gb", :tag => 'student_village_summary_en' do
        let(:params) {['student-village','en-gb']}
        include_examples "Check summary for a property"
      end

      context "for zh-cn", :tag => 'te_puni_village_summary_cn' do
        let(:params) {['te-puni-village','zh-cn']}
        include_examples "Check summary for a property"
      end
    end

    context "Get rooms of a property" do

      let(:payload) { FrontendFacadePayload::Property::Rooms.payload key }

      def get_elements hash, category_name = nil, unit_name = nil, listing_id = nil
        categories = hash['categories']
        categories.each do |e|
          if e['name'] == category_name
            if unit_name == nil
              return e
            elsif
              units = e['units']
              units.each do |e1|
                if e1['name'] == unit_name
                  if listing_id == nil
                    return e1
                  elsif
                    listings = e1['listings']
                    listings.each do |e2|
                      if e2['id'] == listing_id
                        return e2
                      end
                    end
                  end
                end
              end
            end
          end
        end
        return nil
      end

      it "Check unit basic info is correct including bathroom_type, max_occupancy, id, name, distinctions", :tag => 'testing_room_property1' do |example|
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-1')
        expect(response[:status]).to be(200)
        unit_expected = get_elements(payload, 'private-room', 'Unit 1')
        unit_actual = get_elements(response[:message], 'private-room', 'Unit 1')
        ['bathroom_type', 'max_occupancy', 'id', 'name', 'distinctions'].each do |e|
          expect(unit_actual[e]).to be_deep_equal(unit_expected[e])
        end
      end

      it "Check unit state is correct for available_with_price, available, coming_soon, sold_out", :tag => 'testing_room_property1' do |example|
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-1')
        expect(response[:status]).to be(200)
        unit_expected = get_elements(payload, 'private-room', 'Unit 1')
        unit_actual = get_elements(response[:message], 'private-room', 'Unit 1')
        expect(unit_actual['state']).to eq(unit_expected['state'])
        ['Unit 2', 'unit 3', 'Unit 4'].each do |e|
          unit_expected = get_elements(payload, 'entire-place', e)
          unit_actual = get_elements(response[:message], 'entire-place', e)
          expect(unit_actual['state']).to eq(unit_expected['state'])
        end
      end

      it "Check listing basic info including id, availability, price_min, price_max", :tag => 'testing_room_property1' do |example|
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-1')
        expect(response[:status]).to be(200)
        listing_expected = get_elements(payload, 'private-room', 'Unit 1', 68918)
        listing_actual = get_elements(response[:message], 'private-room', 'Unit 1', 68918)
        ['availability', 'price_min', 'price_max'].each do |e|
          expect(listing_actual[e]).to eq(listing_expected[e])
        end
      end

      it "Check listing discount price and discount type", :tag => 'testing_room_property1' do |example|
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-1')
        expect(response[:status]).to be(200)
        [68918, 68917].each do |e|
          listing_expected = get_elements(payload, 'private-room', 'Unit 1', e)
          listing_actual = get_elements(response[:message], 'private-room', 'Unit 1', e)
          expect(listing_actual['discount']['type']).to  eq(listing_expected['discount']['type'])
          expect(listing_actual['discount']['value']).to  eq(listing_expected['discount']['value'])
          expect(listing_actual['discounted_price_min']).to eq(listing_expected['discounted_price_min'])
          expect(listing_actual['discounted_price_max']).to eq(listing_expected['discounted_price_max'])
        end
      end

      it "Check listing state for available_with_price, available, coming_soon or sold_out.", :tag => 'testing_room_property1' do |example|
        def get_listing_id_state hash
          listings = []
          hash.each do |e|
            listing = []
            listing << e['id']
            listing << e['state']
            listings << listing
          end
          return listings
        end

        response = frontend_facade.get_rooms_for_a_property('testing-room-property-1')
        expect(response[:status]).to be(200)
        unit_expected = get_elements(payload, 'private-room', 'Unit 1')
        unit_actual = get_elements(response[:message], 'private-room', 'Unit 1')
        listings_expected = get_listing_id_state(unit_expected['listings'])
        listings_actual = get_listing_id_state(unit_actual['listings'])
        expect(listings_actual).to be_deep_equal(listings_expected)
      end

      it "Check inactive listing won't be returned from api." do
        # Check listing 68925, 68926, 68927, 68928 of Unit 1 is not returned because there're inactive.
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-1')
        expect(response[:status]).to be(200)
        unit_actual = get_elements(response[:message], 'private-room', 'Unit 1')
        listing_ids = []
        unit_actual['listings'].each do |e|
          listing_ids << e['id']
        end
        expect(listing_ids).to be_deep_equal(listing_ids - [68925, 68926, 68927, 68928])
      end

      it "Check listing duration and l18n_key", :tag => 'testing_room_property1' do |example|
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-1')
        expect(response[:status]).to be(200)
        [68918, 68924, 68922, 68917, 68920].each do |e|
          listing_expected = get_elements(payload, 'private-room', 'Unit 1', e)
          listing_actual = get_elements(response[:message], 'private-room', 'Unit 1', e)
          ['duration_min', 'duration_max', 'i18n_key'].each do |e1|
            expect(listing_actual['durations'][e1]).to eq(listing_expected['durations'][e1])
          end
        end
      end

      it "Check listing start dates and l18n_key", :tag => 'testing_room_property1' do |example|
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-1')
        expect(response[:status]).to be(200)
        [68918, 68924, 68922, 68919, 68920].each do |e|
          listing_expected = get_elements(payload, 'private-room', 'Unit 1', e)
          listing_actual = get_elements(response[:message], 'private-room', 'Unit 1', e)
          ['start_date_min', 'start_date_max', 'i18n_key'].each do |e1|
            expect(listing_actual['start_dates'][e1]).to eq(listing_expected['start_dates'][e1])
          end
        end
      end

      it "Check listing tenancy_periods", :tag => 'testing_room_property4' do |example|
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-4')
        expect(response[:status]).to be(200)
        listing_expected = get_elements(payload, 'private-room', 'Unit 1', 68937)
        listing_actual = get_elements(response[:message], 'private-room', 'Unit 1', 68937)
        expect(listing_actual['tenancy_periods']).to be_deep_equal(listing_expected['tenancy_periods'])
      end

      it "Check category basic info including name. ", :tag => 'testing_room_property2' do |example|
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-2')
        expect(response[:status]).to be(200)
        categories = response[:message]['categories']
        result_category_name = []
        expect_category_name = ['shared-room','private-room','entire-place']
        categories.each do |e|
          result_category_name << e['name']
        end
        expect(result_category_name).to be_deep_equal(expect_category_name)
      end

      it "Check category state is correct for available, coming_soon or sold_out. ", :tag => 'testing_room_property2' do |example|
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-2')
        expect(response[:status]).to be(200)
        ['private-room', 'shared-room', 'entire-place'].each do |e|
          category_expected = get_elements(payload, e)
          category_actual = get_elements(response[:message], e)
          expect(category_actual['state']).to eq(category_expected['state'])
        end
      end

      it "Check category state is available_with_price or inactive ", :tag => 'testing_room_property1' do |example|
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-1')
        expect(response[:status]).to be(200)
        ['private-room', 'shared-room'].each do |e|
          category_expected = get_elements(payload, e)
          category_actual = get_elements(response[:message], e)
          expect(category_actual['state']).to eq(category_expected['state'])
        end
      end

      it "Check property state is available_with_price if there have available_with_price, available, coming_soon category. ", :tag => 'testing_room_property1' do |example|
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-1')
        expect(response[:status]).to be(200)
        expect(response[:message]['state']).to eq(payload['state'])
      end

      it "Check property state is available if there have available, coming_soon, sold_out category. ", :tag => 'testing_room_property2' do |example|
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-2')
        expect(response[:status]).to be(200)
        expect(response[:message]['state']).to eq(payload['state'])
      end

      it "Check property state is coming_soon if there have coming_soon, sold_out category at least. ", :tag => 'testing_room_property3' do |example|
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-3')
        expect(response[:status]).to be(200)
        expect(response[:message]['state']).to eq(payload['state'])
      end

      it "Check property state is sold_out if all categories are sold_out or state = null.", :tag => 'testing_room_property4' do |example|
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-4')
        expect(response[:status]).to be(200)
        expect(response[:message]['state']).to eq(payload['state'])
      end

    end

    # context "Get Property" do
    #   it "dbfactory demo" ,:tag => 'Users2' do |example|
    #     key = example.metadata[:tag]
    #     frontend_facade = FrontendFacadePayload::Property::Users.new(:ssh => 'Property_ssh', :db => 'Property_db')
    #     puts frontend_facade.id
    #     puts frontend_facade.name
    #     puts frontend_facade.address
    #     puts frontend_facade.expect_result(key)
    #   end
    # end
  end

  describe 'Universities' do

    context "Get the details of a university." do

      let(:payload) { FrontendFacadePayload::Universities::Details.payload key }

      it "Check basic information is correct based on given university for en-gb.", :tag => 'university_of_liverpool_details_en' do |example|
        response = frontend_facade.get_details_of_a_given_university('university-of-liverpool', 'en-gb')
        expect(response[:status]).to be(200)
        expect(response[:message]).to eq(payload)
      end

      it "Check basic information is correct based on given university for zh-cn.", :tag => 'university_of_liverpool_details_cn' do |example|
        response = frontend_facade.get_details_of_a_given_university('university-of-liverpool', 'zh-cn')
        expect(response[:status]).to be(200)
        expect(response[:message]).to eq(payload)
      end
    end

    context "Get a list of universities." do

      let(:payload) { FrontendFacadePayload::Universities::List.payload key }

      it "Check basic info is correct for zh-cn.", :tag => 'given_ae_cn' do |example|
        response = frontend_facade.get_list_of_universities('ae', nil, 'zh-cn')
        expect(response[:status]).to be(200)
        expect(response[:message]).to eq(payload)
      end

      it "Check basic info is correct for en-gb.", :tag => 'given_ae_en' do |example|
        response = frontend_facade.get_list_of_universities('ae', nil, 'en-gb')
        expect(response[:status]).to be(200)
        expect(response[:message]).to eq(payload)
      end

      it "Check all universities can be returned if country and city is not specified." do |example|
        response = frontend_facade.get_list_of_universities(nil, nil, 'en-gb')
        expect(response[:status]).to be(200)
        expect(response[:message]['universities'].size).to eq 837
      end

      it "Check all universities can be returned if country and city is specified." do |example|
        response = frontend_facade.get_list_of_universities(nil, 'london', 'en-gb')
        expect(response[:status]).to be(200)
        expect(response[:message]['universities'].size).to eq 85
      end

      it "Check unpublished university is not returned." do |example|
        # city-of-glasgow-college is not published.
        response = frontend_facade.get_list_of_universities(nil, 'glasgow', 'en-gb')
        expect(response[:status]).to be(200)
        response[:message]['universities'].each do |e|
          expect(e['slug']).not_to eq('city-of-glasgow-college')
        end
      end

      it "Check response can be sorted by name,original_name,slug and rank.", :tag => 'given_jp_en' do |example|
        ["name", "original_name", "slug", "rank"].each do |e|
          response = frontend_facade.get_list_of_universities('jp', nil, 'zh-cn',e)
          expect(response[:status]).to be(200)
          if e == 'rank'
            expected_array = payload['universities'].sort_by{|x| x[e] * -1}
            size = expected_array.size
            for i in 0..size - 1
              expect(response[:message]['universities'][i]['rank']).to eq(expected_array[i]['rank'])
            end
          else
            expected_array = payload['universities'].sort_by{|x| x[e]}
            expect(response[:message]['universities']).to eq(expected_array)
          end
        end
      end
    end
  end


  describe "Locations" do

    context "Get the list of countries" do

      let(:payload) { FrontendFacadePayload::Locations::Countries.payload key }

      it "Check basic information is correct for en-gb", :tag => 'location_countries_list_en' do |example|
        response = frontend_facade.get_list_of_countries('en-gb')
        expect(response[:status]).to be(200)
        expect(response[:message]).to be_deep_equal(payload)
      end

      it "Check basic information is correct for zh-cn.", :tag => 'location_countries_list_cn' do |example|
        response = frontend_facade.get_list_of_countries('zh-cn')
        expect(response[:status]).to be(200)
        expect(response[:message]).to be_deep_equal(payload)
      end

      it "Check response can be sorted by name,original_name,slug for en-gb", :tag => 'location_countries_list_en' do |example|
        ["name", "original_name", "slug"].each do |e|
          expected_array = payload['countries'].sort_by{|x| x[e]}
          response = frontend_facade.get_list_of_countries('en-gb', e)
          expect(response[:status]).to be(200)
          expect(response[:message]['countries']).to eq(expected_array)
        end
      end

      it "Check response can be sorted by name for zh-cn", :tag => 'location_countries_list_cn' do |example|
        expected_array = payload['countries'].sort_by{|x| x['name']}
        response = frontend_facade.get_list_of_countries('zh-cn', 'name')
        expect(response[:status]).to be(200)
        expect(response[:message]['countries']).to eq(expected_array)
      end

      it "Check unpublished country is not returned." do |example|
        # da is not published.
        response = frontend_facade.get_list_of_countries('en-gb')
        expect(response[:status]).to be(200)
        response[:message]['countries'].each do |e|
          expect(e['slug']).not_to eq('da')
        end
      end
    end

    context "Get the list of cities of a given country" do

      let(:payload) { FrontendFacadePayload::Locations::Cities.payload key }

      it "Check basic information is correct based on given country for en-gb.", :tag => 'location_cities_au_en' do |example|
        response = frontend_facade.get_cities_of_a_given_country('au', 'en-gb')
        expect(response[:status]).to be(200)
        expect(response[:message]).to be_deep_equal(payload)
      end

      it "Check basic information is correct based on given country for zh-cn.", :tag => 'location_cities_au_cn' do |example|
        response = frontend_facade.get_cities_of_a_given_country('au', 'zh-cn')
        expect(response[:status]).to be(200)
        expect(response[:message]).to be_deep_equal(payload)
      end

      it "Check unpublished cities are not returned for de.", :tag => 'location_cities_de_en' do |example|
        # unpublished-city-test-dan is not published.
        response = frontend_facade.get_cities_of_a_given_country('de', 'en-gb')
        expect(response[:status]).to be(200)
        response[:message]['cities'].each do |e|
          expect(e['slug']).not_to eq('unpublished-city-test-dan')
        end
      end

      it "Check response can be sorted by name,original_name,slug,rank for en-gb", :tag => 'location_cities_au_en' do |example|
        ["name", "original_name", "slug", "rank"].each do |e|
          response = frontend_facade.get_cities_of_a_given_country('au', 'en-gb', e)
          expect(response[:status]).to be(200)
          if e == 'rank'
            expected_array = payload['cities'].sort_by{|x| x[e] * -1}
            size = expected_array.size
            for i in 0..size - 1
              expect(response[:message]['cities'][i]['rank']).to eq(expected_array[i]['rank'])
            end
          else
            expected_array = payload['cities'].sort_by{|x| x[e]}
            expect(response[:message]['cities']).to eq(expected_array)
          end
        end
      end

      it "Check response can be sorted by name for zh-cn", :tag => 'location_cities_au_cn' do |example|
        response = frontend_facade.get_cities_of_a_given_country('au', 'zh-cn', 'name')
        expect(response[:status]).to be(200)
        expected_array = payload['cities'].sort_by{|x| x['name']}
        expect(response[:message]['cities']).to eq(expected_array)
      end
    end

    context "Get the details of a city" do

      let(:payload) { FrontendFacadePayload::Locations::City.payload key }

      it "Check basic info base on the given city for en-gb.", :tag => 'location_city_sydney_en' do |example|
        response = frontend_facade.get_details_of_a_city('sydney', 'en-gb')
        expect(response[:status]).to be(200)
        expect(response[:message]).to be_deep_equal(payload)
      end

      it "Check basic info base on the given city for zh-cn.", :tag => 'location_city_sydney_cn' do |example|
        response = frontend_facade.get_details_of_a_city('sydney', 'zh-cn')
        expect(response[:status]).to be(200)
        expect(response[:message]).to be_deep_equal(payload)
      end

      it "Check unpublished areas are not returned", :tag => 'location_city_london_en' do |example|
        response = frontend_facade.get_details_of_a_city('london', 'en-gb')
        expect(response[:status]).to be(200)
        expect(response[:message]['areas']).to be_deep_equal(payload['areas'])
      end
    end

    context "Get the list of areas of a given city." do

      let(:payload) { FrontendFacadePayload::Locations::Areas.payload key }

      it "Check basic info is correct base on given city for en-gb.", :tag => 'location_areas_sydney_en' do |example|
        response = frontend_facade.get_areas_of_a_given_city('sydney', 'en-gb')
        expect(response[:status]).to be(200)
        expect(response[:message]).to be_deep_equal(payload)
      end

      it "Check basic info is correct base on given city for zh-cn.", :tag => 'location_areas_sydney_cn' do |example|
        response = frontend_facade.get_areas_of_a_given_city('sydney', 'zh-cn')
        expect(response[:status]).to be(200)
        expect(response[:message]).to be_deep_equal(payload)
      end

      it "Check unpublished areas are not returned.", :tag => 'location_areas_london_en' do |example|
        # london-area-test is not published.
        response = frontend_facade.get_areas_of_a_given_city('london', 'en-gb')
        expect(response[:status]).to be(200)
        response[:message]['areas'].each do |e|
          expect(e['slug']).not_to eq('london-area-test')
        end
      end

      it "Check areas for non-area city" do
        expected = {"areas" => []}
        response = frontend_facade.get_areas_of_a_given_city('wellington-changed', 'en-gb')
        expect(response[:status]).to be(200)
        expect(response[:message]).to eq(expected)
      end

      it "Check response can be sorted by name,original_name,slug,rank for en-gb", :tag => 'location_areas_sydney_en' do |example|
        ["name", "original_name", "slug", "rank"].each do |e|
          response = frontend_facade.get_areas_of_a_given_city('sydney', 'en-gb', e)
          expect(response[:status]).to be(200)
          if e == 'rank'
            expected_array = payload['areas'].sort_by{|x| x[e] * -1}
            size = expected_array.size
            for i in 0..size - 1
              expect(response[:message]['areas'][i]['rank']).to eq(expected_array[i]['rank'])
            end
          else
            expected_array = payload['areas'].sort_by{|x| x[e]}
            expect(response[:message]['areas']).to eq(expected_array)
          end
        end
      end

      it "Check response can be sorted by name for zh-cn", :tag => 'location_areas_sydney_cn' do |example|
        response = frontend_facade.get_areas_of_a_given_city('sydney', 'zh-cn', 'name')
        expect(response[:status]).to be(200)
        expected_array = payload['areas'].sort_by{|x| x['name']}
        expect(response[:message]['areas']).to eq(expected_array)
      end
    end

    context "Get the details of an area" do

      let(:payload) { FrontendFacadePayload::Locations::Area.payload key }

      it "Check area infomation for en-gb", :tag => 'location_area_wembley_en' do |example|
        response = frontend_facade.get_details_of_an_area('wembley', 'en-gb')
        expect(response[:status]).to be(200)
        expect(response[:message]).to be_deep_equal(payload)
      end

      it "Check area infomation for zh-cn", :tag => 'location_area_wembley_cn' do |example|
        response = frontend_facade.get_details_of_an_area('wembley', 'zh-cn')
        expect(response[:status]).to be(200)
        expect(response[:message]).to be_deep_equal(payload)
      end
    end
  end
end
