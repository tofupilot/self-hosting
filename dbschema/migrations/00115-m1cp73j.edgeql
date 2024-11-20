CREATE MIGRATION m1cp73jon7nhgeurjbn32zzn6d3cqvx7n7mnoznq3gfcg3voqvxrnq
    ONTO m1756junvktnrldjgnepvxm3ic5ncry66sxb2sfi3wd7g7m2tm5pkq
{
  CREATE MODULE chat IF NOT EXISTS;
  CREATE TYPE chat::Chat EXTENDING default::PrimitiveProperty {
      CREATE ACCESS POLICY IAllowOnlyUserToAccessItsChats
          DENY ALL USING (NOT ((GLOBAL default::currentUserId ?= .createdBy.id)));
      CREATE REQUIRED PROPERTY chatId: std::str {
          CREATE CONSTRAINT std::exclusive;
      };
      CREATE REQUIRED PROPERTY path: std::str;
      CREATE PROPERTY sharePath: std::str;
      CREATE REQUIRED PROPERTY title: std::str;
  };
  CREATE TYPE chat::Message EXTENDING default::PrimitiveProperty {
      CREATE REQUIRED LINK chat: chat::Chat {
          ON SOURCE DELETE ALLOW;
          ON TARGET DELETE DELETE SOURCE;
      };
      CREATE ACCESS POLICY IAllowOnlyUserToAccessItsMessages
          DENY ALL USING (NOT ((GLOBAL default::currentUserId ?= .chat.createdBy.id)));
      CREATE REQUIRED PROPERTY content: std::str;
      CREATE PROPERTY functionCall: std::str;
      CREATE REQUIRED PROPERTY messageId: std::str {
          CREATE CONSTRAINT std::exclusive;
      };
      CREATE PROPERTY name: std::str;
      CREATE REQUIRED PROPERTY role: std::str;
      CREATE PROPERTY toolCallId: std::str;
      CREATE PROPERTY toolCalls: std::str;
  };
  ALTER TYPE chat::Chat {
      CREATE MULTI LINK messages := (.<chat[IS chat::Message]);
  };
};
