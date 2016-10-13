require 'spec_helper'

describe "Frontend Facade" do

  let(:frontend_facade) { FrontendFacade.new }
  let(:key) { key = @key }

  # describe "Users" do
  #   it "should create user", :tag => 'Users1' do |example|
  #     key = example.metadata[:tag]
  #     frontend_facade_payload = FrontendFacadePayload::Property::Users.new(key)
  #     puts frontend_facade_payload.payload
  #     response = frontend_facade.create_user(frontend_facade_payload.payload)
  #     expect(response.code).to be(200)
  #   end
  # end

  describe 'Property' do

    context "Get summary of a property" do

      let(:payload) { FrontendFacadePayload::Property::Summary.payload key }

      it "Check summary for a property for en-gb.", :tag => 'student_villiage_summary_en' do |example|
        response = frontend_facade.get_summary_for_a_property('student-village', 'en-gb')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result).to be_deep_equal(payload)
      end

      it "Check summary for a property for zh-cn.", :tag => 'te_puni_village_summary_cn' do |example|
        response = frontend_facade.get_summary_for_a_property('te-puni-village', 'zh-cn')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result).to be_deep_equal(payload)
      end
    end

    context "Get rooms of a property" do

      let(:payload) { FrontendFacadePayload::Property::Rooms.payload key }

      it "Check unit basic info is correct including bathroom_type, max_occupancy, id, name, distinctions", :tag => 'testing_room_property1' do |example|
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-1')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result['bathroom_type']).to eq(payload['bathroom_type'])
        expect(result['max_occupancy']).to eq(payload['max_occupancy'])
        expect(result['id']).to eq(payload['id'])
        expect(result['name']).to eq(payload['name'])
        expect(result['distinctions']).to be_deep_equal(payload['distinctions'])
      end

      it "Check unit state is correct for available_with_price, available, coming_soon, sold_out", :tag => 'testing_room_property1' do |example|
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-1')
        result = response.parsed_response
        expect(response.code).to be(200)
        categories = result['categories']
        categories.each do |e|
          if e['name'] == 'private-room'
            units = e['units']
            units.each do |e1|
              if e1['name'] == "Unit 1"
                # Check available_with_price
                expect(e1['state']).to eq(payload['categories'][1]['units'][0]['state'])
                break
              end
            end
          elsif e['name'] == 'entire-place'
            units = e['units']
            units.each do |e1|
              if e1['name'] == "Unit 2"
                # Check available
                expect(e1['state']).to eq(payload['categories'][2]['units'][0]['state'])
              elsif e1['name'] == "unit 3"
                # Check coming_soon
                expect(e1['state']).to eq(payload['categories'][2]['units'][1]['state'])
              elsif e1['name'] == "Unit 4"
                # Check sold_out
                expect(e1['state']).to eq(payload['categories'][2]['units'][2]['state'])
              end
            end
          end
        end
      end

      it "Check listing basic info including id, availability, price_min, price_max", :tag => 'testing_room_property1' do |example|
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-1')
        result = response.parsed_response
        expect(response.code).to be(200)
        flag = false
        listing_expected = payload['categories'][1]['units'][0]['listings'][0]
        categories = result['categories']
        categories.each do |e|
          if e['name'] == 'private-room'
            units = e['units']
            units.each do |e1|
              if e1['name'] == 'Unit 1'
                listings = e1['listings']
                listings.each do |e2|
                  if e2['id'] == listing_expected['id']
                    flag = true
                    expect(e2['availability']).to  eq(listing_expected['availability'])
                    expect(e2['price_min']).to eq(listing_expected['price_min'])
                    expect(e2['price_max']).to eq(listing_expected['price_max'])
                  end
                end
              end
            end
          end
        end
        expect(flag).to eq(true)
      end

      it "Check listing discount price and discount type", :tag => 'testing_room_property1' do |example|
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-1')
        result = response.parsed_response
        expect(response.code).to be(200)
        flag1 = false
        flag2 = false
        listing_expected_1 = payload['categories'][1]['units'][0]['listings'][0]
        listing_expected_2 = payload['categories'][1]['units'][0]['listings'][3]
        categories = result['categories']
        categories.each do |e|
          if e['name'] == 'private-room'
            units = e['units']
            units.each do |e1|
              if e1['name'] == 'Unit 1'
                listings = e1['listings']
                listings.each do |e2|
                  if e2['id'] == listing_expected_1['id']
                    # Check percentage discount
                    flag1 = true
                    expect(e2['discount']['type']).to  eq(listing_expected_1['discount']['type'])
                    expect(e2['discount']['value']).to  eq(listing_expected_1['discount']['value'])
                    expect(e2['discounted_price_min']).to eq(listing_expected_1['discounted_price_min'])
                    expect(e2['discounted_price_max']).to eq(listing_expected_1['discounted_price_max'])
                  elsif e2['id'] == listing_expected_2['id']
                    # Check absolte discount
                    flag2 = true
                    expect(e2['discount']['type']).to  eq(listing_expected_2['discount']['type'])
                    expect(e2['discount']['value']).to  eq(listing_expected_2['discount']['value'])
                    expect(e2['discounted_price_min']).to eq(listing_expected_2['discounted_price_min'])
                    expect(e2['discounted_price_max']).to eq(listing_expected_2['discounted_price_max'])
                  end
                end
              end
            end
          end
        end
        expect(flag1).to eq(true)
        expect(flag2).to eq(true)
      end

      it "Check listing state for available_with_price, available, coming_soon or sold_out.", :tag => 'testing_room_property1' do |example|
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-1')
        result = response.parsed_response
        expect(response.code).to be(200)
        listings_expected = payload['categories'][1]['units'][0]['listings']
        categories = result['categories']
        categories.each do |e|
          if e['name'] == 'private-room'
            units = e['units']
            units.each do |e1|
              if e1['name'] == 'Unit 1'
                listings = e1['listings']
                expect(listings.count).to eq(listings_expected.count)
                listings.each do |e2|
                  listings_expected.each do |e3|
                    if e2['id'] == e3['id']
                      expect(e2['state']).to eq(e3['state'])
                      break
                    end
                  end
                end
              end
            end
          end
        end
      end

      it "Check inactive listing won't be returned from api." do
        # Check listing 68925, 68926, 68927, 68928 of Unit 1 is not returned because there're inactive.
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-1')
        result = response.parsed_response
        expect(response.code).to be(200)
        categories = result['categories']
        categories.each do |e|
          if e['name'] == 'private-room'
            units = e['units']
            units.each do |e1|
              if e1['name'] == 'Unit 1'
                listings = e1['listings']
                listings.each do |e2|
                  [68925, 68926, 68927, 68928].each do |e3|
                    expect(e2['id']).not_to eq(e3)
                  end
                end
              end
            end
          end
        end
      end

      it "Check listing duration and l18n_key", :tag => 'testing_room_property1' do |example|
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-1')
        result = response.parsed_response
        expect(response.code).to be(200)
        flag = 0
        listings_expected = payload['categories'][1]['units'][0]['listings']
        categories = result['categories']
        categories.each do |e|
          if e['name'] == 'private-room'
            units = e['units']
            units.each do |e1|
              if e1['name'] == 'Unit 1'
                listings = e1['listings']
                [0, 1, 2, 3, 5].each do |e2|
                  listings.each do |e3|
                    if e3['id'] == listings_expected[e2]['id']
                      flag = flag + 1
                      expect(e3['durations']['duration_min']).to eq(listings_expected[e2]['durations']['duration_min'])
                      expect(e3['durations']['duration_max']).to eq(listings_expected[e2]['durations']['duration_max'])
                      expect(e3['durations']['i18_key']).to eq(listings_expected[e2]['durations']['i18_key'])
                      break
                    end
                  end
                end
              end
            end
          end
        end
        expect(flag).to eq(5)
      end

      it "Check listing start dates and l18n_key", :tag => 'testing_room_property1' do |example|
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-1')
        result = response.parsed_response
        expect(response.code).to be(200)
        flag = 0
        listings_expected = payload['categories'][1]['units'][0]['listings']
        categories = result['categories']
        categories.each do |e|
          if e['name'] == 'private-room'
            units = e['units']
            units.each do |e1|
              if e1['name'] == 'Unit 1'
                listings = e1['listings']
                [0, 1, 2, 4, 5].each do |e2|
                  listings.each do |e3|
                    if e3['id'] == listings_expected[e2]['id']
                      flag = flag + 1
                      expect(e3['start_dates']['start_date_min']).to  eq(listings_expected[e2]['start_dates']['start_date_min'])
                      expect(e3['start_dates']['start_date_max']).to eq(listings_expected[e2]['start_dates']['start_date_max'])
                      expect(e3['start_dates']['i18_key']).to eq(listings_expected[e2]['start_dates']['i18_key'])
                      break
                    end
                  end
                end
              end
            end
          end
        end
        expect(flag).to eq(5)
      end

      it "Check listing tenancy_periods", :tag => 'testing_room_property4' do |example|
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-4')
        result = response.parsed_response
        expect(response.code).to be(200)
        flag = false
        listing = payload['categories'][1]['units'][0]['listings'][0]
        categories = result['categories']
        categories.each do |e|
          if e['name'] == 'private-room'
            units = e['units']
            units.each do |e1|
              if e1['name'] == 'Unit 1'
                listings = e1['listings']
                listings.each do |e2|
                  if e2['id'] == listing['id']
                    flag = true
                    expect(e2['tenancy_periods']).to be_deep_equal(listing['tenancy_periods'])
                  end
                end
              end
            end
          end
        end
        expect(flag).to be(true)
      end

      it "Check category basic info including name. ", :tag => 'testing_room_property2' do |example|
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-2')
        result = response.parsed_response
        expect(response.code).to be(200)
        category_size = result['categories'].size
        expect_category_name = ['shared-room','private-room','entire-place']
        for i in 0..category_size - 1
          (result_category_name ||= []) << result['categories'][i]['name']
        end
        expect(result_category_name).to be_deep_equal(expect_category_name)
      end

      it "Check category state is correct for available, coming_soon or sold_out. ", :tag => 'testing_room_property2' do |example|
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-2')
        result = response.parsed_response
        expect(response.code).to be(200)
        category_size = result['categories'].size
        for i in 0..category_size - 1
          if result['categories'][i]['name'] == 'private-room'
            expect(result['categories'][i]['state']).to eq(payload['categories'][1]['state'])
          elsif result['categories'][i]['name'] == 'shared-room'
            expect(result['categories'][i]['state']).to eq(payload['categories'][0]['state'])
          else
            expect(result['categories'][i]['state']).to eq(payload['categories'][2]['state'])
          end
        end
      end

      it "Check category state is available_with_price or inactive ", :tag => 'testing_room_property1' do |example|
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-1')
        result = response.parsed_response
        expect(response.code).to be(200)
        category_size = result['categories'].size
        for i in 0..category_size - 1
          if result['categories'][i]['name'] == 'private-room'
            expect(result['categories'][i]['state']).to eq(payload['categories'][1]['state'])
          elsif result['categories'][i]['name'] == 'shared-room'
            expect(result['categories'][i]['state']).to eq(payload['categories'][0]['state'])
          end
        end
      end

      it "Check property state is available_with_price if there have available_with_price, available, coming_soon category. ", :tag => 'testing_room_property1' do |example|
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-1')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result['state']).to eq(payload['state'])
      end

      it "Check property state is available if there have available, coming_soon, sold_out category. ", :tag => 'testing_room_property2' do |example|
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-2')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result['state']).to eq(payload['state'])
      end

      it "Check property state is coming_soon if there have coming_soon, sold_out category at least. ", :tag => 'testing_room_property3' do |example|
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-3')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result['state']).to eq(payload['state'])
      end

      it "Check property state is sold_out if all categories are sold_out or state = null.", :tag => 'testing_room_property4' do |example|
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-4')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result['state']).to eq(payload['state'])
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

  describe "Locations" do

    context "Get the list of countries" do

      let(:payload) { FrontendFacadePayload::Locations::Countries.payload key }

      it "Check basic information is correct for en-gb and unpublished country is not returned.", :tag => 'location_countries_list_en' do |example|
        response = frontend_facade.get_list_of_countries('en-gb')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result).to be_deep_equal(payload)
      end

      it "Check basic information is correct for zh-cn.", :tag => 'location_countries_list_cn' do |example|
        response = frontend_facade.get_list_of_countries('zh-cn')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result).to be_deep_equal(payload)
      end

      it "Check response can be sorted by name,original_name,slug for en-gb", :tag => 'location_countries_list_en' do |example|
        ["name", "original_name", "slug"].each do |e|
          expected_array = payload['countries'].sort_by{|x| x[e]}
          response = frontend_facade.get_list_of_countries('en-gb', e)
          result = response.parsed_response
          expect(response.code).to be(200)
          expect(result['countries']).to eq(expected_array)
        end
      end

      it "Check response can be sorted by name for zh-cn", :tag => 'location_countries_list_cn' do |example|
        expected_array = payload['countries'].sort_by{|x| x['name']}
        response = frontend_facade.get_list_of_countries('zh-cn', 'name')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result['countries']).to eq(expected_array)
      end
    end

    context "Get the list of cities of a given country" do

      let(:payload) { FrontendFacadePayload::Locations::Cities.payload key }

      it "Check basic information is correct based on given country for en-gb.", :tag => 'location_cities_au_en' do |example|
        response = frontend_facade.get_cities_of_a_given_country('au', 'en-gb')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result).to be_deep_equal(payload)
      end

      it "Check basic information is correct based on given country for zh-cn.", :tag => 'location_cities_au_cn' do |example|
        response = frontend_facade.get_cities_of_a_given_country('au', 'zh-cn')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result).to be_deep_equal(payload)
      end

      it "Check unpublished cities are not returned for de.", :tag => 'location_cities_de_en' do |example|
        response = frontend_facade.get_cities_of_a_given_country('de', 'en-gb')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result).to be_deep_equal(payload)
      end

      it "Check response can be sorted by name,original_name,slug,rank for en-gb", :tag => 'location_cities_au_en' do |example|
        ["name", "original_name", "slug", "rank"].each do |e|
          response = frontend_facade.get_cities_of_a_given_country('au', 'en-gb', e)
          result = response.parsed_response
          expect(response.code).to be(200)
          if e == 'rank'
            expected_array = payload['cities'].sort_by{|x| x[e] * -1}
            size = expected_array.size
            for i in 0..size - 1
              expect(result['cities'][i]['rank']).to eq(expected_array[i]['rank'])
            end
          else
            expected_array = payload['cities'].sort_by{|x| x[e]}
            expect(result['cities']).to eq(expected_array)
          end
        end
      end

      it "Check response can be sorted by name for zh-cn", :tag => 'location_cities_au_cn' do |example|
        response = frontend_facade.get_cities_of_a_given_country('au', 'zh-cn', 'name')
        result = response.parsed_response
        expect(response.code).to be(200)
        expected_array = payload['cities'].sort_by{|x| x['name']}
        expect(result['cities']).to eq(expected_array)
      end
    end

    context "Get the details of a city" do

      let(:payload) { FrontendFacadePayload::Locations::City.payload key }

      it "Check basic info base on the given city for en-gb.", :tag => 'location_city_sydney_en' do |example|
        response = frontend_facade.get_details_of_a_city('sydney', 'en-gb')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result).to be_deep_equal(payload)
      end

      it "Check basic info base on the given city for zh-cn.", :tag => 'location_city_sydney_cn' do |example|
        response = frontend_facade.get_details_of_a_city('sydney', 'zh-cn')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result).to be_deep_equal(payload)
      end

      it "Check unpublished areas are not returned", :tag => 'location_city_london_en' do |example|
        response = frontend_facade.get_details_of_a_city('london', 'en-gb')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result['areas']).to be_deep_equal(payload['areas'])
      end
    end

    context "Get the list of areas of a given city." do

      let(:payload) { FrontendFacadePayload::Locations::Areas.payload key }

      it "Check basic info is correct base on given city for en-gb.", :tag => 'location_areas_sydney_en' do |example|
        response = frontend_facade.get_areas_of_a_given_city('sydney', 'en-gb')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result).to be_deep_equal(payload)
      end

      it "Check basic info is correct base on given city for zh-cn.", :tag => 'location_areas_sydney_cn' do |example|
        response = frontend_facade.get_areas_of_a_given_city('sydney', 'zh-cn')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result).to be_deep_equal(payload)
      end

      it "Check unpublished areas are not returned.", :tag => 'location_areas_london_en' do |example|
        response = frontend_facade.get_areas_of_a_given_city('london', 'en-gb')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result).to be_deep_equal(payload)
      end

      it "Check areas for non-area city" do
        expected = {"areas" => []}
        response = frontend_facade.get_areas_of_a_given_city('wellington-changed', 'en-gb')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result).to eq(expected)
      end

      it "Check response can be sorted by name,original_name,slug,rank for en-gb", :tag => 'location_areas_sydney_en' do |example|
        ["name", "original_name", "slug", "rank"].each do |e|
          response = frontend_facade.get_areas_of_a_given_city('sydney', 'en-gb', e)
          result = response.parsed_response
          expect(response.code).to be(200)
          if e == 'rank'
            expected_array = payload['areas'].sort_by{|x| x[e] * -1}
            size = expected_array.size
            for i in 0..size - 1
              expect(result['areas'][i]['rank']).to eq(expected_array[i]['rank'])
            end
          else
            expected_array = payload['areas'].sort_by{|x| x[e]}
            expect(result['areas']).to eq(expected_array)
          end
        end
      end

      it "Check response can be sorted by name for zh-cn", :tag => 'location_areas_sydney_cn' do |example|
        response = frontend_facade.get_areas_of_a_given_city('sydney', 'zh-cn', 'name')
        result = response.parsed_response
        expect(response.code).to be(200)
        expected_array = payload['areas'].sort_by{|x| x['name']}
        expect(result['areas']).to eq(expected_array)
      end
    end

    context "Get the details of an area" do

      let(:payload) { FrontendFacadePayload::Locations::Area.payload key }

      it "Check area infomation for en-gb", :tag => 'location_area_wembley_en' do |example|
        response = frontend_facade.get_details_of_an_area('wembley', 'en-gb')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result).to be_deep_equal(payload)
      end

      it "Check area infomation for zh-cn", :tag => 'location_area_wembley_cn' do |example|
        response = frontend_facade.get_details_of_an_area('wembley', 'zh-cn')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result).to be_deep_equal(payload)
      end
    end
  end
end
