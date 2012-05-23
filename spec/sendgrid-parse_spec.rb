# encoding: UTF-8
require 'sendgrid-parse'

describe Sendgrid::Parse::EncodableHash do
  test_string_1 = "Hello €"
  test_string_1_windows1252_encoded = "Hello \x80"
  test_string_1_utf8_encoded = "Hello \xE2\x82\xAC"

  it "windows-1252 should encode to utf-8" do
    params = {
      :charsets => '{"text":"WINDOWS-1252"}',
      :text => test_string_1_windows1252_encoded
    }

    new_params = Sendgrid::Parse::EncodableHash.new(params).encode("UTF-8")
    new_params[:text].should eql(test_string_1)
  end

  it "utf-8 should encode to utf-8" do
    params = {
      :charsets => '{"text":"UTF-8"}',
      :text => test_string_1_utf8_encoded
    }

    new_params = Sendgrid::Parse::EncodableHash.new(params).encode("UTF-8")
    new_params[:text].should eql(test_string_1)
  end

  it "should not change same encoding strings" do
    params = {
      :charsets => '{"text":"UTF-8"}',
      :text => test_string_1
    }

    new_params = Sendgrid::Parse::EncodableHash.new(params).encode("UTF-8")
    new_params[:text].should eql(test_string_1)
  end

  it "should strip unconvertible characters" do
    params = {
      :charsets => '{"text":"UTF-8"}',
      :text => "Résumé"
    }

    new_params = Sendgrid::Parse::EncodableHash.new(params).encode("ASCII")
    new_params[:text].should_not eql("Résumé")
    new_params[:text].should eql("Rsum")
  end

  its "encode should be non-destructive" do
    params = {
      :charsets => '{"text":"UTF-8"}',
      :text => "Résumé"
    }

    new_params = Sendgrid::Parse::EncodableHash.new(params).encode("ASCII")
    new_params[:text].should eql("Rsum")

    params[:text].should eql("Résumé")
  end

  its "encode! should be destructive" do
    params = {
      :charsets => '{"text":"UTF-8"}',
      :text => "Résumé"
    }

    new_params = Sendgrid::Parse::EncodableHash.new(params)
    new_params.encode!("ASCII")
    new_params[:text].should eql("Rsum")
  end

  it "should re-write the charsets json envelope upon encoding" do
    params = {
      :charsets => '{"text":"WINDOWS-1252"}',
      :text => test_string_1_windows1252_encoded
    }

    new_params = Sendgrid::Parse::EncodableHash.new(params).encode("UTF-8")
    new_params[:text].should eql(test_string_1)
    new_params[:charsets].should eql "{\"text\":\"UTF-8\"}"
  end

  it "should symbolize on initialize" do
    params = {
      'charsets' => '{"text":"WINDOWS-1252"}',
      'text' => test_string_1_windows1252_encoded
    }

    new_params = Sendgrid::Parse::EncodableHash.new(params).encode("UTF-8")
    new_params.has_key?(:text).should eql(true)
  end

  if RUBY_VERSION >= '1.9'
    it "should correctly change encoding types of charsets" do
      params = {
        :charsets => '{"text":"WINDOWS-1252"}',
        :text => test_string_1_windows1252_encoded
      }

      new_params = Sendgrid::Parse::EncodableHash.new(params).encode("WINDOWS-1252")
      new_params[:text].encoding.should eql(Encoding::Windows_1252)

      new_params = Sendgrid::Parse::EncodableHash.new(params).encode("UTF-8")
      new_params[:text].encoding.should eql(Encoding::UTF_8)
    end

    it "should correctly force encoding types of non-specified fields" do
      params = {
        :charsets => '{"text":"WINDOWS-1252"}',
        :text => test_string_1_windows1252_encoded,
        :subject => "Test subject"
      }

      new_params = Sendgrid::Parse::EncodableHash.new(params).encode("WINDOWS-1252")
      new_params[:text].encoding.should eql(Encoding::Windows_1252)
      new_params[:subject].encoding.should eql(Encoding::Windows_1252)

      new_params = Sendgrid::Parse::EncodableHash.new(params).encode("UTF-8")
      new_params[:text].encoding.should eql(Encoding::UTF_8)
      new_params[:subject].encoding.should eql(Encoding::UTF_8)
    end
  end
end