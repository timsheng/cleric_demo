require 'spec_helper'

describe "Frontend Facade" do

  let(:frontend_facade) {FrontendFacade.new()}

  describe "Users" do
    it "should create user", :tag => 'Users1' do |example|
      key = example.metadata[:tag]
      frontend_facade_payload = FrontendFacadePayload.new(key)
      puts frontend_facade_payload.payload
      response = frontend_facade.create_user(frontend_facade_payload.payload)
      expect(response.code).to be(200)
    end
  end

  describe 'Property' do

    context "Property summary" do
      it "get summary for a property for en-gb", :tag => 'student_villiage_summary_en' do |example|
        key = example.metadata[:tag]
        frontend_facade_payload = FrontendFacadePayload.new(key)
        expected = frontend_facade_payload.payload
        response = frontend_facade.get_summary_for_a_property('student-village', 'en-gb')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result).to be_deep_equal(expected)
      end

      it "get summary for a property for zh-cn", :tag => 'te_puni_village_summary_cn' do |example|
        key = example.metadata[:tag]
        frontend_facade_payload = FrontendFacadePayload.new(key)
        expected = frontend_facade_payload.payload
        response = frontend_facade.get_summary_for_a_property('te-puni-village', 'zh-cn')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result).to be_deep_equal(expected)
      end
    end

    context "Get Property" do
      it "dbfactory demo" ,:tag => 'Users2' do |example|
        key = example.metadata[:tag]
        frontend_facade = FrontendFacade.new(:ssh => 'Property_ssh', :db => 'Property_db')
        # puts frontend_facade.id
        # puts frontend_facade.name
        # puts frontend_facade.address
        puts frontend_facade.expect_result(key)
      end
    end

    context "new payload structure" do
      it "demo", :tag => 'student_villiage_summary_en' do |example|
        key = example.metadata[:tag]
        property_payload = FrontendFacadePayload::Property::Summary.new(key)
        puts property_payload.payload
      end
    end
  end

  describe "Locations" do

    context "Get the list of countries" do

      def check_countries_sort key, sort, locale
        frontend_facade_payload = FrontendFacadePayload.new(key)
        expected = frontend_facade_payload.payload
        expected_array = expected['countries'].sort_by{|x| x[sort]}
        response = frontend_facade.get_list_of_countries(locale, sort)
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result['countries']).to eq(expected_array)
      end

      it "Check basic information is correct for en-gb and unpublished country is not returned.", :tag => 'location_countries_list_en' do |example|
        key = example.metadata[:tag]
        frontend_facade_payload = FrontendFacadePayload.new(key)
        expected = frontend_facade_payload.payload
        response = frontend_facade.get_list_of_countries('en-gb')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result).to be_deep_equal(expected)
      end

      it "Check basic information is correct for zh-cn.", :tag => 'location_countries_list_cn' do |example|
        key = example.metadata[:tag]
        frontend_facade_payload = FrontendFacadePayload.new(key)
        expected = frontend_facade_payload.payload
        response = frontend_facade.get_list_of_countries('zh-cn')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result).to be_deep_equal(expected)
      end

      it "Check response can be sorted by name,original_name,slug for en-gb", :tag => 'location_countries_list_en' do |example|
        key = example.metadata[:tag]
        ["name", "original_name", "slug"].each do |e|
          check_countries_sort(key, e, 'en-gb')
        end
      end

      it "Check response can be sorted by name for zh-cn", :tag => 'location_countries_list_cn' do |example|
        key = example.metadata[:tag]
        check_countries_sort(key, 'name', 'zh-cn')
      end
    end

    context "Get the list of cities of a given country" do

      def check_cities_sort key, sort, locale
        frontend_facade_payload = FrontendFacadePayload.new(key)
        expected = frontend_facade_payload.payload
        response = frontend_facade.get_cities_of_a_given_country('au', locale, sort)
        result = response.parsed_response
        expect(response.code).to be(200)
        if sort == 'rank'
          expected_array = expected['cities'].sort_by{|x| x[sort] * -1}
          size = expected_array.size
          for i in 0..size - 1
            expect(result['cities'][i]['rank']).to eq(expected_array[i]['rank'])
          end
        else
          expected_array = expected['cities'].sort_by{|x| x[sort]}
          expect(result['cities']).to eq(expected_array)
        end
      end

      it "Check basic information is correct based on given country for en-gb.", :tag => 'location_cities_au_en' do |example|
        key = example.metadata[:tag]
        frontend_facade_payload = FrontendFacadePayload.new(key)
        expected = frontend_facade_payload.payload
        response = frontend_facade.get_cities_of_a_given_country('au', 'en-gb')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result).to be_deep_equal(expected)
      end

      it "Check basic information is correct based on given country for zh-cn.", :tag => 'location_cities_au_cn' do |example|
        key = example.metadata[:tag]
        frontend_facade_payload = FrontendFacadePayload.new(key)
        expected = frontend_facade_payload.payload
        response = frontend_facade.get_cities_of_a_given_country('au', 'zh-cn')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result).to be_deep_equal(expected)
      end

      it "Check unpublished cities are not returned for de.", :tag => 'location_cities_de_en' do |example|
        key = example.metadata[:tag]
        frontend_facade_payload = FrontendFacadePayload.new(key)
        expected = frontend_facade_payload.payload
        response = frontend_facade.get_cities_of_a_given_country('de', 'en-gb')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result).to be_deep_equal(expected)
      end

      it "Check response can be sorted by name,original_name,slug,rank for en-gb", :tag => 'location_cities_au_en' do |example|
        key = example.metadata[:tag]
        ["name", "original_name", "slug", "rank"].each do |e|
          check_cities_sort key, e, 'en-gb'
        end
      end

      it "Check response can be sorted by name for zh-cn", :tag => 'location_cities_au_cn' do |example|
        key = example.metadata[:tag]
        check_cities_sort key, 'name', 'zh-cn'
      end
    end
  end
end
