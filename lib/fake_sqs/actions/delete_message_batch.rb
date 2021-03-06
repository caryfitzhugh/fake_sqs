module FakeSQS
  module Actions
    class DeleteMessageBatch

      def initialize(request, options = {})
        @request   = request
        @queues    = options.fetch(:queues)
        @responder = options.fetch(:responder)
      end

      def call(params)
        name = params['queue']

        queue = @queues.get(name)
        receipts = params.select { |k,v| k =~ /DeleteMessageBatchRequestEntry\.\d+\.ReceiptHandle/ }

        deleted = []

        receipts.each do |key, value|
          id = key.split('.')[1]
          queue.delete_message(value)
          deleted << params.fetch("DeleteMessageBatchRequestEntry.#{id}.Id")
        end

        @responder.call :DeleteMessageBatch do |xml|
          deleted.each do |id|
            xml.DeleteMessageBatchResultEntry do
              xml.Id id
            end
          end
        end
      end
    end
  end
end
