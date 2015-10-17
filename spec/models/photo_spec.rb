require 'rails_helper'

describe Photo do
  let(:file_path) { File.join(Rails.root, 'spec', 'fixtures', 'files') }
  let(:file_name) { 'test.jpg' }
  let(:test_user) { Fabricate.build(:user) }
  let(:source)    { Rack::Test::UploadedFile.new(File.join(file_path, file_name)) }
  let!(:area)     { Fabricate(:area) }
  let(:memory)    { Fabricate.build(:photo_memory, user: test_user, source: source, area: area) }

  it_behaves_like "a memory"
  it_behaves_like "locatable"

  describe 'validation' do
    describe "source" do
      it "can't be blank" do
        memory.source.remove!
        expect(memory).to be_invalid
        expect(memory.errors[:source]).to include("You need to choose a file to upload")
      end

      describe 'must have an allowed file extension' do
        context "file is a .jpg" do
          let(:file_name) { 'test.jpg' }

          it "is valid" do
            expect(memory).to be_valid
          end
        end

        context "file is a .jpeg" do
          let(:file_name) { 'test.jpeg' }

          it "is valid" do
            expect(memory).to be_valid
          end
        end

        context "file is a .png" do
          let(:file_name) { 'test.png' }

          it "is valid" do
            expect(memory).to be_valid
          end
        end

        context "file is a .gif" do
          let(:file_name) { 'test.gif' }

          it "is valid" do
            expect(memory).to be_valid
          end
        end

        context "file is a .txt" do
          let(:file_name) { 'test.txt' }

          it "is invalid" do
            expect(memory).to be_invalid
            expect(memory.errors[:source]).to include("You are not allowed to upload \"txt\" files, allowed types: JPG, JPEG, GIF, PNG, jpg, jpeg, gif, png")
          end
        end
      end

      describe "file size" do
        context "when under max size" do
          let(:file_name) { 'under.jpg' }

          it "is valid" do
            expect(memory).to be_valid
          end
        end

        context "when equal to max size" do
          let(:file_name) { 'equal.jpg' }

          it "is valid" do
            expect(memory).to be_valid
          end
        end

        context "when over max size" do
          let(:file_name) { 'over.jpg' }

          it "is invalid" do
            expect(memory).to be_invalid
            expect(memory.errors[:source]).to include("file size must be less than or equal to 4 MB")
          end
        end
      end
    end


  end

  describe 'updating' do
    let(:now) { Time.now }
    let(:old) { 2.days.ago }

    before :each do
      allow(memory.source).to receive(:recreate_versions!)
      memory.updated_at = old
      memory.save!
    end

    context 'when photo has been rotated' do
      before :each do
        Timecop.freeze(now) do
          memory.update(rotation: '90')
        end
      end

      it 'recreates the photo versions' do
        expect(memory.source).to have_received(:recreate_versions!)
      end

      it 'changes updated at' do
        expect(memory.updated_at).to eql(now)
      end
    end

    context 'when image has not been rotated' do
      context 'when rotation is nil' do
        before :each do
          Timecop.freeze(now) do
            memory.update(rotation: nil)
          end
        end

        it 'does not change updated at' do
          expect(memory.updated_at).to eql(old)
        end

        it 'does not recreate the photo versions' do
          expect(memory.source).not_to have_received(:recreate_versions!)
        end
      end

      context 'when rotation is 0' do
        before :each do
          Timecop.freeze(now) do
            memory.update(rotation: '0')
          end
        end

        it 'does not change updated at' do
          expect(memory.updated_at).to eql(old)
        end

        it 'does not recreate the photo versions' do
          expect(memory.source).not_to have_received(:recreate_versions!)
        end
      end
    end
  end

  describe "rotation" do
    describe "when setting" do
      it "provides an integer when given a string" do
        subject.rotation = "90"
        expect(subject.rotation).to eql(90)
      end

      it "provides an integer when given an integer" do
        subject.rotation = 90
        expect(subject.rotation).to eql(90)
      end

      it "provides an integer when given a float" do
        subject.rotation = "90.2"
        expect(subject.rotation).to eql(90)
      end

      it "provides 0 when given nil" do
        subject.rotation = nil
        expect(subject.rotation).to eql(0)
      end

      it "provides nil when not set" do
        expect(subject.rotation).to be_nil
      end
    end

    describe "when checking" do
      it "is false when image has no rotation" do
        memory.rotation = nil
        expect(memory.rotated?).to be_falsy
      end

      it "is false when image has rotation of 0" do
        memory.rotation = "0"
        expect(memory.rotated?).to be_falsy
      end

      it "is true when image is rotated by > 0" do
        memory.rotation = "90"
        expect(memory.rotated?).to be_truthy
      end

      it "is true when image is rotated by < 0" do
        memory.rotation = "-90"
        expect(memory.rotated?).to be_truthy
      end
    end
  end
end
