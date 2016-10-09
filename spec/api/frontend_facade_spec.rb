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
        response = frontend_facade.get_summary_for_a_property('student-village','en-gb')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result).to be_deep_equal(expected)
      end

      it "get summary for a property for zh-cn", :tag => 'te_puni_village_summary_cn' do |example|
        key = example.metadata[:tag]
        frontend_facade_payload = FrontendFacadePayload.new(key)
        expected = frontend_facade_payload.payload
        response = frontend_facade.get_summary_for_a_property('te-puni-village','zh-cn')
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
  end

  describe "Locations" do
    context "Get the list of areas of a given city." do
      def check_areas_sort key, sort, locale
        frontend_facade_payload = FrontendFacadePayload.new(key)
        expected = frontend_facade_payload.payload
        response = frontend_facade.get_areas_of_a_given_city('sydney', locale, sort)
        result = response.parsed_response
        expect(response.code).to be(200)
        if sort == 'rank'
          expected_array = expected['areas'].sort_by{|x| x[sort] * -1}
          size = expected_array.size
          for i in 0..size - 1
            expect(result['areas'][i]['rank']).to eq(expected_array[i]['rank'])
          end
        else
          expected_array = expected['areas'].sort_by{|x| x[sort]}
          expect(result['areas']).to eq(expected_array)
        end
      end

      it "Check basic info is correct base on given city for en-gb.", :tag => 'location_areas_sydney_en' do |example|
        key = example.metadata[:tag]
        frontend_facade_payload = FrontendFacadePayload.new(key)
        expected = frontend_facade_payload.payload
        response = frontend_facade.get_areas_of_a_given_city('sydney', 'en-gb')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result).to be_deep_equal(expected)
      end

      it "Check basic info is correct base on given city for zh-cn.", :tag => 'location_areas_sydney_cn' do |example|
        key = example.metadata[:tag]
        frontend_facade_payload = FrontendFacadePayload.new(key)
        expected = frontend_facade_payload.payload
        response = frontend_facade.get_areas_of_a_given_city('sydney', 'zh-cn')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result).to be_deep_equal(expected)
      end

      it "Check unpublished areas are not returned.", :tag => 'location_areas_london_en' do |example|
        key = example.metadata[:tag]
        frontend_facade_payload = FrontendFacadePayload.new(key)
        expected = frontend_facade_payload.payload
        response = frontend_facade.get_areas_of_a_given_city('london', 'en-gb')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result).to be_deep_equal(expected)
      end

      it "Check areas for non-area city" do
        expected = {"areas" => []}
        response = frontend_facade.get_areas_of_a_given_city('wellington-changed', 'en-gb')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result).to eq(expected)
      end

      it "Check response can be sorted by name,original_name,slug,rank for en-gb", :tag => 'location_areas_sydney_en' do |example|
        key = example.metadata[:tag]
        ["name", "original_name", "slug", "rank"].each do |e|
          check_areas_sort key, e, 'en-gb'
        end
      end

      it "Check response can be sorted by name for zh-cn", :tag => 'location_areas_sydney_cn' do |example|
        key = example.metadata[:tag]
        check_areas_sort key, 'name', 'zh-cn'
      end
    end
  end
end
