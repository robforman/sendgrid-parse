# encoding: UTF-8
require 'sendgrid-parse'
require 'active_support/hash_with_indifferent_access'

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

  it "should skip unknown 'charsets' encoding types" do
    params = {
      :charsets => '{"text":"x-user-defined"}',
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

  it "should symbolize active_support hashes correctly" do
    params = {
      'charsets' => '{"text":"WINDOWS-1252"}',
      'text' => test_string_1_windows1252_encoded
    }

    hash = HashWithIndifferentAccess.new(params)

    new_params = Sendgrid::Parse::EncodableHash.new(hash).encode("UTF-8")
    new_params.has_key?(:text).should eql(true)
    new_params[:charsets].should eql "{\"text\":\"UTF-8\"}"

  end

  if RUBY_VERSION >= '1.9'
    it "should blow up on unknown target encoding type" do
      params = {
        :charsets => '{"text":"UTF-8"}',
        :text => test_string_1
      }

      expect { new_params = Sendgrid::Parse::EncodableHash.new(params).encode("UTF-88") }.to raise_error(Encoding::ConverterNotFoundError)
    end

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
  else
    it "should blow up on unknown target encoding type" do
      params = {
        :charsets => '{"text":"UTF-8"}',
        :text => test_string_1
      }

      expect { new_params = Sendgrid::Parse::EncodableHash.new(params).encode("UTF-88") }.to raise_error(Iconv::InvalidEncoding)
    end
  end
end