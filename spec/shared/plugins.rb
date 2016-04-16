RSpec.shared_context 'plugins' do
  ROM.plugins do
    adapter :sql do
      upcase_name = Module.new do
        def execute(tuples)
          upcased = Array([tuples]).flatten.map do |t|
            h = t.to_h
            h.merge(name: h.fetch(:name).upcase)
          end

          if one?
            super(upcased.first)
          else
            super(upcased)
          end
        end
      end

      register :upcase_name, upcase_name, type: :command
    end
  end
end
