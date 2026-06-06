
Card creation

                 Web / Mobile Client
                         │
                    API Gateway
                         │
                   Create Card Lambda
                    /             \
                   /               \
                  ▼                 ▼
           Save to DynamoDB   Publish Event
                                      │
                                      ▼
                               EventBridge Bus
                                      │
          ┌───────────────┬───────────┴─────────────┐
          │               │                         │
          ▼               ▼                         ▼
   Review Lambda   Analytics Lambda      Notification Lambda
          │               │                         │
          ▼               ▼                         ▼
      DynamoDB      Analytics Table            SNS/Email


Card Review Process


User reviews card
        │
        ▼
Review API Lambda
        │
        ├── Update review record
        └── Publish ReviewSubmitted
                     │
                     ▼
               EventBridge Bus
                     │
        ┌────────────┼────────────┐
        │            │            │
        ▼            ▼            ▼
  Analytics    Notification    SQS Queue
    Lambda         Lambda           │
                                    ▼
                        Scheduling Lambda
                                    │
                                    ▼
                    Update next due date in DynamoDB


"We use DynamoDB because the system is driven by predictable, high-throughput key-based access patterns (user → deck → due cards), and we want low-latency reads/writes without relational overhead or connection scaling issues."