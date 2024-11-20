CREATE MIGRATION m1rjipzokgudzoqh24idnv2sm3ia5m574nkplabku6lyvvq3ljcwvq
    ONTO m1cp73jon7nhgeurjbn32zzn6d3cqvx7n7mnoznq3gfcg3voqvxrnq
{
  ALTER TYPE chat::Chat {
      DROP PROPERTY sharePath;
  };
  ALTER TYPE chat::Message {
      DROP PROPERTY functionCall;
      DROP PROPERTY name;
      DROP PROPERTY toolCallId;
      DROP PROPERTY toolCalls;
  };
};
