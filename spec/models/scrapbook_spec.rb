require 'rails_helper'

describe Scrapbook do
  describe 'validation' do
    it 'must have a title' do
      expect(subject).to be_invalid
      expect(subject.errors[:title]).to include("can't be blank")
    end

    it 'must belong to a user' do
      expect(subject).to be_invalid
      expect(subject.errors[:user]).to include("can't be blank")
    end
  end

  describe 'searching' do
    before :each do
      @term_in_title            = Fabricate(:scrapbook, title: 'Edinburgh Castle test')
      @term_in_description      = Fabricate(:scrapbook, description: 'This is an Edinburgh Castle test')
      @terms_not_found          = Fabricate(:scrapbook, title: 'test', description: 'test')
    end

    let(:results) { Scrapbook.text_search(terms) }

    context 'when no terms are given' do
      let(:terms) { nil }

      it 'returns all records' do
        expect(results.count(:all)).to eql(3)
      end
    end

    context 'when blank terms are given' do
      let(:terms) { '' }

      it 'returns all records' do
        expect(results.count(:all)).to eql(3)
      end
    end

    context 'text fields' do
      let(:terms) { 'castle' }

      it 'returns all records matching the given query' do
        expect(results.count(:all)).to eql(2)
      end

      it "includes records where title matches" do
        expect(results).to include(@term_in_title)
      end

      it "includes records where description matches" do
        expect(results).to include(@term_in_description)
      end
    end
  end

  describe '#cover' do
    it 'provides a ScrapbookCover for the scrapbook' do
      allow(ScrapbookCover).to receive(:new)
      subject.cover
      expect(ScrapbookCover).to have_received(:new).with(subject)
    end
  end

  describe '#update' do
    let(:initial_params) {{ title: 'new title' }}
    let(:params)         { initial_params }

    subject { Fabricate(:scrapbook) }

    before :each do
      allow(ScrapbookMemory).to receive(:reorder_for_scrapbook)
      allow(ScrapbookMemory).to receive(:remove_from_scrapbook)
      subject.update(params)
    end

    describe "ordering" do
      context 'when there is no ordering' do
        it 'does not update the ordering' do
          expect(ScrapbookMemory).not_to have_received(:reorder_for_scrapbook)
        end
      end

      context 'when there is an empty ordering' do
        let(:params) { initial_params.merge({ordering: ''}) }

        it 'does not update the ordering' do
          expect(ScrapbookMemory).not_to have_received(:reorder_for_scrapbook)
        end
      end

      context 'when there is an ordering' do
        let(:params) { initial_params.merge({ordering: '1,2,3'}) }

        it 'updates the ordering' do
          expect(ScrapbookMemory).to have_received(:reorder_for_scrapbook).with(subject, %w(1 2 3))
        end
      end
    end

    describe "deleted" do
      context 'when there are no deleted' do
        it 'does not remove the deleted' do
          expect(ScrapbookMemory).not_to have_received(:remove_from_scrapbook)
        end
      end

      context 'when there is an empty deleted' do
        let(:params) { initial_params.merge({deleted: ''}) }

        it 'does not remove the deleted' do
          expect(ScrapbookMemory).not_to have_received(:remove_from_scrapbook)
        end
      end

      context 'when there is a deleted' do
        let(:params) { initial_params.merge({deleted: '4,5'}) }

        it 'removes the deleted' do
          expect(ScrapbookMemory).to have_received(:remove_from_scrapbook).with(subject, %w(4 5))
        end
      end
    end

    context "when there is ordering and deleted" do
      let(:params) { initial_params.merge({
        ordering: '1,2,3',
        deleted: '4,5'
      })}


      it 'passes the rest of the params upstream' do
        subject.update(params)
        expect(subject.title).to eql('new title')
      end

      it "is false if invalid" do
        params[:title] = nil
        expect(subject.update(params)).to be_falsy
      end

      it "is false if there are errors" do
        stub_errors = double(messages: ['test error'], clear: true, empty?: true)
        allow(subject).to receive(:errors).and_return(stub_errors)
        expect(subject.update(params)).to be_falsy
      end

      it "is true if valid and there are no errors" do
        expect(subject.update(params)).to be_truthy
      end
    end
  end

  describe '#ordered_memories' do
    subject { Fabricate(:scrapbook) }

    context 'when the scrapbook has no memories' do
      it 'provides and empty collection' do
        expect(subject.ordered_memories).to be_empty
      end
    end

    context 'when the scrapbook has one memory' do
      let!(:scrapbook_memory) { Fabricate(:scrapbook_memory, scrapbook: subject) }
      let(:memory)           { scrapbook_memory.memory }

      it 'provides a collection with just that memory' do
        expect(subject.ordered_memories.length).to eql(1)
        expect(subject.ordered_memories).to eql([memory])
      end
    end

    context 'when the scrapbook has more than one memory' do
      let!(:sm_1)    { Fabricate(:scrapbook_memory, scrapbook: subject) }
      let!(:sm_2)    { Fabricate(:scrapbook_memory, scrapbook: subject) }
      let!(:sm_3)    { Fabricate(:scrapbook_memory, scrapbook: subject) }
      let(:memory_1) { sm_1.memory }
      let(:memory_2) { sm_2.memory }
      let(:memory_3) { sm_3.memory }

      it 'provides a collection with all memories in order' do
        expect(subject.ordered_memories.length).to eql(3)
        expect(subject.ordered_memories).to eql([memory_1, memory_2, memory_3])
      end

      it 'provides a collection with all memories in order if the order is changed' do
        subject.update({ordering: "#{sm_2.id},#{sm_3.id},#{sm_1.id}"})
        expect(subject.ordered_memories.length).to eql(3)
        expect(subject.ordered_memories).to eql([memory_2, memory_3, memory_1])
      end
    end
  end

  describe '#approved_ordered_memories' do
    subject { Fabricate(:scrapbook) }

    context 'when the scrapbook has one memory' do
      let!(:scrapbook_memory) { Fabricate(:scrapbook_memory, scrapbook: subject, memory: memory) }

      context 'and it is not approved' do
        let(:memory) { Fabricate(:memory) }

        it 'provides a collection with just that memory' do
          expect(subject.approved_ordered_memories).to be_empty
        end
      end

      context 'and it is approved' do
        let(:memory) { Fabricate(:approved_memory) }

        it 'provides a collection with just that memory' do
          expect(subject.approved_ordered_memories.length).to eql(1)
          expect(subject.approved_ordered_memories).to eql([memory])
        end
      end
    end

    context 'when the scrapbook has more than one memory and not all are approved' do
      let(:memory_1) { Fabricate(:memory) }
      let(:memory_2) { Fabricate(:approved_memory) }
      let(:memory_3) { Fabricate(:approved_memory) }
      let!(:sm_1)    { Fabricate(:scrapbook_memory, scrapbook: subject, memory: memory_1) }
      let!(:sm_2)    { Fabricate(:scrapbook_memory, scrapbook: subject, memory: memory_2) }
      let!(:sm_3)    { Fabricate(:scrapbook_memory, scrapbook: subject, memory: memory_3) }

      it 'provides a collection with only approved memories in order' do
        expect(subject.approved_ordered_memories.length).to eql(2)
        expect(subject.approved_ordered_memories).to eql([memory_2, memory_3])
      end

      it 'provides a collection with only approved memories in order if the order is changed' do
        subject.update({ordering: "#{sm_3.id},#{sm_2.id},#{sm_1.id}"})
        expect(subject.approved_ordered_memories.length).to eql(2)
        expect(subject.approved_ordered_memories).to eql([memory_3, memory_2])
      end
    end
  end
end
