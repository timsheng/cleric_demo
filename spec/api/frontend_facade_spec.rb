require 'spec_helper'

describe "Frontend Facade" do

  subject(:frontend_facade) { FrontendFacade.new }
  let(:key) { key = @key }
  let(:params) { params = @params }

  describe "Users" do

    context "User sign up" do
      let(:payload) { FrontendFacadePayload::Users::Signup.payload key }
      let(:response) { frontend_facade.user_signup(payload) }

      it "able to sign up for a new user", :key => 'new_user' do
        expect(response[:status]).to be(200)
        expect(response[:message]['auth_token']).not_to be_nil
      end

      it "unable to sign up for an exist user", :key => 'exist_user' do
        expect(response[:status]).to be(400)
        expect(response[:message]['error']).to eql("USER_ALREADY_EXISTS")
      end

      it "unable to sign up with an invalid email", :key => 'invalid_email_user' do
        expect(response[:status]).to be(400)
        expect(response[:message]['error']).to eql("BAD_REQUEST")
        expect(response[:message]['error_description']).to eql("Validation failure")
      end
    end

    context "User login" do
      let(:payload) { FrontendFacadePayload::Users::Login.payload key }
      let(:response) { frontend_facade.user_login(payload) }
      let(:response_twice) { frontend_facade.user_login(payload) }

      it "able to login with correct password", :key => 'user_correct_password' do
        expect(response[:status]).to be(200)
        expect(response[:message]['auth_token']).not_to be_nil
      end

      it "unable to login with incorrect password", :key => 'user_incorrect_password' do
        expect(response[:status]).to be(401)
        expect(response[:message]['error']).to eql("INVALID_CREDENTIALS")
      end

      context "Check multiple JWT-token is available", :key => 'user_correct_password' do
        let(:token_1) {response[:message]['auth_token']}
        let(:token_2) {response_twice[:message]['auth_token']}

        it "there is different token if user login twice" do
          expect(token_1).not_to eql(token_2)
        end

        it "the two token is able to create enquiry" do
          payload_enquiry = FrontendFacadePayload::Enquiry::CreateEnquiry.payload('enquiry1')
          [token_1, token_2].each do |e|
            response = frontend_facade.create_enquiry(payload_enquiry, e)
            expect(response[:status]).to be(200)
          end
        end

        it "the two token is able to set password" do
          payload_password = FrontendFacadePayload::Users::SetPassword.payload('password2')
          [token_1, token_2].each do |e|
            response = frontend_facade.user_set_password(payload_password, e)
            expect(response[:status]).to be(200)
          end
        end
      end
    end

    context "User forgot password" do
      let(:payload) { FrontendFacadePayload::Users::User.payload key }
      let(:response) { frontend_facade.user_forgot_password(payload, *params) }

      it "failed if language is not provided", :key => 'exist_user' do
        expect(response[:status]).to be(400)
        expect(response[:message]['error']).to eql("BAD_REQUEST")
        expect(response[:message]['error_description']).to eql("`language code` must be provided.")
      end

      it "success if provide real email", :key => 'exist_user', :params => ['zh-cn'] do
        expect(response[:status]).to be(200)
      end

      it "failed if provide un-exist email", :key => 'new_user', :params => ['zh-cn'] do
        expect(response[:status]).to be(404)
        expect(response[:message]['error']).to eql("USER_NOT_FOUND")
      end
    end

    context "Reset password" do
      pending
    end

    context "Validate reset_password_token" do
      pending
    end

    context "Check user exists" do
      let(:payload) { FrontendFacadePayload::Users::User.payload key }
      let(:response) { frontend_facade.check_user_exist(payload) }

      it "true if user exist", :key => 'exist_user' do
        expect(response[:status]).to be(200)
      end

      it "false if user doesn't exist", :key => 'new_user' do
        expect(response[:status]).to be(404)
        expect(response[:message]['error']).to eql("USER_NOT_FOUND")
      end
    end

    context "Set password" do
      let(:payload_new_user) { FrontendFacadePayload::Users::Signup.payload 'new_user'}
      let(:payload_password) { FrontendFacadePayload::Users::SetPassword.payload 'password1'}
      let(:response_signup) { frontend_facade.user_signup(payload_new_user) }
      let(:response) { frontend_facade.user_set_password(payload_password, *params) }

      it "failed if token is not provided" do
        expect(response[:status]).to be(401)
        expect(response[:message]['error']).to eq("INVALID_CREDENTIALS")
        expect(response[:message]['error_description']).to eq("Token not found.")
      end

      it "success if token is avaiable" do
        response = frontend_facade.user_set_password(payload_password, response_signup[:message]['auth_token'])
        expect(response[:status]).to be(200)
        expect(response[:message]['auth_token']).to eq(response_signup[:message]['auth_token'])
      end

      it "failed if token is incorrect", :params => ['incorrecttoken'] do
        expect(response[:status]).to be(401)
        expect(response[:message]['error']).to eq("INVALID_CREDENTIALS")
        expect(response[:message]['error_description']).to eq("Token incorrecttoken is invalid.")
      end
    end
  end

  describe 'Property' do
    context "Get summary of a property" do
      let(:payload) { FrontendFacadePayload::Property::Summary.payload key }
      let(:response) { frontend_facade.get_summary_for_a_property(*params) }

      context "Check summary for a property" do
        it "should be correct for en-gb", :key => 'student_village_summary_en', :params => ['student-village','en-gb'] do
          expect(response[:status]).to be(200)
          expect(response[:message]).to be_deep_equal(payload)
        end

        it "should be correct for zh-cn", :key => 'te_puni_village_summary_cn', :params => ['te-puni-village','zh-cn'] do
          expect(response[:status]).to be(200)
          expect(response[:message]).to be_deep_equal(payload)
        end

        it "translated is false if property is not translated", :params => ['testing-room-property-5','zh-cn'] do
          expect(response[:status]).to be(200)
          expect(response[:message]['translated']).to be false
        end
      end
    end

    context "Get rooms of a property" do
      let(:payload) { FrontendFacadePayload::Property::Rooms.payload key }
      let(:response) { frontend_facade.get_rooms_for_a_property(*params) }

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

      context "Check unit", :key => 'testing_room_property1', :params => ['testing-room-property-1'] do
        it "basic info should including bathroom_type, max_occupancy, id, name, distinctions" do
          expect(response[:status]).to be(200)
          unit_expected = get_elements(payload, 'private-room', 'Unit 1')
          unit_actual = get_elements(response[:message], 'private-room', 'Unit 1')
          ['bathroom_type', 'max_occupancy', 'id', 'name', 'distinctions'].each do |e|
            expect(unit_actual[e]).to be_deep_equal(unit_expected[e])
          end
        end

        it "state should including available_with_price, available, coming_soon, sold_out" do
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
      end

      context "Check listing", :key => 'testing_room_property1', :params => ['testing-room-property-1'] do
        it "basic info should including id, availability, price_min, price_max" do
          expect(response[:status]).to be(200)
          listing_expected = get_elements(payload, 'private-room', 'Unit 1', 68918)
          listing_actual = get_elements(response[:message], 'private-room', 'Unit 1', 68918)
          ['availability', 'price_min', 'price_max'].each do |e|
            expect(listing_actual[e]).to eq(listing_expected[e])
          end
        end

        it "should return correct discount price and discount type" do
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

        it "state should including available_with_price, available, coming_soon or sold_out." do
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

          expect(response[:status]).to be(200)
          unit_expected = get_elements(payload, 'private-room', 'Unit 1')
          unit_actual = get_elements(response[:message], 'private-room', 'Unit 1')
          listings_expected = get_listing_id_state(unit_expected['listings'])
          listings_actual = get_listing_id_state(unit_actual['listings'])
          expect(listings_actual).to be_deep_equal(listings_expected)
        end

        it "inactive listing shouldn't be returned from api." do
          # Check listing 68925, 68926, 68927, 68928 of Unit 1 is not returned because there're inactive.
          expect(response[:status]).to be(200)
          unit_actual = get_elements(response[:message], 'private-room', 'Unit 1')
          listing_ids = []
          unit_actual['listings'].each do |e|
            listing_ids << e['id']
          end
          expect(listing_ids).to be_deep_equal(listing_ids - [68925, 68926, 68927, 68928])
        end

        it "should return correct duration max and duration min and l18n_key" do
          expect(response[:status]).to be(200)
          [68918, 68924, 68922, 68917, 68920].each do |e|
            listing_expected = get_elements(payload, 'private-room', 'Unit 1', e)
            listing_actual = get_elements(response[:message], 'private-room', 'Unit 1', e)
            ['duration_min', 'duration_max', 'i18n_key'].each do |e1|
              expect(listing_actual['durations'][e1]).to eq(listing_expected['durations'][e1])
            end
          end
        end

        it "should return correct start dates and l18n_key" do
          expect(response[:status]).to be(200)
          [68918, 68924, 68922, 68919, 68920].each do |e|
            listing_expected = get_elements(payload, 'private-room', 'Unit 1', e)
            listing_actual = get_elements(response[:message], 'private-room', 'Unit 1', e)
            ['start_date_min', 'start_date_max', 'i18n_key'].each do |e1|
              expect(listing_actual['start_dates'][e1]).to eq(listing_expected['start_dates'][e1])
            end
          end
        end

        it "should return correct listing tenancy_periods", :key => 'testing_room_property4', :params => 'testing-room-property-4' do
          expect(response[:status]).to be(200)
          listing_expected = get_elements(payload, 'private-room', 'Unit 1', 68937)
          listing_actual = get_elements(response[:message], 'private-room', 'Unit 1', 68937)
          expect(listing_actual['tenancy_periods']).to be_deep_equal(listing_expected['tenancy_periods'])
        end
      end

      context "Check category", :key => 'testing_room_property2', :params => 'testing-room-property-2' do
        it "basic info should including name." do
          expect(response[:status]).to be(200)
          categories = response[:message]['categories']
          result_category_name = []
          expect_category_name = ['shared-room','private-room','entire-place']
          categories.each do |e|
            result_category_name << e['name']
          end
          expect(result_category_name).to be_deep_equal(expect_category_name)
        end

        it "state should include available, coming_soon or sold_out." do
          expect(response[:status]).to be(200)
          ['private-room', 'shared-room', 'entire-place'].each do |e|
            category_expected = get_elements(payload, e)
            category_actual = get_elements(response[:message], e)
            expect(category_actual['state']).to eq(category_expected['state'])
          end
        end

        it "state should be available_with_price or inactive", :key => 'testing_room_property1', :params => 'testing-room-property-1' do
          expect(response[:status]).to be(200)
          ['private-room', 'shared-room'].each do |e|
            category_expected = get_elements(payload, e)
            category_actual = get_elements(response[:message], e)
            expect(category_actual['state']).to eq(category_expected['state'])
          end
        end
      end

      context "Check property state" do
        it "should be available_with_price if there have available_with_price, available, coming_soon category.", :key => 'testing_room_property1', :params => 'testing-room-property-1' do
          expect(response[:status]).to be(200)
          expect(response[:message]['state']).to eq(payload['state'])
        end

        it "should be available if there have available, coming_soon, sold_out category.", :key => 'testing_room_property2', :params => 'testing-room-property-2' do
          expect(response[:status]).to be(200)
          expect(response[:message]['state']).to eq(payload['state'])
        end

        it "should be coming_soon if there have coming_soon, sold_out category at least.", :key => 'testing_room_property3', :params => 'testing-room-property-3' do
          expect(response[:status]).to be(200)
          expect(response[:message]['state']).to eq(payload['state'])
        end

        it "should be sold_out if all categories are sold_out or state = null.", :key => 'testing_room_property4', :params => 'testing-room-property-4' do
          expect(response[:status]).to be(200)
          expect(response[:message]['state']).to eq(payload['state'])
        end
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
      let(:response) { frontend_facade.get_details_of_a_given_university(*params) }

      context "Check basic info" do
        it "should be correct based on given university for en-gb.", :key => 'university_of_liverpool_details_en', :params => ['university-of-liverpool', 'en-gb'] do
          expect(response[:status]).to be(200)
          expect(response[:message]).to eq(payload)
        end

        it "should be correct based on given university for zh-cn.", :key => 'university_of_liverpool_details_cn', :params => ['university-of-liverpool', 'zh-cn'] do
          expect(response[:status]).to be(200)
          expect(response[:message]).to eq(payload)
        end
      end
    end

    context "Get a list of universities." do
      let(:payload) { FrontendFacadePayload::Universities::List.payload key }
      let(:response) { frontend_facade.get_list_of_universities(*params) }

      context "Check basic info" do
        it "should be correct for zh-cn.", :key => 'given_ae_cn', :params => ['ae', nil, 'zh-cn'] do
          expect(response[:status]).to be(200)
          expect(response[:message]).to eq(payload)
        end

        it "should be correct for en-gb.", :key => 'given_ae_en', :params => ['ae', nil, 'en-gb'] do
          expect(response[:status]).to be(200)
          expect(response[:message]).to eq(payload)
        end
      end

      context "Check unpublished university", :params => [nil, 'glasgow', 'en-gb'] do
        it "should not returned." do
          # city-of-glasgow-college is not published.
          expect(response[:status]).to be(200)
          response[:message]['universities'].each do |e|
            expect(e['slug']).not_to eq('city-of-glasgow-college')
          end
        end
      end

      context "Check all universities" do
        it "should return if country and city is not specified.", :params => [nil, nil, 'en-gb'] do
          expect(response[:status]).to be(200)
          expect(response[:message]['universities'].size).to eq 837
        end

        it "can be returned if country and city is specified.", :params => [nil, 'london', 'en-gb'] do
          expect(response[:status]).to be(200)
          expect(response[:message]['universities'].size).to eq 85
        end

        it "can be sorted by name, original_name, slug and rank.", :key => 'given_jp_en' do
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
  end

  describe "Locations" do
    context "Get the list of countries", :key => 'location_countries_list_en', :params => 'en-gb' do
      let(:payload) { FrontendFacadePayload::Locations::Countries.payload key }
      let(:response) { frontend_facade.get_list_of_countries(*params) }

      context "Check basic info" do
        it "should be correct for en-gb." do
          expect(response[:status]).to be(200)
          expect(response[:message]).to be_deep_equal(payload)
        end

        it "should be correct for zh-cn.", :key => 'location_countries_list_cn', :params => 'zh-cn' do
          expect(response[:status]).to be(200)
          expect(response[:message]).to be_deep_equal(payload)
        end
      end

      context "Check countries" do
        it "should can be sorted by name, original_name, slug for en-gb" do
          ["name", "original_name", "slug"].each do |e|
            expected_array = payload['countries'].sort_by{|x| x[e]}
            response = frontend_facade.get_list_of_countries('en-gb', e)
            expect(response[:status]).to be(200)
            expect(response[:message]['countries']).to eq(expected_array)
          end
        end

        it "should be sorted by name for zh-cn", :key => 'location_countries_list_cn', :params => ['zh-cn', 'name'] do
          expected_array = payload['countries'].sort_by{|x| x['name']}
          response = frontend_facade.get_list_of_countries('zh-cn', 'name')
          expect(response[:status]).to be(200)
          expect(response[:message]['countries']).to eq(expected_array)
        end
      end

      context "Check unpublished country" do
        it "Check unpublished country is not returned." do
          # da is not published.
          expect(response[:status]).to be(200)
          response[:message]['countries'].each do |e|
            expect(e['slug']).not_to eq('da')
          end
        end
      end
    end

    context "Get the list of cities of a given country", :key => 'location_cities_au_en', :params => ['au', 'en-gb'] do
      let(:payload) { FrontendFacadePayload::Locations::Cities.payload key }
      let(:response) { frontend_facade.get_cities_of_a_given_country(*params) }

      context "Check basic info" do
        it "should be correct based on given country for en-gb." do
          expect(response[:status]).to be(200)
          expect(response[:message]).to be_deep_equal(payload)
        end

        it "should be correct based on given country for zh-cn.", :key => 'location_cities_au_cn', :params => ['au', 'zh-cn'] do
          expect(response[:status]).to be(200)
          expect(response[:message]).to be_deep_equal(payload)
        end
      end

      context "Check cities" do
        it "unpublished cities shouldn't return for de.", :key => 'location_cities_de_en', :params => ['de', 'en-gb'] do
          expect(response[:status]).to be(200)
          response[:message]['cities'].each do |e|
            expect(e['slug']).not_to eq('unpublished-city-test-dan')
          end
        end

        it "can be sorted by name, original_name, slug, rank for en-gb" do
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

        it "can be sorted by name for zh-cn", :key => 'location_cities_au_cn', :params => ['au', 'zh-cn', 'name'] do
          expect(response[:status]).to be(200)
          expected_array = payload['cities'].sort_by{|x| x['name']}
          expect(response[:message]['cities']).to eq(expected_array)
        end
      end
    end

    context "Get the details of a city" do
      let(:payload) { FrontendFacadePayload::Locations::City.payload key }
      let(:response) { frontend_facade.get_details_of_a_city(*params) }

      context "Check basic info" do
        it "should be correct based on the given city for en-gb.", :key => 'location_city_sydney_en', :params => ['sydney', 'en-gb'] do
          expect(response[:status]).to be(200)
          expect(response[:message]).to be_deep_equal(payload)
        end

        it "should be correct based on the given city for zh-cn.", :key => 'location_city_sydney_cn', :params => ['sydney', 'zh-cn'] do
          expect(response[:status]).to be(200)
          expect(response[:message]).to be_deep_equal(payload)
        end
      end

      context "Check unpublished areas" do
        it "shouldn't be returned", :params => ['london', 'en-gb'] do
          expect(response[:status]).to be(200)
          response[:message]['areas'].each do |e|
            expect(e['slug']).not_to eq('london-area-test')
          end
        end
      end
    end

    context "Get the list of areas of a given city.", :key => 'location_areas_sydney_en', :params => ['sydney', 'en-gb'] do
      let(:payload) { FrontendFacadePayload::Locations::Areas.payload key }
      let(:response) { frontend_facade.get_areas_of_a_given_city(*params) }

      context "Check basic info" do
        it "should be correct base on given city for en-gb." do
          expect(response[:status]).to be(200)
          expect(response[:message]).to be_deep_equal(payload)
        end

        it "should be correct base on given city for zh-cn.", :key => 'location_areas_sydney_cn', :params => ['sydney', 'zh-cn'] do
          expect(response[:status]).to be(200)
          expect(response[:message]).to be_deep_equal(payload)
        end
      end

      context "Check unpublished areas" do
        it "shouldn't return.", :params => ['london', 'en-gb'] do
          expect(response[:status]).to be(200)
          response[:message]['areas'].each do |e|
            expect(e['slug']).not_to eq('london-area-test')
          end
        end
      end

      context "Check areas" do
        it "should be correct for non-area city", :params => ['wellington-changed', 'en-gb'] do
          expected = {"areas" => []}
          expect(response[:status]).to be(200)
          expect(response[:message]).to eq(expected)
        end

        it "can be sorted by name, original_name, slug, rank for en-gb" do
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

        it "can be sorted by name for zh-cn", :key => 'location_areas_sydney_cn', :params => ['sydney', 'zh-cn', 'name'] do
          expect(response[:status]).to be(200)
          expected_array = payload['areas'].sort_by{|x| x['name']}
          expect(response[:message]['areas']).to eq(expected_array)
        end
      end
    end

    context "Get the details of an area" do
      let(:payload) { FrontendFacadePayload::Locations::Area.payload key }
      let(:response) { frontend_facade.get_details_of_an_area(*params) }

      context "Check area basic info" do
        it "should be correct for en-gb", :key => 'location_area_wembley_en', :params => ['wembley', 'en-gb'] do
          expect(response[:status]).to be(200)
          expect(response[:message]).to be_deep_equal(payload)
        end

        it "should be correct for zh-cn", :key => 'location_area_wembley_cn', :params => ['wembley', 'zh-cn'] do
          expect(response[:status]).to be(200)
          expect(response[:message]).to be_deep_equal(payload)
        end
      end
    end
  end
end

describe "demo" do
  after(:each) {frontend_facade.close_ssh frontend_facade.port}

  context "db" do
    let(:frontend_facade) { FrontendFacade.new(:ssh => 'Property_ssh', :db => 'Property_db')}

    it "arbitrary raw SQL example" do
      dataset = frontend_facade.db["select id, name from properties limit 10"]
      # will return the number of records in the result set
      dataset.count
      # will return an array containing all values of the id column in the result set
      dataset.map(:id)
      dataset.each do |row|
        p row
      end
    end

    it "change database" do
      frontend_facade.connect_database('Listing_db')
    end

    it "avg column by" do
      puts frontend_facade.avg_property_rank(:city_lsg_id => 231004020)
    end

    it "query specific column by" do
      # id is unique
      puts frontend_facade.query_property_rank(:id => 1)
    end

    it "query columns by" do
      # city_lsg_id is not unique
      puts frontend_facade.query_property_rank(:city_lsg_id => 231004020)
    end

  end

end
