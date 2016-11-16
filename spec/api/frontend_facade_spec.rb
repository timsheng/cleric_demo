require 'spec_helper'

describe "Frontend Facade" do

  subject(:frontend_facade) { FrontendFacade.new }
  let(:key) { key = @key }
  let(:params) { params = @params }

  before(:all) do
    
  end

  after(:each) do
    # frontend_facade.close_ssh frontend_facade.port
  end

  describe "Enquiries" do

    context "Create enquiry" do

      let(:payload) { FrontendFacadePayload::Enquiry::CreateEnquiry.payload key }
      let(:response) { frontend_facade.create_enquiry(payload, *params) }

      it "success for a new student, check enquiry/user/student is created, email is sent, token is returned and password_set is false.", :key => 'enquiry_full' do
        email = payload['student']['email']
        sql = "select m.body_text from messages m left join recipients r on r.message_id = m.id where r.email = '#{email}'"
        dbfactory = PropertiesDBFactory.new(@pool.use(:db => 'Identity_db'))
        expect(response[:status]).to be(200)
        expect(response[:message]['auth_token']).not_to be_nil
        expect(response[:message]['password_set']).to be false
        expect(dbfactory.query_identity_user(:email => email)).not_to be_empty
        dbfactory = PropertiesDBFactory.new(@pool.use(:db => 'Booking_db'))
        expect(dbfactory.query_booking_student(:email => email)).not_to be_empty
        student_id = dbfactory.query_booking_student(:email => email)[0][:id]
        expect(dbfactory.query_booking_enquiry(:student_id => student_id)).not_to be_empty
        dbfactory = PropertiesDBFactory.new(@pool.use(:db => 'Messages_db'))
        expect(dbfactory.query(sql)).not_to be_empty
      end

      it "failed for an exist student without JWT token", :key => 'enquiry_exist_user' do
        expect(response[:status]).to be(400)
        expect(response[:message]['error']).to eql("USER_ALREADY_EXISTS")
      end

      it "failed for an exist student with an incorrect token", :key => 'enquiry_exist_user' do
        response = frontend_facade.create_enquiry(payload, 'incorrect_token')
        expect(response[:status]).to be(401)
        expect(response[:message]['error']).to eql("INVALID_CREDENTIALS")
        expect(response[:message]['error_description']).to end_with("is invalid.")
      end
    end
  end

  describe "Users" do

    def get_reset_tokens is_valid = true
      sql = "select m.body_text from messages m left join recipients r on r.message_id = m.id where r.email = '#{payload['email']}' and m.status = 'sent' and m.body_text like '%reset-token%' order by m.created_at desc"
      dbfactory = PropertiesDBFactory.new(@pool.use(:db => 'Messages_db'))
      data = dbfactory.query(sql)
      if is_valid
        reset_token = data[0][:body_text].split("reset-token=")[1].split(" ")[0]
      elsif
        reset_token = data.last[:body_text].split("reset-token=")[1].split(" ")[0]
      end
      return [reset_token, data.count]
    end

    context "User sign up" do
      let(:payload) { FrontendFacadePayload::Users::Signup.payload key }
      let(:response) { frontend_facade.user_signup(payload) }

      it "able to sign up for a new user", :key => 'new_user' do
        expect(response[:status]).to be(200)
        expect(response[:message]['auth_token']).not_to be_nil
        sleep 1
        dbfactory = PropertiesDBFactory.new(@pool.use(:db => 'Booking_db'))
        expect(dbfactory.query_booking_student(:email => response[:message]['email'])).not_to be_empty
        dbfactory = PropertiesDBFactory.new(@pool.use(:db => 'Identity_db'))
        expect(dbfactory.query_identity_user(:email => response[:message]['email'])).not_to be_empty
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

        it "the two token is able to create enquiry for exist user" do
          payload_enquiry = FrontendFacadePayload::Enquiry::CreateEnquiry.payload('enquiry_exist_user')
          [token_1, token_2].each do |e|
            response = frontend_facade.create_enquiry(payload_enquiry, e)
            expect(response[:status]).to be(200)
            expect(response[:message]['auth_token']).to eq(e)
            expect(response[:message]['password_set']).to be true
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

      it "success if provide real email", :key => 'exist_user', :params => ['zh-cn'] do
        result = get_reset_tokens
        expect(response[:status]).to be(200)
        sleep 10
        expected = get_reset_tokens
        expect(expected[1]).to be(result[1] + 1)
      end

      it "success if provide un-exist email", :key => 'new_user', :params => ['zh-cn'] do
        expect(response[:status]).to be(200)
      end

      it "failed if language is not provided", :key => 'exist_user' do
        expect(response[:status]).to be(400)
        expect(response[:message]['error']).to eql("BAD_REQUEST")
        expect(response[:message]['error_description']).to eql("`language code` must be provided.")
      end
    end

    context "Reset password", :key => 'exist_user' do
      let(:payload) { FrontendFacadePayload::Users::User.payload key }

      it "success if provide a valid reset_password_token" do
        reset_token = get_reset_tokens
        response = frontend_facade.user_reset_password(reset_token[0], "Password12")
        expect(response[:status]).to be(200)
        expect(response[:message]['auth_token']).not_to be_nil
      end

      it "fail to reset password with incorrect reset_password_token." do
        response = frontend_facade.user_reset_password("incorrect_token", "Password12")
        expect(response[:status]).to be(401)
        expect(response[:message]['error']).to eq("INVALID_CREDENTIALS")
        expect(response[:message]['error_description']).to end_with("is invalid.")
      end

      it "fail to reset password if token is expired(more than 24 hours)." do
        reset_token = get_reset_tokens false
        response = frontend_facade.user_reset_password(reset_token[0], "Password12")
        expect(response[:status]).to be(401)
        expect(response[:message]['error']).to eq("INVALID_CREDENTIALS")
        expect(response[:message]['error_description']).to end_with("is invalid.")
      end

      it "fail to reset password without password and correct reset_password_token." do
        reset_token = get_reset_tokens
        response = frontend_facade.user_reset_password(reset_token[0])
        expect(response[:status]).to be(400)
        expect(response[:message]['error']).to eq("BAD_REQUEST")
      end
    end

    context "Validate reset_password_token", :key => 'exist_user' do
      let(:payload) { FrontendFacadePayload::Users::User.payload key }

      it "success if provide a valid reset_password_token" do
        reset_token = get_reset_tokens
        response = frontend_facade.validate_reset_token(reset_token[0])
        expect(response[:status]).to be(200)
      end

      it "fail if provide a expired reset_password_token(more than 24h)" do
        reset_token = get_reset_tokens false
        response = frontend_facade.validate_reset_token(reset_token[0])
        expect(response[:status]).to be(401)
        expect(response[:message]['error']).to eq("INVALID_CREDENTIALS")
        expect(response[:message]['error_description']).to end_with("is invalid.")
      end

      it "fail if provide a incorrect reset_password_token" do
        response = frontend_facade.validate_reset_token("incorrect_token")
        expect(response[:status]).to be(401)
        expect(response[:message]['error']).to eq("INVALID_CREDENTIALS")
        expect(response[:message]['error_description']).to end_with("is invalid.")
      end
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

      it "failed if token is not provided" do
        expect(response[:status]).to be(401)
        expect(response[:message]['error']).to eq("INVALID_CREDENTIALS")
        expect(response[:message]['error_description']).to eq("Token not found.")
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

        it "translated is false if property is not translated", :params => ['testing-room-property-11','zh-cn'] do
          expect(response[:status]).to be(200)
          expect(response[:message]['translated']).to be false
        end

        it "unpublished property return 404", :params => ['1-penta-house','zh-cn'] do
          dbfactory = PropertiesDBFactory.new(@pool.use(:db => 'Property_db'))
          data = dbfactory.db[:properties].filter(:published => 0, :slug => "1-penta-house").all
          expect(data.count).to be(1)
          expect(response[:status]).to be(404)
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

      it "unpublished property return 404", :params => ['1-penta-house'] do
        dbfactory = PropertiesDBFactory.new(@pool.use(:db => 'Property_db'))
        data = dbfactory.db[:properties].filter(:published => 0, :slug => "1-penta-house").all
        expect(data.count).to be(1)
        expect(response[:status]).to be(404)
      end

      context "Check unit", :key => 'testing_room_property11', :params => ['testing-room-property-11'] do
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

      context "Check listing", :key => 'testing_room_property11', :params => ['testing-room-property-11'] do
        # 999999008 has a range price
        it "basic info should including id, availability, price_min, price_max" do
          expect(response[:status]).to be(200)
          listing_expected = get_elements(payload, 'private-room', 'Unit 1', 999999008)
          listing_actual = get_elements(response[:message], 'private-room', 'Unit 1', 999999008)
          ['availability', 'price_min', 'price_max'].each do |e|
            expect(listing_actual[e]).to eq(listing_expected[e])
          end
        end

        it "should return correct discount price and discount type" do
          # 999999008 absolute discount, 999999006 percentage discount
          expect(response[:status]).to be(200)
          [999999008, 999999006].each do |e|
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
          # Check listing 999999007, 999999004 of Unit 1 is not returned because there're inactive.
          expect(response[:status]).to be(200)
          unit_actual = get_elements(response[:message], 'private-room', 'Unit 1')
          listing_ids = []
          unit_actual['listings'].each do |e|
            listing_ids << e['id']
          end
          expect(listing_ids).to be_deep_equal(listing_ids - [999999007, 999999004])
        end

        it "should return correct duration max and duration min and l18n_key" do
          # Listing type: 999999006 fixed, 999999008 fixed-open-end, 999999009 flexible, 999999011 flexible-open-end, 999999002 placeholder
          expect(response[:status]).to be(200)
          [999999006, 999999008, 999999009, 999999011, 999999002].each do |e|
            listing_expected = get_elements(payload, 'private-room', 'Unit 1', e)
            listing_actual = get_elements(response[:message], 'private-room', 'Unit 1', e)
            ['duration_min', 'duration_max', 'i18n_key'].each do |e1|
              expect(listing_actual['durations'][e1]).to eq(listing_expected['durations'][e1])
            end
          end
        end

        it "should return correct start dates and l18n_key" do
          # Listing type: 999999006 fixed, 999999008 fixed-open-end, 999999009 flexible, 999999011 flexible-open-end, 999999002 placeholder
          expect(response[:status]).to be(200)
          [999999006, 999999008, 999999009, 999999011, 999999002].each do |e|
            listing_expected = get_elements(payload, 'private-room', 'Unit 1', e)
            listing_actual = get_elements(response[:message], 'private-room', 'Unit 1', e)
            ['start_date_min', 'start_date_max', 'i18n_key'].each do |e1|
              expect(listing_actual['start_dates'][e1]).to eq(listing_expected['start_dates'][e1])
            end
          end
        end

        it "should return correct listing tenancy_periods", :key => 'testing_room_property11', :params => 'testing-room-property-11' do
          # Listing type: 999999009 flexible
          expect(response[:status]).to be(200)
          listing_expected = get_elements(payload, 'private-room', 'Unit 1', 999999009)
          listing_actual = get_elements(response[:message], 'private-room', 'Unit 1', 999999009)
          expect(listing_actual['tenancy_periods']).to be_deep_equal(listing_expected['tenancy_periods'])
        end
      end

      context "Check category", :key => 'testing_room_property12', :params => 'testing-room-property-12' do
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

        it "state should be available_with_price or inactive", :key => 'testing_room_property11', :params => 'testing-room-property-11' do
          expect(response[:status]).to be(200)
          ['private-room', 'shared-room'].each do |e|
            category_expected = get_elements(payload, e)
            category_actual = get_elements(response[:message], e)
            expect(category_actual['state']).to eq(category_expected['state'])
          end
        end
      end

      context "Check property state" do
        it "should be available_with_price if there have available_with_price, available, coming_soon category.", :key => 'testing_room_property11', :params => 'testing-room-property-11' do
          expect(response[:status]).to be(200)
          expect(response[:message]['state']).to eq(payload['state'])
        end

        it "should be available if there have available, coming_soon, sold_out category.", :key => 'testing_room_property12', :params => 'testing-room-property-12' do
          expect(response[:status]).to be(200)
          expect(response[:message]['state']).to eq(payload['state'])
        end

        it "should be coming_soon if there have coming_soon, sold_out category at least.", :key => 'testing_room_property13', :params => 'testing-room-property-13' do
          expect(response[:status]).to be(200)
          expect(response[:message]['state']).to eq(payload['state'])
        end

        it "should be sold_out if all categories are sold_out or state = null.", :key => 'testing_room_property14', :params => 'testing-room-property-14' do
          expect(response[:status]).to be(200)
          expect(response[:message]['state']).to eq(payload['state'])
        end
      end
    end
  end

  describe 'Universities' do
    let(:dbfactory) { PropertiesDBFactory.new(@pool.use(:db => 'Universities_db')) }

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
          data = dbfactory.query_universities(:slug => "city-of-glasgow-college")
          expect(data[0][:published]).to be false
          expect(response[:status]).to be(200)
          response[:message]['universities'].each do |e|
            expect(e['slug']).not_to eq('city-of-glasgow-college')
          end
        end
      end

      context "Check all universities" do
        it "should return if country and city is not specified.", :params => [nil, nil, 'en-gb'] do
          data = dbfactory.query_universities(:published => 1)
          expect(response[:status]).to be(200)
          expect(response[:message]['universities'].size).to eq data.count
        end

        it "can be returned if country and city is specified.", :params => [nil, 'london', 'en-gb'] do
          data = dbfactory.db[:universities].filter(:published => 1, :city_id => 412).all
          expect(response[:status]).to be(200)
          expect(response[:message]['universities'].size).to eq data.count
        end

        it "can be sorted by name, original_name, slug and rank.", :key => 'given_jp_cn' do
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
    let(:dbfactory) { PropertiesDBFactory.new(@pool.use(:db => 'Locations_db')) }

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
          data = dbfactory.query_locations_countries(:slug => "da")
          expect(data[0][:published]).to be false
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
        it "unpublished cities shouldn't return.", :params => ['us', 'en-gb'] do
          data = dbfactory.query_locations_cities(:slug => "north-miami-fl")
          expect(data[0][:published]).to be false
          expect(response[:status]).to be(200)
          response[:message]['cities'].each do |e|
            expect(e['slug']).not_to eq('north-miami-fl')
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

        it "quick_facts and points_of_interest is returned for non-area city", :key => 'location_city_wellington_en', :params => ['wellington-changed', 'en-gb'] do
          expect(response[:status]).to be(200)
          expect(response[:message]['quick_facts']).to be_deep_equal(payload['quick_facts'])
          expect(response[:message]['points_of_interest']).to be_deep_equal(payload['points_of_interest'])
        end
      end

      context "Check unpublished areas" do
        it "shouldn't be returned", :params => ['london', 'en-gb'] do
          data = dbfactory.query_locations_areas(:slug => "central-london")
          expect(data[0][:published]).to be false
          expect(response[:status]).to be(200)
          response[:message]['areas'].each do |e|
            expect(e['slug']).not_to eq('central-london')
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
          data = dbfactory.query_locations_areas(:slug => "central-london")
          expect(data[0][:published]).to be false
          expect(response[:status]).to be(200)
          response[:message]['areas'].each do |e|
            expect(e['slug']).not_to eq('central-london')
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
