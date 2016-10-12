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

      it "Check state if there have available, coming_soon or sold_out. ", :tag => 'testing_room_property2' do |example|
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

      it "Check state is available_with_price or no active units in the category. ", :tag => 'testing_room_property1' do |example|
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

      it "Check state is available_with_price if there have available_with_price, available, coming_soon category. ", :tag => 'testing_room_property1' do |example|
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-1')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result['state']).to be_deep_equal(payload['state'])
      end

      it "Check state is available if there have available, coming_soon, sold_out category. ", :tag => 'testing_room_property2' do |example|
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-2')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result['state']).to be_deep_equal(payload['state'])
      end

      it "Check state is coming_soon if there have coming_soon, sold_out category at least. ", :tag => 'testing_room_property3' do |example|
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-3')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result['state']).to be_deep_equal(payload['state'])
      end

      it "Check state is sold_out if all categories are sold_out or state = null.", :tag => 'testing_room_property4' do |example|
        response = frontend_facade.get_rooms_for_a_property('testing-room-property-4')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result['state']).to be_deep_equal(payload['state'])
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
